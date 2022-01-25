package main

import (
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/service/ssm"
	consul "github.com/hashicorp/consul/api"
)

func main() {
	region := os.Getenv("AWS_DEFAULT_REGION")
	for {
		serverip, err := getAServer(region)
		if err != nil {
			fmt.Println(err)
		}
		serverip = serverip + ":8500"
		fmt.Printf("Received server private ip %s", serverip)
		services, err := getServices(region)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(services)
		err = registerServices(serverip, services)
		if err != nil {
			fmt.Println(err)
		}
		time.Sleep(10 * time.Second)
	}
}

func getAServer(region string) (string, error) {
	svc := ec2.New(session.New(), &aws.Config{
		Region: &region,
	})
	resp, err := svc.DescribeInstances(&ec2.DescribeInstancesInput{
		Filters: []*ec2.Filter{
			&ec2.Filter{
				Name:   aws.String("tag:consulcloud"),
				Values: []*string{aws.String("consulserver")},
			},
			&ec2.Filter{
				Name:   aws.String("instance-state-name"),
				Values: []*string{aws.String("running")},
			},
		},
	})

	if err != nil {
		return "", fmt.Errorf("discover-aws: DescribeInstances failed: %s", err)
	}

	for _, r := range resp.Reservations {
		for _, inst := range r.Instances {
			if inst.PrivateIpAddress == nil {
				fmt.Printf("[DEBUG] discover-aws: Instance %s has no private ip", inst.InstanceId)
				continue
			} else {
				return *inst.PrivateIpAddress, nil
			}
		}
	}
	return "", errors.New("discover-aws: no instances with privateips found")

}

func getServices(region string) ([]consul.AgentServiceRegistration, error) {
	services := []consul.AgentServiceRegistration{}
	svc := ec2.New(session.New(), &aws.Config{
		Region: &region,
	})
	resp, err := svc.DescribeInstances(&ec2.DescribeInstancesInput{
		Filters: []*ec2.Filter{
			&ec2.Filter{
				Name:   aws.String("tag:consulcloud"),
				Values: []*string{aws.String("service")},
			},
			&ec2.Filter{
				Name:   aws.String("instance-state-name"),
				Values: []*string{aws.String("running")},
			},
		},
	})

	if err != nil {
		return nil, fmt.Errorf("discover-aws: DescribeInstances failed: %s", err)
	}

	for _, r := range resp.Reservations {
		for _, inst := range r.Instances {
			if inst.PrivateIpAddress == nil {
				fmt.Printf("[DEBUG] discover-aws: Instance %s has no private ip", *inst.InstanceId)
			} else {
				var serviceconfig string
				for _, tag := range inst.Tags {
					if *tag.Key == "consulserviceconfig" {
						serviceconfig = *tag.Value
					}
				}
				if serviceconfig == "" {
					fmt.Printf("[DEBUG] discover-aws: Instance %s has no serviceconfig", *inst.InstanceId)
				} else {
					fmt.Sprintf("Retrieving Service Config %s", serviceconfig)
					service, err := getConfiguration(serviceconfig, region)
					if err != nil {
						fmt.Errorf("Unable to get Parameter: %s", err)
					}
					service.ID = *inst.InstanceId
					service.Address = *inst.PrivateIpAddress
					if service.Check != nil {
						service.Check.GRPC = strings.Replace(service.Check.GRPC, "HEALTHROUTE", *inst.PrivateIpAddress, -1)
					}
					fmt.Println(service)
					services = append(services, service)
				}

			}
		}
	}
	return services, nil
}

func getConfiguration(name string, region string) (consul.AgentServiceRegistration, error) {
	service := consul.AgentServiceRegistration{}
	svc := ssm.New(session.New(), &aws.Config{
		Region: &region,
	})
	resp, err := svc.GetParameter(&ssm.GetParameterInput{Name: &name})
	if err != nil {
		return service, err
	}
	var doc []byte
	doc, err = base64.StdEncoding.DecodeString(*resp.Parameter.Value)

	if err != nil {
		return service, err
	}
	err = json.Unmarshal(doc, &service)
	fmt.Println(err)
	fmt.Println(service.Weights)
	return service, err

}

func registerServices(serveraddress string, services []consul.AgentServiceRegistration) error {
	config := consul.DefaultConfig()
	config.Address = serveraddress
	c, err := consul.NewClient(config)
	if err != nil {
		return err
	}
	agent := c.Agent()

	for _, service := range services {
		if err := agent.ServiceRegister(&service); err != nil {
			return err
		}
	}
	return nil
}
