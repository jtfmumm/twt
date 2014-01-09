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
	if [ "$1" -eq 0 ]; then 
		echo "TWEET SKETCHES"
	else 
		echo "TWEET ARCHIVE"
	fi
	echo "SELECT tweet FROM tweets WHERE archived = \"$1\";" > $TWTDIR/temp.sql
	sqlite3 $TWTDIR/twt.db < $TWTDIR/temp.sql > $TWTDIR/tweets.txt
	cat $TWTDIR/tweets.txt -n
	rm temp.sql
}

archive()
{
	display 1
	echo "------------------------------------------"
	echo "| (d)ump to text file and delete         |"
	echo "| (r)eturn to main menu                  |"
	echo "------------------------------------------"
	read INPUT
	if [ "$INPUT" = "d" ]; then
		cd -
		echo "SELECT tweet FROM tweets WHERE archived = 1;" > temp.sql
		sqlite3 $TWTDIR/twt.db < temp.sql >> twt-archive.txt
		rm temp.sql
		cd $TWTDIR
		echo "delete from tweets where archived = 1;" > temp.sql
		sqlite3 twt.db < temp.sql
		rm temp.sql
		menu
	fi
	menu
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
	seq 76 | tr -d '\n' | sed 's/./\-/g'
}

add()
{
	clear
	template
	echo "Go!"
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
	display 0
	echo "Edit which tweet?"
	read INPUT
	if [ ! "$INPUT" ]; then
		menu
	fi

	sed -n "$INPUT"p < $TWTDIR/tweets.txt > temp.txt
	read TWEET < temp.txt
	rm temp.txt
	
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

	echo "update tweets set tweet = \"$NEW_TWEET\" where tweet = \"$TWEET\";" > temp.sql
	sqlite3 $TWTDIR/twt.db < temp.sql
	rm temp.sql
	menu	
}

move()
{
	display 0
	echo "Move which tweet to archive?"
	read INPUT
	if [ ! "$INPUT" ]; then
		menu
	fi

	sed -n "$INPUT"p < $TWTDIR/tweets.txt > temp.txt
	read TWEET < temp.txt
	rm temp.txt

	echo "update tweets set archived = 1 where tweet = \"$TWEET\";" > temp.sql
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
	display 0
	echo "Kill which tweet?"
	read INPUT
	if [ ! "$INPUT" ]; then
		menu
	fi

	sed -n "$INPUT"p < $TWTDIR/tweets.txt > temp.txt
	read TWEET < temp.txt
	rm temp.txt

	echo "delete from tweets where tweet = \"$TWEET\";" > temp.sql
	sqlite3 twt.db < temp.sql
	rm temp.sql
	menu
}

menu()
{
	clear
	display 0
	echo "----------------------------------------"
	echo "| (a)dd new          (e)dit            |" 
	echo "| (v)iew archive     (m)ove to archive |"
	echo "| (k)ill (delete)    (q)uit            |" 
	echo "----------------------------------------"
	read INPUT
	if [ "$INPUT" = "a" ]; then
		add
	elif [ "$INPUT" = "k" ]; then
		kil
	elif [ "$INPUT" = "q" ]; then
		exit 0
	elif [ "$INPUT" = "e" ]; then
		edit
	elif [ "$INPUT" = "m" ]; then
		move
	elif [ "$INPUT" = "v" ]; then
		archive
	else
		menu	
	fi
}

if [ "$1" = "h" ]; then
	hlp
elif [ "$1" = "d" ]; then
	display 0
elif [ "$1" = "k" ]; then
	kil
elif [ "$1" = "e" ]; then
	edit
else
	menu
fi
 
