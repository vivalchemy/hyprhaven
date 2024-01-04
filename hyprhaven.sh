#!/bin/bash

# constants
BASE_URL="https://wallhaven.cc/api/v1/search?"
QUERY_PARAMS=""
WALLPAPER_DIR="${HOME}/Pictures/wallpapers"
HYPRPAPER_CONF_FILE="$HOME/.config/hypr/hyprpaper.conf"
TMP_FILE="${WALLPAPER_DIR}tmp.txt"
MIN_RES="1920x1080" #	|| PERMITTED_RES="1920x1080,1920x1200"
PERMITTED_RATIO="16x9,16x10"
MAX_IMAGES=50
IMG_FILE_COUNTER=1
MAX_PAGES=5
CATEGORIES=0
PURITY=0
API_KEY="" # fill your api key here
MONITOR_NAME="eDP-1"

# check if there is any query
if [[ $# -eq 0 ]]; then
	echo "+-------------------------------------------------------------+"
	echo -e "|    \e[38;5;196m  _                      _                           \e[0m    |"
	echo -e "|    \e[38;5;202m | |__  _   _ _ __  _ __| |__   __ ___   _____ _ __  \e[0m    |"
	echo -e "|    \e[38;5;208m | '_ \| | | | '_ \| '__| '_ \ / _\` \ \ / / _ \ '_ \ \e[0m    |"
	echo -e "|    \e[38;5;214m | | | | |_| | |_) | |  | | | | (_| |\ V /  __/ | | |\e[0m    |"
	echo -e "|    \e[38;5;220m |_| |_|\__, | .__/|_|  |_| |_|\__,_| \_/ \___|_| |_|\e[0m    |"
	echo -e "|    \e[38;5;226m        |___/|_|                                     \e[0m    |"
	echo -e "|            A wallpaper setup script for \e]8;;https://github.com/hyprwm/hyprpaper\ahyprpaper\e]8;;\a           |"
	echo "+-------------------------------------------------------------+"
	echo -e "\n\nOptions:\n"
	echo "-r: Set a random wallpaper from the local directory."
	echo "-d: Fetch and download wallpapers from Wallhaven based on specified criteria."
	echo "-c CATEGORY: Specify wallpaper categories (e.g., \"general, anime\")."
	echo "-p PURITY: Specify wallpaper purity (e.g., \"sfw, nsfw\")."
	echo "-q QUERY: Specify a search query for wallpapers."
	echo "-s FILE_PATH: Set a specific wallpaper using the provided file path."
	exit 1
fi

doesFileExist() {
	if ! [[ -f $1 ]]; then
		echo "$1 File not found"
		exit 1
	fi
}

getImgUrl() {
	BASE_IMG_URL="https://w.wallhaven.cc/full/$(echo $1 | cut -c1-2)/wallhaven-$1.$2"
	echo $BASE_IMG_URL
}
# setup some constant parameters
setConfigs() {
	[[ -n "$2" ]] && QUERY_PARAMS+="&$1=$2"
}

# format the query and add to the final url
setQuery() {
	local PARSED_QUERY=$(echo $1 | awk '{$1=$1; print}' | sed 's/ /%20/g')
	QUERY_PARAMS+="&q=$PARSED_QUERY"
}

# Add categories and tags
# Example usage:
# setModifiers category "general, anime"
# setModifiers purity "sfw, nsfw"
setModifiers() {
	local PARAM_TYPE=$1
	local INPUT_STRING=$2

	if ! [[ "$INPUT_STRING" =~ ^[a-z,[:space:]]+$ ]]; then
		echo "The string contains invalid characters."
		exit 1
	fi

	local PARSED_QUERY=$(echo "$INPUT_STRING" | tr ", " " " | awk '{$1=$1; print}')
	local ARRAY=($PARSED_QUERY)

	for MODIFIER in "${ARRAY[@]}"; do
		case "$MODIFIER" in
		# categories
		general) ((CATEGORIES += 100)) ;;
		anime) ((CATEGORIES += 10)) ;;
		people) ((CATEGORIES += 1)) ;;
			# purity
		sfw) ((PURITY += 100)) ;;
		sketchy) ((PURITY += 10)) ;;
		nsfw)
			[[ -n $API_KEY ]] && ((PURITY += 1)) || echo "The API key is not set. Cannot access nsfw images."
			;;
		esac
	done

	# Format the values with leading zeros
	CATEGORIES=$(printf "%03d" $CATEGORIES)
	PURITY=$(printf "%03d" $PURITY)

	[[ "$PARAM_TYPE" == "category" ]] && QUERY_PARAMS+="&categories=$CATEGORIES"
	[[ "$PARAM_TYPE" == "purity" ]] && QUERY_PARAMS+="&purity=$PURITY"
	# echo "${BASE_URL}${QUERY_PARAMS}"
}

# Set the wallpaper from the given file location
setWallpaper() {
	doesFileExist $1
	killall hyprpaper
	echo -e "preload = $1	\n wallpaper = $MONITOR_NAME, $1" >$HYPRPAPER_CONF_FILE
	hyprpaper
}

# Set the wallpaper from the wallpaper directory
setRandomWallpaper() {
	# checks if the wallpaper directory has any file or not
	if ! [[ $(ls | wc -w) -gt 0 ]]; then
		echo "There is no file in the image directory"
		exit 1
	fi

	local IMG_FILE=$(ls $WALLPAPER_DIR | shuf -n 1)
	setWallpaper "${WALLPAPER_DIR}${IMG_FILE}"
}

# Get the img ids from the wall haven api
getImageUrls() {
	local PAGE_COUNT=1

	[[ -f "${TMP_FILE}" ]] && echo -n "" >$TMP_FILE
	while [[ $(wc -l <"$TMP_FILE") -lt $MAX_IMAGES && $PAGE_COUNT -le $MAX_PAGES ]]; do
		QUERY_PARAMS=$(echo "$QUERY_PARAMS" | sed 's/&page=[0-9]\+//g') # removes previous page numbers
		QUERY_PARAMS+="&page=$PAGE_COUNT"                               # adds current page number
		curl -s "${BASE_URL}${QUERY_PARAMS#&}" | jq | rg path | sed 's/.*wallhaven-\(.*\)\.\(.*\)".*/\1 \2/g' >>"${TMP_FILE}"
		# curl "${BASE_URL}${QUERY_PARAMS#&}" | jq | rg path | sed 's/.*wallhaven-\(.*\)\.\(.*\)".*/\1 \2/g'
		# echo "${BASE_URL}${QUERY_PARAMS#&}"
		echo "$PAGE_COUNT $(wc -l <$TMP_FILE)"
		((PAGE_COUNT++))
	done
}

# download each image in the array in the specified directory
downloadImages() {
	cat $TMP_FILE
	# check if the array is empty
	[[ ! -s "${TMP_FILE}" ]] && echo "Error: The image array is empty" && exit 1
	# Check if the file exists
	doesFileExist ${TMP_FILE}
	CURRENT_DIRECTORY=$PWD
	cd $WALLPAPER_DIR
	# Loop to read each line from the file
	while IFS= read -r ITEM; do
		# Check if the line is not empty
		if [[ -n "$ITEM" ]]; then
			# local FILE_EXTENSION="${ITEM##*.}"
			local FILE_EXTENSION=$(echo $ITEM | awk '{print $2}')
			# Process each non-empty line
			# echo "curl -o \"${IMG_FILE_COUNTER}.${FILE_EXTENSION}\" \"${BASE_IMG_URL}${ITEM}\""
			curl -s -o "${IMG_FILE_COUNTER}.${FILE_EXTENSION}" "$(getImgUrl $ITEM)"
		fi
		if [[ $IMG_FILE_COUNTER -lt $MAX_IMAGES ]]; then
			((IMG_FILE_COUNTER++))
		else
			notify-send "The images have been downloaded"
			exit 0
		fi
	done <"${TMP_FILE}"

	rm "${TMP_FILE}" # remove the tmp file after downloading the images

	cd $CURRENT_DIRECTORY
}

# setConfigs $API_KEY "apikey" this doesn't work cause an empty string is not counted as an argument
setConfigs "apikey" $API_KEY
setConfigs "atleast" $MIN_RES
setConfigs "resolutions" $PERMITTED_RES
setConfigs "ratios" $PERMITTED_RATIO

while getopts 'rdc:p:q:s:' flag; do
	case "${flag}" in
	r) setRandomWallpaper ;;
	d)
		echo "Fetching image urls"
		getImageUrls
		echo "Downloading the images"
		downloadImages
		;;
	c) setModifiers "category" "${OPTARG}" ;;
	p) setModifiers "purity" "${OPTARG}" ;;
	q) setQuery "${OPTARG}" ;;
	s) setWallpaper "${OPTARG}" ;;
	*)
		echo "wrong flag"
		exit 1
		;;
	esac
done

# while getopts 'rvc:p:q:s:' flag; do
# 	if [[ "$flag" -eq 'c' || "$flag" -eq 'p' || "$flag" -eq 'q']]; then
# 		# [[ $flag -eq 'v' ]] && echo "Fetching the image Urls"
# 		getImageUrls
# 		# [[ $flag -eq 'v' ]] && echo "Downloading the images"
# 		downloadImages
# 		exit 0
# 	fi
# done

# for flag in "$@"; do
# 	echo "$flag"
# done
# make sure to remove the first occurance of #& from the final output
echo "${BASE_URL}${QUERY_PARAMS#&}"
