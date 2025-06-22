FROM ubuntu:22.04

# Install all original dependencies
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
      sudo curl ffmpeg git locales nano \
      python3.10 python3-pip screen ssh unzip wget \
      openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --set python3 /usr/bin/python3.10 && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3

# Install Node.js (original version)
RUN curl -sL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y nodejs

# Configure locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Configure SSH for Termius access
RUN mkdir /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'root:choco' | chpasswd && \
    ssh-keygen -A

# Install zrok (latest)
RUN curl -sL https://zrok.io/install | bash

# Startup script (zrok + SSH)
RUN echo "#!/bin/sh" > /start && \
    echo "service ssh start" >> /start && \
    echo "zrok enable FVfex9GLPrBU || true" >> /start && \
    echo "zrok share public localhost:22 --name myssh &" >> /start && \
    echo "sleep infinity" >> /start && \
    chmod +x /start

# Expose original ports + SSH
EXPOSE 22 80 8888 8080 443 5130-5135 3306

# Start everything
CMD ["/start"]
