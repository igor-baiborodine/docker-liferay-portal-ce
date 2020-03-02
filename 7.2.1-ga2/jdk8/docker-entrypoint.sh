#!/usr/bin/env bash
set -e

if [ "$(ls -A $LIFERAY_BASE)" ]; then
  if [ -d "$LIFERAY_BASE/tomcat" ]; then
    path="$(readlink -f $LIFERAY_HOME/tomcat)"
    mv "$LIFERAY_BASE/tomcat" "$LIFERAY_BASE/$(basename $path)"
  fi
  cp -rv "$LIFERAY_BASE"/* "$LIFERAY_HOME"
fi

for f in "$LIFERAY_INIT"/*; do
  case "$f" in
    *.sh) . "$f" ;;
  esac
done

if [ "$1" = 'catalina.sh' -a "$(id -u)" = '0' ]; then
  chown -R liferay:liferay "$LIFERAY_HOME"
  exec gosu liferay "$@"
fi

exec "$@"

