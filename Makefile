GOSS_VERSION := 0.3.5

all: pull build

pull:
	docker pull bearstech/debian:stretch
	docker pull bearstech/debian:jessie

build: jessie stretch

jessie:
	docker build -t bearstech/nginx:1.6 -f Dockerfile.$@ .

stretch:
	docker build -t bearstech/nginx:1.10 -f Dockerfile.$@ .
	docker tag bearstech/nginx:1.10 bearstech/nginx:latest

push:
	docker push bearstech/nginx:1.6
	docker push bearstech/nginx:1.10
	docker push bearstech/nginx:latest

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

test: bin/goss
	docker-compose -f tests/docker-compose.yml down || true
	docker-compose -f tests/docker-compose.yml up -d
	docker-compose -f tests/docker-compose.yml exec goss \
		goss -g nginx.yaml validate --max-concurrent 4 --format documentation
	docker-compose -f tests/docker-compose.yml down || true

tests: test