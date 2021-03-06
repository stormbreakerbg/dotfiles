# Some colors, if in an interactive session
if [[ $- == *i* ]]; then
  green=$(tput setaf 2)
  blue=$(tput setaf 4)
  blueish=$(tput setf 0)
  red=$(tput setaf 1)
  bold=$(tput bold)
  reset=$(tput sgr0)
  cyan=$(tput setaf 6)
fi

# Shorten directory names if the path is too long
# /this/is/a/really/long/path/to/a/directory -> /t/i/a/r/l/p/t/a/directory
chomp_dir () {
  local p=${1/#$HOME/\~} b s
  s=${#p}
  while [[ $p != ${p//\/} ]]&&(($s>$2))
  do
    p=${p#/}
    [[ $p =~ \.?. ]]
    b=$b/${BASH_REMATCH[0]}
    p=${p#*/}
    ((s=${#b}+${#p}))
  done
  echo ${b/\/~/\~}${b+/}$p
}

git_prompt () {
  git_branch=$(echo $(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p'))

  if [ -n "$git_branch" ]; then
    git status | grep "nothing to commit" > /dev/null 2>&1;

    if [ "$?" -eq "0" ]; then
      # @4 - Clean repository - nothing to commit
      git_prompt_result='\[$blueish\]'$git_branch' '
    else
      # @5 - Changes to working tree
      git_prompt_result='\[$red\]'$git_branch' '
    fi
  else
    git_prompt_result=''
  fi
}

last_status () {
  if [ $1 != 0 ]; then
    last_status_result='\[$red\]:( '
  else
    last_status_result=''
  fi
}

set_host_user () {
  set_user

  if [[ $HOSTNAME != "SapphiraX.local" && $HOSTNAME != "SapphiraX.astea" && $HOSTNAME != "Sapphira.local" && $HOSTNAME != "Sapphira.astea" && $HOSTNAME != "storm" ]]; then
    host_user=' \[$cyan\]$HOSTNAME'$user
  else
    host_user=$user
  fi
}

set_user () {
  if [[ $USER != 'stormbreaker' && $USER != 'gangelov' ]]; then
    user=' \[$cyan\]:$USER '
  else
    user=' '
  fi
}

render_prompt () {
  last_status $?
  git_prompt
  set_host_user

  PS1=$host_user$last_status_result'\[$green\]$(chomp_dir "$(pwd)" 30) '$git_prompt_result'\[$reset\]$ '
}

PROMPT_COMMAND=render_prompt
