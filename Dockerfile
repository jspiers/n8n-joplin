FROM n8nio/n8n:0.106.0-debian as builder
RUN apt-get update \
 && apt-get install -y \
        git \
        python-minimal \
        build-essential \
        libsecret-1-0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# https://github.com/nodejs/node-gyp/issues/1236#issuecomment-309447800
USER node
RUN NPM_CONFIG_PREFIX=/home/node/.joplin-bin npm --unsafe-perm -g install joplin

# Copy the built joplin into a clean Debian image
FROM n8nio/n8n:0.106.0-debian as release
COPY --from=builder --chown=node:node /home/node/.joplin-bin /home/node/.joplin-bin
ENV PATH=$PATH:/home/node/.joplin-bin/bin

# Joplin config directory can be mounted for persistence of config and database
# USER node
RUN mkdir -p /home/node/.config/joplin
RUN chown node:node /home/node/.config/joplin
VOLUME /home/node/.config/joplin

# Configure Joplin by importing a JSON configuration file from a mounted volume
ENV JOPLIN_CONFIG_JSON=/secrets/joplin-config.json
VOLUME /secrets
# Updated entrypoint script performs "joplin config --import-file $JOPLIN_CONFIG_JSON"
COPY --chown=node:node joplin-entrypoint.sh /joplin-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh", "/joplin-entrypoint.sh"]
CMD ["n8n"]
