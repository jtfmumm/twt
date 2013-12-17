#!/bin/sh

INSTALL=/usr/local/bin

if ! type "sqlite3" > /dev/null; then
	echo "sqlite3 is not installed!"
	echo "Install with --> sudo apt-get install sqlite3"
	read TEST
	exit 0
fi

mkdir ~/.twt/
touch ~/.twt/twt.cfg
touch ~/.twt/twt.db

echo "CREATE TABLE tweets (id integer PRIMARY KEY AUTOINCREMENT, tweet text, archived integer DEFAULT 0);" > initialize_db.sql
sqlite3 ~/.twt/twt.db < initialize_db.sql	
rm initialize_db.sql

echo "Where do you want to install the script? (default: /usr/local/bin)"
read INPUT
if [ "$INPUT" ]; then
	INSTALL=$INPUT
fi

cp twt.sh twt
cp twt $INSTALL
chmod 755 $INSTALL/twt
rm twt

echo "Type twt at the command line to run the script!"
