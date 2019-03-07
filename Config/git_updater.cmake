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
      #check which project we are on: otb or otb-data
      set(_PROJECT otb)
      execute_process(COMMAND ${GIT_COMMAND} remote -v
        OUTPUT_VARIABLE _remotes_urls)
      string(FIND ${_remotes_urls} "gitlab.orfeo-toolbox.org/orfeotoolbox/otb-data.git" IS_OTB_DATA )
      if ( IS_OTB_DATA GREATER -1 )
        set(_PROJECT otb-data)
      endif()
      # add the remote
      execute_process(
        COMMAND ${GIT_COMMAND} remote add ${_REMOTE} https://gitlab.orfeo-toolbox.org/${_REMOTE}/${_PROJECT}.git)
    endif()
  else()
    message("Wrong remote name found : ${_REMOTE}")
    return()
  endif()
else()
  set(_REMOTE origin)
endif()

# check if local branch already exists
execute_process(COMMAND ${GIT_COMMAND} branch --list "${_BRANCH}"
  OUTPUT_VARIABLE _local_branches)

# run the update
# clean tree
execute_process(COMMAND ${GIT_COMMAND} clean -d -f -f)
execute_process(COMMAND ${GIT_COMMAND} fetch --all --prune)
execute_process(COMMAND ${GIT_COMMAND} reset --hard origin/develop )

# if(_is_local EQUAL -1)
if ( NOT _local_branches )
  execute_process(COMMAND ${GIT_COMMAND} checkout -b ${_BRANCH} --track ${_REMOTE}/${_BRANCH})
else()
  # this two command might be redundant but...
  execute_process(COMMAND ${GIT_COMMAND} checkout ${_BRANCH})
  execute_process(COMMAND ${GIT_COMMAND} reset --hard ${_REMOTE}/${_BRANCH})
endif()

# sync with a reference branch
if(SYNC_BRANCH)
  execute_process(COMMAND ${GIT_COMMAND} merge origin/${SYNC_BRANCH})
endif()
