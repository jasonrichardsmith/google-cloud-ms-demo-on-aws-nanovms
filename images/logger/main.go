package main

import (
	"crypto/tls"
	"crypto/x509"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"sort"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/ec2metadata"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
	"github.com/aws/aws-sdk-go/service/ec2"
	uuid "github.com/satori/go.uuid"
	"gopkg.in/mcuadros/go-syslog.v2"
	"gopkg.in/mcuadros/go-syslog.v2/format"
)

var port = os.Getenv("PORT")
var logGroupName = os.Getenv("LOG_GROUP_NAME")
var streamName = uuid.NewV4()
var sequenceToken = ""

var (
	client *http.Client
	pool   *x509.CertPool
)

func init() {
	pool = x509.NewCertPool()
	pool.AppendCertsFromPEM(pemCerts)
}

func main() {
	if logGroupName == "" {
		var err error
		logGroupName, err = getLogGroup()
		if err != nil {
			log.Fatal("LOG_GROUP_NAME must be specified")
		}
	}

	if port == "" {
		port = "514"
	}

	address := fmt.Sprintf("0.0.0.0:%v", port)
	log.Println("Starting syslog server on", address)
	log.Println("Logging to group:", logGroupName)
	initCloudWatchStream()

	channel := make(syslog.LogPartsChannel, 100)
	handler := syslog.NewChannelHandler(channel)

	server := syslog.NewServer()
	server.SetFormat(syslog.Automatic)
	server.SetHandler(handler)
	server.ListenUDP(address)
	server.ListenTCP(address)

	server.Boot()

	go func(channel syslog.LogPartsChannel) {
		ticker := time.NewTicker(200 * time.Millisecond)
		defer ticker.Stop() // release when done, if we ever will

		loglist := make([]format.LogParts, 0)
		for {
			select {
			case <-ticker.C:
				if len(loglist) <= 0 {
					continue
				}
				sendToCloudWatch(loglist)
				loglist = make([]format.LogParts, 0)
			case logParts := <-channel:
				loglist = append(loglist, logParts)
			}
		}
	}(channel)

	server.Wait()
}

func getLogGroup() (string, error) {

	ec2meta := ec2metadata.New(session.New())
	identity, err := ec2meta.GetInstanceIdentityDocument()
	if err != nil {
		return "", fmt.Errorf("GetInstanceIdentityDocument failed: %s", err)
	}
	fmt.Printf("Received %s in region %s", identity.InstanceID, identity.Region)
	svc := ec2.New(session.New(), &aws.Config{
		Region: &identity.Region,
	})

	var resp *ec2.DescribeInstancesOutput
	resp, err = svc.DescribeInstances(&ec2.DescribeInstancesInput{
		InstanceIds: []*string{&identity.InstanceID},
	})
	if err != nil {
		return "", fmt.Errorf("GetInstance failed: %s", err)
	}

	for _, r := range resp.Reservations {
		for _, inst := range r.Instances {
			for _, tag := range inst.Tags {
				if *tag.Key == "loggroup" {
					return *tag.Value, nil
				}
			}

		}
	}
	return "", errors.New("No LogGroupName found")

}

func sendToCloudWatch(buffer []format.LogParts) {
	// service is defined at run time to avoid session expiry in long running processes
	var svc = cloudwatchlogs.New(session.New())
	// set the AWS SDK to use our bundled certs for the minimal container (certs from CoreOS linux)
	svc.Config.HTTPClient = &http.Client{Transport: &http.Transport{TLSClientConfig: &tls.Config{RootCAs: pool}}}

	params := &cloudwatchlogs.PutLogEventsInput{
		LogGroupName:  aws.String(logGroupName),
		LogStreamName: aws.String(streamName.String()),
	}

	sort.Slice(buffer, func(i, j int) bool {
		return buffer[i]["timestamp"].(time.Time).Before(buffer[j]["timestamp"].(time.Time))
	})

	for _, logPart := range buffer {
		params.LogEvents = append(params.LogEvents, &cloudwatchlogs.InputLogEvent{
			Message:   aws.String(logPart["content"].(string)),
			Timestamp: aws.Int64(makeMilliTimestamp(logPart["timestamp"].(time.Time))),
		})
	}

	// first request has no SequenceToken - in all subsequent request we set it
	if sequenceToken != "" {
		params.SequenceToken = aws.String(sequenceToken)
	}

	resp, err := svc.PutLogEvents(params)
	if err != nil {
		log.Println(err)
	}
	log.Printf("Pushed %v entries to CloudWatch", len(buffer))

	sequenceToken = *resp.NextSequenceToken
}

func initCloudWatchStream() {
	// service is defined at run time to avoid session expiry in long running processes
	var svc = cloudwatchlogs.New(session.New())
	// set the AWS SDK to use our bundled certs for the minimal container (certs from CoreOS linux)
	svc.Config.HTTPClient = &http.Client{Transport: &http.Transport{TLSClientConfig: &tls.Config{RootCAs: pool}}}

	_, err := svc.CreateLogStream(&cloudwatchlogs.CreateLogStreamInput{
		LogGroupName:  aws.String(logGroupName),
		LogStreamName: aws.String(streamName.String()),
	})

	if err != nil {
		log.Fatal(err)
	}

	log.Println("Created CloudWatch Logs stream:", streamName)
}

func makeMilliTimestamp(input time.Time) int64 {
	return input.UnixNano() / int64(time.Millisecond)
}
