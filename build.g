Sending build context to Docker daemon  142.8kB
[91m[WARNING]: Empty continuation line found in:
    RUN chmod 744 /usr/bin/shiny-server.sh &&     mv /src/shiny-server/samples/sample-apps /srv/shiny-server/ &&     mv /src/shiny-server/samples/welcome.html /srv/shiny-server/ &&     rm -rf /src/ EXPOSE 3838
[WARNING]: Empty continuation lines will become errors in a future release.
[0mStep 1/9 : FROM rhub/r-minimal:4.0.5
 ---> 2796ae448661
Step 2/9 : COPY --from=amnet04/node:node8x_alpine3.14  /opt /opt
 ---> 2c37802753c6
Step 3/9 : RUN ln -s /opt/bin/node /usr/local/bin/node &&     ln -s /opt/bin/npm /usr/local/bin/npm &&     ln -s /opt/bin/npx /usr/local/bin/npx &&     apk upgrade --update &&     apk add --no-cache --virtual .build-deps bash cmake gcc g++ git R-dev curl python3 &&     apk add --no-cache libstdc++ xtail &&     ln -s $(which python3) /usr/bin/python &&     python -m ensurepip && pip3 install --upgrade pip &&     installr -d -t "libsodium-dev curl-dev linux-headers autoconf automake"              -a libsodium shiny &&     DOWNLOAD_STATIC_LIBV8=1 installr  -c V8
 ---> Running in 3a1ff2a1432d
fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/APKINDEX.tar.gz
(1/9) Upgrading busybox (1.33.1-r6 -> 1.33.1-r7)
Executing busybox-1.33.1-r7.post-upgrade
(2/9) Upgrading libcrypto1.1 (1.1.1l-r0 -> 1.1.1n-r0)
