#!/bin/bash
# Script to generate po files outside of the normal build process
#  
# Pre-requisite:
# The following tools must be installed on your system and accessible from path
# gawk, find, xgettext, sed, python, msguniq, msgmerge, msgattrib, msgfmt, msginit
#
# Run this script from within the po folder.
#
# Author: Pr2 for OpenPLi Team
# Version: 1.1
#
# Retrieve languages from Makefile.am LANGS variable for backward compatibility
#
localgsed="sed"
findoptions=""

#
# Script only run with sed but on some distro normal sed is already sed so checking it.
#
sed --version 2> /dev/null | grep -q "GNU"
if [ $? -eq 0 ]; then
	localgsed="sed"
else
	"$localgsed" --version | grep -q "GNU"
	if [ $? -eq 0 ]; then
		printf "GNU sed found: [%s]\n" $localgsed
	fi
fi

which python
if [ $? -eq 1 ]; then
	printf "python not found on this system, please install it first or ensure that it is in the PATH variable.\n"
	exit 1
fi

#
# On Mac OSX find option are specific
#
if [[ "$OSTYPE" == "darwin"* ]]
	then
		# Mac OSX
		printf "Script running on Mac OSX [%s]\n" "$OSTYPE"
    	findoptions=" -s -X "
        localgsed="gsed"
fi

#
# Arguments to generate the pot and po files are not retrieved from the Makefile.
# So if parameters are changed in Makefile please report the same changes in this script.
#
printf "Creating temporary file enigma2-py.pot\n"
find $findoptions .. -name "*.py" -exec xgettext --no-wrap -L Python --from-code=UTF-8 -kpgettext:1c,2 --add-comments="TRANSLATORS:" -d EnhancedMovieCenter -s -o EnhancedMovieCenter-py.pot {} \+
$localgsed --in-place EnhancedMovieCenter-py.pot --expression=s/CHARSET/UTF-8/
printf "Creating temporary file EnhancedMovieCenter-xml.pot\n"
find $findoptions .. -name "*.xml" -exec python ./../xml2po.py {} \+ > EnhancedMovieCenter-xml.pot
printf "Merging pot files to create: EnhancedMovieCenter.pot\n"
cat EnhancedMovieCenter-py.pot EnhancedMovieCenter-xml.pot | msguniq -s --no-wrap --no-location -o EnhancedMovieCenter.pot -
#printf "remove pot Creation date\n"
#$localgsed -i -e'/POT-Creation/d' EnhancedMovieCenter.pot
printf "remove temp pot files\n"
rm EnhancedMovieCenter-py.pot EnhancedMovieCenter-xml.pot
printf "pot update from script finished!\n"
