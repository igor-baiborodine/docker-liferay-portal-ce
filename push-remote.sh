#!/usr/bin/env bash

main() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"

  git clone "https://github.com/igor-baiborodine/$REPO.git" "~/$REPO"
  cp README.md supported-tags "~/$REPO"

  cd "~/$REPO"
  git add README.md supported-tags

  git status
  git commit -m "$TRAVIS_COMMIT_MESSAGE [skip travis]"
  git push "https://${TRAVIS_GITHUB_TOKEN}@github.com/igor-baiborodine/${REPO}" master  > /dev/null 2>&1
}

main "$@"
