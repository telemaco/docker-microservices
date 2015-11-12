# Nginx with consul-template bundled

This project is a Docker container for [nginx (extended version)](https://bugs.launchpad.net/ubuntu/trusty/+package/nginx-extras) bundled with [consul-template](https://github.com/hashicorp/consul-template) (v0.9.0) which allows you dynamically create nginx configuration files based on services that are registered in consul. Usually used together with [registrator](https://github.com/gliderlabs/registrator)

## Getting the container

The container is based on the latest ubuntu [image](https://registry.hub.docker.com/_/ubuntu/) and available on the Docker Index:

	$ docker pull andrexus/nginx-consul-template

## Using the container

	$ docker run -d --name nginx -p 80:80 -p 443:443 andrexus/nginx-consul-template

You may want to replace default consul config file and templates that are located under

	/etc/consul-template/config.cfg
	/etc/consul-template/templates/

You can mount your config files as extra volumes

	$ docker run -d --name nginx \
	  -p 80:80 -p 443:443 \
	  -v "consul-template.cfg:/etc/consul-template/config.cfg"
	  -v "templates:/etc/consul-template/templates" \
      andrexus/nginx-consul-template
      
## Testing with docker-compose
	$ docker-compose up

If you are using boot2docker your docker IP might look like this 192.168.59.103.
Add the following to your /etc/hosts file.

	192.168.59.103  foo.dev
	192.168.59.103  bar.dev
	
- Hit http://foo.dev
- Hit http://bar.dev

## License

MIT