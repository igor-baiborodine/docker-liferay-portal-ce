################################################################################
# This Dockerfile was generated from the template at ../../Dockerfile-alpine.template
#
# Beginning of multi-stage Dockerfile
################################################################################

################################################################################
# Beginning of multi-stage Dockerfile
#
# Build stage 0: builder
################################################################################

#FROM openjdk:placeholder AS builder
FROM openjdk:8u201-jdk-alpine3.9 AS builder

#ENV LIFERAY_PORTAL_CE_TOMCAT_DOWNLOAD_URL=placeholder
ENV LIFERAY_PORTAL_CE_BUNDLE_DOWNLOAD_URL=https://releases.liferay.com/portal/7.1.2-ga3/liferay-ce-portal-tomcat-7.1.2-ga3-20190107144105508.tar.gz

# to be removed
COPY liferay-portal-ce-bundle.tar.gz .

RUN set -ex; \
    #wget -O liferay-portal-ce-bundle.tar.gz "$LIFERAY_PORTAL_CE_BUNDLE_DOWNLOAD_URL"; \
    mkdir /liferay-portal-ce-bundle; \
    tar -zxf liferay-portal-ce-bundle.tar.gz -C /liferay-portal-ce-bundle --strip-components=1; \
    rm liferay-portal-ce-bundle.tar.gz

################################################################################
# Build stage 1: the actual liferay-portal-ce image
################################################################################
FROM openjdk:8u201-jdk-alpine3.9

RUN adduser -D liferay && addgroup liferay liferay

RUN apk add --no-cache \
# su-exec for easy step-down from root
    'su-exec>=0.2' \
    tomcat-native \
    ttf-dejavu \
    tree \
    bash

#ENV LIFERAY_PORTAL_CE_VERSION=placeholder
ENV LIFERAY_PORTAL_CE_VERSION=7.1.2-ga3
ENV LIFERAY_HOME=/opt/liferay
ENV LIFERAY_BASE=/etc/opt/liferay
# override default portal.properties
ENV LIFERAY_SETUP_PERIOD_WIZARD_PERIOD_ENABLED=false
ENV LIFERAY_TERMS_PERIOD_OF_PERIOD_USE_PERIOD_REQUIRED=false
ENV LIFERAY_USERS_PERIOD_REMINDER_PERIOD_QUERIES_PERIOD_ENABLE=false

COPY --from=builder --chown=liferay:liferay /liferay-portal-ce-bundle ${LIFERAY_HOME}

RUN set -ex; \
    mkdir -p "$LIFERAY_BASE"; \
    ls "$LIFERAY_HOME" | grep tomcat | sed 's/.*-//' > "$LIFERAY_HOME/tomcat_version"; \
    ln -s "$LIFERAY_HOME"/tomcat-$(cat "$LIFERAY_HOME"/tomcat_version) "$LIFERAY_HOME/tomcat"; \
    chown -R liferay:liferay "$LIFERAY_BASE";

LABEL \
    maintainer="Igor Baiborodine <ibaiborodine@gmail.com>" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="liferay-portal-ce" \
    org.label-schema.version="${LIFERAY_PORTAL_CE_VERSION}" \
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
CMD ["bash", "-c", "$LIFERAY_HOME/tomcat/bin/catalina.sh run"]

################################################################################
# End of multi-stage Dockerfile
################################################################################
