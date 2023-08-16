#!/bin/sh
#
# Entweder den Benutzername und Password unten ändern, oder das script ausführen
# mit: ECAMPUS_USER=mmustermann ECAMPUS_PASSWORD='Pa$$w0rd' path/to/login.sh

set -e

user=${ECAMPUS_USER:-deinbenutzternamehier}
passwd=${ECAMPUS_PASSWORD:-deinpasswordhiero}

cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
cookiejar=$cache_dir/wbs_cookies

! [ -e "$cache_dir" ] &&
	mkdir -p -- "$cache_dir" >/dev/null

curl \
	'https://ecampus.wbstraining.de/ilias.php?lang=de&client_id=wbs50&cmd=post&cmdClass=ilstartupgui&cmdNode=10f&baseClass=ilStartUpGUI&rtoken=' \
	--cookie-jar "$cookiejar" \
	--no-progress-meter \
	-X POST \
	--data-raw "username=$user&password=$passwd&cmd%5BdoStandardAuthentication%5D=Anmelden" \
	| grep -Fom1 "Benutzername oder Passwort ungültig" >&2 &&
		exit 1 ||
		printf 'Eingeloggt\n' >&2
