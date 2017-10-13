# Limits of terminal
minX=1
minY=1
maxX=$(tput cols)
maxY=$(tput lines)

# Some consts
timeOutTime=0.03
run=1

# Models
dinoModel=''
dinoModel+='   BBBB.'
dinoModel+=' BBBBBBBBBB.'
dinoModel+=' CCCDDCD .'
dinoModel+='CDCDDDCDDDD.'
dinoModel+='CDCCDDDCDDDD.'
dinoModel+='CCDDDDCCCC.'
dinoModel+='  DDDDDDD.'	

# Logic
main(){
	# Setup terminal settings
	backgroundLetter=Q
	intColor $backgroundLetter
	background=$?
	stty -echo
	tput civis -- invisible
	tput setab $background
	tput clear

	dinoW=11
	dinoH=7
	dinoX=10
	dinoY=$((maxY-dinoH))
		prevDinoY=$dinoY
	dinoVy=0
	dinoJumpLimit=$((2*maxY/3))

	obstacleX=$((maxX-10))
	prevObstacleX=$obstacleX
	obstacleY=$((maxY-3))
	drawModel $dinoX $dinoY "$dinoModel"
	while test $run -eq 1; do
		getChar $timeOutTime
		if [[ "$charGot" != "" ]]; then
			sleep $timeOutTime
		fi
		case "$charGot" in 
			"q")
				run=0
				break
				;;
			"w")
				if ((dinoVy == 0)); then
					dinoVy=-5
					updateModel $dinoX $dinoJumpLimit $dinoX $dinoY "$dinoModel"
				fi
				;;
			"s")
				;;
		esac
		prevDinoY=$dinoY
		((dinoY+=dinoVy))
		if ((dinoY+dinoH > maxY)); then
			((dinoY-=dinoVy))
			dinoVy=0
			updateModel $dinoX $dinoY $dinoX $dinoJumpLimit "$dinoModel"
		fi
		if ((dinoY<dinoJumpLimit)); then
			((dinoY+=dinoVy))
			dinoVy=5
		fi
		# if test $dinoVy -ne 0; then
		# 	updateModel $dinoX $dinoY $dinoX $prevDinoY "$dinoModel"
		# fi
		# updateSolidRect $obstacleX $obstacleY $prevObstacleX $obstacleY 2 3 1
		prevObstacleX=$obstacleX
		((obstacleX-=2))
		if (( obstacleX <= 5 )); then
			obstacleX=$((maxX-10))
		fi
	done
	tput cnorm -- normal
	stty sane
}

# getChar timeout
# Saves key in charGot; Blocks for timeout amount of time
charGot=''
getChar(){
	charGot=''
	IFS= read -r -t $1 -n 1 -s holder && charGot="$holder"
}


# drawModel x y model
# Draws model model
drawModel(){
	x=$1
	xi=$x
	yi=$2
	model=$3
	buff=""
	for ((i=0; i<${#model}; i++)); do
		color="${model:$i:1}"
		if [[ "$color" == "." ]]; then
			((yi++))
			((xi=x))
		else
			if [[ "$color" == " " ]]; then
				((xi++))
				continue
			fi
			intColor $color
			tput setab $?
			echo -ne "\033[$yi;"$xi"f "
			wait
			((xi++))
		fi
	done 
	tput setab $background
}

# eraseModel x y model
# Replaces pixels of model with background color
eraseModel(){
	model=$3
	newModel=''
	for ((i=0; i<${#model}; ++i)); do
		color="${model:$i:1}"
		if [[ "$color" == "." ]] || [[ "$color" == " " ]]; then
			newModel+=$color
		else
			newModel+=$backgroundLetter
		fi
	done 
	drawModel $1 $2 "$newModel"
}

# solidRect x y width height color
# Draws a solid rectangle at x, y
solidRect(){
	x=$1
	y=$2
	w=$3
	h=$4
	color=$5
	tput setab $color
	space=""
	for ((i=0;i<w;++i)); do
		space+=" "
	done
	buff=""
	for ((i=y;i<h+y;++i));do
		buff+="\033[$i;"$x"f$space"
	done
	echo -ne "$buff"
	tput setab $background	
}

# intColor colorLetter
# Maps colors A, B, C... to colors 0, 1, 2...
intColor(){
	return $(($(printf '%d' "'$1")-65))
}

# updateModel x- y prevx prevy model
# Erases previous model and draws new one
updateModel(){
	# Todo Fix this bug
	log "Started erase" $2
	eraseModel $3 $4 "$5"
	log "Finished erase" $2
	log "Started draw" $2
	drawModel $1 $2 "$5"
	log "Finished draw" $2
}

# updateSolidRect x y prevx prevy width height color
# Erases previous rect and draws new one
updateSolidRect(){
	solidRect $3 $4 $5 $6 $background
	solidRect $1 $2 $5 $6 $7
}


# log into log file
log(){
	cat >> log <<< "$@"
}

main