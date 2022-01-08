################################################################################
# This Dockerfile was generated from the template at ../../Dockerfile.template
#
# Beginning of multi-stage Dockerfile
#
# Build stage 0: builder
################################################################################
FROM openjdk:8-jdk-alpine AS builder

ENV LIFERAY_DOWNLOAD_URL https://releases.liferay.com/portal/7.4.3.6-ga6/liferay-ce-portal-tomcat-7.4.3.6-ga6-20211227141428520.tar.gz
ENV LIFERAY_DOWNLOAD_MD5 a932673ee3297079b55c33cf1efd578f

ADD "$LIFERAY_DOWNLOAD_URL" /tmp/liferay-bundle.tar.gz

RUN set -eux; \
    echo "$LIFERAY_DOWNLOAD_MD5  /tmp/liferay-bundle.tar.gz" | md5sum -c -; \
    mkdir /tmp/liferay-bundle; \
    tar -zxf /tmp/liferay-bundle.tar.gz -C /tmp/liferay-bundle --strip-components=1

################################################################################
# Build stage 1: the actual liferay-portal-ce image
################################################################################
FROM openjdk:8-jdk-alpine

LABEL \
    maintainer="Igor Baiborodine <igor@kiroule.com>" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="liferay-portal-ce" \
    org.label-schema.vcs-url="https://github.com/igor-baiborodine/docker-liferay-portal-ce" \
    org.label-schema.usage="https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/master/README.md"

ENV LIFERAY_VERSION 7.4.3.6-ga6
ENV LIFERAY_HOME /opt/liferay
ENV LIFERAY_BASE /etc/opt/liferay
ENV LIFERAY_INIT /docker-entrypoint-initliferay.d
ENV PATH ${LIFERAY_HOME}/tomcat/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}
ENV TOMCAT_NATIVE_VERSION 1.2.26

RUN addgroup liferay && adduser -D -G liferay liferay

RUN set -ex; \
    apk add --no-cache \
    # su tool for easy step-down from root
    'su-exec>=0.2' \
    # Font family based on the Bitstream Vera Fonts with a wider range of characters
    ttf-dejavu \
    bash; \
    # Tomcat native library using the Apache Portable Runtime
    wget http://dl-cdn.alpinelinux.org/alpine/v3.12/community/x86_64/tomcat-native-${TOMCAT_NATIVE_VERSION}-r0.apk; \
    apk add --allow-untrusted tomcat-native-${TOMCAT_NATIVE_VERSION}-r0.apk

COPY --from=builder --chown=liferay:liferay /tmp/liferay-bundle ${LIFERAY_HOME}

RUN set -eux; \
    path=$(find "$(cd ..; pwd)" -name "catalina.sh"); \
    ln -s "${path%%/bin*}" "$LIFERAY_HOME/tomcat"; \
    mkdir -p "$LIFERAY_BASE" "$LIFERAY_INIT"; \
    chown -R liferay:liferay "$LIFERAY_BASE" "$LIFERAY_INIT"

RUN set -e; \
    native_lines="$(catalina.sh configtest 2>&1)"; \
    native_lines="$(echo "$native_lines" | grep 'Apache Tomcat Native')"; \
    native_lines="$(echo "$native_lines" | sort -u)"; \
    if ! echo "$native_lines" | grep "INFO: Loaded Apache Tomcat Native library" >&2; then \
        echo >&2 "$native_lines"; \
        exit 1; \
    fi

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
