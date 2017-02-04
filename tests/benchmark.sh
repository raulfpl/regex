#!/bin/bash

for i in $(seq 1 10)
do
    N=$(($i*20000))
    ./nc $N a > $(($i*20))ka.txt
    ./nc $(($N/2)) ab > $(($i*10))kab.txt
done

PROGS=(re2 haskell-regexp grep igrep)

if ! which gtime &> /dev/null ; then
    GTIME=/usr/bin/time
else
    GTIME=gtime
fi

declare -a COMMANDS=(
    "$GTIME -f \"%e\" ./re2 \"(a + b + ab)*\" < \$N"
    "$GTIME -f \"%e\" haskell-regex-exe \"(a|b|ab)*\" < \$N"
    "$GTIME -f \"%e\" grep -x -E \"(a|b|ab)*\" \$N"
    "$GTIME -f \"%e\" ./verigrep \"(a + b + ab)*\" \$N"
)

for c in a ab
do
    echo -n \#thousands of $c's|' > $c's'.dat

    for p in ${PROGS[@]}
    do
        echo -n $p'|' >> $c's'.dat
    done
    echo -n -e '\n' >> $c's'.dat

    for i in $(seq 1 10)
    do
        N=$(($i*20/${#c}))k$c".txt"
        echo -n ${N%k*} >> $c's'.dat
        for ((p=0;p<${#PROGS[@]};p++))
        do
            echo -n -e '\t' >> $c's'.dat
            echo -n $(eval ${COMMANDS[$p]} 2>&1 1>/dev/null) >> $c's'.dat
        done
        echo -n -e '\n' >> $c's'.dat

    done
    echo -ne "\n" >> $c's'.dat

done

rm *ka.txt
rm *kab.txt
