#!/bin/bash

while [ 1=1 ]
do
lastlog | awk '!/Nov/ {print}'
sleep 30
done
