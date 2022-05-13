FROM rhub/r-minimal:4.0.5
# Alpine 3.14.3

# MAINTAINER "Carlos Alberto Rodríguez" amnet04@gmail.com

#################################################################################
#                                                                               #
#               0. Install shiny-server prerequisites                           #
#                                                                               #
#################################################################################

# Note: https://www.dazhuanlan.com/dalizi/topics/1690292

COPY --from=amnet04/node:node8x_alpine3.14  /opt /opt
COPY config/shiny-server.conf /etc/shiny-server/shiny-server.conf               
COPY scripts/shiny-server.sh /usr/local/bin/shiny-server.sh  

RUN apk add --no-cache --virtual .build-deps \
            cairo  \
            cmake \
            curl \
            curl-dev \
            fontconfig \ 
            freetype-dev \
            g++ \
            gcc \
            git \
            icu-libs \
            libxml2-dev \
            libxt-dev \
            msttcorefonts-installer \
            python2 \
            R-dev && \ 
    apk add --no-cache libstdc++  cairo-dev  icu-libs && \
    update-ms-fonts && fc-cache -f &&\
    python -m ensurepip && pip install --upgrade pip && \
    mkdir /src && cd /src && \
    installr -d -t "libsodium-dev curl-dev linux-headers autoconf automake" \
             -a libsodium shiny && \
    DOWNLOAD_STATIC_LIBV8=1 installr -a curl -c V8 && \
    installr Cairo svglite rmarkdown && \
    git clone https://github.com/velaco/shiny-server.git && \
    mkdir /src/shiny-server/ext && mv /opt /src/shiny-server/ext/node && \
    cp /src/shiny-server/ext/node/bin/node /src/shiny-server/ext/node/bin/shiny-server && \
    rm /src/shiny-server/ext/node/bin/npm && \ 
    ln -s /src/shiny-server/ext/node/bin/node /usr/local/bin/ && \
    cd /src/shiny-server && \
    mkdir tmp && \
    cd tmp && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local ../ && \
    make && mkdir ../build && \
    (cd .. && ./bin/npm --python="/usr/bin/python" \
                        --nodedir="/src/shiny-server/ext/node" install) && \
    (cd .. && ./bin/npm --python="/usr/bin/python" \
                        --nodedir="/src/shiny-server/ext/node" audit fix) && \
    (cd .. && ./bin/node \
              ./ext/node/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js \
              --python="/usr/bin/python" \
              --nodedir="/src/shiny-server/ext/node" rebuild) && \
    make install &&\
    ln -s /usr/local/shiny-server/bin/shiny-server /usr/local/bin/shiny-server && \
    addgroup -g 1000 -S shiny && \ 
    adduser -u 1000 -D -S -G shiny shiny && \
    mkdir -p /srv/shiny-server && \
    mkdir -p /var/lib/shiny-server && \
    mkdir -p /var/log/shiny-server && \
    mkdir -p /etc/shiny-server && \
    chown -R shiny:shiny /srv/shiny-server && \
    chown -R shiny:shiny /var/lib/shiny-server && \
    chown -R shiny:shiny /var/log/shiny-server && \
    chmod 744 /usr/local/bin/shiny-server.sh && \
    chown shiny:shiny /usr/local/bin/shiny-server.sh  && \
    mv /src/shiny-server/samples/sample-apps /srv/shiny-server/ && \
    mv /src/shiny-server/samples/welcome.html /srv/shiny-server/ && \
    chown -R shiny:shiny /srv/shiny-server && \
    rm -rf /src && \
    apk del .build-deps && \
    rm -rf .cache && \
    rm -rf /root/* && \
    rm -rf /usr/lib/python3.9 && \
    rm -rf /usr/lib/python2.7 

EXPOSE 3838
USER shiny
CMD ["shiny-server.sh"]

