#!/bin/bash

# Puts all the PSID codebooks into one folder, converting PDF to text when
# needed

SRC_PATH=/d/data/bIncome/src/psid
DEST_PATH=/d/data/bIncome/codebooks

formating () {
    # Args: file path, variable prefix (V or ER), max page number
    sed -i "/Page .* of $3/d" $TXT_PATH
    sed -i "/^ *$/d" $1
    sed -i "/^$2.*/! s/^/    /" $1
    sed -i "/^$2.*/ s/^/\n/" $1
}

# PDF to text
if [ "a" = "a" ]; then
    TXT_PATH=$DEST_PATH/1993.txt
    pdftotext.exe -layout $SRC_PATH/fam_1993/fam1993_codebook.pdf $TXT_PATH
    sed -i "/1993 Family Data/d" $TXT_PATH
    formating $TXT_PATH "V" "471"

    TXT_PATH=$DEST_PATH/1994.txt
    pdftotext.exe -layout $SRC_PATH/fam_1994/fam1994er_codebook.pdf $TXT_PATH
    sed -i "/DYNAMICS: 1994 PUBLIC/d" $TXT_PATH
    formating $TXT_PATH "ER" "667"

    TXT_PATH=$DEST_PATH/1995.txt
    pdftotext.exe -layout $SRC_PATH/fam_1995/fam1995er_codebook.pdf $TXT_PATH
    sed -i "/DYNAMICS: 1995 PUBLIC/d" $TXT_PATH
    formating $TXT_PATH "ER" "611"

    TXT_PATH=$DEST_PATH/1996.txt
    pdftotext.exe -layout $SRC_PATH/fam_1996/fam1996er_codebook.pdf $TXT_PATH
    sed -i "/DYNAMICS: 1997 PUBLIC/d" $TXT_PATH
    formating $TXT_PATH "ER" "718"

    TXT_PATH=$DEST_PATH/1997.txt
    pdftotext.exe -layout $SRC_PATH/fam_1997/fam1997er_codebook.pdf $TXT_PATH
    sed -i "/DYNAMICS: 1997 PUBLIC/d" $TXT_PATH
    formating $TXT_PATH "ER" "659"

    TXT_PATH=$DEST_PATH/1999.txt
    pdftotext.exe -layout $SRC_PATH/fam_1999/fam1999er_codebook.pdf $TXT_PATH
    sed -i "/DYNAMICS: 1999 PUBLIC/d" $TXT_PATH
    formating $TXT_PATH "ER" "1023"

    TXT_PATH=$DEST_PATH/2001.txt
    pdftotext.exe -layout $SRC_PATH/fam_2001/fam2001er_codebook.pdf $TXT_PATH
    sed -i "/DYNAMICS: 2001 PUBLIC/d" $TXT_PATH
    formating $TXT_PATH "ER" "982"

    TXT_PATH=$DEST_PATH/2003.txt
    pdftotext.exe -layout $SRC_PATH/fam_2003/fam2003er_codebook.pdf $TXT_PATH
    sed -i "/DYNAMICS: 2003 PUBLIC/d" $TXT_PATH
    formating $TXT_PATH "ER" "927"

    TXT_PATH=$DEST_PATH/2005.txt
    pdftotext.exe -layout $SRC_PATH/fam_2005/fam2005er_codebook.pdf $TXT_PATH
    sed -i "/DYNAMICS: 2005 PUBLIC/d" $TXT_PATH
    formating $TXT_PATH "ER" "785"

    TXT_PATH=$DEST_PATH/2007.txt
    pdftotext.exe -layout $SRC_PATH/fam_2007/fam2007er_codebook.pdf $TXT_PATH
    sed -i "/DYNAMICS: 2007 PUBLIC/d" $TXT_PATH
    formating $TXT_PATH "ER" "1497"
fi

for year in ` seq 1974 1992 `;
do
    cp $SRC_PATH/fam_$year/FAM${year}DOC.txt $DEST_PATH/${year}.txt
done
