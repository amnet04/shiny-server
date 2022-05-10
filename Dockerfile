FROM rhub/r-minimal:4.0.5
# Alpine 3.14.3

# MAINTAINER "Carlos Alberto Rodríguez" amnet04@gmail.com

#################################################################################
#                                                                               #
#               0. Install shiny-server prerequisites                           #
#                                                                               #
#################################################################################

# Note: gcompat is required to execute glib binaries (such as node version 
#       include in shiny-server source). Information found in: https://stackoverflow.com/questions/66963068/docker-alpine-executable-binary-not-found-even-if-in-path/66974607#66974607

COPY --from=amnet04/node8x:0.1  /opt /opt

RUN ln -s /opt/bin/node /usr/local/bin/node && \
    ln -s /opt/bin/npm /usr/local/bin/npm && \
    ln -s /opt/bin/npx /usr/local/bin/npx && \
    apk upgrade --update && \
    apk add --no-cache --virtual .build-deps bash cmake gcc g++ git R-dev curl && \ 
            libuv-dev linux-headers  libgcc python3 \
    apk add --no-cache libstdc++ && \
    ln -s $(which python3) /usr/bin/python && \
    python -m ensurepip && pip3 install --upgrade pip && \
    installr -d -t "libsodium-dev curl-dev linux-headers autoconf automake" \
             -a libsodium shiny && \
    DOWNLOAD_STATIC_LIBV8=1 installr  -c V8
       
RUN mkdir /src && cd /src && \
    git clone https://github.com/velaco/shiny-server.git && \
    cd shiny-server && mkdir tmp && cd tmp && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local ../ && \
    make && mkdir ../build #&& \
    (cd .. && npm --python="/usr/bin/python" --nodedir=/opt install) && \
    make install
