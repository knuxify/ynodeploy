#!/bin/sh

if [ ! -d scripts ]; then
	echo "Please run this script from the base ynodeploy directory"
	exit 1
fi

# Check if dependencies are present
for dep in git docker python3; do
	if not which "$dep" &>/dev/null; then
		echo "$dep is not installed! Please get it from your distribution's package manager."
		exit 1
	fi
done

# Begin cloning repositories
for repo in ynobadges ynohome ynolocations ynopreloads \
			ynorankings ynoserver ynotranslations forest-orb \
			ynoengine
do
	[ -d repos/"$repo" ] && continue
	echo "Cloning ynoproject/$repo..."
	git clone https://github.com/ynoproject/"$repo" repos/"$repo"
done

if [ ! -d repos/easyrpg_buildscripts ]; then
	echo "Cloning EasyRPG/buildscripts..."
	git clone https://github.com/EasyRPG/buildscripts repos/easyrpg_buildscripts
fi

if [ ! -d repos/liblcf ]; then
	echo "Cloning EasyRPG/liblcf..."
	git clone https://github.com/EasyRPG/Tools repos/liblcf
fi

# Apply buildscript patches
echo "Applying buildscript patches..."
./engine/prepare.sh

# Change ynoproject.net to yno.local
echo "Replacing ynoproject.net with yno.local..."
./scripts/change-domain.sh ynoproject.net yno.local http

# Apply ynorankings patch for custom DB credentials
echo "Applying ynorankings patch"
cd repos/ynorankings
# https://github.com/ynoproject/ynorankings/pull/5
wget https://github.com/knuxify/minnarankings/commit/c9fe47ec75c81218ff0ba0e5f0e17be9f434feee.patch
git apply c9fe47ec75c81218ff0ba0e5f0e17be9f434feee.patch
rm c9fe47ec75c81218ff0ba0e5f0e17be9f434feee.patch
cd ../..

# Badge data path fixup
echo "ynobadges: Applying fix for badge data path..."
cd repos/ynobadges
ln -s badges data
cd ../..

# Create dummy word filter (otherwise chat is broken)
echo "ynoserver: Creating dummy word filter lists (filterwords.txt)..."
touch repos/ynoserver/filterwords.txt

# Generate key.bin (needed by ynoserver)
echo "Generating key.bin and key.txt..."
python3 scripts/generate_key.py

# Prepare engine
echo "Preparing engine build..."
cd engine
./prepare.sh
cd ..

echo "Setting key in engine..."
sed -i "s/^const unsigned char psk\[\] \= .*/const unsigned char psk\[\] \= \{ $(cat key.txt) \};/" repos/ynoengine/src/multiplayer/yno_connection.cpp

# Copy example configs to target locations
echo "Copying example configs to target locations..."
cp docker-compose.yml.example docker-compose.yml
cp nginx.conf.example nginx.conf
cp configs/rankings.yml.example configs/rankings.yml

echo "All done!"
echo "Add games by running:"
echo ""
echo "  ./scripts/add-game.sh gamename path/to/game/files"
echo ""
echo "See README.md for more information."
