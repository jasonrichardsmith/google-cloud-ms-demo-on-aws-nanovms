.DEFAULT_GOAL=help

.PHONY: help
help:
	@echo 'Usage: make ENVIRONMENT=[dev|test|...] <target>'
	@echo 'targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: buildadservice
buildadservice:  ## builds adservice
	./scripts/dockerbuild.sh adservice

.PHONY: buildasgtoconsul
buildasgtoconsul:  ## builds adservice
	./scripts/dockerbuild.sh asgtoconsul

.PHONY: buildcartservice
buildcartservice:  ## builds cartservice
	./scripts/dockerbuild.sh cartservice

.PHONY: buildcheckoutservice
buildcheckoutservice:  ## builds checkoutservice
	./scripts/dockerbuild.sh checkoutservice

.PHONY: buildconsul
buildconsul:  ## builds consul
	./scripts/dockerbuild.sh consul

.PHONY: buildcurrencyservice
buildcurrencyservice:  ## builds currencyservice
	./scripts/dockerbuild.sh currencyservice

.PHONY: buildemailservice
buildemailservice:  ## builds emailservice
	./scripts/dockerbuild.sh emailservice

.PHONY: buildfluentbit
buildfluentbit:  ## builds fluentbit
	./scripts/dockerbuild.sh fluentbit

.PHONY: buildfrontend
buildfrontend:  ## builds frontend
	./scripts/dockerbuild.sh frontend

.PHONY: buildpaymentservice
buildpaymentservice:  ## builds paymentservice
	./scripts/dockerbuild.sh paymentservice

.PHONY: buildproductcatalogservice
buildproductcatalogservice:  ## builds productcatalogservice
	./scripts/dockerbuild.sh productcatalogservice

.PHONY: buildrecommendationservice
buildrecommendationservice:  ## builds recommendationservice
	./scripts/dockerbuild.sh recommendationservice

.PHONY: buildshippingservice
buildshippingservice:  ## builds shippingservice
	./scripts/dockerbuild.sh shippingservice

.PHONY: buildall
buildall: buildadservice buildasgtoconsul buildcartservice buildcheckoutservice buildconsul 
buildall: buildcurrencyservice buildemailservice buildfrontend buildpaymentservice buildproductcatalogservice
buildall: buildrecommendationservice buildshippingservice buildfluentbit

.PHONY: cleanamis
cleanamis:
	./scripts/deleteamis.sh

.PHONY: deploy
deploy:
	./scripts/deploy.sh
	./scripts/deployoutput.sh

.PHONY: destroy
destroy:
	./scripts/destroy.sh


