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
&& chmod 664 /etc/fusionpbx/config.lua \
&& cp -R /var/www/fusionpbx/app/scripts/resources/scripts/* /usr/share/freeswitch/scripts/ \
&& cd /usr/share/freeswitch/scripts/ \
&& chown -R www-data:www-data * 

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
# on port ranges. instead we use Docker host iptables to pass RTP port ranges as follows:
#iptables -t nat -A DOCKER -p udp -m multiport --dport 16384:32768 -j DNAT --to-destination 1CONTAINER_IP_ADDRESS:16384-32768
#iptables -t nat -A POSTROUTING -j MASQUERADE -p tcp --source CONTAINER_IP_ADDRESS --destination CONTAINER_IP_ADDRESS --dport 16384:32768
#iptables -A DOCKER -j ACCEPT -p udp --destination CONTAINER_IP_ADDRESS --dport 16384:32768

#If you want to change RTP port ranges you need to modify "RTP Port Range" in /etc/freeswitch/autoload_configs/switch.conf.xml

#RUN chmod 755 /etc/supervisor/conf.d/supervisord.conf \
#&& chmod 755 usr/bin/start-freeswitch.sh 

#We do not create volumes here using docker file, because the docker will name them randomly.
#We will create volumes at the time of making fusionpbx container: "docker container run -d" command using -v or --volume, as follows:
# " docker run -d  \
# --name FUSIONPBX_CONTAINER_NAME \
# -p 80:80 -p 443:443 -p 2855:2855 -p 2856:2856 -p 9001:9001 -p 5060:5060/tcp -p 5060:5060/udp -p 5070:5070/tcp -p 5070:5070/udp -p 5080:5080/tcp -p 5080:5080/udp -p 7443:7443/tcp \
# -v psdb-msr:/var/lib/postgresql \
# -v etcfs-msr:/etc/freeswitch \
# -v varlibfs-msr:/var/lib/freeswitch \
# -v usrsharefs-msr:/usr/share/freeswitch \
# -v fusionweb-msr:/var/www/fusionpbx \
# FUSIONPBX_IMAGE:VERSION

#If you want to create volume using the docker file, use the below command:
#VOLUME ["/var/lib/postgresql", "/etc/freeswitch", "/var/lib/freeswitch", "/usr/share/freeswitch", "/var/www/fusionpbx"]

CMD /usr/bin/supervisord -n
