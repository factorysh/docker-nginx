GOSS_VERSION := 0.3.5

all: pull build

pull:
	docker pull bearstech/debian:stretch
	docker pull bearstech/debian:jessie

build: jessie stretch

jessie:
	docker build -t bearstech/nginx:1.6 --build-arg DEBIAN_DISTRO=jessie .

stretch:
	docker build -t bearstech/nginx:1.10 --build-arg DEBIAN_DISTRO=stretch .
	docker tag bearstech/nginx:1.10 bearstech/nginx:latest

push:
	docker push bearstech/nginx:1.6
	docker push bearstech/nginx:1.10
	docker push bearstech/nginx:latest

remove_image:
	docker rmi bearstech/nginx:1.6
	docker rmi bearstech/nginx:1.10
	docker rmi bearstech/nginx:latest

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

tests_nginx/data:
	mkdir -p tests_nginx/data
	chmod 777 tests_nginx/data

test: bin/goss tests_nginx/data
	docker-compose -f tests_nginx/docker-compose.yml down || true
	docker run --rm -v `pwd`/tests_nginx:/test/data bearstech/debian rm -rf /test/data/log
	docker-compose -f tests_nginx/docker-compose.yml up -d traefik
	sleep 1
	docker-compose -f tests_nginx/docker-compose.yml run -T --use-aliases client \
		goss -g nginx.yaml validate --max-concurrent 4 --format documentation
	docker-compose -f tests_nginx/docker-compose.yml down || true

tests: test
