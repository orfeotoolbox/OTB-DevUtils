set(otb-template-module_SRC
LIST_OF_CXX_FILES
)

add_library(otb-template-module ${otb-template-module_SRC})
target_link_libraries(otb-template-module LINK_LIBRARIES_TO_BE_REPLACED)
otb_module_target(otb-template-module)
