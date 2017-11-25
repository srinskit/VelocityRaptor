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
sound=0
quitKey="q"
updateKey="u"
playKey="p"
readmeKey="r"
instKey="i"
continueKey=""
modelSelectKey="m"

mainScreen(){
    tput clear
	drawBorder
	echo -ne "\e[$((maxY/2-7/2-3));"$((maxX/2-8/2))"fVELOCITY"    
	drawModel $((maxX/2-31/2)) $((maxY/2-7/2)) "$startModel"
    panelY=$((maxY-2))
	echo -ne "\e[$panelY;"$((4))"fQuit (q)"
	echo -ne "\e[$panelY;"$((maxX/4-11/2))"fUpdate (u)"            
	echo -ne "\e[$panelY;"$((maxX/2-8/2))"fPlay (p)"
	echo -ne "\e[$panelY;"$((3*maxX/4-10/2))"fReadMe (r)"    
	echo -ne "\e[$panelY;"$((maxX-4-16))"fInstructions (i)"
	read -n1 charGot
	while [[ "$charGot" != "$quitKey" ]] && [[ "$charGot" != "$updateKey" ]] && [[ "$charGot" != "$playKey" ]]\
     && [[ "$charGot" != "$readmeKey" ]] && [[ "$charGot" != "$instKey" ]] && [[ "$charGot" != "$modelSelectKey" ]] && [[ "$charGot" != "$continueKey" ]]; do
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
    esac
done

tput cnorm -- normal
stty sane
tput clear