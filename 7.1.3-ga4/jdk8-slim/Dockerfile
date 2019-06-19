################################################################################
# This Dockerfile was generated from the template at ../../Dockerfile-slim.template
#
# Beginning of multi-stage Dockerfile
################################################################################

################################################################################
# Beginning of multi-stage Dockerfile
#
# Build stage 0: builder
################################################################################

FROM openjdk:8-jdk-slim AS builder

ENV LIFERAY_DOWNLOAD_URL https://releases.liferay.com/portal/7.1.3-ga4/liferay-ce-portal-tomcat-7.1.3-ga4-20190508171117552.tar.gz
ENV LIFERAY_DOWNLOAD_MD5 9831cfdd0488223513e78b08975ff505

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    wget; \
    wget -O liferay-bundle.tar.gz "$LIFERAY_DOWNLOAD_URL"; \
    echo "$LIFERAY_DOWNLOAD_MD5 liferay-bundle.tar.gz" | md5sum -c -; \
    mkdir /tmp/liferay-bundle; \
    tar -zxf liferay-bundle.tar.gz -C /tmp/liferay-bundle --strip-components=1; \
    # download backport version of tomcat-native since stretch's package repo contains an incompatible version (1.2.12)
    wget -O /tmp/libtcnative-1.deb 'http://ftp.us.debian.org/debian/pool/main/t/tomcat-native/libtcnative-1_1.2.21-1~bpo9+1_amd64.deb'

################################################################################
# Build stage 1: the actual liferay-portal-ce image
################################################################################
FROM openjdk:8-jdk-slim

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

ENV LIFERAY_VERSION 7.1.3-ga4
ENV LIFERAY_HOME /opt/liferay
ENV LIFERAY_BASE /etc/opt/liferay
ENV PATH ${LIFERAY_HOME}/tomcat/bin:${PATH}

COPY --from=builder --chown=liferay:liferay /tmp/liferay-bundle ${LIFERAY_HOME}
COPY --from=builder /tmp/libtcnative-1.deb .

RUN set -ex \
    && path=$(find "$(cd ..; pwd)" -name "catalina.sh") \
    && ln -s "${path%%/bin*}" "$LIFERAY_HOME/tomcat" \
    && mkdir -p "$LIFERAY_BASE" \
    && chown -R liferay:liferay "$LIFERAY_BASE"

RUN set -ex; \
    # install Tomcat native library using the Apache Portable Runtime
    dpkg -i libtcnative-1.deb; \
    ln -s /usr/lib/x86_64-linux-gnu/libtcnative-1.so /usr/lib/libtcnative-1.so; \
    rm libtcnative-1.deb

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
    ${LIFERAY_BASE}

WORKDIR ${LIFERAY_HOME}

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080 11311
CMD ["catalina.sh", "run"]

################################################################################
# End of multi-stage Dockerfile
################################################################################
