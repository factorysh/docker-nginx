
include Makefile.lint
include Makefile.build_args

GOSS_VERSION := 0.3.5

all: pull build

pull:
	docker pull bearstech/debian:stretch
	docker pull bearstech/debian:buster
	docker pull bearstech/debian:bullseye

build: build-stretch build-buster build-bullseye

build-stretch:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=stretch \
		-t bearstech/nginx:1.10 \
		.
	# debian tag is only locals, to ease tests
	docker tag bearstech/nginx:1.10 bearstech/nginx:stretch

build-buster:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=buster \
		-t bearstech/nginx:1.14 \
		.
	# debian tag is only locals, to ease tests
	docker tag bearstech/nginx:1.14 bearstech/nginx:buster

build-bullseye:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=bullseye \
		-t bearstech/nginx:1.18 \
		.
	# debian tag is only locals, to ease tests
	docker tag bearstech/nginx:1.18 bearstech/nginx:bullseye
	docker tag bearstech/nginx:1.18 bearstech/nginx:latest

push:
	docker push bearstech/nginx:1.10
	docker push bearstech/nginx:1.14
	docker push bearstech/nginx:1.18
	docker push bearstech/nginx:latest

remove_image:
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/nginx")

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

tests_nginx/data:
	mkdir -p tests_nginx/data

test: bin/goss test-stretch test-buster test-bullseye

test-stretch:
	docker-compose -f tests_nginx/docker-compose.yml down || true
	rm -Rf tests_nginx/data && mkdir tests_nginx/data
	docker run --rm -v `pwd`/tests_nginx/data:/test/data bearstech/debian:buster bash -c 'mkdir -p /test/data/log && chmod -R 777 /test/data'
	rm -f tests_nginx/data/log/* tests_nginx/traefik_hosts
	touch tests_nginx/traefik_hosts
	DEBIAN_VERSION=stretch \
		docker-compose -f tests_nginx/docker-compose.yml up -d
	DEBIAN_VERSION=stretch \
		docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
			wait_for_services -vd 2 --timeout 120
	DEBIAN_VERSION=stretch \
		docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
			traefik_hosts > tests_nginx/traefik_hosts
	DEBIAN_VERSION=stretch \
		docker-compose -f tests_nginx/docker-compose.yml exec -T client \
			goss -g nginx.yaml validate --max-concurrent 4 --format documentation

test-buster:
	docker-compose -f tests_nginx/docker-compose.yml down || true
	rm -Rf tests_nginx/data && mkdir tests_nginx/data
	docker run --rm -v `pwd`/tests_nginx/data:/test/data bearstech/debian:buster bash -c 'mkdir -p /test/data/log && chmod -R 777 /test/data'
	rm -f tests_nginx/data/log/* tests_nginx/traefik_hosts
	touch tests_nginx/traefik_hosts
	DEBIAN_VERSION=buster \
		docker-compose -f tests_nginx/docker-compose.yml up -d
	DEBIAN_VERSION=buster \
		docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
			wait_for_services -vd 2 --timeout 120
	DEBIAN_VERSION=buster \
		docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
			traefik_hosts > tests_nginx/traefik_hosts
	DEBIAN_VERSION=buster \
		docker-compose -f tests_nginx/docker-compose.yml exec -T client \
			goss -g nginx.yaml validate --max-concurrent 4 --format documentation

test-bullseye:
	docker-compose -f tests_nginx/docker-compose.yml down || true
	rm -Rf tests_nginx/data && mkdir tests_nginx/data
	docker run --rm -v `pwd`/tests_nginx/data:/test/data bearstech/debian:bullseye bash -c 'mkdir -p /test/data/log && chmod -R 777 /test/data'
	rm -f tests_nginx/data/log/* tests_nginx/traefik_hosts
	touch tests_nginx/traefik_hosts
	DEBIAN_VERSION=bullseye \
		docker-compose -f tests_nginx/docker-compose.yml up -d
	DEBIAN_VERSION=bullseye \
		docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
			wait_for_services -vd 2 --timeout 120
	DEBIAN_VERSION=bullseye \
		docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
			traefik_hosts > tests_nginx/traefik_hosts
	DEBIAN_VERSION=bullseye \
		docker-compose -f tests_nginx/docker-compose.yml exec -T client \
			goss -g nginx.yaml validate --max-concurrent 4 --format documentation

down:
	docker-compose -f tests_nginx/docker-compose.yml down || true
	rm -Rf tests_nginx/data

tests: test down
