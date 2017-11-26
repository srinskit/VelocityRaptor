# Limits of terminal
minX=1
minY=1
maxX=$(tput cols)
maxY=$(tput lines)
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
# Todo ignore initial spaces
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
	echo -ne "$buff"
}

# solidRect x y width height color
# Draws a solid rectangle at x, y
solidRect(){
	x=$(($1 < minX ? minX : $1))
	y=$(($2 < mixY ? minY : $2))
	w=$(($1 < minX ? $3+$1 : $3))
	w=$((x+w > maxX ? w - ((x+w)-maxX)+1 : w))
	h=$(($2 < minY ? $4+$2 : $4))
	h=$((y+h > maxY ? h - ((y+h)-maxY)+1 : h))	
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

moveLeftSolidRect(){
	dw=$(($3-$1))
	if ((dw >= $5 || dw <= 0)); then
		updateSolidRect $1 $2 $3 $4 $5 $6 $7
	else
		endx=$(($1+$5))
		solidRect $1 $2 $dw $6 $7
		solidRect $endx $4 $dw $6 $background
	fi
}

# Border
drawBorder(){
	buff=""
	for((i=0;i<maxX;++i)); do
		buff+="#"
	done
	echo -en "\e[0;0f$buff\e[$((maxY));0f$buff"
}