#!/bin/bash

# if mac change stata command for batch
if [ -a /Applications/Stata/StataMP.app/Contents/MacOS/StataMP ] ; then 
    stata="/Applications/Stata/StataMP.app/Contents/MacOS/StataMP -b"
else
    stata=stata
fi

python -m clean.psid.io --rebuild-all
python -m clean.bank_panels
$stata do clean/make_panel_with_weights.do
$stata do clean/make_ES_data.do

