raptor="$rocketModelV"
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
            raptor="$marioModel"		
            dinoH=7
            dinoW=12
            ;;
        3)
            raptor="$rocketModel"
            dinoH=7
            dinoW=12
            ;;
        "$quitKey")
            run=0
            ;;
        *)
            raptor="$rocketModelV"
            dinoH=6
            dinoW=9
            ;;
    esac
}