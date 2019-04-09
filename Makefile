GOSS_VERSION := 0.3.5
GIT_VERSION := $(shell git rev-parse HEAD)

all: pull build

pull:
	docker pull bearstech/debian:stretch

build:
	docker build \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		-t bearstech/nginx:1.10 \
		.
	docker tag bearstech/nginx:1.10 bearstech/nginx:latest

push:
	docker push bearstech/nginx:1.10
	docker push bearstech/nginx:latest

remove_image:
	docker rmi bearstech/nginx:1.10
	docker rmi bearstech/nginx:latest

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

tests_nginx/data:
	mkdir -p tests_nginx/data

test: bin/goss tests_nginx/data
	docker-compose -f tests_nginx/docker-compose.yml down || true
	docker run --rm -v `pwd`/tests_nginx/data:/test/data bearstech/debian bash -c 'mkdir -p /test/data/log && chmod -R 777 /test/data'
	rm -f tests_nginx/data/log/*
	docker-compose -f tests_nginx/docker-compose.yml up -d traefik
	sleep 1
	docker-compose -f tests_nginx/docker-compose.yml run -T client \
		goss -g nginx.yaml validate --max-concurrent 4 --format documentation

down:
	docker-compose -f tests_nginx/docker-compose.yml down || true

tests: test down
