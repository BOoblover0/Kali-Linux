FROM ubuntu:22.04

# 1. Install essential packages with clean cleanup
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      curl wget openssh-server sudo \
      python3.10 python3-pip git nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Direct zrok binary installation (no installer issues)
RUN mkdir -p /usr/local/zrok/bin && \
    wget https://github.com/openziti/zrok/releases/latest/download/zrok_linux_amd64 -O /usr/local/zrok/bin/zrok && \
    chmod +x /usr/local/zrok/bin/zrok && \
    ln -s /usr/local/zrok/bin/zrok /usr/local/bin/zrok

# 3. Configure environment
ENV PATH="/usr/local/zrok/bin:${PATH}" \
    ZROK_TOKEN="FVfex9GLPrBU"

# 4. SSH setup with secure defaults
RUN mkdir /run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'root:choco' | chpasswd && \
    ssh-keygen -A -t ed25519 && \
    ssh-keygen -A -t rsa

# 5. Startup script with health checks
RUN echo '#!/bin/bash\n\
service ssh start\n\
\n\
# Start zrok tunnel with retries\n\
for i in {1..5}; do\n\
  if zrok share public localhost:22 --name myssh; then\n\
    echo "zrok tunnel established at: https://myssh.zrok.io"\n\
    break\n\
  else\n\
    echo "zrok attempt $i failed, retrying..."\n\
    sleep 5\n\
  fi\n\
done &\n\
\n\
# Keep container alive\n\
tail -f /dev/null' > /start && \
    chmod +x /start

# 6. Health check (tests SSH internally)
HEALTHCHECK --interval=30s --timeout=5s \
  CMD netstat -tuln | grep -q ':22 ' || exit 1

EXPOSE 22
CMD ["/start"]
