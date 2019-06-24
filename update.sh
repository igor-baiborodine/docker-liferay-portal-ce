#!/usr/bin/env bash
set -eo pipefail

supported_tag="$1"
echo "supported_tag: $supported_tag"

if [[ -d "$supported_tag" ]]; then
  echo "Already supported tag: $supported_tag"
  exit 1
fi

version="${supported_tag%%/*}"
variant="$(basename "$supported_tag")"
java_variant="${variant%%-*}"

if [[ "$java_variant" != jdk* ]]; then
  echo "Not supported Java variant: $java_variant"
  exit 1
fi

os_variant="${variant#$java_variant-}"

if [[ "${os_variant}" == "${java_variant}" ]] ; then
  os_variant=
fi

echo "version: $version
variant: $variant
java_variant: $java_variant
os_variant: $os_variant"

# e.g., openjdk:8-jdk, openjdk:8-jdk-alpine, openjdk:11-jdk-slim
base_image="openjdk:${java_variant:3}-${java_variant:0:3}${os_variant:+-$os_variant}"
echo "base_image: $base_image"

full_version=$(
  curl -fsSL --compressed "https://releases.liferay.com/portal/$version/" \
    | grep -E '<a href="liferay-ce-portal-tomcat-'"$version"'-[0-9]+.tar.gz.MD5' \
    | sed -r 's!.*<a href="liferay-ce-portal-tomcat-([^"/]+)/?.tar.gz.MD5".*!\1!'
)
download_url="https://releases.liferay.com/portal/$version/liferay-ce-portal-tomcat-$full_version.tar.gz"
echo "download_url: $download_url"

md5=$(
  curl -fsSL "$download_url.MD5" \
    | cut -d' ' -f1
)
echo "md5: $md5"

echo "Adding Dockerfile for $version/$variant..."
mkdir -p "$version/$variant"

sed \
  -e 's!%%BASE_IMAGE%%!'"$base_image"'!g' \
  -e 's!%%LIFERAY_VERSION%%!'"$version"'!g' \
  -e 's!%%LIFERAY_DOWNLOAD_URL%%!'"$download_url"'!g' \
  -e 's!%%LIFERAY_DOWNLOAD_MD5%%!'"$md5"'!g' \
  "Dockerfile${os_variant:+-$os_variant}.template" \
  > "$version/$variant/Dockerfile"

su_tool='gosu'
if [[ ${os_variant} == alpine ]] ; then
  su_tool='su-exec'
fi

sed \
  -e 's!%%SU_TOOL%%!'"$su_tool"'!g' \
  docker-entrypoint.template \
  > "$version/$variant/docker-entrypoint.sh"
chmod +x "$version/$variant/docker-entrypoint.sh"

travis="$(awk '/matrix:/{print;getline;$0="    - VERSION='"$version"' VARIANT='"$variant"'"}1' ./.travis.yml)"
echo "Modifying .travis.yml with new VERSION/VARIANT[$version/$variant]..."
echo "$travis" > .travis.yml

if [[ -f ./supported-tags ]]; then
  if grep -q "$version" ./supported-tags; then
    echo "Found in supported-tags: release[$version]"
    echo "$supported_tag" >> ./supported-tags
  else
    echo "Not found in supported-tags: release[$version]"
    echo "$supported_tag" > ./supported-tags

    for release_path in $(ls -d */); do
      if [[ ${supported_tag} != "$release_path"* ]]; then
        echo "Removing directory: release[$release_path]..."
        rm -rf "$release_path"
      fi
    done
  fi
else
  echo "Creating supported-tags file..."
  echo "$supported_tag" > ./supported-tags
fi

git add .
git commit -m "Add supported tag [$supported_tag]"
git push
