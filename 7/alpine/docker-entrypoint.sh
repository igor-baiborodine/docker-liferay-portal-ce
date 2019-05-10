#!/bin/bash
set -e

printenv

echo "
cmd: $0
args: $@
Docker user ID:$(id -u)
tomcat_version:$(cat tomcat_version)"

if [[ "$(ls -A $LIFERAY_BASE)" ]]; then
    tree --noreport "$LIFERAY_BASE"

    if [[ -d "$LIFERAY_BASE/tomcat" ]]; then
        mv "$LIFERAY_BASE/tomcat" "$LIFERAY_BASE/tomcat-$(cat tomcat_version)"
    fi
    cp -rv "$LIFERAY_BASE"/* "$LIFERAY_HOME"
else
    echo "$LIFERAY_BASE empty"
fi

if [[ "$(id -u)" = '0' ]] && [[ ( "$1" == *'catalina.sh' ) || ( "$3" == *'catalina.sh'* ) ]]; then
    chown -R liferay:liferay "$LIFERAY_HOME"
    exec su-exec liferay "$@"
fi

exec "$@"
