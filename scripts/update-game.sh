#!/bin/sh -e

if [ $# != 2 ]; then
    echo "Not enough arguments."
    echo "Usage:"
    echo "  $0 gamename path/to/game/files"
    exit 1
fi

for f in nginx.conf docker-compose.yml; do
    if [ ! -f "$f" ]; then
        echo "$f not found; did you run scripts/init.sh? Are you running this script in the main ynodeploy directory?"
        exit 1
    fi
done

game_name="$1"
shift
game_path="$@"
target_path=games/"$game_name"

if [ $(realpath $target_path) != $(realpath $game_path) ]; then
    echo "Copying game files to games directory..."
    [ ! -d games ] && mkdir games
    if [ -d "$target_path" ]; then
        echo "Game with shortcode $game_name already exists!"
        echo "To replace, press any key. To abort, press Ctrl+C"
        read -n1 _tmp
        rm -r "$target_path"
    fi
    cp -r "$game_path" "$target_path"
fi

echo "Converting audio files to opus..."
"$(dirname $0)"/audioconvert/audioconvert "$target_path"

echo "Running gencache..."

"$(dirname $0)"/gencache/gencache "$target_path" --output "$target_path"/index.json

