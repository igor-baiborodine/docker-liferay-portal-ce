#!/usr/bin/env bash

set -e
source $(dirname "$0")/helper.sh

usage() {
  echo "Usage: $0 -t <tag> -u <use-case> [-v <volume-dir>] [-r <run-mode>]" 1>&2
  exit 1
}

main() {
  liferay_home=/opt/liferay
  liferay_base=/etc/opt/liferay
  liferay_init=/docker-entrypoint-initliferay.d

  # run by default container in detached mode
  run_mode='-d'

  while getopts "t:u:v:r:h" opt; do
    case $opt in
    t)
      tag="$OPTARG"
      ;;
    u)
      use_case="$OPTARG"
      ;;
    v)
      volume_dir="$OPTARG"
      ;;
    r)
      run_mode="$OPTARG"
      ;;
    h)
      usage
      ;;
    *)
      usage
      ;;
    esac
  done
  echo "use_case:$use_case, tag:$tag, run_mode:$run_mode, volume_dir: $volume_dir"

  base_cmd="docker run run_mode_option --name test-$use_case -p 80:8080 options $tag"
  base_cmd="${base_cmd/run_mode_option/$run_mode}"
  echo "base_cmd:$base_cmd"

  if [[ "$use_case" == 'base' ]]; then
    eval "${base_cmd/options/}"
  fi

  if [[ "$use_case" == 'env-var' ]]; then
    eval "${base_cmd/options/'--env LIFERAY_SETUP_PERIOD_WIZARD_PERIOD_ENABLED=false'}"
  fi

  if [[ "$use_case" == 'jpda' ]]; then
    base_cmd="${base_cmd/options/} catalina.sh jpda run"
    eval "$base_cmd"
  fi

  if [[ "$use_case" == 'healthcheck' ]]; then
    health_options="--health-cmd='curl -fsS \"http://localhost:8080/c/portal/layout\" || exit 1' --health-start-period=1m --health-interval=30s --health-retries=5"
    eval "${base_cmd/options/$health_options}"
  fi

  if [[ "$use_case" == 'tomcat-version' ]]; then
    eval "docker run --rm -it $tag version.sh | grep 'Server version'"
    exit 0
  fi

  if [[ "$use_case" == 'extended' ]]; then
    dockerfile=$(cat volume/my/own/extended-dockerfile/Dockerfile)
    dockerfile=${dockerfile/tag/$tag}
    echo "$dockerfile" | docker build -t test-extended-image -
    base_cmd=${base_cmd%options*}
    eval "$base_cmd test-extended-image"
  fi

  if [[ "$use_case" == 'deploy' ]]; then
    check_not_empty "$volume_dir" "$0[$use_case][volume_dir]"
    mkdir -p "$volume_dir/my/own/deploydir"
    volume_option="-v $volume_dir/my/own/deploydir:$liferay_home/deploy"
    eval "${base_cmd/options/$volume_option}"
  fi

  if [[ "$use_case" == 'document-library' ]]; then
    check_not_empty "$volume_dir" "$0[$use_case][volume_dir]"
    mkdir -p "$volume_dir/my/own/datadir"
    volume_option="-v $volume_dir/my/own/datadir:$liferay_home/data/document_library"
    eval "${base_cmd/options/$volume_option}"
  fi

  # test copying portal-ext.properties and tomcat/bin/setenv.sh
  if [[ "$use_case" == 'liferay-base' ]]; then
    check_not_empty "$volume_dir" "$0[$use_case][volume_dir]"
    mkdir -p "$volume_dir/my/own/liferaybasedir"
    volume_option="-v $volume_dir/my/own/liferaybasedir:$liferay_base"
    eval "${base_cmd/options/$volume_option}"
  fi

  if [[ "$use_case" == 'liferay-init' ]]; then
    check_not_empty "$volume_dir" "$0[$use_case][volume_dir]"
    mkdir -p "$volume_dir/my/own/liferayinitdir"
    volume_option="-v $volume_dir/my/own/liferayinitdir:$liferay_init"
    eval "${base_cmd/options/$volume_option}"
  fi

  echo "Container test-$use_case is running..."
}

main "$@"
