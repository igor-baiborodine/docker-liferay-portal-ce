#!/usr/bin/env bash

echo "Executing customized setenv.sh..."

CATALINA_OPTS="$CATALINA_OPTS -Dfile.encoding=UTF8 -Djava.net.preferIPv4Stack=true -Dorg.apache.catalina.loader.WebappClassLoader.ENABLE_CLEAR_REFERENCES=false -Duser.timezone=GMT -Xms2560m -Xmx2560m -XX:MaxNewSize=1536m -XX:MaxMetaspaceSize=384m -XX:MetaspaceSize=384m -XX:NewSize=1536m -XX:SurvivorRatio=7"
