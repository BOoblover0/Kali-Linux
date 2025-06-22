FROM ubuntu:22.04

# Update system and install essential packages
RUN apt-get -y update && apt-get -y upgrade && apt-get install -y sudo
RUN sudo apt-get install -y curl ffmpeg git locales nano python3-pip screen ssh unzip wget  

# Set up locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_21.x | bash -
RUN sudo apt-get install -y nodejs

# Set environment
ENV LANG en_US.utf8

# Install bore for SSH tunneling
RUN wget -O bore.tar.gz https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz
RUN tar -xzf bore.tar.gz && mv bore /usr/local/bin/ && rm bore.tar.gz

# Configure SSH
RUN mkdir -p /run/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config 
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'Port 22' >> /etc/ssh/sshd_config
RUN echo root:choco | chpasswd

# Generate SSH host keys
RUN ssh-keygen -A

# Create start script
RUN echo '#!/bin/bash' > /start
RUN echo 'echo "=== Ubuntu Container with Bore.pub SSH Tunnel ==="' >> /start
RUN echo 'echo "Starting SSH daemon..."' >> /start
RUN echo '/usr/sbin/sshd -D &' >> /start
RUN echo 'sleep 3' >> /start
RUN echo 'echo ""' >> /start
RUN echo 'echo "🚀 Starting bore.pub tunnel..."' >> /start
RUN echo 'echo "📡 Connecting to bore.pub..."' >> /start
RUN echo 'echo ""' >> /start
RUN echo 'echo "⚡ Your SSH connection details:"' >> /start
RUN echo 'echo "   Host: bore.pub"' >> /start
RUN echo 'echo "   Username: root"' >> /start
RUN echo 'echo "   Password: kaal"' >> /start
RUN echo 'echo "   Port: (see below)"' >> /start
RUN echo 'echo ""' >> /start
RUN echo 'echo "🔗 Tunnel starting..."' >> /start
RUN echo 'bore local 22 --to bore.pub' >> /start

# Make start script executable
RUN chmod +x /start

# Expose ports
EXPOSE 22 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Start container
CMD ["/start"]
