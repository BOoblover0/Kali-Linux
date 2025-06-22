FROM ubuntu:22.04

# Install base dependencies including Python 3.10
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y sudo curl ffmpeg git locales nano python3.10 python3-pip screen ssh unzip wget

# Set up Python 3.10 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --set python3 /usr/bin/python3.10 && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3

# Set up locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y nodejs

# Configure SSH
RUN mkdir /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo root:choco | chpasswd && \
    ssh-keygen -A

# Create startup script
RUN echo "#!/bin/sh" > /start && \
    echo "# Start localhost.run SSH tunnel" >> /start && \
    echo "while true; do" >> /start && \
    echo "  ssh -o StrictHostKeyChecking=no \\" >> /start && \
    echo "      -o ServerAliveInterval=60 \\" >> /start && \
    echo "      ssh.localhost.run" >> /start && \
    echo "  sleep 10" >> /start && \
    echo "done &" >> /start && \
    echo "" >> /start && \
    echo "# Start SSH server" >> /start && \
    echo "/usr/sbin/sshd -D" >> /start && \
    chmod 755 /start

# Expose ports (these are just declarations, actual forwarding happens via SSH)
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Start command
CMD /start
