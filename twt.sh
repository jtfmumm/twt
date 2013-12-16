#!/bin/bash

TWTDIR=~/.twt/
PARAMS=$@

cd $TWTDIR

quit()
{
	exit 0
}

display()
{
	clear
	echo "TWEET SKETCHES"
	echo 'select * from tweets;' > $TWTDIR/temp.sql
	sqlite3 $TWTDIR/twt.db < temp.sql
	rm temp.sql
}

err()
{
	echo "ERROR: Limit to 144 characters!"
	eval $1
}

template()
{
	#Displays symbols to represent max length
	echo "Limit 144 characters:"
	seq 76 | tr -d '\n' | sed 's/./\-/g' | sed '$a\'
}

add()
{
	clear
	template
	echo "Type in your tweet!"
	read INPUT
	echo $INPUT | wc -c > temp.txt
	read COUNT < temp.txt
	rm temp.txt
	if [ "$COUNT" -gt 144 ]; then
		err add
	fi
	echo "insert into tweets (tweet) values (\"$INPUT\");" > $TWTDIR/temp.sql
	sqlite3 $TWTDIR/twt.db < temp.sql
	rm temp.sql
	menu
}

edit()
{
	display
	echo "Edit which tweet?"
	read INPUT
	if [ ! "$INPUT" ]; then
		quit
	fi
	
	echo "select tweet from tweets where id = \"$INPUT\";" > $TWTDIR/temp.sql
    sqlite3 $TWTDIR/twt.db < temp.sql > temp.txt
	read TWEET < temp.txt
	rm temp.txt
	rm temp.sql
	
	clear
	template
	echo "Edit your tweet:"
	read -e -i "$TWEET" NEW_TWEET
	
	echo $NEW_TWEET | wc -c > temp.txt
	read COUNT < temp.txt
	rm temp.txt
	if [ "$COUNT" -gt 144 ]; then
		err edit
	fi	

	echo "update tweets set tweet = \"$NEW_TWEET\" where id = \"$INPUT\";" > temp.sql
	sqlite3 $TWTDIR/twt.db < temp.sql
	rm temp.sql
	menu	
}

hlp()
{
	echo no parameters "new tweet"
	echo "-h help"
	echo "-d display"
	echo "-e edit"
	echo "-k kill a tweet"
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
	menu
}

menu()
{
	clear
	display
	echo "----------------------------------"
	echo "(a) add"
	echo "(e) edit"
	echo "(k) kill"
	echo "----------------------------------"
	read INPUT
	if [ "$INPUT" = "a" ]; then
		add
	elif [ "$INPUT" = "k" ]; then
		kil
	elif [ "$INPUT" = "e" ]; then
		edit
	else
		menu	
	fi
}

if [ "$1" = "h" ]; then
	hlp
elif [ "$1" = "d" ]; then
	display
elif [ "$1" = "k" ]; then
	kil
elif [ "$1" = "e" ]; then
	edit
else
	menu
fi
 