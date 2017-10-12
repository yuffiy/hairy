;;; -*- lexical-binding: t -*-

;;; Utils

(defmacro deftask (name &optional docs &rest body)
  "Run tasks."
  `(progn ,@body))

(defun ms (num)
  "Make millisec number"
  (timer-duration (concat (number-to-string num) "millisec")))

(defun configure-package-sources (&optional unstable noimage protocol)
  "Configure package sources.

* [Elpa](https://elpa.gnu.org/) - Default
* [Melpa](https://melpa.org/)   - Popular
"
  (let* ((elpa               '("gnu" .
                               "http://elpa.gnu.org/packages/"))
	 (elpa-image         '("gun" .
                               "http://elpa.emacs-china.org/gnu/"))
	 (melpa-stable       '("melpa-stable" .
                               "http://stable.melpa.org/packages/"))
	 (melpa-stable-image '("melpa-stable" .
                               "http://elpa.emacs-china.org/melpa-stable/"))
	 (melpa              '("melpa" .
                               "http://melpa.org/packages/"))
	 (melpa-image        '("melpa" .
                               "http://elpa.emacs-china.org/melpa/"))
	 (env-noimage  "EMACS_PACKAGE_NOT_USE_IMAGE")
	 (env-unstable "EMACS_PACKAGE_USE_UNSTABLE")
	 (is-noimage  (or noimage (getenv env-noimage)))
	 (is-unstable (or unstable (getenv env-unstable))))
    (if (not is-noimage)
	(list elpa
	      (if is-unstable melpa melpa-stable))
      (list elpa-image
	    (if is-unstable melpa-image melpa-stable-image)))))

(defun reset-package-source ()
  "Reset package source."
  (interactive)
  (setq package-archives (configure-package-sources))
  (package-initialize))

(defun require-or-install (feature &optional filename)
  "Install package when require failed."
  (unless (funcall 'require feature filename t)
    (progn
      (package-install feature)
      (funcall 'require feature filename))))

(defun maximize-emacs ()
  "Maximize emacs."
  (interactive)
  (w32-send-sys-command 61488))

(defun maximize-restore-emacs ()
  "Maximize emacs."
  (interactive)
  (w32-send-sys-command 61728))

(defun set-font-color (str color)
  "Set font color."
  (propertize str 'face `((:foreground ,color))))



;;;; Package

(defun configure-package ()
  "Configure"
  (require 'package)
  (reset-package-source)
  (global-set-key (kbd "C-c C-p l") 'package-list-packages-no-fetch)
  (global-set-key (kbd "C-c C-p r") 'reset-package-source)
  (global-set-key (kbd "C-c C-p i") 'package-install)
  ;; TODO fetch-timeout
  )

(deftask initial-package
  "Apply package ocnfigs."
  (configure-package))



;;;; Preload

(defun configure-dash ()
  "Configure dash-2.12.0"
  (require-or-install 'dash)
  (eval-after-load 'dash (dash-enable-font-lock)))

(deftask preload-library
  "Preload utils library"
  (configure-dash)
  (require-or-install 's)
  (require-or-install 'f))



;;;; Editor

(defun configure-editorconfig ()
  "Configure editorconfig"
  (require-or-install 'editorconfig)
  (require-or-install 'editorconfig-custom-majormode)
  (editorconfig-mode 1)
  (add-hook 'editorconfig-custom-hook 'editorconfig-custom-majormode))

(defun configure-auto-file ()
  "Auto file save, backup, read"
  (global-auto-revert-mode 1)
  (setq make-backup-files nil)
  (setq save-interprogram-paste-before-kill t)
  (setq load-prefer-newer t))

(defun configure-buffer ()
  "Configure Buffer and MiniBuffer"
  (require-or-install 'ibuffer-vc)
  (global-set-key (kbd "C-x C-b") 'ibuffer)
  (require 'uniquify)
  (setq-default uniquify-buffer-name-style 'forward)
  (require-or-install 'smex)
  (require-or-install 'ido-vertical-mode)
  (fset 'yes-or-no-p 'y-or-n-p)
  (setq enable-recursive-minibuffers t)
  (ido-mode 1)
  (ido-everywhere 1)
  (setq-default ido-enable-flex-matching t)
  (ido-vertical-mode 1)
  (smex-initialize)
  (global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command))

(defun configure-conding-system ()
  "Use utf-8 coding system."
  (prefer-coding-system 'utf-8)
  (set-language-environment "UTF-8")
  (set-default-coding-systems 'utf-8)
  (set-buffer-file-coding-system 'utf-8)
  (setq-default file-name-coding-system 'utf-8))

(defun configure-frame-default ()
  "Configure default ui and frame size."
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (tooltip-mode -1)
  (set-frame-width (selected-frame) 86)
  (set-frame-height (selected-frame) 33))

(defun configure-ui ()
  "Configure default UI."
  (setq frame-title-format "emacs@%b")
  (mouse-avoidance-mode 'animate)
  (setq column-number-mode t)
  (set-background-color "snow")
  (set-face-attribute 'default nil :family "Consolas")
  (set-face-attribute 'default nil :height 100)
  (set-face-attribute 'default nil :foreground "#2e3137")
  (set-face-attribute 'fringe nil
                      :foreground (face-foreground 'default)
                      :background (face-background 'default))
  (require-or-install 'fill-column-indicator)
  (fci-mode 1)
  (setq fill-column 80)
  (setq-default fci-rule-column 80)
  (setq-default indent-tabs-mode nil))

(defun on-tab-title-press (button)
  (message (format "Button pressed!")))

(define-button-type 'startup-tab-title
  'action 'on-tab-title-press
  'follow-link t
  'help-echo "Click Button"
  'help-args "test")

(defun render-list-todos ()
  "Render todos list.

● foo
● bar
"
  (s-join "\n"
   (-map (lambda (item)
           (concat "○" " " item)
           ) (list "foo" "bar" "baz" "qux")))
  )

(defun configure-startup-screen ()
  "Render startup screen."
  (setq inhibit-startup-screen t)
  (let ((hairy-buffer-name "*Hairy*")
        (window (selected-window))
        (window-width (window-body-width))
        (window-height (window-body-height))
        (char-\[ (set-font-color "[" "lightgray"))
        (char-\] (set-font-color "]" "lightgray"))
        (char-\H (set-font-color "H" "SlateBlue"))
        (char-\A (set-font-color "A" "DeepSkyBlue"))
        (char-\I (set-font-color "I" "DodgerBlue"))
        (char-\Y (set-font-color "Y" "plum"))
        (char-\R (set-font-color "R" "purple"))
        (char-\B (set-font-color "B" "salmon"))
        (hr (s-pad-left 39 " " (set-font-color "__________" "lightgray")))
        (word-emacs (s-pad-left 40 " " (set-font-color "ξmacs" "thistle")))
        (body-point 0))
    (save-current-buffer
      (when (get-buffer hairy-buffer-name)
        (kill-buffer hairy-buffer-name))
      (generate-new-buffer hairy-buffer-name)
      (set-buffer (get-buffer-create hairy-buffer-name))
      (font-lock-mode nil)
      (setq mode-line-format nil)

      (newline (- (/ window-height 2) 1))
      (insert (s-center window-width (concat char-\[
                                             "  "
                                             char-\H
                                             "  "
                                             char-\A
                                             "  "
                                             "I"
                                             "  "
                                             "R"
                                             "  "
                                             char-\Y
                                             "  "
                                             char-\]
                                             "     "
                                             char-\R
                                             "  "
                                             "A"
                                             "  "
                                             "B"
                                             "  "
                                             char-\B
                                             "  "
                                             char-\I
                                             "  "
                                             "T")))
      (newline 1)
      (insert (s-center window-width hr))
      (newline 1)
      (insert (s-center window-width word-emacs))
      (newline 4)
      (insert (s-repeat (/ (- window-width 36) 2) " "))
      (insert-text-button (set-font-color "[T]" "purple")
                          'action (lambda (_button)
                                    (delete-region body-point (buffer-end 1))
                                    ))
      (insert "odos")
      (insert (s-repeat 6 " "))
      (insert-text-button (set-font-color "[P]" "plum")
                          'help-echo "Start coding…"
                          'action (lambda (_button)
                                    (delete-region body-point (buffer-end 1))
                                    ))
      (insert "rojects")
      (insert (s-repeat 6 " "))
      (insert-text-button (set-font-color "[B]" "SlateBlue")
                          'action (lambda (_button)
                                    (delete-region body-point (buffer-end 1))
                                    ))
      (insert "logs")
      (newline)
      ;; (newline 4)
      ;; <Body>
      (setq body-point (point))
      ;; (insert (render-list-todos))
      ;; (insert (s-center window-width "[ ] foo"))
      ;; (newline)
      ;; (insert (s-center window-width "[x] foo"))

      (newline 1)
      ;;(read-only-mode 1)
      )
    (setq initial-buffer-choice (lambda () (get-buffer "*Hairy*")))
    ))

(defun configure-restart-emacs ()
  "Restart emacs"
  (require-or-install 'restart-emacs)
  (setq restart-emacs-restore-frames t)
  ;; (setq restart-emacs--args "-q --load f:\\hairy\\hairy.el")
  ;; TODO
  )

(deftask editor
  "Reset editor."
  (configure-editorconfig)
  (configure-auto-file)
  (configure-buffer)
  (configure-conding-system)
  (configure-frame-default)
  (configure-ui)
  (configure-startup-screen)
  (configure-restart-emacs)
  (setq visible-bell t))



;;;; Fast coding

(defun configure-undo-redo ()
  "Configure undo and redo."
  (setq kill-ring-max 200))

(defun configure-region ()
  "Fast make region or parens."
  (require-or-install 'expand-region)
  (require-or-install 'multiple-cursors)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-?") 'mc/mark-all-like-this)
  (global-set-key (kbd "C-=") 'er/expand-region))

(defun configure-parens ()
  "Highlight or auto fill parens."
  (require-or-install 'smartparens)
  (show-smartparens-global-mode 1)
  (smartparens-global-mode 1)
  (show-paren-mode 1)
  (setq show-paren-style 'parentheses)
  ;; TODO auto fill parens in block
  )

(defun configure-insert-delete ()
  "Fast insert/delete line word and anything."
  (autoload 'zap-up-to-char "misc" "Kill up" t)
  (global-set-key (kbd "M-z") 'zap-up-to-char))

(defun bind-company-keymaps ()
  "Binding company mode keymaps."
  (define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle)
  (define-key company-active-map (kbd "S-TAB") 'company-select-previous))

(defun configure-complition ()
  "Fast complite code.
1. Company
2. Yasnippet
3. Abbr
"
  (global-set-key (kbd "M-/") 'hippie-expand)
  (require-or-install 'yasnippet)
  (yas-global-mode 1)
  (require-or-install 'company)
  (global-company-mode)
  ;;(eval-)
  (eval-after-load 'company
    '(progn
       (bind-company-keymaps)
       (setq company-require-match nil)
       (setq company-auto-complete t))))

(defun configure-jump ()
  "Fast move and jump."
  (require-or-install 'mwim)
  (global-set-key (kbd "C-a") 'mwim-beginning-of-code-or-line)
  (global-set-key (kbd "C-e") 'mwim-end-of-code-or-line)
  (global-set-key (kbd "C-r") 'isearch-backward-regexp)
  (global-set-key (kbd "C-M-s") 'isearch-forward)
  (global-set-key (kbd "C-M-r") 'isearch-backward)
  (global-set-key (kbd "C-.") 'imenu)
  (require-or-install 'ivy)
  (require-or-install 'swiper)
  (require-or-install 'counsel)
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (global-set-key "\C-s" 'swiper)
  ;; (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "<f6>") 'ivy-resume)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
  (global-set-key (kbd "<f1> l") 'counsel-find-library)
  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
  (global-set-key (kbd "C-c g") 'counsel-git)
  (global-set-key (kbd "C-c j") 'counsel-git-grep)
  (global-set-key (kbd "C-c k") 'counsel-ag)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
  (define-key read-expression-map (kbd "C-r") 'counsel-expression-history))

(defun configure-whitespace ()
  "Highlight whitespace."
  (require 'whitespace)
  ;; (global-whitespace-mode 1)
  (setq whitespace-line-column 80)
  (setq whitespace-style '(face trailing lines-tail))
  ;; (setq-default show-trailing-whitespace t)
  (add-hook 'before-save-hook 'delete-trailing-whitespace))

(deftask fastcoding
  "Fast coding basic set"
  (configure-undo-redo)
  (configure-whitespace)
  (configure-region)
  (configure-parens)
  (configure-insert-delete))

(deftask fastcoding-delay
  ""
  (run-with-timer (ms 100) nil 'configure-complition)
  (run-with-timer (ms 100) nil 'configure-jump))



;;; Projects

(defun configure-project ()
  ""
  (require-or-install 'projectile)
  (require-or-install 'ag))

(deftask project
  "Apply project configs."
  (run-with-timer (ms 100) nil 'configure-project))



;;; Javascript

(defun configure-nodejs-repl ()
  "Configure Nodejs repl"
  (let* ((command "node")
	 (arg-version (concat command " --version"))
	 (version (s-chomp (shell-command-to-string arg-version)))
	 (prompt (concat "nodejs" "(" version ")" "> ")))
    (require-or-install 'nodejs-repl)
    (setq nodejs-repl-prompt prompt)
    (global-set-key (kbd "C-c C-r js") 'nodejs-repl)
    (add-hook 'js-mode-hook 'binding-nodejs-keymaps)))
;; TODO crash when type "TAB"

(defun binding-nodejs-keymaps ()
  "Nodejs-repl keybindings."
  (define-key js-mode-map (kbd "C-x C-e") 'nodejs-repl-send-last-expression)
  (define-key js-mode-map (kbd "C-c C-r") 'nodejs-repl-send-region)
  (define-key js-mode-map (kbd "C-c C-l") 'nodejs-repl-load-file)
  (define-key js-mode-map (kbd "C-c C-z") 'nodejs-repl-switch-to-repl))

(defun configure-json-mode ()
  "Configure json mode."
  (require-or-install 'json-mode)
  (add-to-list 'auto-mode-alist '("\\.babelrc" . json-mode))
  (add-to-list 'auto-mode-alist '("\\.eslintrc" . json-mode)))

(defun lang-javascript ()
  "Configure javascript mode."
  ;; Nodejs-repl
  (configure-nodejs-repl)
  ;; Json
  (configure-json-mode)
  ;; Templates
  ;;()
  )

(deftask javascript
  "Apply javascript-IDE configs."
  (run-with-timer (ms 100) nil 'lang-javascript))



;;; Http

(defun lang-http ()
  ""
  (require-or-install 'httprepl)
  )

(deftask javascript
  "Apply HTTP utils configs."
  (run-with-timer (ms 100) nil 'lang-http))



;;; AutoHotKey

(defun lang-ahk ()
  ""
  (require-or-install 'ahk-mode)
  )

(deftask javascript
  "Apply javascript-IDE configs."
  (run-with-timer (ms 100) nil 'lang-ahk))