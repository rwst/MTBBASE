#!/bin/sh

v=`cat version`
d=`date +%Y-%m-%d`
sed "s/Current version: *[0-9]*</Current version: $v</g; s/Last change: [^<]*</Last change: $d</g" <~/Sites/Site/MTB-GOA.html >MTB-GOA.html

