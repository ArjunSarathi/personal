# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# CUSTOM PROMPT
ERR="\$(if [ \$? == 0 ]; then echo '>:)'; else echo '\[\033[0;31m\]>:(\[\033[0m\]'; fi)"
RESET="\[\033[0m\]"
RED="\[\033[0;31m\]"
GREEN="\[\033[01;32m\]"
BLUE="\[\033[01;34m\]"
YELLOW="\[\033[0;33m\]"
WHITE="\[\033[1;37m\]"
GRAY="\[\033[0;37m\]"
HPIPE="\[\e(0\]q\[\e(B\]"
UP_PIPE="\[\e(0\]lq\[\e(B\]"  # l for the initial up, then q as connect
DOWN_PIPE="\[\e(0\]mq\[\e(B\]"  # see above. m=down
OB='\[\033[0;37m\][\[\033[0m\]' # open bracket
CB='\[\033[0;37m\]]\[\033[0m\]' # close bracket

function ssh_connection() {
  if [[ -n $SSH_CONNECTION ]]; then
    echo "$RED(ssh)$RESET "
  fi
}

function work_env() {
  case $HOSTNAME in
    *prod*)     echo "$OB${RED}PRODUCTION$CB$HPIPE";;
    *dev*)      echo "$OB${YELLOW}DEV$CB$HPIPE";;
    *test*)     echo "$OB${GREEN}TEST$CB$HPIPE";;
    *)          echo "";;
  esac
}

PS_LINE=`printf -- '- %.0s' {1..200}`
function parse_git_branch {
  PS_BRANCH=''
  PS_FILL=${PS_LINE:0:$COLUMNS}
  if [ -d .svn ]; then
    PS_BRANCH="(svn r$(svn info|awk '/Revision/{print $2}'))"
    return
  elif [ -f _FOSSIL_ -o -f .fslckout ]; then
    PS_BRANCH="(fossil $(fossil status|awk '/tags/{print $2}')) "
    return
  fi
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  PS_BRANCH="(git ${ref#refs/heads/}) "
}
PROMPT_COMMAND=parse_git_branch
PS_GIT="$YELLOW\$PS_BRANCH"
PS_TIME="\[\033[\$((COLUMNS-10))G\] $OB\t$CB"
HIST_NO="$OB\!$CB"
EXIT_CODE="$OB$ERR$CB"
PS_INFO="$UP_PIPE$(work_env)$OB$BLUE\w$CB$HPIPE$OB$WHITE\u@\h$CB$HPIPE${HIST_NO} $(ssh_connection)"
export PS1="${PS_INFO} ${PS_GIT}${PS_TIME}\n${RESET}$DOWN_PIPE${EXIT_CODE} > "

### ETERNAL BASH HISTORY
# ---------------------
# https://stackoverflow.com/a/19533853/
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

### PACKAGES
export PATH=$HOME/scripts:$PATH

### FUNCTIONS
addalias()
{
        new_alias="alias $(echo $1 | sed -e "s/=/='/" -e "s/$/'/")"
        echo $new_alias >> ~/.bashrc
        source ~/.bashrc
}
cd() { builtin cd $* && ls ;}

### ALIASES
alias daddy='sudo'
alias l='ls -lAh'
alias shrink='export PS1="\u > "' # temporarily shrinks the prompt so that it doesn't show the working directory
alias search='grep -rwn * -e '
alias push='git push -u origin master'
alias pull='git pull'
alias gits='git status'
alias gaa='git add --all'
alias 'gcn!'='git commit -v --no-edit --amend'
alias force='git push origin master --force' 
alias 'oops!'='gaa && gcn! && force'
alias ls='ls --color'
alias grep='grep --color=auto'
alias rc='vim ~/.bashrc'
alias rd='rmdir'
alias src='source ~/.bashrc'
