#!/usr/bin/env bash

set -e

REPO_URL='https://github.com/igor-baiborodine/docker-liferay-portal-ce'

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

main() {
  local supported_tag="$1"
  local commit_hash="$2"
  echo "supported_tag: $supported_tag, commit_hash: $commit_hash"

  sed -i 's,'"$supported_tag"','"$supported_tag:$commit_hash"',g' ./supported-tags
  local tags_content=

  for t in $(cat ./supported-tags); do
    local tag="${t%%:*}"
    local commit="${t#*:}"
    echo "tag: $tag, commit: $commit"

    tags_content='-  [`'"${tag/\//-}"'` (*'"${tag}/Dockerfile"'*)]('"${REPO_URL}/blob/${commit}/${tag}/Dockerfile"$')\n'"$tags_content"
  done
  echo "tags_content: $tags_content"

  cat ./readme/template.md > ./README.md
  replace_field ./README.md 'TAGS' "$tags_content"
  replace_field ./README.md 'CONTENT' "$(cat "readme/content.md")"
  replace_field ./README.md 'VARIANT' "$(cat "readme/variant.md")"
  replace_field ./README.md 'LICENSE' "$(cat "readme/license.md")"
  replace_field ./README.md 'IMAGE' 'ibaiborodine/liferay-portal-ce'
}

main "$@"
