# nginx web/proxy server (extended version) with consul-template bundled

FROM ubuntu:15.04
MAINTAINER Andrew Teil <andrexus@gmail.com>

ENV CONSUL_TEMPLATE_VERSION 0.10.0
ENV CONSUL_TEMPLATE_URL https://github.com/hashicorp/consul-template/releases/download/v${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz

# Install curl nginx-extras and consul-template
RUN \
  apt-get update && apt-get upgrade -y --no-install-recommends && \
  apt-get -y install curl nginx-extras && \
  rm -rf /etc/nginx/sites-enabled/* && \
  rm -rf /var/lib/apt/lists/* && \
  curl -L $CONSUL_TEMPLATE_URL | tar -C /usr/local/bin --strip-components 1 -zxf -

# Forward request and error logs to docker log collector
RUN \
  ln -sf /dev/stdout /var/log/nginx/access.log && \
  ln -sf /dev/stderr /var/log/nginx/error.log && \
  ln -sf /dev/stdout /var/log/consul-template.log

ADD start.sh /srv/start.sh
ADD consul-template.cfg /etc/consul-template/config.cfg
ADD templates/ /etc/consul-template/templates/

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

WORKDIR /etc/nginx
ENTRYPOINT ["/srv/start.sh"]
