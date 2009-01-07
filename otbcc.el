;;; otbcc.el --- "OTB Code Creator" for generating code stubs.

;; This software is provided as-is, without express or implied
;; warranty.  Permission to use, copy, modify, distribute or sell this
;; software, without fee, for any purpose and by any individual or
;; organization, is hereby granted, provided that the above copyright
;; notice and this paragraph appear in all copies.

;;; Commentary:

;; This is a set of functions for generation of OTB module templates,
;; comment blocks, function and method stubs, etc.  You can bind these
;; functions to key sequences in c++-mode buffers.
;;
;; Put the following line in your .emacs file
;; (load-library "otbcc")
;; and eventually update the load path:
;; (setq load-path (cons "/path-to-otbcc.el-directory/" load-path))
;; User entry points:
;;   otbcc-insert-copyright-notice
;;   otbcc-insert-class-template
;;
;; User variables:

;;
;; See the docstrings for more information.

;;; Code:


(defun otbcc-insert-copyright-notice ()
  (interactive )
  (insert "/*=========================================================================

Program:   ORFEO Toolbox
Language:  C++
Date:      $Date$
Version:   $Revision$


Copyright (c) Centre National d'Etudes Spatiales. All rights reserved.
See OTBCopyright.txt for details.


This software is distributed WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.  See the above copyright notices for more information.

=========================================================================*/\n"))


(defun otbcc-insert-class-template (&optional className)
  (interactive "sClass Name: ")
  (insert "#ifndef __otb" className "_h\n")
  (insert "#define __otb" className "_h\n\n\n")
  (insert "namespace otb\n{\n\n")
  (insert "/** \\class " className "\n*  \\brief This class \n*\n*\n*/\n")
  (insert "template <class T>\nclass ITK_EXPORT " className " : public BaseClass\n")
  (insert "\t{\n") ;class opening brace
  (insert "public:\n")
  (insert "/** Standard typedefs */\n")
  (insert "typedef " className " Self;\n")
  (insert "typedef BaseClass Superclass;\n")
  (insert "typedef itk::SmartPointer<Self> Pointer;\n")
  (insert "typedef itk::SmartPointer<const Self> ConstPointer;\n")
  (insert "\n/** Type macro */\n")
  (insert "itkTypeMacro(" className ",BaseClass);\n")
  (insert "\n/** Creation through object factory macro */\n")
  (insert "itkNewMacro(Self);\n")

  (insert "\t};\n\n") ;class closing brace
  (insert "} // End namespace otb\n\n")
  
  (insert "#ifndef OTB_MANUAL_INSTANTIATION\n"); to be made optional if class is not template
  (insert "#include \"otb" className ".txx\"\n")
  (insert "#endif\n\n")

  (insert "#endif\n"); closes ifndef className

)
