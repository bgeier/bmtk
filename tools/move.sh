#!/bin/bash
# moves files from current folder to bmtk tree
for f in *.m
do 
    of=$(find ../ -name $f|grep -v rnlib ) 
    #echo $f,$of
    if [ ! -z "$of" ]; then 
	echo $f
	mv $f ${of%/*} 
    fi
done
