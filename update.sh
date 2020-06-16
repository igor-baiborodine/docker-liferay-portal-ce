#!/usr/bin/env bash
set -eo pipefail

replace_field() {
  local target_file="$1"
  local field="$2"
  local content="$3"

  local extra_sed="${4:-}"
  local sed_escaped_value
  sed_escaped_value="$(echo "$content" | sed 's/[\/&]/\\&/g')"
  sed_escaped_value="${sed_escaped_value//$'\n'/\\n}"
  sed -ri -e "s/${extra_sed}%%${field}%%${extra_sed}/$sed_escaped_value/g" "$target_file"
}

dry_run=false
usage() { echo "Usage: $0 -t <tag> [-p <path>] [-d]" 1>&2; exit 1; }

while getopts "dt:p:" opt; do
  case $opt in
  d)
    dry_run=true
    dry_run_dir=dry-run
    ;;
  t)
    new_supported_tag="$OPTARG"
    ;;
  p)
    # path to a previously downloaded Liferay bundle
    liferay_local_path="$OPTARG"
    ;;
  *)
    usage
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
partial_template="Dockerfile-${os_variant}-partial.template"

if [[ "${os_variant}" == "${java_variant}" ]]; then
  os_variant=
  partial_template='Dockerfile-partial.template'
fi

echo "version: $version
variant: $variant
java_variant: $java_variant
os_variant: $os_variant
partial_template: $partial_template"

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

if [[ -n "$liferay_local_path" ]]; then
  download_url="$liferay_local_path"
  echo "download_url: $download_url"
fi

cat "Dockerfile.template" > "$release_dir/Dockerfile"
replace_field "$release_dir/Dockerfile" 'PARTIAL_TEMPLATE' "$(cat "$partial_template")"
replace_field "$release_dir/Dockerfile" 'BASE_IMAGE' "$base_image"
replace_field "$release_dir/Dockerfile" 'LIFERAY_VERSION' "$version"
replace_field "$release_dir/Dockerfile" 'LIFERAY_DOWNLOAD_URL' "$download_url"
replace_field "$release_dir/Dockerfile" 'LIFERAY_DOWNLOAD_MD5' "$md5"

su_tool=gosu
if [[ ${os_variant} == alpine ]]; then
  su_tool=su-exec
fi

cat docker-entrypoint.template > "$release_dir/docker-entrypoint.sh"
replace_field "$release_dir/docker-entrypoint.sh" 'SU_TOOL' "$su_tool"
chmod +x "$release_dir/docker-entrypoint.sh"

travis="$(awk '/matrix:/{print;getline;$0="    - VERSION='"$version"' VARIANT='"$variant"'"}1' ./.travis.yml)"
echo "Modifying .travis.yml with new VERSION/VARIANT[$version/$variant]..."

if [[ "$dry_run" == true ]]; then
  echo "$travis" > "$release_dir/.travis.yml"
  echo "Dry run completed"
  exit 0
fi
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
