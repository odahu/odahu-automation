FROM postgres:12-alpine

ENV RCLONE_VER 1.52.3

RUN set -ex && \
    apk add --no-cache \
    fuse pigz && \
    echo "user_allow_other" >> /etc/fuse.conf

RUN cd /tmp && \
    wget -O rclone.zip "https://github.com/rclone/rclone/releases/download/v${RCLONE_VER}/rclone-v${RCLONE_VER}-linux-amd64.zip" && \
    unzip rclone.zip && \
    mv rclone-v${RCLONE_VER}-linux-amd64/rclone /usr/local/bin && \
    chmod +x /usr/local/bin/rclone && \
    rm -rf rclone* 
