#!/usr/bin/env bash

#
# some about bash
#

# checking configuration files after login.
/etc/profile
~/.profile
~/.bash_profile
~/.bash_login

# then for non-login conf
~/.bashrc

# then at logout
~/.bash_logout

# escape characters type
# <Esc>
\e
\033
\x18

# reset all atributes
\e[0m

#
# 8/16 colors
#
# foregrounds
echo -e "\e[31mDEFAULT RED FOREGROUND\e[0m color."
echo -e "\e[91mLIGHT RED FOREGROUND\e[0m color."

# backgrounds
echo -e "\e[41mDEFAULT FONT ON RED BACKGROUND\e[0m color."
echo -e "\e[101mLIGHT RED BACKGROUND\e[0m color."

# combinations; light red fg on dark red bg
echo -e "\e[91;41m light red fg on dark red bg\e[0m"
echo -e "\e[41;91m light red fg on dark red bg\e[0m"

#
# description of 88/256 codes
#
# foreground code
<Esc>[38;5;$(COLORCODE)m

# background code
<Esc>[48;5;$(COLORCODE)m

# combinations
<Esc>[38;5;$(COLORCODE);38;5;$(COLORCODE)m<TEXT><Esc>\0m
<Esc>[38;5;$(COLORCODE);38;5;$(COLORCODE)m<TEXT><Esc>\0m
<Esc>[38;5;$(COLORCODE);38;5;$(COLORCODE)m<TEXT><Esc>\0m # with bold text

# Standard PS1
PS1='\u@\h-`uname -s`:\w \$ '
PS1='\u@\h\d\@\n\w\$'

# colored sourced
PS1='\e[1;31;48;5;234m\u\e[38;5;240m@\e[1;38;5;28;48;5;234m\h \e[38;5;66m\d \@\e[0m\n\e[0;31;48;5;234m[\w] \e[1m\$\e[0m '
PS1='\e[92m[\u@\h]:\w \$\e[0m '
