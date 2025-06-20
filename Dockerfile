FROM debian:latest

# Install minimal dependencies
RUN apt-get update && apt-get install -y \
    python3-http.server ssh autossh curl

# Setup SSH (simplified)
RUN mkdir -p /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'root:choco' | chpasswd

# Create minimal HTTP response (for Render's health checks)
RUN echo "OK" > /health.txt

# Startup script
RUN echo '#!/bin/sh\n\
# Dummy HTTP server (just for Render compliance)\n\
python3 -m http.server $PORT --bind 0.0.0.0 --directory / & \n\
\n\
# Real SSH tunnel (your actual service)\n\
autossh -M 0 -N \n\
    -o "StrictHostKeyChecking=no" \n\
    -o "ServerAliveInterval=60" \n\
    -R 0:localhost:22 serveo.net &\n\
\n\
# SSH daemon\n\
/usr/sbin/sshd -D\n\
' > /start && chmod +x /start

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:$PORT/health.txt || exit 1

EXPOSE $PORT 22
CMD ["/start"]
