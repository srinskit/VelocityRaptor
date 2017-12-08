# Some consts
timeOutTime=0.03
WalkMode=0
JumpMode=1
JumpLevel=3
GodMode=2
GodLevel=6
jumpCounter=0
# Logic
runGame(){
	tput clear
	obstacleW=$((maxX/10))
	obstacleH=$((obstacleW/2))
	dinoW=9
	dinoH=6
	
	midY=$((maxY/2))
	upY=$((midY-obstacleH-5))
	downY=$((midY+obstacleH+5))
	score=-1
	level=0
	upperObstacleX=$((maxX/2))
	pUpperObstacleX=$upperObstacleX
	upperObstacleY=$upY
	lowerObstacleX=$((maxX))	
	lowerObstacleY=$((downY-obstacleH))	
	pLowerObstacleX=$lowerObstacleX
	randomColor
	lowerObstacleColor=$?
	randomColor	
	upperObstacleColor=$?
	obstacleV=$((level+2))		
	dinoX=$obstacleW
	dinoY=$((downY-dinoH))
	pDinoY=$dinoY
	dinoUy=0	
	gameMode=$WalkMode		
	gameMode=$GodMode
	gameMode=$JumpMode	
	nextGameMode=$gameMode	
		
	soundpid=-1

	displayScore(){
		((score++))
		if ((score%5==0)); then		
			((level++))
			obstacleV=$((level+2))			
			if ((level>=GodLevel)); then
				nextGameMode=$GodMode
			elif ((level>=JumpLevel)); then
				nextGameMode=$JumpMode
			else
				nextGameMode=$WalkMode
			fi
		fi	
		echo -ne "\e[$((maxY-4));"$((maxX/2-10/2-2))"f Level : $level"		
		echo -ne "\e[$((maxY-3));"$((maxX/2-10/2-2))"f Score : $score"
	}
	
	drawModel $dinoX $dinoY "$raptor"
	displayScore	
	while test $run -eq 1; do
		getChar $timeOutTime
		if [[ "$charGot" != "" ]]; then
			sleep $timeOutTime
		fi
		case "$charGot" in 
			"$quitKey")
				run=0 ;;
			"w")
				if ((dinoY > upY && dinoUy != -2)); then
					dinoUy=-2
					# Possible bug; pid already assigned to other process?
					if ((sound==1)); then
						kill -0 $soundpid 2> /dev/null
						if ((soundpid==-1 || $? == 1)); then
							paplay sounds/jump.wav &	
							soundpid=$!
						fi
					fi
				fi
				;;
			"s")
				if ((dinoY + dinoH < downY && dinoUy != 2)); then
					dinoUy=2
					# Possible bug; pid already assigned to other process?
					if ((sound==1)); then
						kill -0 $soundpid 2> /dev/null
						if ((soundpid==-1 || $? == 1)); then
							paplay sounds/jump.wav &	
							soundpid=$!
						fi
					fi
				fi
				;;
			$pausekey)
			pause=1
			while [ $pause -eq 1 ]
			do
			read -n1 pause_char
			if [ $pause_char=="p" ]
			then
			pause=0
			fi
			done
		esac
		pDinoY=$dinoY
		if ((gameMode == WalkMode)); then
			((dinoY+=dinoUy))
			if ((dinoY + dinoH > downY)); then
				dinoY=$((downY-dinoH))
				dinoUy=0
			fi
			if ((dinoY < upY)); then
				dinoY=$upY
				dinoUy=0
			fi
		elif ((gameMode == JumpMode)); then
			if ((dinoUy != 0)); then
				((jumpCounter++))
				if ((jumpCounter > 10)); then
					if ((dinoUy > 0)); then
						dinoY=$((downY-dinoH))
					fi
					if ((dinoUy < 0)); then					
						dinoY=$((upY))					
					fi
					dinoUy=0
					jumpCounter=0
				else
					dinoY=$((midY-dinoH/2))
				fi
			fi
		elif ((gameMode == GodMode)); then
			if ((dinoUy > 0)); then
				dinoY=$((downY-dinoH))
				dinoUy=0
			fi
			if ((dinoUy < 0)); then
				dinoY=$upY
				dinoUy=0
			fi
		fi
		if ((dinoUy==0 && nextGameMode!=gameMode)); then
			gameMode=$nextGameMode
			if ((gameMode==WalkMode)); then
				modeName="WALK"
			elif ((gameMode==JumpMode)); then
				modeName="JUMP"			
			elif ((gameMode==GodMode)); then
				modeName="GOD "
			fi
			echo -ne "\e[$((maxY-1));"$((maxX/2-10/2-1))"f$modeName MODE"
			clearTitle(){
				doNothing=1
			}
			clearTitle
		fi
		moveLeftSolidRect $lowerObstacleX $lowerObstacleY $pLowerObstacleX $lowerObstacleY $obstacleW $obstacleH $lowerObstacleColor
		if (( dinoX + dinoW >= lowerObstacleX && dinoX <= lowerObstacleX+obstacleW && dinoY + dinoH >= lowerObstacleY && dinoY <= lowerObstacleY+obstacleH )); then
			drawModel $dinoX $dinoY "$raptor"
			run=0
		fi
		if (( dinoX + dinoW >= upperObstacleX && dinoX <= upperObstacleX+obstacleW && dinoY + dinoH >= upperObstacleY && dinoY <= upperObstacleY+obstacleH )); then
			drawModel $dinoX $dinoY "$raptor"
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

		if ((pDinoY!=dinoY)); then
			updateModel $dinoX $dinoY $dinoX $pDinoY "$raptor"
		fi
		if [ $run -eq 0 ]; then
			echo -ne "\e[$((maxY/2));"$((maxX/2-10/2-2))"fGAME OVER!"			
			read -n1 charGot
			while  [[ "$charGot" != "$quitKey" ]] && [[ "$charGot" != "$continueKey" ]]; do
				read -n1 charGot				
			done
		fi	
	done
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