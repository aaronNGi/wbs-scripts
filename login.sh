#!/bin/sh

user=wbsuser
passwd=wbspassword

curl \
	'https://ecampus.wbstraining.de/ilias.php?lang=de&client_id=wbs50&cmd=post&cmdClass=ilstartupgui&cmdNode=10f&baseClass=ilStartUpGUI&rtoken=' \
	--no-progress-meter \
	-X POST \
	--data-raw "username=$user&password=$passwd&cmd%5BdoStandardAuthentication%5D=Anmelden"
