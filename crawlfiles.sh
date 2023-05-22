#!/bin/sh
#
# Dirty recursive scraper which will break when the sites layout changes.

cookiejar=${XDG_CACHE_HOME:-$HOME/.cache}/wbs_cookies
baseurl=https://ecampus.wbstraining.de
basedir=$PWD

die() {
	fmt="%s: $1"
	shift
	printf "$fmt" "${0##*/}" "$@" >&2
	exit 1
}

info() {
	printf "$@" >&2
}

crawl() {
	curl --cookie "$cookiejar" --no-progress-meter "$1" \
	| grep '<h3 class="il_ContainerItemTitle"><a href="' \
	| while IFS= read -r line; do
		link=${line#*<a href=}
		link=${link%% class=*}
		link=${link#\"}
		link=${link%\"}
		name=${line%</a>*}
		name=${name##*>}

		if [ "$PWD" = "$basedir" ]; then
			relapath=$name
		else
			relapath=${PWD#"$basedir"/}/$name
		fi

		case $link in
			*[?\&]cmd=calldirectlink*) # Link
				info 'Creating link file: %s\n' "$relapath"
				# TODO: html decode.
				# TODO: don't overwrite files blindly
				printf '%s/%s\n' "$baseurl" "$link" >"$name" ||
					die 'Failed writing file: %s\n' "$PWD/$name"
			;;

			*[?\&]cmd=view*) # Directory
				info 'Making directory: %s\n' "$relapath"
				[ -e "$name" ] ||
					mkdir -- "$name" || exit
				cd "$name" || exit
				crawl "$baseurl/$link"
				cd .. || exit
			;;

			*goto.php*[?\&]target=*) # File
				info 'Getting file: %s\n' "$relapath"
				curl \
					--cookie "$cookiejar" \
					--no-clobber \
					--no-progress-meter \
					--remote-name \
					--remote-header-name \
					--remote-time \
					"$link"
			;;
		esac
	done
}

[ $# -ne 1 ] &&
	die 'Usage: %s <url>\n' "${0##*/}"

[ -r "$cookiejar" ] ||
	die 'Cookie jar does not exist or not readable: %s\n' "$cookiejar"

crawl "$1"
