#!/bin/bash
US_ID=100
GR_ID=82
BASEVOL=./piw_vols
if [ ! -d ${BASEVOL} ]; then
  mkdir $BASEVOL
fi
for i in _data themes plugins local template-extension upload galleries; do
  if [ ! -d ${BASEVOL}/${i} ]; then
    mkdir ${BASEVOL}/${i}
  fi
  chown ${US_ID}:${GR_ID} ${BASEVOL}/${i}
done
