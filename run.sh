# Limits of terminal
minX=1
minY=1
maxX=$(tput cols)
maxY=$(tput lines)
((maxY++))

# Some consts
timeOutTime=0.03
run=1

# Models
dinoModel=''
dinoModel+='   BBBB.'
dinoModel+=' BBBBBBBBBB.'
dinoModel+=' CCCDDCD.'
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
	upY=$((1*maxY/8))
	# downY=$((maxY-dinoH))
	downY=$((maxY-dinoH-1*maxY/8))	
	midY=$(((upY+downY)/2))
	dinoX=5
	dinoY=$downY
	prevDinoY=$dinoY
	dinoUy=0
	realDinoY=$downY
	halfG=5
	t=0

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
				if ((dinoY > midY)); then
					updateModel $dinoX $upY $dinoX $dinoY "$dinoModel"
					dinoY=$upY
				fi
				# dinoUy=-7
				;;
			"s")
				if ((dinoY < midY)); then
					updateModel $dinoX $downY $dinoX $dinoY "$dinoModel"
					dinoY=$downY
				fi
				;;
		esac
		
		# Falling animation?
		# prevDinoY=$dinoY
		# if ((dinoUy!=0)); then
		# 	realDinoY=$(bc <<< "$realDinoY + $dinoUy*$t+$halfG*$t*$t")
		# 	dinoY=$(bc <<< "$realDinoY/1")
		# 	t=$(bc <<< "$t+0.15")
		# 	if ((dinoY > downY)); then
		# 		dinoY=$downY
		# 		realDinoY=$downY
		# 		t=0
		# 		dinoUy=0				
		# 	fi
		# 	if ((prevDinoY!=dinoY)); then
		# 		# tput clear &
		# 		updateModel $dinoX $dinoY $dinoX $prevDinoY "$dinoModel"
		# 		# drawModel $dinoX $dinoY "$dinoModel"
		# 	fi
		# fi

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
drawModelOld(){
	x=$1
	xi=$x
	yi=$2
	model=$3
	buff=""
	data=""
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
			((xi++))
		fi
	done 
	tput setab $background
}
drawModel(){
	x=$1
	yi=$2
	model=$3
	buff=""
	data=""
	for ((i=0; i<${#model}; i++)); do
		color="${model:$i:1}"
		if [[ "$color" == "." ]]; then
			buff+="\e[$yi;"$x"f$data"
			((yi++))
			data=""
		else
			if [[ "$color" == " " ]]; then
				data+="\e[48;5;$background""m "
				continue
			fi
			intColor $color
			backColor=$?
			data+="\e[48;5;$backColor""m "
		fi
	done 
	buff+="\e[48;5;$background""m"
	echo -en "$buff"
}

# eraseModel x y model
# Replaces pixels of model with background color
eraseModelOld(){
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
eraseModel(){
	x=$1
	yi=$2
	model=$3
	buff=""
	spaces=""
	for ((i=0; i<${#model}; i++)); do
		if [[ "${model:$i:1}" == "." ]]; then
			buff+="\e[$yi;"$x"f\e[48;5;"$background"m$spaces"		
			((yi++))
			spaces=""			
		else
			spaces+=" "
		fi
	done
	buff+="\e[48;5;$background""m"	
	echo -ne "$buff"
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
updateModelOld(){
	eraseModelOld $3 $4 "$5"
	drawModelOld $1 $2 "$5"
}
updateModel(){
	eraseModel $3 $4 "$5"
	drawModel $1 $2 "$5"
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