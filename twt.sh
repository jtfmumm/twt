#!/bin/sh

TWTDIR=~/.twt/
PARAMS=$@

cd $TWTDIR

quit()
{
	exit 0
}

display()
{
	echo 'select * from tweets;' > $TWTDIR/temp.sql
	sqlite3 $TWTDIR/twt.db < temp.sql
	rm temp.sql
}

err()
{
	echo "ERROR: Limit to 144 characters!"
	add
}

add()
{
	echo "Type in your tweet!"
	seq 76 | tr -d '\n' | sed 's/./\-/g' | sed '$a\'
	read INPUT
	echo $INPUT | wc -c > temp.txt
	read COUNT < temp.txt
	rm temp.txt
	if [ "$COUNT" -gt 144 ]; then
		err
	fi
	echo "insert into tweets (tweet) values (\"$INPUT\");" > $TWTDIR/temp.sql
	sqlite3 $TWTDIR/twt.db < temp.sql
	rm temp.sql
}

hlp()
{
	echo -h "help"
	echo -d "display"
	echo -k "kill a tweet"
	echo Limit to 144 characters\!
	seq 76 | tr -d '\n' | sed 's/./\-/g' | sed '$a\' 
	quit
}

kil()
{
	display
	echo "Kill which tweet?"
	read INPUT
	if [ ! "$INPUT" ]; then
		quit
	fi
	echo "delete from tweets where id = \"$INPUT\";" > temp.sql
	sqlite3 twt.db < temp.sql
	rm temp.sql
	kil
}

if [ "$1" = "h" ]; then
	hlp
elif [ "$1" = "d" ]; then
	display
elif [ "$1" = "k" ]; then
	kil
else
	add
fi
 