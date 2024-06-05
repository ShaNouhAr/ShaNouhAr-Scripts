#!/bin/bash
echo "Utilisation CPU :"
top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}' 
echo
echo "Utilisation mémoire :"
free -m | awk 'NR==2{printf "Mémoire utilisée: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
