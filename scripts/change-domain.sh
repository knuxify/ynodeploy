#!/bin/sh

# change-domain.sh - change the target domain name for all files
# usage: ./scripts/change-domain.sh old.domain new.domain (http/https)

if [ ! -f repos ]; then
	echo "Please run this script from the base ynodeploy directory."
	exit 1
fi

if [ $# != 2 ] && [ $# != 3 ]; then
	echo "Incorrect number of parameters."
	echo "Usage:"
	echo ""
	echo "  $0 old.domain new.domain (http/https)"
	echo ""
	exit 1
fi

old_domain=$1
new_domain=$2
secure=$3

old_domain_escaped=$(echo $old_domain | sed 's/\./\\./g')
new_domain_escaped=$(echo $new_domain | sed 's/\./\\./g')

expressions="-e s/$old_domain_escaped/$new_domain_escaped/g"

if [ "$secure" == "https" ]; then
	expressions="$expressions -e s/http\:\/\/$new_domain_escaped/https\:\/\/$new_domain_escaped/g"
	expressions="$expressions -e s/http\:\/\/connect\.$new_domain_escaped/https\:\/\/connect\.$new_domain_escaped/g"
	expressions="$expressions -e s/ws\:\/\/connect\.$new_domain_escaped/wss\:\/\/connect\.$new_domain_escaped/g"
elif [ "$secure" == "http" ]; then
	expressions="$expressions -e s/https\:\/\/$new_domain_escaped/http\:\/\/$new_domain_escaped/g"
	expressions="$expressions -e s/https\:\/\/connect\.$new_domain_escaped/http\:\/\/connect\.$new_domain_escaped/g"
	expressions="$expressions -e s/wss\:\/\/connect\.$new_domain_escaped/ws\:\/\/connect\.$new_domain_escaped/g"
fi

for repo in ynohome ynoserver forest-orb; do
	find repos/$repo -type f \( -name *.js -o -name *.go -o -name *.html -o -name *.php \) -exec \
		sed -i $expressions {} \;
done

if [ -f "nginx.conf" ]; then
	sed -i -e "s/$old_domain_escaped/$new_domain_escaped/g" \
		   -e "s/$(echo $old_domain_escaped | sed 's/\./\\./g')/$(echo $new_domain_escaped | sed 's/\./\\./g')/g" \
		   nginx.conf
fi
