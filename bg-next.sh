#!/bin/bash

#HELP


FILE=${FILE:-/tmp/wallpaper}
colors_name=("red-blood" "red-crimson" "red-communist" "red-persian" "salmon" "purple"
"purple-dark" "blue-bluebell" "blue-royal" "blue-tomb" "blue-petrichor" "green-neon"
"green" "green-dark" "green-brown" "green-yellow" "gold-antique" "yellow"
"sunglow" "orange-light" "orange" "orange-red" "brown-light" "brown"
"black" "gray-dark" "gray-light" "white" "gray-charcoal" )
colors_hex=("660000" "990000" "cc0000" "cc3333" "ea4c88" "993399"
"663399" "333399" "0066cc" "0099cc" "66cccc" "77cc33" 
"669900" "336600" "666600" "999900" "cccc33" "ffff00" 
"ffcc33" "ff9900" "ff6600" "cc6633" "996633" "663300" 
"000000" "999999" "cccccc" "ffffff" "424153" )
colors_length=${#colors_name[@]}

Help()
{
    printf "\tUsage: bg-next [-q <Search term>] [-c <Color in hex>]\n\n"
    printf "\tAvailable colors are: \n\n"

    printf "\t"
    for (( color=0; color<${colors_length}; color++));
    do
        printf "%s " ${colors_name[$color]}
        if [ $(($color % 5)) == 4 ]; then
            printf "\n\t"
        fi
    done
    

    printf "\n\n\tUse bg-next -s or --save to copy the current wallpaper to your pictures for later"

}


Colors()
{
    local name=$1
    for (( color=0; color<${colors_length}; color++));
    do
        if [ $name == ${colors_name[$color]} ]; then
            COLOR=${colors_hex[$color]}
            return
        fi
    done
}

while getopts "hq:c:s-:" option; do
    case $option in
        h)Help
          exit;;
        q)QUERY=$OPTARG ;;
        c)Colors "$OPTARG" ;;
        s)cp "$FILE" "$HOME/Pictures/$RANDOM.png" 
          exit ;;
        -);;
        \?) echo "Invalid option -$OPTARG" >&2 ;;
    esac
done

for arg in "$@"; do
    case $arg in
        --query=*) QUERY="${arg#*=}" ;;
        --color=*) COLORS "${arg#*=}" ;;    
        --help=*) Help
            exit ;;
        --save=*) 
            cp "$FILE" "$HOME/Pictures/$RANDOM.png"
            exit ;;
    esac
done



RESOLUTION=$(xdpyinfo | grep -oP 'dimensions:\s+\K\S+')

PURITY=110
CATEGORIES=111
API=
API_URL="https://wallhaven.cc/api/v1/search?api_key=$API"

if [ -n "$QUERY" ]; then
    QUERY=$(echo $QUERY | sed 's/ /+/g')
    API_URL+="&q=$QUERY"    
fi

if [ -n "$COLOR" ]; then
    API_URL+="&colors=$COLOR"
fi

API_URL+="&categories=$CATEGORIES&purity=$PURITY&resolutions=$RESOLUTION&sorting=random"
DOWNLOAD=$(curl -L "$API_URL" | jq -r '.data[0].path')
curl -L "$DOWNLOAD" -o "$FILE"

nitrogen --set-auto $FILE
#wal -c
#wal -q --saturate 0.3 -i $FILE
