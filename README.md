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
3. Copy `docker-compose.yml.example` to `docker-compose.yml`, and `nginx.conf.example`
   to `nginx.conf`.
4. Open `docker-compose.yml`. If you want to change the DB credentials, do so here.
5. Copy `configs/rankings.yml.example` to `configs/rankings.yml`. If you didn't change
   the DB credentials in the previous step, you do not need to change anything here.
6. For every game you want to add (replace `gamename` with the short name of the
   game you want to add):
    * Copy `configs/server.yml.example` to `configs/gamename.yml`.
      Open the file and modify it according to the comments.
    * Place the game files in `games/CHANGEME`.
    * In `nginx.conf`, look for the commented out samples that mention the string `CHANGEME`;
      replace `gamename` with the short name of the game.
    * In `docker-compose.yml`, find the `server-CHANGEME` example; uncomment it and replace
     `CHANGEME` with the short name.
7. Compile ynoengine using the scripts in the `engine` folder (see `engine/README.md`).
   Copy `ynoengine-simd.js`, `ynoengine-simd.wasm`, `ynoengine.js`, `ynoengine.wasm` and `easyrpg-player.wasm` into `repos/ynoserver`.
8. Run the container with `docker compose up -d`.
    * You may need to start the Docker service first.
    * If you get errors about insufficient permissions, use `sudo` or add your user
     to the `docker` group or equivalent for your distribution - consult your
     distro's docs.

To check the logs, run `docker compose logs`. To stop the container, run `docker compose down`.

By default, the site will be accessible through http://yno.local, with the API
exposed at http://connect.yno.local. You should add entries in your hosts file
(`/etc/hosts` on Linux) to resolve to yno.local:

```
127.0.0.1 yno.local
127.0.0.1 connect.yno.local
```

## Maintenance

**TODO** these scripts don't actually exist yet

### Updating YNO server components

Run `./scripts/update-repos.sh`, which runs `git pull` in all subfolders of `repos`.
Then, shut down the containers with `docker compose down`, and restart with
`docker compose up --build` to get the containers to rebuild.

### Updating games

Extract the new game files to any directory, then run `./scripts/deploy-game.sh path/to/game/files gamename`
(change the arguments as needed).
