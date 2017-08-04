all: jessie stretch latest 

jessie: 
	docker build -t bearstech/nginx:$@ -f Dockerfile.$@ . 

stretch:
	docker build -t bearstech/nginx:$@ -f Dockerfile.$@ . 

latest: stretch
	docker tag bearstech/nginx:$< bearstech/nginx:$@ 

pull:
	docker pull bearstech/debian:stretch
	docker pull bearstech/debian:jessie

push:
	docker push bearstech/nginx:jessie
	docker push bearstech/nginx:stretch
	docker push bearstech/nginx:latest
