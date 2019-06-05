#!/bin/bash
set -eo pipefail

versions=( "$@" )
if [[ ${#versions[@]} -eq 0 ]]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

echo "versions: $versions" # e.g. '7.1.2-ga3/8u212-jdk-alpine3.9'

for version in "${versions[@]}"; do
	majorVersion="${version%%.*}"
	releaseVersion="${version%%/*}"
    echo "majorVersion:$majorVersion, releaseVersion:$releaseVersion"

	fullVersion="$(
		curl -fsSL --compressed "https://releases.liferay.com/portal/$releaseVersion/" \
			| grep -E '<a href="liferay-ce-portal-tomcat-'"$releaseVersion"'-[0-9]+.tar.gz.MD5' \
			| sed -r 's!.*<a href="liferay-ce-portal-tomcat-([^"/]+)/?.tar.gz".*!\1!'
	)"
	echo "fullVersion:$fullVersion"

	variant="$(basename "$version")"
	javaVariant="${variant%%-*}"
	echo "variant:$variant, javaVariant:$javaVariant"

done
