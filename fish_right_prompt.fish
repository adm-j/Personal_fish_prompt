
# function get_git_status -d "Gets the current git status"
#   if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
#     set -l dirty (command git status -s --ignore-submodules=dirty | wc -l | sed -e 's/^ *//' -e 's/ *$//' 2> /dev/null)
#     set -l ref (command git describe --tags --exact-match 2> /dev/null ; or command git symbolic-ref --short HEAD 2> /dev/null ; or command git rev-parse --short HEAD 2> /dev/null)

#     if [ "$dirty" != "0" ]
#       set_color -b normal
#       set_color red
#       echo "$dirty changed file"
#       if [ "$dirty" != "1" ]
#         echo "s"
#       end
#       echo " "
#       set_color -b red
#       set_color white
#     else
#       set_color -b brgreen
#       set_color white
#     end

#     echo " $ref "
#     set_color normal
#    end
# end

function get_changed_files
  set changed_files_count (git status --porcelain | wc -l)
  if test "$changed_files_count" -gt 0
    set_color -b normal
    set_color brred 
    echo "[^$changed_files_count]"
  end 
end


function fish_right_prompt -d "Prints right prompt"
  get_changed_files
end