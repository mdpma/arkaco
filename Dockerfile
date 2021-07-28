#FusionPBX Docker Image 
FROM ubuntu:20.04
LABEL Author="Mojtaba Dehghani, Behrouz Varzande @ ArkaPro.ir"
LABEL App="FusionPBX"
LABEL Version="v1.2"

#Pre-install packages if you use container
RUN apt update \
&& apt install -y apt-utils \
&& apt install -y lsb-release \
&& apt install -y systemd \
&& apt install -y systemd-sysv \
&& apt install -y ca-certificates \
&& apt install -y dialog \
&& apt install -y nano \
&& apt install -y supervisor  \
&& apt install -y vim \
&& apt install -y dnsutils \
&& apt install -y net-tools \
&& apt install -y iputils-ping \
&& apt install -y iputils-tracepath \
&& apt install -y  wget \
&& apt install -y curl \
&& apt install -y gnupg \
&& apt install -y python3-pip \
&& apt install memcached libmemcached-tools -y \
&& apt install -y iptables \
&& systemctl start memcached && systemctl enable 

#install erlang
RUN wget -O- https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add - \
&&  echo "deb https://packages.erlang-solutions.com/ubuntu focal contrib" | sudo tee /etc/apt/sources.list.d/rabbitmq.list \
&& && apt install -y erlang 

#Install FusionPBX on Ubuntu 20.04
RUN wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/ubuntu/pre-install.sh | sh \
&& cd /usr/src/fusionpbx-install.sh/ubuntu && ./install.sh
# Open the container up to the world.
# Freeswitch ports and protocols guide : https://freeswitch.org/confluence/display/FREESWITCH/Firewall
EXPOSE 9001 
EXPOSE 80 443 
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp 5070/udp 5070/tcp
EXPOSE 5066/tcp 7443/tcp
EXPOSE 2855-2856/tcp 	
#EXPOSE 8021/tcp >> 8021 is for ESL that is a security risk when publishing to the world
#EXPOSE 64535-65535/udp >> We do not open rtp ports because of the Docker limitation
# on port ranges. instead we use Docker host iptables to pass RTP port ranges as following:
#CIP=$(sudo docker inspect --format='{{.NetworkSettings.IPAddress}}' $CID)
#sudo iptables -A DOCKER -t nat -p udp -m udp ! -i docker0 --dport 60535:65535 -j DNAT --to-destination $CIP:60535-65535
#sudo iptables -A DOCKER -p udp -m udp -d $CIP/32 ! -i docker0 -o docker0 --dport 60535:65535 -j ACCEPT
#sudo iptables -A POSTROUTING -t nat -p udp -m udp -s $CIP/32 -d $CIP/32 --dport 60535:65535 -j MASQUERADE

USER root
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start-freeswitch.sh /usr/bin/start-freeswitch.sh

RUN chmod 755 /etc/supervisor/conf.d/supervisord.conf \
&& chmod 755 usr/bin/start-freeswitch.sh 

#We do not declare volumes here, because the docker will name them randomly.
#We will create volumes when passing "docker container run -d" command using -v or --volume.
#VOLUME ["/var/lib/postgresql", "/etc/freeswitch", "/var/lib/freeswitch", "/usr/share/freeswitch", "/var/www/fusionpbx"]
CMD /usr/bin/supervisord -n
