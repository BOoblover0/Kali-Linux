FROM ubuntu:22.04

# Install base dependencies
RUN apt-get update -y && \
    apt-get install -y \
      curl wget openssh-server sudo \
      python3.10 python3-pip git nano

# Install zrok (with explicit error handling)
RUN curl -sSL https://zrok.io/install > /tmp/install-zrok.sh && \
    chmod +x /tmp/install-zrok.sh && \
    /tmp/install-zrok.sh || echo "Zrok install completed with exit code $?" && \
    rm /tmp/install-zrok.sh

# Configure SSH
RUN mkdir /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'root:choco' | chpasswd && \
    ssh-keygen -A

# Startup script
RUN echo "#!/bin/bash" > /start && \
    echo "service ssh start" >> /start && \
    echo "zrok enable FVfex9GLPrBU || true" >> /start && \
    echo "zrok share public localhost:22 --name myssh &" >> /start && \
    echo "tail -f /dev/null" >> /start && \
    chmod +x /start

EXPOSE 22
CMD ["/start"]
