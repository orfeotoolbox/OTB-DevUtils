# script to update a git repository and reset it to a given branch

# analyse TESTED_BRANCH
get_filename_component(_BRANCH ${TESTED_BRANCH} NAME)
get_filename_component(_REMOTE ${TESTED_BRANCH} DIRECTORY)
if(_REMOTE)
  if(_REMOTE MATCHES "^[a-zA-Z0-9_-]+\$")
    # check if the remote is already present
    execute_process(COMMAND ${GIT_COMMAND} remote
      OUTPUT_VARIABLE _remotes)
    string(REPLACE "\n" ";" _remote_list "${_remotes}END")
    # remove last item (because of trailing newline)
    list(REMOVE_AT _remote_list -1)
    message("Remote list : ${_remote_list}")
    list(FIND _remote_list ${_REMOTE} _is_remote_here)
    if(_is_remote_here EQUAL -1)
      # add the remote
      execute_process(
        COMMAND ${GIT_COMMAND} remote add ${_REMOTE} https://gitlab.orfeo-toolbox.org/${_REMOTE}/otb.git)
    endif()
  else()
    message("Wrong remote name found : ${_REMOTE}")
    return()
  endif()
else()
  set(_REMOTE origin)
endif()

# check if local branch already exists
execute_process(COMMAND ${GIT_COMMAND} branch
  OUTPUT_VARIABLE _local_branches)
string(REPLACE "\n" " " in_line "${_local_branches}")
string(STRIP "${in_line}" striped_line)
string(REPLACE "  " " " striped_line "${striped_line}")
string(REPLACE "  " " " striped_line "${striped_line}")
string(REPLACE " " ";" split_line "${striped_line}")
list(FIND split_line "${_BRANCH}" _is_local)

# run the update
execute_process(COMMAND ${GIT_COMMAND} fetch --all)
execute_process(COMMAND ${GIT_COMMAND} reset --hard HEAD)
execute_process(COMMAND ${GIT_COMMAND} clean -d -f -f)
if(_is_local EQUAL -1)
  execute_process(COMMAND ${GIT_COMMAND} checkout -b ${_BRANCH} --track ${_REMOTE}/${_BRANCH})
else()
  execute_process(COMMAND ${GIT_COMMAND} checkout ${_BRANCH})
  execute_process(COMMAND ${GIT_COMMAND} reset --hard ${_REMOTE}/${_BRANCH})
endif()

# sync with develop
if(SYNC_DEVELOP)
  execute_process(COMMAND ${GIT_COMMAND} merge origin/develop)
endif()
