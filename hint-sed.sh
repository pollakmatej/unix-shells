#
# USEFULL SED HINTS
#

# just print digits only from string
echo "ref12345678" | sed 's/[^0-9]*//g'

# cut last character from string
echo "20956 20957 20960 20961 20962 20963.." | sed 's/.$//'
