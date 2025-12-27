# ynodeploy

Deployment scripts for YNOProject

## Setup for development

Prerequisites:

* Server running Linux
* `git`, `docker` and `docker-compose` installed

1. Clone the ynodeploy repository and open it:
   `$ git clone https://github.com/knuxify/ynodeploy; cd ynodeploy`
2. Run `./scripts/init.sh` to check for dependencies and clone the other repositories;
   they will end up in the `repos` directory.
3. Open `docker-compose.yml`. If you want to change the DB credentials, do so here.
4. Copy `configs/rankings.yml.example` to `configs/rankings.yml`. If you didn't change
   the DB credentials in the previous step, you do not need to change anything here.
5. For every game you want to add (replace `gamename` with the short name of the
   game you want to add):
5.1. Copy `configs/server.yml.example` to `configs/gamename.yml`.
     Open the file and modify it according to the comments.
5.2. Place the game files in `games/CHANGEME`.
5.3. In `nginx.conf`, look for the commented out samples that mention the string `CHANGEME`;
     replace `gamename` with the short name of the game.
5.4. In `docker-compose.yml`, find the `server-CHANGEME` example; uncomment it and replace
     `CHANGEME` with the short name.
6. Run the container with `docker compose up -d`.
6.1. You may need to start the Docker service first.
6.2. If you get errors about insufficient permissions, use `sudo` or add your user
     to the `docker` group or equivalent for your distribution - consult your
     distro's docs.
7. Open `repos/forest-orb`; replace all mentions of `ynoproject.net` with `yno.local`.
   Replace `https://` with `http://` and `wss://` with `ws://`.
8. Open `repos/ynoserver`; replace all mentions of `ynoproject.net` with `yno.local`.
8. Open `repos/ynohome`; replace all mentions of `ynoproject.net` with `yno.local`.
10. Get `ynoengine-simd.js`, `ynoengine-simd.wasm` and `easyrpg-player.wasm`, either
   from ynoproject.net (`https://ynoproject.net/2kki/(filename)`), or by compiling
   them yourself (see `engine` folder for build scripts).
   Place them in `repos/ynoserver`.

To check the logs, run `docker compose logs`. To stop the container, run `docker compose down`.

By default, the site will be accessible through http://yno.local, with the API
exposed at http://connect.yno.local.

## Maintenance

### Updating YNO server components

Run `./scripts/update-repos.sh`, which runs `git pull` in all subfolders of `repos`.
Then, shut down the containers with `docker compose down`, and restart with
`docker compose up --build` to get the containers to rebuild.

### Updating games

Extract the new game files to any directory, then run `./scripts/deploy-game.sh path/to/game/files gamename`
(change the arguments as needed).
