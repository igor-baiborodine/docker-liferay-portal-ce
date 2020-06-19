#!/usr/bin/env bash

set -e

usage() {
  echo "Usage: $0 -t <tag>" 1>&2
  exit 1
}

main() {
  while getopts "t:" opt; do
    case $opt in
    t)
      tag="$OPTARG"
      ;;
    *)
      usage
      ;;
    esac
  done
  echo "Starting dry run for tag: $tag ..."

  $(dirname "$0")/release-image.sh -t "$tag" -d
  commit_hash=$(uuidgen)
  $(dirname "$0")/generate-readme.sh -t "$tag" -c "$commit_hash" -d
}

main "$@"
