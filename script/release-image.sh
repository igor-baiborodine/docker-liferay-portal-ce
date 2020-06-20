#!/usr/bin/env bash

set -eo pipefail
source $(dirname "$0")/helper.sh

usage() {
  echo "Usage: $0 -t <tag> [-p <path>] [-d]" 1>&2
  exit 1
}

main() {
  dry_run=false
  work_dir="."

  while getopts "t:p:d" opt; do
    case $opt in
    t)
      new_supported_tag="$OPTARG"
      ;;
    p)
      # path to a previously downloaded Liferay bundle
      liferay_local_path="$OPTARG"
      ;;
    d)
      dry_run=true
      work_dir="dry-run"
      ;;
    *)
      usage
      ;;
    esac
  done
  echo "new_supported_tag:$new_supported_tag, dry_run:$dry_run"

  check_not_empty "$new_supported_tag" "$0[new_supported_tag]"

  if [[ -d "$new_supported_tag" && "$dry_run" == false ]]; then
    echo "Already supported tag: $new_supported_tag"
    exit 1
  fi

  version="${new_supported_tag%%/*}"
  variant="$(basename "$new_supported_tag")"
  java_variant="${variant%%-*}"
  check_not_empty "$java_variant" "$0[java_variant]"

  if [[ "$java_variant" != jdk* ]]; then
    echo "Not supported Java variant: $java_variant"
    exit 1
  fi

  os_variant="${variant#$java_variant-}"
  check_not_empty "$os_variant" "$0[os_variant]"
  partial_template="Dockerfile-${os_variant}-partial.template"

  printf "%s\n" "version: $version" \
    "variant: $variant" \
    "java_variant: $java_variant" \
    "os_variant: $os_variant" \
    "partial_template: $partial_template"

  # e.g., openjdk:8-jdk, openjdk:8-jdk-alpine, openjdk:11-jdk
  base_image="openjdk:${java_variant:3}-${java_variant:0:3}-${os_variant}"
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
  release_dir="$work_dir/$version/$variant"
  mkdir -p "$release_dir"

  if [[ -n "$liferay_local_path" ]]; then
    download_url="$liferay_local_path"
    echo "download_url: $download_url"
  fi

  cat "Dockerfile.template" >"$release_dir/Dockerfile"
  replace_field "$release_dir/Dockerfile" 'PARTIAL_TEMPLATE' "$(cat "$partial_template")"
  replace_field "$release_dir/Dockerfile" 'BASE_IMAGE' "$base_image"
  replace_field "$release_dir/Dockerfile" 'LIFERAY_VERSION' "$version"
  replace_field "$release_dir/Dockerfile" 'LIFERAY_DOWNLOAD_URL' "$download_url"
  replace_field "$release_dir/Dockerfile" 'LIFERAY_DOWNLOAD_MD5' "$md5"

  su_tool='gosu'
  if [[ ${os_variant} == alpine ]]; then
    su_tool='su-exec'
  fi

  cat docker-entrypoint.template >"$release_dir/docker-entrypoint.sh"
  replace_field "$release_dir/docker-entrypoint.sh" 'SU_TOOL' "$su_tool"
  chmod +x "$release_dir/docker-entrypoint.sh"

  travis="$(awk '/matrix:/{print;getline;$0="    - VERSION='"$version"' VARIANT='"$variant"'"}1' ./.travis.yml)"
  echo "Modifying .travis.yml with new VERSION/VARIANT[$version/$variant]..."
  echo "$travis" >"$work_dir/.travis.yml"

  if [[ -f "$work_dir/supported-tags" ]]; then
    if grep -q "$version" "$work_dir/supported-tags"; then
      echo "Found in supported-tags: release[$version]"
      echo "$new_supported_tag" >>"$work_dir/supported-tags"
    else
      echo "Not found in supported-tags: release[$version]"
      echo "$new_supported_tag" >"$work_dir/supported-tags"

      for release_dir in $(ls -d [7-9]*/); do
        if [[ ${new_supported_tag} != "$release_dir"* ]]; then
          echo "Removing directory: release[$release_dir]..."
          rm -rf "$release_dir"
        fi
      done
    fi
  else
    echo "Creating supported-tags file..."
    echo "$new_supported_tag" >"$work_dir/supported-tags"
  fi

  if [[ "$dry_run" == true ]]; then
    echo "Image release dry run completed for tag [$new_supported_tag]"
    exit 0
  fi

  git add .
  git commit -m "Add new supported tag [$new_supported_tag]"
  git push
}

main "$@"
