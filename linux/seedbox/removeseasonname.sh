#!/bin/bash

for oldName in Fairy.Tail.S??E???.MULTI.1080p.BDlight.x265-SAHKELPLAISIR.mkv; do
  newName=$(echo "$oldName" | sed 's/S[0-9][0-9]E//')
  echo "Renommer $oldName en $newName"
  mv "$oldName" "$newName"
done
