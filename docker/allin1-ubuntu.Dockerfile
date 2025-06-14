
FROM ubuntu:22.04

# install basic dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    redis-server \
    wget \
    supervisor \
    netcat-openbsd \
 && rm -rf /var/lib/apt/lists/*

# install zookeeper
RUN wget https://dlcdn.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3-bin.tar.gz \
    && tar -xzf apache-zookeeper-3.9.3-bin.tar.gz -C /opt \
    && mv /opt/apache-zookeeper-3.9.3-bin /opt/zookeeper \
    && rm apache-zookeeper-3.9.3-bin.tar.gz

# configure zookeeper
RUN mkdir -p /var/lib/zookeeper && \
    echo "tickTime=2000\n\
dataDir=/var/lib/zookeeper\n\
clientPort=2181\n\
initLimit=5\n\
syncLimit=2\n" > /opt/zookeeper/conf/zoo.cfg

# wait-for-it.sh
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

# copy java app
ADD https://github.com/crossoverJie/cim/releases/download/v2.1.0/cim-server-1.0.0-SNAPSHOT.jar /cim-server.jar
ADD https://github.com/crossoverJie/cim/releases/download/v2.1.0/cim-forward-route-1.0.0-SNAPSHOT.jar /cim-route.jar

RUN mkdir -p /var/log/supervisor
ADD https://raw.githubusercontent.com/crossoverJie/cim/refs/heads/master/docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["supervisord", "-n"]
