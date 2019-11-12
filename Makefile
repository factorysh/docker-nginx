
include Makefile.lint
include Makefile.build_args

GOSS_VERSION := 0.3.5

all: pull build

pull:
	docker pull bearstech/debian:stretch

build:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
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
	rm -f tests_nginx/data/log/* tests_nginx/traefik_hosts
	touch tests_nginx/traefik_hosts
	docker-compose -f tests_nginx/docker-compose.yml up -d traefik
	docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
		wait_for_services -vd 2 --timeout 120
	docker-compose -f tests_nginx/docker-compose.yml exec -T traefik \
		traefik_hosts > traefik_hosts
	docker-compose -f tests_nginx/docker-compose.yml run -T client \
		goss -g nginx.yaml validate --max-concurrent 4 --format documentation

down:
	docker-compose -f tests_nginx/docker-compose.yml down || true

tests: test down
