#!/bin/bash
# Includes
. drawers.sh
. models.sh
. queue.sh
	
# Some consts
timeOutTime=0.03
run=0

quitKey="q"
continueKey=""
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

	# Physics vars
	init(){
		score=-1
		level=0
		upperObstacleX=$((maxX/2))
		pUpperObstacleX=$upperObstacleX
		upperObstacleY=$((maxY/4-obstacleH/2))
		lowerObstacleX=$((maxX))	
		lowerObstacleY=$((3*maxY/4-obstacleH/2))	
		pLowerObstacleX=$lowerObstacleX
		randomColor
		lowerObstacleColor=$?
		randomColor	
		upperObstacleColor=$?
		obstacleV=$((level+2))		
		dinoX=$obstacleW
		dinoY=$downY
		pDinoY=$dinoY
		dinoUy=0	
	}

	obstacleW=$((maxX/10))
	obstacleH=$((obstacleW/2))
	dinoW=9
	dinoH=6
	
	upY=$((maxY/4-obstacleH/2))
	downY=$((3*maxY/4-obstacleH/2+obstacleH-dinoH))
	midY=$(((upY+downY)/2))
	init
		
	# renderQueuer &
	# renderQueuerPid=$?
	soundpid=-1

	displayScore(){
		((score++))
		if ((score%5==0)); then		
			((level++))
			obstacleV=$((level+2))			
		fi
		echo -ne "\e[$((maxY-4));"$((maxX/2-10/2-2))"f Level : $level"		
		echo -ne "\e[$((maxY-3));"$((maxX/2-10/2-2))"f Score : $score"
	}

	tput clear
	drawBorder
	drawModel $((maxX/2-25)) $((maxY/3)) "$startModel"
	echo -ne "\e[$((2*maxY/3));"$((maxX/2-20/2-2))"f Hit space to start!"
	echo -ne "\e[$((2*maxY/3+1));"$((maxX/2-16/2-2))"f Hit q to quit!"	
	read -n1 charGot
	while [[ "$charGot" != "$quitKey" ]] && [[ "$charGot" != "$continueKey" ]]; do
		read -n1 charGot				
	done 
	if [[ "$charGot" == "$quitKey" ]]; then	
		tput clear
		run=0	
	else
		run=1
	fi
	modelSelection(){
		tput clear
		drawBorder		
		drawModel $((maxX/4-dinoW/2)) $((maxY/4)) "$marioModel"
		echo -ne "\e[$((maxY/2-3));"$((maxX/4))"f1"		
		drawModel $((2*maxX/4-9/2)) $((maxY/4)) "$rocketModelV"
		echo -ne "\e[$((maxY/2-3));"$((2*maxX/4))"f2"				
		drawModel $((3*maxX/4-5)) $((maxY/4)) "$rocketModel"
		echo -ne "\e[$((maxY/2-3));"$((3*maxX/4))"f3"				
		echo -ne "\e[$((2*maxY/3));"$((maxX/2-14/2))"fSelect Model!"
		read -n1 Modelnum
		case $Modelnum in
			1)
				model="$marioModel"		
				dinoH=7
				dinoW=12
				;;
			3)
				model="$rocketModel"
				dinoH=7
				dinoW=12
				;;
			"$quitKey")
				run=0
				;;
			*)
				model="$rocketModelV"
				dinoH=6
				dinoW=9
				;;
		esac
	}
	if [ $run -eq 1 ]; then
		modelSelection
		tput clear
		if [ $run -eq 1 ]; then
			drawModel $dinoX $dinoY "$model"
			displayScore
		fi
	fi
	while test $run -eq 1; do
		getChar $timeOutTime
		if [[ "$charGot" != "" ]]; then
			sleep $timeOutTime
		fi
		case "$charGot" in 
			"$quitKey")
				run=0 ;;
			"w")
			    if ((dinoY >= upY && dinoUy != -2)); then
					dinoUy=-2
					# Possible bug; pid already assigned to other process?
					if ((dinoY >upY)); then
						kill -0 $soundpid 2> /dev/null
						if ((soundpid==-1 || $? == 1)); then
							paplay sounds/jump.wav &	
							soundpid=$!
						fi
					fi
				fi ;;
			"s") ;;
		esac
		pDinoY=$dinoY
		((dinoY+=dinoUy))
		if ((dinoY > downY)); then
			dinoY=$downY		
			dinoUy=0
		fi
		if ((dinoY < upY)); then
			dinoY=$upY
			dinoUy=2
		fi
		if ((pDinoY!=dinoY)); then
			# updateModel $dinoX $dinoY $dinoX $pDinoY "$model" 
			updateModel $dinoX $dinoY $dinoX $pDinoY "$model"
		fi
		moveLeftSolidRect $lowerObstacleX $lowerObstacleY $pLowerObstacleX $lowerObstacleY $obstacleW $obstacleH $lowerObstacleColor
		if (( dinoX + dinoW >= lowerObstacleX && dinoX <= lowerObstacleX+obstacleW && dinoY + dinoH >= lowerObstacleY && dinoY <= lowerObstacleY+obstacleH )); then
			drawModel $dinoX $dinoY "$model"
			run=0
		fi
		if (( dinoX + dinoW >= upperObstacleX && dinoX <= upperObstacleX+obstacleW && dinoY + dinoH >= upperObstacleY && dinoY <= upperObstacleY+obstacleH )); then
			drawModel $dinoX $dinoY "$model"
			run=0
		fi
		pLowerObstacleX=$lowerObstacleX
		((lowerObstacleX-=obstacleV))
		if (( lowerObstacleX < -obstacleW-obstacleV)); then
			lowerObstacleX=$((maxX))
			randomColor
			lowerObstacleColor=$?
			displayScore			
		fi
		moveLeftSolidRect $upperObstacleX $upperObstacleY $pUpperObstacleX $upperObstacleY $obstacleW $obstacleH $upperObstacleColor	
		pUpperObstacleX=$upperObstacleX
		((upperObstacleX-=obstacleV))
		if (( upperObstacleX < -obstacleW-obstacleV)); then
			upperObstacleX=$((maxX))
			randomColor
			upperObstacleColor=$?
			displayScore						
		fi

		# ((x=dinoX+dinoW))
		# ((y=lowerObstacleX+2))
		# ((z=$lowerObstacleX+$obstacleW+1))
		# if [ $x -gt $y ] && [ $dinoY -gt $lowerObstacleY ] || [ $dinoX -gt $z ] && [ $dinoY -gt $lowerObstacleY ]; then
		# 	run=0
		# fi
		# ((x=dinoX+dinoW))		
		# ((y1=upperObstacleX+2))
		# ((z=$upperObstacleX+$obstacleW+1))
		# if [ $x -gt $y1 ] && [ $dinoY -lt $upperObstacleY ] || [ $dinoX -gt $z ] && [ $dinoY -lt $upperObstacleY ];then
		# 	run=0			
		# fi

		if [ $run -eq 0 ]; then
			echo -ne "\e[$((maxY/2));"$((maxX/2-10/2-2))"fGAME OVER!"			
			read -n1 charGot
			while [[ "$charGot" != "$continueKey" ]]; do
				read -n1 charGot				
			done
			tput clear
			drawBorder
			displayScore
			drawModel $((maxX/2-20)) $((maxY/3)) "$endModel"
			echo -ne "\e[$((2*maxY/3));"$((maxX/2-22/2-2))"f Hit space to replay!"
			echo -ne "\e[$((2*maxY/3+1));"$((maxX/2-16/2-2))"f Hit q to quit!"	
			read -n1 charGot
			while [[ "$charGot" != "$quitKey" ]] && [[ "$charGot" != "$continueKey" ]]; do
				read -n1 charGot				
			done 
			tput clear
			if [[ "$charGot" == "$quitKey" ]]; then
				run=0	
			else
				run=1
				init
				modelSelection
			fi
			tput clear
			if [ $run -eq 1 ]; then
				init
				drawModel $dinoX $dinoY "$model"
				displayScore
			fi
		fi	
	done
	# kill $renderQueuerPid
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

# log into log file
log(){
	cat >> log <<< "$@"
}

renderQueuer(){
	while true; do
		qEmpty
		if [ $? -eq 0 ]; then
			qPop
			echo $qPopped
		fi
	done
}

main
