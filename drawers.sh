# intColor colorLetter
# Maps colors A, B, C... to colors 0, 1, 2...
intColor(){
	return $(($(printf '%d' "'$1")-65))
}
randomColor(){
	color=$(($RANDOM%17))
	if ((color==background)); then
		color=0;
	fi
	return $color
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

# updateModel x y prevx prevy model
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
