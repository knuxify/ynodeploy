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

# Generate key.bin (needed by ynoserver)
echo "Generating key.bin for ynoserver..."
echo -e "import os\nwith open('key.bin', 'wb+') as key: key.write(os.urandom(32))" | python3

echo "All done!"
