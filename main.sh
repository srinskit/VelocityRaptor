#!/bin/bash

# Includes
. drawers.sh
. models.sh
. queue.sh
. run.sh
. model_select.sh

# Setup terminal settings
backgroundLetter=Q
intColor $backgroundLetter
background=$?
stty -echo
tput civis -- invisible
tput setab $background
tput clear

exitGame=0
sound=1
quitKey="q"
updateKey="u"
playKey="p"
#pausekey added
pausekey="p"
readmeKey="r"
instKey="i"
continueKey=""
modelSelectKey="m"
soundKey="s"
mainScreen(){
    tput clear
	drawBorder
	echo -ne "\e[$((maxY/2-7/2-3));"$((maxX/2-8/2))"fVELOCITY"    
	drawModel $((maxX/2-31/2)) $((maxY/2-7/2)) "$startModel"
    panelY=$((maxY-2))
	echo -ne "\e[$panelY;"$((4))"fQuit (q)"
	# echo -ne "\e[$panelY;"$((maxX/4-11/2))"fUpdate (u)"            
	echo -ne "\e[$panelY;"$((maxX/2-8/2))"fPlay (p)"
	echo -ne "\e[$panelY;"$((maxX-4-16))"fInstructions (i)"
    panelY=$((maxY-4))    
    if test $sound -eq 1; then
        echo -ne "\e[$panelY;"$((4))"fMute (s)"
    else
        echo -ne "\e[$panelY;"$((4))"fUnmute (s)"
    fi         
	echo -ne "\e[$panelY;"$((maxX/2-16/2))"fSelect Model (m)"
	echo -ne "\e[$panelY;"$((maxX-4-10))"fReadMe (r)"    
	read -n1 charGot
	while [[ "$charGot" != "$quitKey" ]] && [[ "$charGot" != "$updateKey" ]] && [[ "$charGot" != "$playKey" ]]\
     && [[ "$charGot" != "$readmeKey" ]] && [[ "$charGot" != "$instKey" ]] && [[ "$charGot" != "$modelSelectKey" ]] && [[ "$charGot" != "$continueKey" ]]\
     && [[ "$charGot" != "$soundKey" ]]; do
		read -n1 charGot				
	done 
}
updateScreen(){
    doNothing=1
    # git pull origin master
}
readmeScreen(){
    tput clear
    cp README.md .tmp.html
    lynx -dump .tmp.html
}
instScreen(){
    tput clear
    cat instructions
}

while [ $exitGame -eq 0 ]; do
    mainScreen
    case $charGot in 
        $quitKey) 
            break 
            ;;
        $updateKey)
            ;;
        $readmeKey)
            readmeScreen
            read -n1
            ;;
        $instKey)
            instScreen
            read -n1
            ;;
        $modelSelectKey)
            modelSelection
            ;;
        $playKey)
            run=1
            runGame
            ;;
        $continueKey)
            run=1  
            runGame
            ;;        
        $soundKey)
            sound=$((sound==0 ? 1: 0))
            ;;    
    esac
done

tput cnorm -- normal
stty sane
tput clear