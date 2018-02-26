FROM centos:latest
MAINTAINER Michael Zamot mzamot@redhat.com

ENV CONFD_VERSION="0.15.0" \
    CONFD_URL="https://github.com/kelseyhightower/confd/releases/download" \
    RABBITMQ_HOST=rabbitmq \
    RABBITMQ_PORT=5672 \
    RABBITMQ_USER=sensu \
    RABBITMQ_PASS=sensu \
    RABBITMQ_VHOST=/sensu \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    SENSU_API_HOST=localhost \
    SENSU_API_PORT=4567 \
    SENSU_API_BIND=0.0.0.0

# Add Sensu repository
ADD files/sensu.repo /etc/yum.repos.d/

RUN yum repolist --disablerepo=* && \
    yum-config-manager --disable \* > /dev/null && \
    yum-config-manager --enable rhel-7-server-rpms > /dev/null && \ 
    yum-config-manager --enable sensu && \
    yum install -y sensu && \
    yum clean all && \
    rm -rf /etc/sensu/config.json.example && \
    curl -o /bin/confd -LJO ${CONFD_URL}/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    chmod +x /bin/confd

ADD conf /etc/confd
RUN /bin/confd -onetime -backend env
