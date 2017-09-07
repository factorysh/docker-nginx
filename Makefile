all: jessie stretch

jessie:
	docker build -t bearstech/nginx:1.6 -f Dockerfile.$@ .

stretch:
	docker build -t bearstech/nginx:1.10 -f Dockerfile.$@ .
	docker tag bearstech/nginx:1.10 bearstech/nginx:latest

pull:
	docker pull bearstech/debian:stretch
	docker pull bearstech/debian:jessie

push:
	docker push bearstech/nginx:1.6
	docker push bearstech/nginx:1.10
	docker push bearstech/nginx:latest
