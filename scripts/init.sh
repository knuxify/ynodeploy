#!/bin/sh

# Check if dependencies are present
for dep in git docker; do
	if not which "$dep" &>/dev/null; then
		echo "$dep is not installed! Please get it from your distribution's package manager."
		exit 1
	fi
done

# Begin cloning repositories
for repo in ynobadges ynohome ynolocations ynopreloads \
			ynorankings ynoserver ynotranslations forest-orb
do
	[ -d repos/"$repo" ] && continue
	echo "Cloning $repo..."
	git clone https://github.com/ynoproject/"$repo" repos/"$repo"
done

# Change ynoproject.net to yno.local
echo "Replacing ynoproject.net with yno.local..."
for repo in ynohome ynoserver forest-orb; do
	find repos/$repo -type f \( -name *.js -o -name *.go -o -name *.html -o -name *.php \) -exec \
		sed -i -e 's/ynoproject\.net/yno\.local/g' \
			   -e 's/https\:\/\/yno.local/http\:\/\/yno.local/g' \
			   -e 's/https\:\/\/connect.yno.local/http\:\/\/connect.yno.local/g' \
			   -e 's/wss\:\/\/connect.yno.local/ws\:\/\/connect.yno.local/g' {} +
done

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
echo "Setting key in engine..."
sed -i "s/^const unsigned char psk\[\] \= .*/const unsigned char psk\[\] \= \{ $(cat key.txt) \};/" ./ynoengine/src/multiplayer/yno_connection.cpp
cd ..

echo "All done!"
