################################################################################
# This Dockerfile was generated from the template at ../../Dockerfile-slim.template
#
# Beginning of multi-stage Dockerfile
#
# Build stage 0: builder
################################################################################
FROM openjdk:11-jdk-slim AS builder

ENV LIFERAY_DOWNLOAD_URL https://releases.liferay.com/portal/7.2.0-ga1/liferay-ce-portal-tomcat-7.2.0-ga1-20190531153709761.tar.gz
ENV LIFERAY_DOWNLOAD_MD5 e68ab5dae19063924ae8d7e7ea0078fa

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    wget; \
    wget -O liferay-bundle.tar.gz "$LIFERAY_DOWNLOAD_URL" -q --show-progress --progress=bar:force 2>&1; \
    echo "$LIFERAY_DOWNLOAD_MD5 liferay-bundle.tar.gz" | md5sum -c -; \
    mkdir /tmp/liferay-bundle; \
    tar -zxf liferay-bundle.tar.gz -C /tmp/liferay-bundle --strip-components=1; \
    # download a stretch-backport version of tomcat-native library
    # since stretch's package repo contains an incompatible version (1.2.12)
    wget -O /tmp/libtcnative-1.deb 'http://ftp.us.debian.org/debian/pool/main/t/tomcat-native/libtcnative-1_1.2.21-1~bpo9+1_amd64.deb' -q --show-progress --progress=bar:force 2>&1

################################################################################
# Build stage 1: the actual liferay-portal-ce image
################################################################################
FROM openjdk:11-jdk-slim

RUN groupadd liferay && useradd -g liferay liferay

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    # su tool for easy step-down from root
    gosu \
    # Font family based on the Bitstream Vera Fonts with a wider range of characters
    fontconfig \
    ttf-dejavu \
    # Apache Portable Runtime dependecy for Tomcat native library
    libapr1; \
    rm -rf /var/lib/apt/lists/*; \
    gosu nobody true

ENV LIFERAY_VERSION 7.2.0-ga1
ENV LIFERAY_HOME /opt/liferay
ENV LIFERAY_BASE /etc/opt/liferay
ENV LIFERAY_INIT /docker-entrypoint-initliferay.d
ENV PATH ${LIFERAY_HOME}/tomcat/bin:${PATH}

COPY --from=builder --chown=liferay:liferay /tmp/liferay-bundle ${LIFERAY_HOME}
COPY --from=builder /tmp/libtcnative-1.deb .

RUN set -ex \
    && path=$(find "$(cd ..; pwd)" -name "catalina.sh") \
    && ln -s "${path%%/bin*}" "$LIFERAY_HOME/tomcat" \
    && mkdir -p "$LIFERAY_BASE" "$LIFERAY_INIT" \
    && chown -R liferay:liferay "$LIFERAY_BASE" "$LIFERAY_INIT" \
    && dpkg -i libtcnative-1.deb \
    && ln -s /usr/lib/x86_64-linux-gnu/libtcnative-1.so /usr/lib/libtcnative-1.so \
    && rm libtcnative-1.deb

RUN set -e \
    && native_lines="$(catalina.sh configtest 2>&1)" \
    && native_lines="$(echo "$native_lines" | grep 'Apache Tomcat Native')" \
    && native_lines="$(echo "$native_lines" | sort -u)" \
    && if ! echo "$native_lines" | grep 'INFO: Loaded APR based Apache Tomcat Native library' >&2; then \
      echo >&2 "$native_lines"; \
      exit 1; \
    fi

LABEL \
    maintainer="Igor Baiborodine <ibaiborodine@gmail.com>" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="liferay-portal-ce" \
    org.label-schema.vcs-url="https://github.com/igor-baiborodine/docker-liferay-portal-ce" \
    org.label-schema.usage="https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/master/README.md"

VOLUME \
    ${LIFERAY_HOME}/data/document_library \
    ${LIFERAY_HOME}/deploy \
    ${LIFERAY_BASE} \
    ${LIFERAY_INIT}

WORKDIR ${LIFERAY_HOME}

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080 11311
CMD ["catalina.sh", "run"]

################################################################################
# End of multi-stage Dockerfile
################################################################################
