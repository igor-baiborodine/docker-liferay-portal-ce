#!/usr/bin/env bash
set -eo pipefail

dry_run=false

while getopts ":t:d" opt; do
  case $opt in
  t)
    new_supported_tag="$OPTARG"
    ;;
  d)
    dry_run=true
    dry_run_dir=dry-run
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    ;;
  esac
done
echo "new_supported_tag:$new_supported_tag, dry_run:$dry_run"

if [[ -d "$new_supported_tag" && "$dry_run" == false ]]; then
  echo "Already supported tag: $new_supported_tag"
  exit 1
fi

version="${new_supported_tag%%/*}"
variant="$(basename "$new_supported_tag")"
java_variant="${variant%%-*}"

if [[ "$java_variant" != jdk* ]]; then
  echo "Not supported Java variant: $java_variant"
  exit 1
fi

os_variant="${variant#$java_variant-}"

if [[ "${os_variant}" == "${java_variant}" ]]; then
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
  curl -fsSL --compressed "https://releases.liferay.com/portal/$version/" |
    grep -E '<a href="liferay-ce-portal-tomcat-'"$version"'-[0-9]+.tar.gz.MD5' |
    sed -r 's!.*<a href="liferay-ce-portal-tomcat-([^"/]+)/?.tar.gz.MD5".*!\1!'
)
download_url="https://releases.liferay.com/portal/$version/liferay-ce-portal-tomcat-$full_version.tar.gz"
echo "download_url: $download_url"

md5=$(
  curl -fsSL "$download_url.MD5" |
    cut -d' ' -f1
)
echo "md5: $md5"

echo "Adding Dockerfile for $version/$variant..."
release_dir="$version/$variant"
if [[ "$dry_run" == true ]]; then
  release_dir="$dry_run_dir/$release_dir"
fi
mkdir -p "$release_dir"

sed \
  -e 's!%%BASE_IMAGE%%!'"$base_image"'!g' \
  -e 's!%%LIFERAY_VERSION%%!'"$version"'!g' \
  -e 's!%%LIFERAY_DOWNLOAD_URL%%!'"$download_url"'!g' \
  -e 's!%%LIFERAY_DOWNLOAD_MD5%%!'"$md5"'!g' \
  "Dockerfile${os_variant:+-$os_variant}.template" \
  > "$release_dir/Dockerfile"

su_tool=gosu
if [[ ${os_variant} == alpine ]]; then
  su_tool=su-exec
fi

sed \
  -e 's!%%SU_TOOL%%!'"$su_tool"'!g' \
  docker-entrypoint.template \
  > "$release_dir/docker-entrypoint.sh"
chmod +x "$release_dir/docker-entrypoint.sh"

if [[ "$dry_run" == true ]]; then
  echo "Dry run completed"
  exit 0
fi

travis="$(awk '/matrix:/{print;getline;$0="    - VERSION='"$version"' VARIANT='"$variant"'"}1' ./.travis.yml)"
echo "Modifying .travis.yml with new VERSION/VARIANT[$version/$variant]..."
echo "$travis" >.travis.yml

if [[ -f ./supported-tags ]]; then
  if grep -q "$version" ./supported-tags; then
    echo "Found in supported-tags: release[$version]"
    echo "$new_supported_tag" >>./supported-tags
  else
    echo "Not found in supported-tags: release[$version]"
    echo "$new_supported_tag" >./supported-tags

    for release_dir in $(ls -d [7-9]*/); do
      if [[ ${new_supported_tag} != "$release_dir"* ]]; then
        echo "Removing directory: release[$release_dir]..."
        rm -rf "$release_dir"
      fi
    done
  fi
else
  echo "Creating supported-tags file..."
  echo "$new_supported_tag" >./supported-tags
fi

git add .
git commit -m "Add new supported tag [$new_supported_tag]"
git push
