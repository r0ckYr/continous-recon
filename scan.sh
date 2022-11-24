#!/bin/bash

subdomains(){
    recon.py $1 2>/dev/null
    subfinder -silent -d $1
    findomain -q -t $1 2>/dev/null
    #amass enum -passive -nocolor -nolocaldb -config ~/tools/amass/config.ini -d $1 2>/dev/null
}


notify(){
    if [[ -s temp ]];then
        echo "Subdomains found for : $1" | notify.py > /dev/null
        cat temp | notify.py > /dev/null
    fi
}


enumerate(){
    cat temp | httpx -sc -cl -title -nc -td -location -silent -ports 443,80,4443,4080,8080,8000,9080,7443,8443,10000,3000,6080,9001 | anew data/$1.httpx > /dev/null
}


#not using it ;|
fuzz(){
    cat $1 | httpx -path ~/tools/tools/files/secret-files -sc -nc -title -cl -location -silent -t 200 -td | tee -a $1.fuzz > /dev/null
}


if [[ ! -d data ]];then
    mkdir data
fi

while :
do
    for i in $(cat root)
    do
        subdomains $i | dnsx -silent | anew domains | tee -a new_domains | tee -a temp
        notify $i
        if [[ -s temp ]];then
            enumerate $i
        fi
        rm temp
    done
    echo '[*]Waiting for next iteration....\n\n'
    sleep 3600
done
