################################################################################
# This Dockerfile was generated from the template at ./Dockerfile-alpine.template
################################################################################

#FROM openjdk:placeholder
FROM openjdk:8u201-jdk-alpine3.9

RUN adduser -D liferay && addgroup liferay liferay

RUN apk add --no-cache \
# su-exec for easy step-down from root
    'su-exec>=0.2' \
    tree \
    tomcat-native \
    ttf-dejavu \
    bash

#ENV LIFERAY_PORTAL_CE_VERSION=placeholder
ENV LIFERAY_PORTAL_CE_VERSION=7.1.2-ga3
#ENV LIFERAY_PORTAL_CE_TOMCAT_DOWNLOAD_URL=placeholder
ENV LIFERAY_PORTAL_CE_DOWNLOAD_URL=https://releases.liferay.com/portal/7.1.2-ga3/liferay-ce-portal-tomcat-7.1.2-ga3-20190107144105508.tar.gz
ENV LIFERAY_HOME=/opt/liferay
ENV LIFERAY_BASE=/etc/opt/liferay

# override default portal.properties
ENV LIFERAY_SETUP_PERIOD_WIZARD_PERIOD_ENABLED=false
ENV LIFERAY_TERMS_PERIOD_OF_PERIOD_USE_PERIOD_REQUIRED=false
ENV LIFERAY_USERS_PERIOD_REMINDER_PERIOD_QUERIES_PERIOD_ENABLE=false

# to be removed
COPY liferay-portal-ce.tar.gz .

RUN set -ex; \
    #wget -O liferay-portal-ce.tar.gz "$LIFERAY_PORTAL_CE_DOWNLOAD_URL"; \
    mkdir -p "$LIFERAY_HOME" "$LIFERAY_BASE"; \
    tar -zxf liferay-portal-ce.tar.gz -C "$LIFERAY_HOME" --strip-components=1; \
    ls "$LIFERAY_HOME" | grep tomcat | sed 's/.*-//' > "$LIFERAY_HOME/tomcat_version"; \
    ln -s "$LIFERAY_HOME"/tomcat-$(cat "$LIFERAY_HOME"/tomcat_version) "$LIFERAY_HOME/tomcat"; \
    chown -R liferay:liferay "$LIFERAY_HOME" "$LIFERAY_BASE"; \
    rm liferay-portal-ce.tar.gz

LABEL maintainer="Igor Baiborodine <ibaiborodine@gmail.com>" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="liferay-portal-ce" \
    org.label-schema.version="${LIFERAY_PORTAL_CE_VERSION}" \
    org.label-schema.vcs-url="https://github.com/igor-baiborodine/docker-liferay-portal-ce" \
    org.label-schema.usage="https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/master/README.md"

VOLUME ${LIFERAY_HOME}/data/document_library \
    ${LIFERAY_HOME}/deploy \
    ${LIFERAY_BASE}

WORKDIR ${LIFERAY_HOME}

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080 11311
CMD ["bash", "-c", "$LIFERAY_HOME/tomcat/bin/catalina.sh run"]
