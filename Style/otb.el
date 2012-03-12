(add-to-list 'load-path "~/.emacs.d/")

;; c++ modes for some files: txx, h
(add-to-list 'auto-mode-alist '("\\.txx\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; cuda files in c mode
(add-to-list 'auto-mode-alist '("\\.cu\\'" . c-mode))

;; Comments 80 col wide
(setq-default fill-column 80)

;; OTB style
(c-add-style "otb"
       '("stroustrup"
         (c-basic-offset . 2)
         (c-offsets-alist
           (c . c-lineup-dont-change)
           (innamespace . 0)
           (inline-open . 0)
           (substatement-open . +)
           (statement-block-intro . 0)
           (arglist-intro . +)
           (arglist-close . 0) ) ) )

(defun maybe-otb-style ()
  (when (and buffer-file-name
             (not (string-match "ossim" buffer-file-name)))
    (c-set-style "otb")))

(add-hook 'c++-mode-hook 'maybe-otb-style)

(add-hook 'c++-mode-hook
          (lambda ()
            (setq tab-width 2) (turn-on-auto-fill)))

(defun apply-otb-style ()
   (c-set-style "otb")
   (indent-region (point-min) (point-max) nil)
   (save-buffer))

;;default compilation command
(setq compile-command "cd ~/OTB/OTB-Binary; make")

;; Always insert spaces, never tabs.
(setq-default indent-tabs-mode nil)

;; Remove trailing whitespace when saving
(add-hook 'c++-mode-hook
           (lambda ()
             (add-to-list 'write-file-functions 'delete-trailing-whitespace)))

;; cmake config
(autoload 'cmake-mode "cmake-mode" t)
(add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-mode))
(add-to-list 'auto-mode-alist '("\\.cmake\\'" . cmake-mode))

;; Ossim style
(c-add-style "ossim"
       '("bsd"
         (c-tab-always-indent . t)
         (c-comment-only-line-offset . 0)
         (c-block-comments-indent-p . nil)
         (c-basic-offset . 3)
         (c-hanging-braces-alist . ((substatement-open after)
                                    (inline-open)
                                    (inline-close)
                                    (brace-list-open)))
         (c-hanging-colons-alist . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)))
         (c-cleanup-list . (scope-operator
                            empty-defun-braces
                            defun-close-semi))
         (c-offsets-alist . ((arglist-close . c-lineup-arglist)
                             (substatement-open . 0)
                             (case-label        . +)
                             (label             . 0)
                             (block-open        . 0)
                             (block-close       . 0)
                             (knr-argdecl-intro . 0)))
         (c-echo-syntactic-information-p . t) ) )


(defun maybe-ossim-style ()
  (when (and buffer-file-name
             (string-match "ossim" buffer-file-name))
    (c-set-style "ossim")))
(add-hook 'c++-mode-hook 'maybe-ossim-style)

;; to be used in batch mode, for example with:
;; find Utilities/otbossimplugins -name "*.h" -o -name "*.cpp" | \
;; xargs -I {} emacs -batch {} \
;; -l /home/christop/.emacs.d/otb.el \
;; -f apply-ossim-style
(defun apply-ossim-style ()
   (c-set-style "ossim")
   (indent-region (point-min) (point-max) nil)
   (save-buffer))
