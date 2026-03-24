#!/bin/sh -e

# Wrapper around update-game which extracts the game files
# from a zip archive.

if [ $# != 2 ]; then
    echo "Not enough arguments."
    echo "Usage:"
    echo "  $0 gamename path/to/game/zip"
    exit 1
fi

if [ ! -d "games" ]; then
    echo "games directory not found; did you run scripts/init.sh? Are you running this script in the main ynodeploy directory?"
    exit 1
fi

game_name="$1"
shift
game_zip_path="$@"

tmpdir="/tmp/yno-game-$RANDOM"
cd "$tmpdir"
unzip -d "$tmpdir" $game_zip_path
game_path=$(basename $(find -name RPG_RT.ldb | head -n1))
if ! [ $game_path ]; then
	echo "Failed to find game files; please check $tmpdir for the unpacked files and run update-game manually."
	exit 1
fi

$(basename $0)/update-game.sh $game_name $game_path
