set -g pad " "

## Function to show a segment
function prompt_segment -d "Function to show a segment"
  # Get colors
  set -l bg $argv[1]
  set -l fg $argv[2]

  # Set 'em
  set_color -b $bg
  set_color -o $fg

  # Print text
  if [ -n "$argv[3]" ]
    echo -n -s $argv[3]
  end
end

## Function to show current status
function show_status -d "Function to show the current status"
  if [ $RETVAL -ne 0 ]
    prompt_segment red white " ▲ "
    set pad ""
    end
  if [ -n "$SSH_CLIENT" ]
      prompt_segment blue white " SSH: "
      set pad ""
    end
end

function show_virtualenv -d "Show active python virtual environments"
  if set -q VIRTUAL_ENV
    set -l venvname (basename "$VIRTUAL_ENV")
    prompt_segment normal white " ($venvname) "
  end
end

## Show user if not in default users
function show_user -d "Show user"
  if not contains $USER $default_user; or test -n "$SSH_CLIENT"
    set -l host (hostname -s)
    set -l who (whoami)
    prompt_segment normal green " ($who) "
  end
end

function _set_venv_project --on-variable VIRTUAL_ENV
    if test -e $VIRTUAL_ENV/.project
        set -g VIRTUAL_ENV_PROJECT (cat $VIRTUAL_ENV/.project)
    end
end

# Show directory
function show_pwd -d "Show the current directory"
  set -l pwd
  if [ (string match -r '^'"$VIRTUAL_ENV_PROJECT" $PWD) ]
    set pwd (string replace -r '^'"$VIRTUAL_ENV_PROJECT"'($|/)' '≫ $1' $PWD)
  else
    set pwd (prompt_pwd --full-length-dirs=4)
  end
  prompt_segment normal brcyan "$pwd"
end

# Show prompt w/ privilege cue
function show_prompt -d "Shows prompt with cue for current priv"
  set -l uid (id -u $USER)
    if [ $uid -eq 0 ]
    prompt_segment red white " ! "
    set_color normal
    echo -n -s " "
  else
    prompt_segment normal green " -> "
    end

  set_color normal
end

function get_git_status -d "Gets the current git status"
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set -l dirty (command git status -s --ignore-submodules=dirty | wc -l | sed -e 's/^ *//' -e 's/ *$//' 2> /dev/null)
    set -l ref (command git describe --tags --exact-match 2> /dev/null ; or command git symbolic-ref --short HEAD 2> /dev/null ; or command git rev-parse --short HEAD 2> /dev/null)

    if [ "$dirty" != "0" ]
      set_color -b normal
      set_color red
      echo "$dirty^"
      # if [ "$dirty" != "1" ]
      #   echo "s"
      # end
      # echo " "
      set_color -b red
      set_color white
    else
      set_color -b brgreen
      set_color white
    end

    echo "$ref"
    set_color normal
   end
end

function get_git_branch -d "Gets the current git branch"
  if test -d .git
    # Get the current branch
    set branch (git symbolic-ref --short HEAD 2>/dev/null)
    if test -n "$branch"
      set changed_files_count (git status --porcelain | wc -l)
      if test "$changed_files_count" -gt 0
        set_color brred
      else 
        set_color brgreen
      end    
      echo -n " [$branch]"
    end
  end
end

## SHOW PROMPT
function fish_prompt
  set -g RETVAL $status
  show_status
  show_virtualenv
  show_user
  show_pwd
  # get_git_status
  get_git_branch
  show_prompt
end
