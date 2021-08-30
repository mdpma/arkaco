#FusionPBX Docker Image 
FROM ubuntu:20.04
LABEL Author="Mojtaba Dehghani, Behrouz Varzande @ ArkaPro.ir"
LABEL App="FusionPBX"
LABEL Version="v1.6"

ARG DEBIAN_FRONTEND=noninteractive

#Pre-install packages if you use container
RUN apt-get update \
&& apt-get upgrade -y \
&& apt-get install -y dialog apt-utils \
&& apt-get install -y git lsb-release \
&& apt-get install -y systemd \
&& apt-get install -y systemd-sysv \
&& apt-get install -y ca-certificates \
&& apt-get install -y nano ntp \
&& apt-get install -y supervisor  \
&& apt-get install -y vim \
&& apt-get install -y dnsutils \
&& apt-get install -y net-tools \
&& apt-get install -y iputils-ping \
&& apt-get install -y iputils-tracepath \
&& apt-get install -y  wget \
&& apt-get install -y curl \
&& apt-get install -y gnupg \
&& apt-get install -y python3-pip \
&& apt-get install -y perl \
&& apt-get install memcached haveged  libmemcached-tools -y \
&& /etc/init.d/memcached start  
#&& apt-get install -y iptables 
#&& systemctl enable memchached

#install erlang
#RUN wget -O - https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add - \
#&&  echo "deb https://packages.erlang-solutions.com/ubuntu focal contrib" | sudo tee /etc/apt/sources.list.d/rabbitmq.list \
RUN  apt-get install -y erlang 

USER root
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start-freeswitch.sh /usr/bin/start-freeswitch.sh
COPY /fusionpbx-source/ubuntu/resources/config.lua /usr/local/src/config.lua

#Install FusionPBX on Ubuntu 20.04
RUN wget -O - https://raw.githubusercontent.com/mdpma/arkaco/master/fusionpbx-source/ubuntu/pre-install.sh | sh \
&& cd /usr/src/arkaco/fusionpbx-source/ubuntu \
&& chmod -R 755 /usr/src/arkaco \
&& ./install.sh

RUN mv /etc/fusionpbx/config.lua /etc/fusionpbx/config.lua.original \
&& cp /usr/local/src/config.lua /etc/fusionpbx \
&& chmod 664 /etc/fusionpbx/config.lua

# Open the container up to the world.
# Freeswitch ports and protocols guide : https://freeswitch.org/confluence/display/FREESWITCH/Firewall
EXPOSE 9001 
EXPOSE 80
EXPOSE 443 
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp 5070/udp 5070/tcp
EXPOSE 5066/tcp 7443/tcp
EXPOSE 2855-2856/tcp 	
#EXPOSE 8021/tcp >> 8021 is for ESL that is a security risk when publishing to the world
#EXPOSE 64535-65535/udp >> We do not open rtp ports because of the Docker limitation
# on port ranges. instead we use Docker host iptables to pass RTP port ranges as following:
#sudo iptables -A DOCKER -t nat -p udp -m udp ! -i docker0 --dport 60535:65535 -j DNAT --to-destination CONTAINER_IP/32:60535-65535
#sudo iptables -A DOCKER -p udp -m udp -d CONTAINER_IP/32 ! -i docker0 -o docker0 --dport 60535:65535 -j ACCEPT
#sudo iptables -A POSTROUTING -t nat -p udp -m udp -s CONTAINER_IP/32 -d CONTAINER_IP/32 --dport 60535:65535 -j MASQUERADE

#RUN chmod 755 /etc/supervisor/conf.d/supervisord.conf \
#&& chmod 755 usr/bin/start-freeswitch.sh 

#We do not declare volumes here, because the docker will name them randomly.
#We will create volumes when passing "docker container run -d" command using -v or --volume.
#VOLUME ["/var/lib/postgresql", "/etc/freeswitch", "/var/lib/freeswitch", "/usr/share/freeswitch", "/var/www/fusionpbx"]
CMD /usr/bin/supervisord -n
