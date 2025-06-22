FROM ubuntu:22.04

# Install all original dependencies including Python 3.10
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y sudo curl ffmpeg git locales nano python3.10 python3-pip screen ssh unzip wget autossh

# Set up Python 3.10 as default (keeping original config)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --set python3 /usr/bin/python3.10 && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3

# Set up locale (keeping original config)
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install Node.js (keeping original config)
RUN curl -sL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y nodejs

# Configure SSH for both local access and ngLocalhost tunnel
RUN mkdir /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo root:choco | chpasswd && \
    ssh-keygen -A

# Create enhanced startup script with ngLocalhost tunnel
RUN echo "#!/bin/sh" > /start && \
    echo "# Generate SSH key if not exists" >> /start && \
    echo "mkdir -p /root/.ssh" >> /start && \
    echo "if [ ! -f /root/.ssh/id_rsa ]; then" >> /start && \
    echo "  ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ''" >> /start && \
    echo "fi" >> /start && \
    echo "" >> /start && \
    echo "# Start ngLocalhost tunnel in background" >> /start && \
    echo "echo 'Starting ngLocalhost tunnel...'" >> /start && \
    echo "autossh -M 0 -N -v \\" >> /start && \
    echo "    -o StrictHostKeyChecking=no \\" >> /start && \
    echo "    -o ServerAliveInterval=60 \\" >> /start && \
    echo "    -o ExitOnForwardFailure=yes \\" >> /start && \
    echo "    -R 2222:localhost:22 \\" >> /start && \
    echo "    nglocalhost.com &" >> /start && \
    echo "" >> /start && \
    echo "# Display connection info" >> /start && \
    echo "echo 'SSH Tunnel established. Connect to your VPS using:'" >> /start && \
    echo "echo 'ssh -p 2222 root@[your-nglocalhost-subdomain]'" >> /start && \
    echo "echo 'Password: choco'" >> /start && \
    echo "" >> /start && \
    echo "# Start SSH server" >> /start && \
    echo "/usr/sbin/sshd -D" >> /start && \
    chmod 755 /start

# Keep all original exposed ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306 22

# Start command
CMD /start
