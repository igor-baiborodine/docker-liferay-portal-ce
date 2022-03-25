################################################################################
# This Dockerfile was generated from the template at ../../Dockerfile.template
#
# Beginning of multi-stage Dockerfile
#
# Build stage 0: builder
################################################################################
FROM openjdk:11-jdk-bullseye AS builder

ENV LIFERAY_DOWNLOAD_URL https://releases.liferay.com/portal/7.4.3.17-ga17/liferay-ce-portal-tomcat-7.4.3.17-ga17-20220322082755437.tar.gz
ENV LIFERAY_DOWNLOAD_MD5 47ed5eb294b83783c2d519120147ea99

ADD "$LIFERAY_DOWNLOAD_URL" /tmp/liferay-bundle.tar.gz

RUN set -eux; \
    echo "$LIFERAY_DOWNLOAD_MD5  /tmp/liferay-bundle.tar.gz" | md5sum -c -; \
    mkdir /tmp/liferay-bundle; \
    tar -zxf /tmp/liferay-bundle.tar.gz -C /tmp/liferay-bundle --strip-components=1

################################################################################
# Build stage 1: the actual liferay-portal-ce image
################################################################################
FROM openjdk:11-jdk-bullseye

LABEL \
    maintainer="Igor Baiborodine <igor@kiroule.com>" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="liferay-portal-ce" \
    org.label-schema.vcs-url="https://github.com/igor-baiborodine/docker-liferay-portal-ce" \
    org.label-schema.usage="https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/master/README.md"

ENV LIFERAY_VERSION 7.4.3.17-ga17
ENV LIFERAY_HOME /opt/liferay
ENV LIFERAY_BASE /etc/opt/liferay
ENV LIFERAY_INIT /docker-entrypoint-initliferay.d
ENV PATH ${LIFERAY_HOME}/tomcat/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}
ENV TOMCAT_NATIVE_VERSION 1.2.31

RUN groupadd liferay && useradd -g liferay liferay

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # su tool for easy step-down from root
        gosu \
        # Font family based on the Bitstream Vera Fonts with a wider range of characters
        fonts-dejavu; \
    rm -rf /var/lib/apt/lists/*; \
    gosu nobody true; \
    wget -O libtcnative-1.deb "http://ftp.us.debian.org/debian/pool/main/t/tomcat-native/libtcnative-1_${TOMCAT_NATIVE_VERSION}-1_amd64.deb" -q --show-progress --progress=bar:force 2>&1; \
    dpkg -i libtcnative-1.deb; \
    rm libtcnative-1.deb

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
