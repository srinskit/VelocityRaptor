declare -a renderQ
qSize=5
qFront=-1
qRear=-1
qPush(){
	if ((qFront==0 && qRear==qSize-1 || qFront==qRear+1)); then
        return 0
    fi
	if ((qFront==-1)); then
		qFront=0
	fi
    qRear=$(( (qRear+1)%qSize ))
    renderQ[$qRear]=$1
    return 1
}
qPopped=-1
qPop(){
    if ((qFront==-1)); then
        return 0
    fi
    qPopped=${renderQ[$qFront]}
    if ((qFront==qRear)); then
		qFront=-1
        qRear=-1
    else
        qFront=$(( (qFront+1)%qSize ))
	fi
    return 1
}
qEmpty(){
    return $((qFront==-1))
}
# qPush 1; echo $?
# qPush 2; echo $?
# qPush 3; echo $?
# qPush 4; echo $?
# qPop; echo -n $?; echo $qPopped
# qPop; echo -n $?; echo $qPopped
# qPush 5; echo $?
# qPush 6; echo $?
# qPush 7; echo $?
# qPush 8; echo $?
# qPop; echo -n $?; echo $qPopped
# qPop; echo -n $?; echo $qPopped
# qPop; echo -n $?; echo $qPopped
# qPop; echo -n $?; echo $qPopped
# qPop; echo -n $?; echo $qPopped
# qPop; echo -n $?; echo $qPopped
# qPop; echo -n $?; echo $qPopped
# qPop; echo -n $?; echo $qPopped
# qPop; echo -n $?; echo $qPopped
