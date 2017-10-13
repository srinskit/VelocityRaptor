main(){
	cols=$(tput cols)
	lines=$(tput lines)
	backgroundLetter=Q
	intColor $backgroundLetter
	background=$?
	stty -echo
	tput civis -- invisible
	tput setab $background
	tput clear
	ybounding=15
	run=1
	ox=70
	pox=70
	yox=22
	yp=20
	pyp=20
	vy=0
	pox1=30
	ox1=30
	yox1=10
	model=''
	model+='     B    .'
	model+='    B B   .'
	model+='   BBBBB  .'
	model+='  B BBB B .'
	model+='     B    .'
	while test $run -eq 1; do
		sleep 0.01
		getChar
		case "$charGot" in 
			"q")
				run=0
				break;;
			"w")
				vy=-2
				# moveUp 
				;;
			"s")
				# moveDown 
				;;
		esac
		if test $yp -ne $pyp; then
			eraseModel 20 $pyp "$model"	
		fi
		drawModel 20 $yp "$model"
		pyp=$yp
		((yp+=vy))
		if (($yp >= 19)); then
			vy=0
		fi
		if (($yp <= 10)); then
			vy=2
		fi
		#Lower obstacle
		solidRect $pox $yox 2 3 $background
		solidRect $ox $yox 2 3 2
		pox=$ox
		((ox-=2))
		if (( ox <= 5 )); then
			ox=70
		fi
		#introducing an upper obstacle to avoid user floating in air
		solidRect $pox1 $yox1 2 3 $background
		solidRect $ox1 $yox1 2 3 2
		pox1=$ox1
		((ox1-=2))
		if((ox1<=5))
		then
		ox1=70
		fi
		done
	tput cnorm -- normal
	stty sane
}

charGot=''
getChar(){
	charGot=''
	IFS= read -r -t 0.02 -n 1 -s holder && charGot="$holder"
	#changes mase in to fix the issue 1 to allow continous pressing of 'w'
	if test $yp -le 10
	then
	charGot=''
	fi
}
moveUp(){
	solidRect 10 18 3 5 $background
	solidRect 10 10 3 5 2
	# sleep 1
}
moveDown(){
	solidRect 10 10 3 5 $background
	solidRect 10 18 3 5 2
}

drawModel(){
	x=$1
	xi=$x
	yi=$2
	str=$3
	buff=""
	for ((i=0; i<${#str}; i++)); do
		color="${str:$i:1}"
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
			buff+="\033[$yi;"$xi"f "
			((xi++))
		fi
		echo -ne "$buff"
	done
	tput setab $background
}

eraseModel(){
	str=$3
	newStr=''
	for ((i=0; i<${#str}; ++i)); do
		color="${str:$i:1}"
		if [[ "$color" == "." ]] || [[ "$color" == " " ]]; then
			newStr+=$color
		else
			newStr+=$backgroundLetter
		fi
	done
	drawModel $1 $2 "$newStr"
}

solidRect(){
	x=$1
	y=$2
	w=$3
	h=$4
	color=$5
	tput setab $color
	space=""
	for ((i=0;i<w;++i)); do
		space+="  "
	done
	buff=""
	for ((i=y;i<h+y;++i));do
		buff+="\033[$i;"$x"f$space"
	done
	echo -ne "$buff"
	tput setab $background	
}

intColor(){
	return $(($(printf '%d' "'$1")-65))
}

main
