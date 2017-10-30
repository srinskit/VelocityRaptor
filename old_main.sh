#!/bin/bash
# Includes
. drawers.sh
. models.sh
. queue.sh

# Limits of terminal
minX=1
minY=1
maxX=$(tput cols)
maxY=$(tput lines)

# Some consts
timeOutTime=0.03
run=1

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
	
	# Border
	for((i=0;i<maxX;++i)); do
		buff+="#"
	done
	echo -en "\e[0;0f$buff\e[$maxY;0f$buff"
	
	# Obstacle attributes
	obstacleW=$((maxX/10))
	obstacleH=$((obstacleW/2))
	upperObstacleX=$((maxX-obstacleW))
	pUpperObstacleX=$upperObstacleX
	upperObstacleY=$((maxY/4-obstacleH/2))
	lowerObstacleX=$((maxX-obstacleW-maxX/2))
	lowerObstacleY=$((3*maxY/4-obstacleH/2))	
	pLowerObstacleX=$lowerObstacleX

	

	# Raptor attributes; Width, Height, etc
	dinoW=7
	dinoH=5
	# Raptor upperlimit, lowerLimit 
	upY=$((1*maxY/8))
	downY=$((maxY-dinoH-1*maxY/8))
	midY=$(((upY+downY)/2))
	dinoX=$obstacleW
	dinoY=$downY
	pDinoY=$dinoY
	dinoUy=0
	
	# realDinoY=$downY
	# halfG=5
	# t=0

	
	randomColor
	lowerObstacleColor=$?
	randomColor	
	upperObstacleColor=$?
	# renderQueuer &
	# renderQueuerPid=$?
	score=0
	level=1
	drawModel $dinoX $dinoY "$rocketModelV"
	while test $run -eq 1; do
		getChar $timeOutTime
		if [[ "$charGot" != "" ]]; then
			sleep $timeOutTime
		fi
		case "$charGot" in 
			"q")
				run=0
				;;
			"w")
				if ((dinoY >= upY)); then
					((dinoUy=-2))
					# ((score+=5))
				fi
				;;
			"s")
				;;
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
			# updateModel $dinoX $dinoY $dinoX $pDinoY "$rocketModelV" 
			updateModel $dinoX $dinoY $dinoX $pDinoY "$rocketModelV" &		
		fi
		
		updateSolidRect $lowerObstacleX $lowerObstacleY $pLowerObstacleX $lowerObstacleY $obstacleW $obstacleH $lowerObstacleColor
		# updateSolidRect $lowerObstacleX $lowerObstacleY $pLowerObstacleX $lowerObstacleY $obstacleW $obstacleH 2 &				
		pLowerObstacleX=$lowerObstacleX
		if [ $score -eq 10 ]
		then 
		((level+=1))
		((score+=1))
		fi
		((lowerObstacleX-=1+level))
		if (( lowerObstacleX <= 0 )); then
			lowerObstacleX=$((maxX-obstacleW))
			randomColor
			lowerObstacleColor=$?
		fi

		updateSolidRect $upperObstacleX $upperObstacleY $pUpperObstacleX $upperObstacleY $obstacleW $obstacleH $upperObstacleColor	
		# updateSolidRect $upperObstacleX $upperObstacleY $pUpperObstacleX $upperObstacleY $obstacleW $obstacleH 2 &
		pUpperObstacleX=$upperObstacleX
		((upperObstacleX-=1+level))
		if (( upperObstacleX <= 0 )); then
			upperObstacleX=$((maxX-obstacleW))
			randomColor
			upperObstacleColor=$?
		fi
		((x=dinoX+dinoW))
		((y=lowerObstacleX+1))
		((z=$lowerObstacleX+$obstacleW))
		if [ $x -gt $y ] && [ $dinoY -gt $lowerObstacleY ] || [ $dinoX -gt $z ] && [ $dinoY -gt $lowerObstacleY ];then
			# echo $dinoX $dinoW $lowerObstacleX
			run=0
		fi
		((y1=upperObstacleX+1))
		((z=$upperObstacleX+$obstacleW+1))
		if [ $x -gt $y1 ] && [ $dinoY -lt $upperObstacleY ] || [ $dinoX -gt $z ] && [ $dinoY -lt $upperObstacleY ];then
			# echo $dinoX $dinoW $lowerObstacleX
			run=0
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

# if ((dinoY < midY)); then
# 	updateModel $dinoX $downY $dinoX $dinoY "$rocketModelV"
# 	dinoY=$downY
# fi
# if ((dinoY > midY)); then
# 	updateModel $dinoX $upY $dinoX $dinoY "$rocketModelV"
# 	dinoY=$upY
# fi
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
# 	if ((pDinoY!=dinoY)); then
# 		tput clear
# 		# updateModel $dinoX $dinoY $dinoX $pDinoY "$rocketModelV" 
# 		sleep 0.005
# 		drawModel $dinoX $dinoY "$rocketModelV"
# 	fi
# fi
