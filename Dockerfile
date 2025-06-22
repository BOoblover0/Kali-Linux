FROM debian:latest

# Install base dependencies including Python 3.10
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y sudo curl ffmpeg git locales nano python3.10 python3-pip openssh-client screen ssh unzip wget autossh

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

# Configure SSH server
RUN mkdir /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'ClientAliveInterval 60' >> /etc/ssh/sshd_config && \
    echo root:choco | chpasswd && \
    ssh-keygen -A

# Generate SSH key for Serveo (if needed)
RUN mkdir -p /root/.ssh && \
    ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N "" && \
    chmod 600 /root/.ssh/id_ed25519

# Create startup script
RUN echo "#!/bin/bash" > /start && \
    echo "# Wait for network" >> /start && \
    echo "while ! curl -s --connect-timeout 3 serveo.net >/dev/null; do" >> /start && \
    echo "  echo 'Waiting for network connectivity...'" >> /start && \
    echo "  sleep 5" >> /start && \
    echo "done" >> /start && \
    echo "" >> /start && \
    echo "# Start Serveo tunnel using autossh for stability" >> /start && \
    echo "autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' \\" >> /start && \
    echo "        -o 'StrictHostKeyChecking=no' -N \\" >> /start && \
    echo "        -R 80:localhost:80 -R 22:localhost:22 serveo.net &" >> /start && \
    echo "" >> /start && \
    echo "# Start SSH server" >> /start && \
    echo "/usr/sbin/sshd -D" >> /start && \
    chmod 755 /start

# Expose ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306 22

# Start command
CMD ["/bin/bash", "/start"]
