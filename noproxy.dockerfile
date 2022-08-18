FROM jetson_docker_image:latest

USER root

RUN useradd -m nvidia
RUN mkdir -p /home/nvidia/.ssh
RUN chown -R nvidia:nvidia /home/nvidia
RUN echo 'nvidia:nvidia' | chpasswd
RUN usermod --shell /bin/bash nvidia && \
        usermod -aG sudo nvidia && \
        echo "nvidia ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN sed -i 's/<SOC>/t194/' /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
RUN apt-get update && apt-get install -y openssh-server
RUN apt-mark hold nvidia-l4t-*
RUN mkdir -p /var/run/sshd
RUN echo 'root:nvidia' | chpasswd
RUN pwunconv
RUN pwconv

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 20022/' /etc/ssh/sshd_config

EXPOSE 20022
USER nvidia
CMD sudo bash -c 'ssh-keygen -A' && sudo bash -c '/usr/sbin/sshd -D &' && /bin/bash
