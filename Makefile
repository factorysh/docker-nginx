
include Makefile.lint
include Makefile.build_args

GOSS_VERSION := 0.3.5

all: pull build

pull:
	docker pull bearstech/debian:stretch
	docker pull bearstech/debian:buster

build: build-stretch build-buster

build-stretch:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=stretch \
		-t bearstech/nginx:1.10 \
		.
	docker tag bearstech/nginx:1.10 bearstech/nginx:latest
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

push:
	docker push bearstech/nginx:1.10
	docker push bearstech/nginx:1.14
	docker push bearstech/nginx:latest

remove_image:
	docker rmi bearstech/nginx:1.10
	docker rmi bearstech/nginx:1.14
	docker rmi bearstech/nginx:latest

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

tests_nginx/data:
	mkdir -p tests_nginx/data

test: bin/goss test-stretch test-buster

test-stretch: down tests_nginx/data
	docker run --rm -v `pwd`/tests_nginx/data:/test/data bearstech/debian bash -c 'mkdir -p /test/data/log && chmod -R 777 /test/data'
	rm -f tests_nginx/data/log/* tests_nginx/traefik_hosts
	touch tests_nginx/traefik_hosts
	DEBIAN_VERSION=stretch \
		docker-compose -f tests_nginx/docker-compose.yml up -d traefik
	DEBIAN_VERSION=stretch \
		docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
			wait_for_services -vd 2 --timeout 120
	DEBIAN_VERSION=stretch \
		docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
			traefik_hosts > tests_nginx/traefik_hosts
	DEBIAN_VERSION=stretch \
		docker-compose -f tests_nginx/docker-compose.yml run -T client \
			goss -g nginx.yaml validate --max-concurrent 4 --format documentation

test-buster: down tests_nginx/data
	docker run --rm -v `pwd`/tests_nginx/data:/test/data bearstech/debian bash -c 'mkdir -p /test/data/log && chmod -R 777 /test/data'
	rm -f tests_nginx/data/log/* tests_nginx/traefik_hosts
	touch tests_nginx/traefik_hosts
	DEBIAN_VERSION=buster \
		docker-compose -f tests_nginx/docker-compose.yml up -d traefik
	DEBIAN_VERSION=buster \
		docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
			wait_for_services -vd 2 --timeout 120
	DEBIAN_VERSION=buster \
		docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
			traefik_hosts > tests_nginx/traefik_hosts
	DEBIAN_VERSION=buster \
		docker-compose -f tests_nginx/docker-compose.yml run -T client \
			goss -g nginx.yaml validate --max-concurrent 4 --format documentation

down:
	docker-compose -f tests_nginx/docker-compose.yml down || true
	rm -Rf tests_nginx/data

tests: test down
