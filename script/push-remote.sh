#!/usr/bin/env bash

set -e

main() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"

  git clone "https://github.com/$TRAVIS_REPO_SLUG.git" "~/build/$TRAVIS_REPO_SLUG"
  cp ./README.md ./supported-tags "~/build/$TRAVIS_REPO_SLUG"

  cd "~/build/$TRAVIS_REPO_SLUG"
  git add ./README.md ./supported-tags

  git status
  git commit -m "$TRAVIS_COMMIT_MESSAGE [skip travis]"
  git push "https://$TRAVIS_GITHUB_TOKEN@github.com/$TRAVIS_REPO_SLUG" master  > /dev/null 2>&1
}

main "$@"
