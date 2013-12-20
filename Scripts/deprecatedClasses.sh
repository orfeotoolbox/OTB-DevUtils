#!/bin/bash

grep -nR -e "^#include \"vcl_deprecated_header.h\"" -e "\deprecated$" Code/
