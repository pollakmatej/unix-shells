#
# .ps1determine
#
# purpose: customizing ps1 prompt, ~/.bashrc, ~/.kshrc are env configs, 
#
# author: matej pollak
#
# version: 1.0.1
#
# history:
#   2018-04-06 v101 matej pollak
#     - bash, escaping colorizing vars by \[ \] for long typing newline
#     - ksh, colorize ps1 properly
#

#
# some comment
#

# basic data
HostName=$(hostname | cut -d '.' -f1)
LoginUID=$(id | awk '{print $1}' | sed 's/[^0-9]*//g')


# define colorize variables
FontRed16="\033[91m"
FontGreen16="\033[92m"
FontRed256="\033[38;5;9m"
FontGreen256="\033[38;5;10m"
ResetAllColors="\033[0m"


# $0 is determine shell type
case $0 in

  *bash*)
    if [ ${LoginUID} -eq 0 ]; then
      printf -- "${FontRed16} -> ${0} shell detected and UID is ${LoginUID}!${ResetAllColors}\n";
      PS1="\[${FontRed16}\]\u@\h $(uname -s):\w # \[${ResetAllColors}\]";

    elif [ ${LoginUID} -gt 0 ]; then
      printf -- "${FontGreen16} -> ${0} shell detected and UID is ${LoginUID}.${ResetAllColors}\n";
      PS1="\[${FontGreen16}\]\u@\h $(uname -s):\w $ \[${ResetAllColors}\]";

    else
      printf -- "non determined user found!\n";
    fi

    export PS1;
  ;;


  *ksh*)
    if [ ${LoginUID} -eq 0 ]; then
      printf -- "${FontRed16} -> ${0} shell detected and UID is ${LoginUID}!${ResetAllColors}\n";
      PS1="$(printf -- "${FontRed16}$(logname)@${HostName}-$(uname -s):\${PWD##*/} > ${ResetAllColors}")";

    elif [ ${LoginUID} -gt 0 ]; then
      printf -- "${FontGreen16} -> ${0} shell detected and UID is ${LoginUID}.${ResetAllColors}\n";
      PS1="$(printf -- "${FontGreen16}$(logname)@${HostName}-$(uname -s):\${PWD##*/} > ${ResetAllColors}")";

    else
      printf -- "non determined user found!\n";
    fi

    export PS1;
  ;;

  *)
    printf -- "no bash nor ksh, using defaults...\n";
  ;;

esac
