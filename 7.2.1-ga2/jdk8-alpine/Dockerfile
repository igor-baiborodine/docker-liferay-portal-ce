################################################################################
# This Dockerfile was generated from the template at ../../Dockerfile-alpine.template
#
# Beginning of multi-stage Dockerfile
#
# Build stage 0: builder
################################################################################
FROM openjdk:8-jdk-alpine AS builder

ENV LIFERAY_DOWNLOAD_URL https://releases.liferay.com/portal/7.2.1-ga2/liferay-ce-portal-tomcat-7.2.1-ga2-20191111141448326.tar.gz
ENV LIFERAY_DOWNLOAD_MD5 ce6baa9ae3590df46760443e80c09831

RUN set -ex; \
    wget -O liferay-bundle.tar.gz "$LIFERAY_DOWNLOAD_URL"; \
    echo "$LIFERAY_DOWNLOAD_MD5  liferay-bundle.tar.gz" | md5sum -c -; \
    mkdir /tmp/liferay-bundle; \
    tar -zxf liferay-bundle.tar.gz -C /tmp/liferay-bundle --strip-components=1

################################################################################
# Build stage 1: the actual liferay-portal-ce image
################################################################################
FROM openjdk:8-jdk-alpine

RUN addgroup liferay && adduser -D -G liferay liferay

RUN set -ex; \
    apk add --no-cache \
    # su tool for easy step-down from root
    'su-exec>=0.2' \
    # Tomcat native library using the Apache Portable Runtime
    tomcat-native \
    # Font family based on the Bitstream Vera Fonts with a wider range of characters
    ttf-dejavu \
    bash

ENV LIFERAY_VERSION 7.2.1-ga2
ENV LIFERAY_HOME /opt/liferay
ENV LIFERAY_BASE /etc/opt/liferay
ENV LIFERAY_INIT /docker-entrypoint-initliferay.d
ENV PATH ${LIFERAY_HOME}/tomcat/bin:${PATH}

COPY --from=builder --chown=liferay:liferay /tmp/liferay-bundle ${LIFERAY_HOME}

RUN set -ex \
    && path=$(find "$(cd ..; pwd)" -name "catalina.sh") \
    && ln -s "${path%%/bin*}" "$LIFERAY_HOME/tomcat" \
    && mkdir -p "$LIFERAY_BASE" "$LIFERAY_INIT"\
    && chown -R liferay:liferay "$LIFERAY_BASE" "$LIFERAY_INIT"

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
