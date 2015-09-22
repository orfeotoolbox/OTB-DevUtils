# script to update a git repository and reset it to a given branch

execute_process(COMMAND ${GIT_COMMAND} fetch origin ${TESTED_BRANCH})
execute_process(COMMAND ${GIT_COMMAND} clean -d -f -f)
execute_process(COMMAND ${GIT_COMMAND} checkout ${TESTED_BRANCH})
execute_process(COMMAND ${GIT_COMMAND} reset --hard origin/${TESTED_BRANCH})
