#!/bin/sh

# update-repos.sh - update all repositories

if [ ! -d repos ]; then
	echo "Please run this script from the base ynodeploy directory."
	exit 1
fi

for repo in "$(pwd)"/repos/*; do
	echo "Pulling $(basename $repo)..."
	cd "$repo"
	git pull
	echo ""
done
