#!/usr/bin/env bash

set -eo pipefail
source $(dirname "$0")/helper.sh

main() {
  dry_run=false
  work_dir="."
  github_repo_url='https://github.com/igor-baiborodine/docker-liferay-portal-ce'

  while getopts "t:c:d" opt; do
    case $opt in
    t)
      supported_tag="$OPTARG"
      ;;
    c)
      commit_hash="$OPTARG"
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

  echo "supported_tag: $supported_tag, commit_hash: $commit_hash, dry_run: $dry_run"

  check_not_empty "$supported_tag" "$0:supported_tag"
  check_not_empty "$commit_hash" "$0:commit_hash"

  sed -i 's,^\b'"$supported_tag"'\b$,'"$supported_tag:$commit_hash"',' "$work_dir/supported-tags"
  tags_content=

  while IFS= read -r line; do
    tag="${line%%:*}"
    commit="${line#*:}"
    echo "tag: $tag, commit: $commit"

    tags_content='-  [`'"${tag/\//-}"'` (*'"${tag}/Dockerfile"'*)]('"${github_repo_url}/blob/${commit}/${tag}/Dockerfile"$')\n'"$tags_content"
  done <"$work_dir/supported-tags"

  echo "tags_content: $tags_content"

  cat "$PWD/readme/template.md" >"$work_dir/README.md"
  replace_field "$work_dir/README.md" 'TAGS' "$tags_content"
  replace_field "$work_dir/README.md" 'CONTENT' "$(cat "./readme/content.md")"
  replace_field "$work_dir/README.md" 'VARIANT' "$(cat "./readme/variant.md")"
  replace_field "$work_dir/README.md" 'LICENSE' "$(cat "./readme/license.md")"
  replace_field "$work_dir/README.md" 'IMAGE' 'ibaiborodine/liferay-portal-ce'

  if [[ "$dry_run" == true ]]; then
    echo "README generation dry run completed for tag [$supported_tag]"
  fi
}

main "$@"
