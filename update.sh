#!/usr/bin/env bash
set -eo pipefail

supported_tag="$1"
echo "supported_tag: $supported_tag"

if [[ -d "$supported_tag" ]]; then
  echo "Already supported tag: $supported_tag"
  exit 1
fi

version="$supported_tag"
release_version="${version%%/*}"
variant="$(basename "$version")"
java_variant="${variant%%-*}"

if [[ "$java_variant" != jdk* ]]; then
  echo "Not supported Java variant: $java_variant"
  exit 1
fi

sub_variant="${variant#$java_variant-}"

if [[ ! (${sub_variant} == alpine || ${sub_variant} == slim) ]] ; then
  echo "Not supported sub-variant: $sub_variant"
  exit 1
fi

echo "Parsed supported_tag {
  release_version: $release_version
  variant: $variant
  java_variant: $java_variant
  sub_variant: $sub_variant
}"

full_version=$(
  curl -fsSL --compressed "https://releases.liferay.com/portal/$release_version/" \
    | grep -E '<a href="liferay-ce-portal-tomcat-'"$release_version"'-[0-9]+.tar.gz.MD5' \
    | sed -r 's!.*<a href="liferay-ce-portal-tomcat-([^"/]+)/?.tar.gz.MD5".*!\1!'
)
download_url="https://releases.liferay.com/portal/$release_version/liferay-ce-portal-tomcat-$full_version.tar.gz"
echo "download_url: $download_url"

md5=$(
  curl -fsSL "$download_url.MD5" \
    | cut -d' ' -f1
)
echo "md5: $md5"

echo "Adding Dockerfile for $release_version/$variant"
mkdir -p "$release_version/$variant"

base_image="openjdk:${java_variant:3}-${java_variant:0:3}${sub_variant:+-$sub_variant}" # ":8-jdk-alpine", ":11-jdk-slim"
echo "base_image:$base_image"

sed \
  -e 's!%%BASE_IMAGE%%!'"$base_image"'!g' \
  -e 's!%%LIFERAY_PORTAL_CE_DOWNLOAD_URL%%!'"$download_url"'!g' \
  -e 's!%%LIFERAY_PORTAL_CE_VERSION%%!'"$release_version"'!g' \
  -e 's!%%LIFERAY_PORTAL_CE_MD5%%!'"$md5"'!g' \
  "Dockerfile${sub_variant:+-$sub_variant}.template" \
  > "$release_version/$variant/Dockerfile"

cp -a docker-entrypoint.sh "$release_version/$variant/"

travis="$(awk '/matrix:/{print;getline;$0="    - VERSION='"$release_version"' VARIANT='"$variant"'"}1' ./.travis.yml)"
echo "Modifying .travis.yml with new VERSION-VARIANT[$release_version-$variant]"
echo "$travis" > .travis.yml

if [[ -f ./supported-tags ]]; then
  if grep -q "$release_version" ./supported-tags; then
    echo "Found in supported-tags: release[$release_version]"
    echo "$supported_tag" >> ./supported-tags
  else
    echo "Not found in supported-tags: release[$release_version]"
    echo "$supported_tag" > ./supported-tags

    for release_path in $(ls -d */); do
      if [[ ${supported_tag} != "$release_path"* ]]; then
        echo "Removing directory: release[$release_path]"
        rm -rf "$release_path"
      fi
    done
  fi
else
  echo "Creating supported-tags file"
  echo "$supported_tag" > ./supported-tags
fi

#  git add .
#  git commit -m "Add supported tag [$supported_tag]"
#  git push
