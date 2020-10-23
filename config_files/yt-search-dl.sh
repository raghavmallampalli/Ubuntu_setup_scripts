#!/bin/bash

if ! [[ $(command -v jq) && $(command -v youtube-dl) ]]; then
	echo "Install jq and youtube-dl, scripts depends on these commands."
	echo "https://github.com/ytdl-org/youtube-dl#installation"
	exit
fi

tempfile=$(mktemp)
youtube_dl_log=$(mktemp)
echo "Searching..."
youtube-dl -j "ytsearch8:$*" > $tempfile

while IFS= read -r line
do
    youtube_urls+=("$line")
done < <(cat $tempfile | jq '.webpage_url' | tr -d '"' )

cat $tempfile | jq -C --tab '.webpage_url, .fulltitle' | nl -b p\"http*

while :
do
    echo "Enter video number to download. q to exit."
    read i
    i=${i:-q}
    if [ "$i" = "q" ]; then	
	echo "Exiting"
	break
    else
    	# don't download anything if you just press enter
    	if [ ! x"$i" == x"" ]; then
	    tempvar2=0
    	    read -p "Enter v for video, a for audio. [v/a]: " tempvar
    	    tempvar=${tempvar:-q}
    	    if [[ $tempvar = v ]]; then
    	    	# to make numbering of videos more intuitive (start from 1 not 0)
    	    	youtube-dl -f 'bestvideo[height<=720]+bestaudio/best[height<=720]' --write-sub ${youtube_urls[$i - 1]}
    	    elif [[ $tempvar = a ]]; then
    	    	youtube-dl -f 140 ${youtube_urls[$i - 1]}
    	    fi
    	fi
    fi
done
if [[ -n "$tempvar2" ]]; then
	if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
		explorer.exe .
	else
		xdg-open .
	fi
fi
