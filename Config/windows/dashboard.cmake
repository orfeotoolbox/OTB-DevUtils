# set( dashboard_no_clean 1 )
# set( dashboard_no_update 1 )
# set( dashboard_no_configure 1 )
# set( dashboard_no_submit 1 )
# set(dashboard_model Experimental)
# set(dashboard_build_target OTBAppOpticalCalibration-all)

set(otb_data_use_largeinput ON)

set(dashboard_cache 
"
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON
OTB_USE_QT4:BOOL=ON
OTB_USE_QWT:BOOL=ON
OTB_USE_6S:BOOL=ON
OTB_USE_CURL:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
OTB_USE_SHARK:BOOL=ON
"
)


include(windows_common.cmake)