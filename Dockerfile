FROM rhub/r-minimal:4.0.5
# Alpine 3.14.3

# MAINTAINER "Carlos Alberto Rodríguez" amnet04@gmail.com

#################################################################################
#                                                                               #
#               0. Install shiny-server prerequisites                           #
#                                                                               #
#################################################################################

# Note: https://www.dazhuanlan.com/dalizi/topics/1690292

RUN apk add --no-cache --virtual .build-deps bash cmake gcc g++ git R-dev python3 curl && \
    apk add --no-cache libstdc++ && \
    ln -s $(which python3) /usr/bin/python && \
    python -m ensurepip && pip3 install --upgrade pip && \
    mkdir /src && cd /src && \
    git clone https://github.com/velaco/shiny-server.git

RUN installr -d -t "libsodium-dev curl-dev linux-headers autoconf automake" \
             -a libsodium shiny

RUN DOWNLOAD_STATIC_LIBV8=1 installr -a curl -c V8


COPY --from=amnet04/node:node8x_alpine3.14  /opt /src/shiny-server/ext/node

RUN cp /src/shiny-server/ext/node/bin/node /src/shiny-server/ext/node/bin/shiny-server && \
    rm /shiny-server/ext/node/bin/npm && \
    cd /src/shiny-server && \
    mkdir tmp && \
    cd tmp && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local ../ && \
    make && mkdir ../build && \
    (cd .. && ./bin/npm --python="/usr/bin/python" \
              --nodedir="/src/shiny-server/ext/node" install) && \
    (cd .. && ./bin/node \
              ./ext/node/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js \
              --python="/usr/bin/python" \
              --nodedir="/src/shiny-server/ext/node" rebuild) && \
    make install
  
COPY config/shiny-server.conf /etc/shiny-server/shiny-server.conf               
COPY scripts/shiny-server.sh /usr/bin/shiny-server.sh  
#    ln -s /opt/bin/npm /usr/local/bin/npm && \
#    ln -s /opt/bin/npx /usr/local/bin/npx 
# 
#   cd shiny-server && mkdir tmp && cd tmp && \
#    cmake -DCMAKE_INSTALL_PREFIX=/usr/local ../ && \
#    make && mkdir ../build && \
#    (cd .. && npm --python="/usr/bin/python" --nodedir=/opt install) && \
##    make install
#
# RUN ln -s /usr/local/shiny-server/bin/shiny-server /usr/bin/shiny-server && \
#     addgroup -g 1000 -S shiny && \ 
#     adduser -u 1000 -D -S -G shiny shiny && \
#     mkdir -p /srv/shiny-server && \
#     mkdir -p /var/lib/shiny-server &&  \
#     mkdir -p /etc/shiny-server
#
#COPY config/shiny-server.conf /etc/shiny-server/shiny-server.conf
#COPY scripts/shiny-server.sh /usr/bin/shiny-server.sh
#
## Move sample apps to test installation, clean up
#RUN chmod 744 /usr/bin/shiny-server.sh && \
#    mv /src/shiny-server/samples/sample-apps /srv/shiny-server/ && \
#    mv /src/shiny-server/samples/welcome.html /srv/shiny-server/ && \
#    rm -rf /src/
#
#EXPOSE 3838
#
#CMD ["/usr/bin/shiny-server.sh"]

