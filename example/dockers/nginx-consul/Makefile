build:
	-docker rmi --force andrexus/nginx-consul-template
	docker build --force-rm -t andrexus/nginx-consul-template --no-cache .

run:
	-docker rm -f nginx
	docker run -d --name nginx \
	-p 80:80 -p 443:443 \
	-v $(shell pwd)/ssl:/etc/nginx/ssl \
	-v $(shell pwd)/conf.d:/etc/nginx/sites-enabled \
	-v $(shell pwd)/htpasswd:/etc/nginx/htpasswd \
	andrexus/nginx-consul-template

reload:
	docker restart nginx

.PHONY: build run reload
