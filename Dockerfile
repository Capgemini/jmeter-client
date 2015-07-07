FROM akbardhedhi/jmeter-common

ENV CONSUL_TEMPLATE_VERSION=0.8.0

ADD https://github.com/hashicorp/consul-template/releases/download/v${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz /

RUN tar zxvf consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz && \
    mv consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64/consul-template /usr/local/bin/consul-template && \
    rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz && \
    rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64

RUN mkdir -p /consul-template/config.d /consul-template/template.d /tests

ADD config/ /consul-template/config.d/
ADD template/ /consul-template/template.d/
ADD launch.sh /launch.sh
ADD tests /tests/

VOLUME [ "/logs" ]

RUN ["chmod", "+x", "/launch.sh"]

ENTRYPOINT ["/launch.sh"]