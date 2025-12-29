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

$(dirname $0)/update-game.sh $game_name "$game_path"

# Update nginx.conf and docker-compose
echo "Updating nginx.conf and docker-compose.yml..."

python3 <<EOF
game_name = "$game_name"

nginx_socket = """upstream server_{game_name}_socket {
    server unix:/opt/server-sockets/{game_name}.sock;
}""".replace("{game_name}", game_name)

nginx_client = """	location /{game_name} {
		alias /opt/client;
		try_files \$uri \$uri/ =404;

		location ~ \\\.php\$ {
			include fastcgi_params;
			fastcgi_pass php-fpm:9000;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
        }

        location /{game_name}/images/charsets/{game_name} {
			alias /opt/games/{game_name}/CharSet;
			try_files \$uri \$uri/ =404;
		}

		location ^~ /{game_name}/locations/ {
			alias /opt/locations/;
			try_files \$uri \$uri/ =404;
		}

		location ^~ /{game_name}/lang/badge/ {
			alias /opt/badges/lang/;
			try_files \$uri \$uri/ =404;
		}
	}
""".replace("{game_name}", game_name)

nginx_server = """	location /{game_name}/ {
		proxy_pass http://server_{game_name}_socket/;

		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto \$scheme;
		proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;

		# Needed for websocket:
		proxy_http_version 1.1;
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Connection \$connection_upgrade;

		proxy_read_timeout 86400;
		proxy_send_timeout 86400;
		# Handle preflight OPTIONS requests
		if (\$request_method = 'OPTIONS') {
			add_header 'Access-Control-Allow-Origin' \$http_origin always;
			add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, PATCH, OPTIONS' always;
			add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Accept, Origin' always;
			add_header 'Access-Control-Max-Age' 86400 always;
			add_header 'Content-Length' 0;
			add_header 'Content-Type' 'text/plain';
			return 204;
		}

		add_header 'Access-Control-Allow-Origin' \$cors_origin always;
		add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, PATCH, OPTIONS' always;
		add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Accept, Origin' always;
		add_header 'Access-Control-Allow-Credentials' 'true' always;
	}""".replace("{game_name}", game_name)

with open("nginx.conf", "r") as nginx_file:
    out = nginx_socket + "\n"
    for line in nginx_file:
        out += line
        if line.strip().startswith("## AUTOMATED (CLIENT):"):
            out += "\n" + nginx_client + "\n"

        elif line.strip().startswith("## AUTOMATED (SERVER):"):
            out += "\n" + nginx_server + "\n"

with open("nginx.conf", "w") as nginx_file:
    nginx_file.write(out)

dc_server = f"""  server-{game_name}:
    build:
      context: ./repos/ynoserver
      dockerfile: ../../docker/ynoserver/Dockerfile
    restart: unless-stopped
    volumes:
      - ./logs:/opt/ynoserver/logs:rw
      - ./configs/{game_name}.yml:/opt/ynoserver/config.yml:ro
      - ./configs/filterwords.txt:/opt/ynoserver/filterwords.txt:ro
      - ./repos/ynobadges:/opt/ynoserver/badges:ro
      - ./games/{game_name}:/opt/games/{game_name}:ro
      - ./key.bin:/opt/ynoserver/key.bin:ro
      - ynoserver-sockets:/opt/ynoserver/sockets:rw
      - ynoserver-saves:/opt/ynoserver/saves:rw
      - ynoserver-screenshots:/opt/ynoserver/screenshots:rw
    depends_on:
      db:
        condition: service_healthy
    networks:
      - backend"""

out = ""
with open("docker-compose.yml", "r") as dc_file:
    for line in dc_file:
        out += line
        if line.strip().startswith("# AUTOMATED:"):
            out += "\n" + dc_server + "\n"

with open("docker-compose.yml", "w") as dc_file:
    dc_file.write(out)

EOF

echo "Creating config..."
cp configs/server.yml.example configs/"$game_name".yml
sed -i "s/CHANGEME/$game_name/g" configs/"$game_name".yml
