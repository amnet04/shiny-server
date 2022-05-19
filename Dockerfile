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
            python2 \
            R-dev && \ 
    apk add --no-cache libstdc++  cairo-dev  icu-libs && \
    python -m ensurepip && pip install --upgrade pip

RUN installr -d -t "libsodium-dev curl-dev linux-headers autoconf automake" \
             -a libsodium shiny && \
    DOWNLOAD_STATIC_LIBV8=1 installr -a curl -c V8 && \
    installr Cairo svglite rmarkdown

RUN mkdir /src && cd /src && \
    git clone https://github.com/velaco/shiny-server.git && \
    mkdir /src/shiny-server/ext && mv /opt/node /src/shiny-server/ext/node && \
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
    make install && \
    apk del .build-deps

FROM rhub/r-minimal:4.0.5

COPY config/shiny-server.conf /etc/shiny-server/shiny-server.conf               

COPY scripts/shiny-server.sh /usr/local/bin/shiny-server.sh  

COPY scripts/tailer.sh  /usr/local/bin/tailer.sh

COPY --from=0 /usr/local /usr/local

COPY --from=0 /src/shiny-server/samples/sample-apps /srv/shiny-server/sample-apps

COPY --from=0 /src/shiny-server/samples/welcome.html /srv/shiny-server/

COPY ./samples/server.R /srv/shiny-server/sample-apps/hello/server.R

COPY ./samples/index.Rmd /srv/shiny-server/sample-apps/rmd/index.Rmd
  
RUN ln -s /usr/local/shiny-server/bin/shiny-server /usr/local/bin/shiny-server && \
    apk add --no-cache libstdc++ cairo-dev curl icu-libs ttf-freefont  && \
    fc-cache && \
    addgroup -g 1000 -S shiny && \ 
    adduser -u 1000 -h /srv/shiny-server -S -G shiny shiny && \
    mkdir -p /var/lib/shiny-server && \
    mkdir -p /var/log/shiny-server && \
    chown -R shiny:shiny /var/lib/shiny-server && \
    chown -R shiny:shiny /var/log/shiny-server && \
    chmod 744 /usr/local/bin/shiny-server.sh && \
    chmod 744 /usr/local/bin/tailer.sh && \
    chown shiny:shiny /usr/local/bin/shiny-server.sh  && \
    chown shiny:shiny /usr/local/bin/tailer.sh && \
    chown -R shiny:shiny /srv/shiny-server && \
    rm -rf /src && \
    rm -rf .cache && \
    rm -rf /root/* && \
    rm -rf /usr/lib/python3.9 && \
    rm -rf /usr/lib/python2.7 && \
    rm -rf /opt

WORKDIR /srv/shiny-server/
EXPOSE 3838
USER shiny
CMD ["shiny-server.sh"]

