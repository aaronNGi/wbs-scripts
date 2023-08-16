#!/bin/sh

set -e

cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
cookiejar=$cache_dir/wbs_cookies

! [ -e "$cache_dir" ] &&
	mkdir -p -- "$cache_dir" >/dev/null

printf 'Username: ' >&2
read -r user
printf 'Password: ' >&2
stty -echo echonl
read -r passwd
stty echo

printf 'Versuche einzuloggen...\n' >&2

curl \
	'https://ecampus.wbstraining.de/ilias.php?lang=de&client_id=wbs50&cmd=post&cmdClass=ilstartupgui&cmdNode=10f&baseClass=ilStartUpGUI&rtoken=' \
	--cookie-jar "$cookiejar" \
	--no-progress-meter \
	-X POST \
	--data-raw "username=$user&password=$passwd&cmd%5BdoStandardAuthentication%5D=Anmelden" \
	| grep -Fom1 "Benutzername oder Passwort ungültig" >&2 &&
		exit 1 ||
		printf 'Eingeloggt\n' >&2
