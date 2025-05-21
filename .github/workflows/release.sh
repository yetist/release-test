#!/usr/bin/bash

######################################################################
# @author      : yetist (yetist@gmail.com)
# @file        : release
# @created     : 星期三 5月 21, 2025 22:19:40 CST
#
# @description :
######################################################################

set -ex
set -o pipefail

echo $GITHUB_TOKEN
GITHUB_REF_NAME=v1.28.0
GITHUB_REPOSITORY=yetist/release-test

#old_tag=$(gh release ls -L 1 --json tagName --jq '.[0].tagName')
old_tag=v1.27.1
old_version=${old_tag:1}
new_tag=${GITHUB_REF_NAME}
new_version=${new_tag:1}
repo_name=${GITHUB_REPOSITORY#*/}

# generate the release_note file
header="Changes since the last release: https://github.com/${GITHUB_REPOSITORY}/compare/${old_tag}...${new_tag}"
echo -e "${header}\n\n" >release_note
cat NEWS >>release_note
sed -i '/^###.*'${old_version}'/,$d' release_note

# release file
title="${repo_name} ${new_version} release"
if [ -d _build/meson-dist/ ]; then
	gh release create ${new_tag} --title "${title}" -F release_note _build/meson-dist/*
else
	# create sha256sum for autotools
	for i in *.tar.xz; do sha256sum $i >$i.sha256sum; done
	gh release create ${new_tag} --title "${title}" -F release_note ${repo_name}-*.tar.xz*
fi

# Notify the release server
# TODO:
