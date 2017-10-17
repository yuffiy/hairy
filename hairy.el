;;; hairy.el --- Hairy Rabbit  -*- lexical-binding: t -*-

;;; Utils

(defmacro deftask (name &optional docs &rest body)
  "Run tasks."
  `(progn ,@body))

(defun ms (num)
  "Make millisec number"
  (timer-duration (concat (number-to-string num) "millisec")))

(defvar package-source-melpa-usestable nil "Use MELPA stable library.")
(defvar package-source-use-image t "Use package source images.")
(defvar package-source-protocol "http://" "Use https:// or http://")

(defun configure-package-sources ()
  "Configure package sources.

* [Elpa](https://elpa.gnu.org/) - Default
* [Melpa](https://melpa.org/)   - Popular
"
  (let* ((elpa               `("gnu" .
                               ,(concat package-source-protocol
                                        "elpa.gnu.org/packages/")))
	 (elpa-image         `("gun" .
                               ,(concat package-source-protocol
                                        "elpa.emacs-china.org/gnu/")))
	 (melpa-stable       `("melpa-stable" .
                               ,(concat package-source-protocol
                                        "stable.melpa.org/packages/")))
	 (melpa-stable-image `("melpa-stable" .
                               ,(concat package-source-protocol
                                        "elpa.emacs-china.org/melpa-stable/")))
	 (melpa              `("melpa" .
                               ,(concat package-source-protocol
                                        "melpa.org/packages/")))
	 (melpa-image        `("melpa" .
                               ,(concat package-source-protocol
                                        "elpa.emacs-china.org/melpa/"))))
    (if (not package-source-use-image)
	(list elpa
	      (if package-source-melpa-usestable melpa-stable melpa))
      (list elpa-image
	    (if package-source-melpa-usestable melpa-stable-image melpa-image)))))

(defun reset-package-source ()
  "Reset package source."
  (interactive)
  (setq package-archives (configure-package-sources))
  (package-initialize))

(defun require-or-install (feature &optional filename source)
  "Install package when require failed."
  (unless (funcall 'require feature filename t)
    (progn
      ;; TODO install from source supports.
      (package-install feature)
      (funcall 'require feature filename))))

(defvar emacs-maximize-p nil "Maximized emacs.")

(defun maximize-or-restore-emacs ()
  "Maximize emacs."
  (interactive)
  (let ((w32-cmd (if emacs-maximize-p 61728 61488)))
    (w32-send-sys-command w32-cmd)
    (setq emacs-maximize-p (not emacs-maximize-p))))

(defun maximize-emacs ()
  "Maximize emacs."
  (interactive)
  (w32-send-sys-command 61488)
  (setq emacs-maximize-p t))

(defun maximize-restore-emacs ()
  "Maximize emacs."
  (interactive)
  (w32-send-sys-command 61728)
  (setq emacs-maximize-p nil))

(defun set-font-color (str color)
  "Set font color."
  (propertize str 'face `((:foreground ,color))))



;;;; Package manager

;; TODO check package upgrade
;; TODO fetch timeout

(defun configure-package ()
  "Configure package."
  (require 'package)
  (reset-package-source)
  (setq package-check-signature nil)
  (unless (or (package-installed-p 'dash)
              (package-installed-p 'projectile))
    (package-refresh-contents)))

(defun binding-package-keymaps ()
  "Bind package keymaps."
  (global-set-key (kbd "C-c C-p l") 'package-list-packages-no-fetch)
  (global-set-key (kbd "C-c C-p r") 'reset-package-source)
  (global-set-key (kbd "C-c C-p i") 'package-install))

;;;###autoload
(deftask initial-package
  "Apply package ocnfigs."
  (configure-package)
  (binding-package-keymaps))



;;;; Preload library.

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
  (setq utf-translate-cjk-mode nil)
  (prefer-coding-system 'utf-8)
  (set-language-environment "UTF-8")
  (set-default-coding-systems 'utf-8)
  (set-buffer-file-coding-system 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (setq locale-coding-system 'utf-8)
  (setq coding-system-for-read 'utf-8)
  (setq coding-system-for-write 'utf-8)
  (setq-default buffer-file-coding-system 'utf-8-unix)
  (setq-default file-name-coding-system 'utf-8-unix))

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
  ;; (set-background-color "snow")
  (set-background-color "FloralWhite")
  (set-face-attribute 'default nil :family "Consolas")
  (set-face-attribute 'default nil :height 120)
  (set-face-attribute 'default nil :foreground "#2e3137")
  (require-or-install 'fill-column-indicator)
  (fci-mode 1)
  (setq fill-column 80)
  (setq-default fci-rule-column 80)
  (setq-default indent-tabs-mode nil))

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

(defun render-banner ()
  "Render banner at startup buffer."
  (let ((char-\[ (set-font-color "[" "lightgray"))
        (char-\] (set-font-color "]" "lightgray"))
        (char-\H (set-font-color "H" "SlateBlue"))
        (char-\A (set-font-color "A" "DeepSkyBlue"))
        (char-\I (set-font-color "I" "DodgerBlue"))
        (char-\Y (set-font-color "Y" "plum"))
        (char-\R (set-font-color "R" "purple"))
        (char-\B (set-font-color "B" "salmon")))
    (s-join "  " (list char-\[ char-\H char-\A "I" "R" char-\Y char-\]
                       " "
                       char-\R "A" "B" char-\B char-\I "T" ))))

(defun render-hr ()
  "Render hr at below banner."
  (s-pad-left 39 " " (set-font-color "__________" "lightgray")))

(defun render-small ()
  "Render small below banner."
  (s-pad-left 40 " " (set-font-color "echo" "DodgerBlue")))

(defun render-nav-item (str color onpress)
  "Render Navigator item."
  (let* ((arr (s-split "" str t))
         (fst (s-wrap (car arr) "[" "]"))
         (tails (s-join "" (cdr arr))))
    (insert-text-button (set-font-color fst color) 'action onpress)
    (insert tails)))

(defun render-nav ()
  "Render navigator."
  (render-nav-item "todos" "purple" (lambda (_btn) (print 42)))
  (insert (s-repeat 6 " "))
  (render-nav-item "projects" "plum" (lambda (_btn) (layout-project)))
  (insert (s-repeat 6 " "))
  (render-nav-item "blog" "SlateBlue" (lambda (_btn) (print 42))))

;; (defun neotree-projectile ()
;;   "Open neotree with projectile as root and open node for current file.
;; If projectile unavailable or not in a project, open node at file path.
;; If file path is not available, open $HOME."
;;   (interactive)
;;   (if (neo-global--window-exists-p)
;;       (call-interactively 'neotree-hide)
;;     (let ((file-name (buffer-file-name)))
;;       (if (and (not file-name)
;;                (let ((buffer-name (buffer-name)))
;;                  (cond
;;                   ((equal buffer-name "*cider-repl server*") nil)
;;                   (t t))))
;;           (neotree-dir "~/")
;;         (let ((dir-name (if (and (fboundp 'projectile-project-p)
;;                                  (projectile-project-p))
;;                             (projectile-project-root)
;;                           (file-name-directory file-name))))
;;           (neotree-dir dir-name)
;;           (when file-name
;;             (neo-buffer--select-file-node file-name)))))))


;; (defvar endless/popup-frame-parameters
;;   '((name . "MINIBUFFER")
;;     (minibuffer . only)
;;     (height . 1)
;;     ;; Ajust this one to your preference.
;;     (top . 200))
;;   "Parameters for the minibuffer popup frame.")

;; (defvar endless/minibuffer-frame
;;   (let ((mf (make-frame endless/popup-frame-parameters)))
;;     (iconify-frame mf) mf)
;;   "Frame holding the extra minibuffer.")

;; (defvar endless/minibuffer-window
;;   (car (window-list endless/minibuffer-frame t))
;;   "")

;; (defmacro with-popup-minibuffer (&rest body)
;;   "Execute BODY using a popup minibuffer."
;;   (let ((frame-symbol (make-symbol "selected-frame")))
;;     `(let* ((,frame-symbol (selected-frame)))
;;        (unwind-protect
;;            (progn
;;              (make-frame-visible endless/minibuffer-frame)
;;              (when (fboundp 'point-screen-height)
;;                (set-frame-parameter
;;                 endless/minibuffer-frame
;;                 'top (point-screen-height)))
;;              (select-frame-set-input-focus endless/minibuffer-frame 'norecord)
;;              ,@body)
;;          (select-frame-set-input-focus ,frame-symbol)))))

;; (defun use-popup-minibuffer (function)
;;   "Rebind FUNCTION so that it uses a popup minibuffer."
;;   (interactive)
;;   (let* ((back-symb (intern (format "endless/backup-%s" function)))
;;          (func-symb (intern (format "endless/%s-with-popup-minibuffer"
;;                                     function)))
;;          (defs `(progn
;;                   (defvar ,back-symb (symbol-function ',function))
;;                   (defun ,func-symb (&rest rest)
;;                     ,(format "Call `%s' with a poupup minibuffer." function)
;;                     ,@(list (interactive-form function))
;;                     (with-popup-minibuffer
;;                      (apply ,back-symb rest))))))
;;     (message "%s" defs)
;;     (when (and (boundp back-symb) (eval back-symb))
;;       (error "`%s' already defined! Can't override twice" back-symb))
;;     (eval defs)
;;     (setf (symbol-function function) func-symb)))

;;; Try at own risk.
;; (use-popup-minibuffer 'read-from-minibuffer)
;;; This will revert the effect.
;; (setf (symbol-function #'read-from-minibuffer) endless/backup-read-from-minibuffer)
;; (setq endless/backup-read-from-minibuffer nil)

;;;
;;
;; +----+-------+-------+------+
;; |    |       |       |      |
;; | w1 |       |       |  w6  |
;; |    |  w3   |   w4  |      |
;; |    |       |       +------+
;; +----+       |       |      |
;; |    |       |       |      |
;; | w2 +-------+-------+  w7  |
;; |    |      w5       |      |
;; +----+---------------+------+
;;
;; w1: explorer
;; w2:
;;
;;;
(defvar layout-project-window-sidebar nil)
(defvar layout-project-window-body nil)
(defvar layout-project-window-project nil)
(defvar layout-project-window-workspace nil)
(defvar layout-project-window-explorer nil)
(defvar layout-project-window-code nil)
(defvar layout-project-window-code1 nil)
(defvar layout-project-window-code2 nil)
(defvar layout-project-window-terminal nil)
(defvar layout-project-window-scm nil)
(defvar layout-project-window-other nil)

(defface project-explorer-default-face
  '((t (:background "#F7F2E9" :height 100)))
  "Project layout explorer default face."
  :group 'layout-project)

;; (require 'json)
(defun workspace-findall ()
  ""
  (require-or-install 'projectile)
  (let* ((projects (projectile-load-known-projects)))
    (-map (lambda (project-root)
            (let* ((project-type (gethash project-root
                                          projectile-project-type-cache))
                   (marker-file (plist-get (gethash project-type
                                                    projectile-project-types)
                                           'marker-files))
                   (version (if (and marker-file
                                     (string= (f-ext (car marker-file)) "json"))
                                (let* ((marker-file-path (concat project-root
                                                                 (car marker-file))))
                                  (alist-get 'version
                                             (json-read-file marker-file-path)))
                              nil)))
              `(:name ,(f-filename project-root)
                      :path ,(f-dirname project-root)
                      :vc ,(projectile-project-vcs project-root)
                      :type ,project-type
                      :version ,version
                      )))
          projects)))

;; (workspace-findall)

(defun configure-neotree ()
  "Configure neotree expolorer."
  (require-or-install 'neotree)
  (setq neo-create-file-auto-open nil
        neo-auto-indent-point nil
        neo-autorefresh nil
        neo-mode-line-type 'none
        neo-window-width 35
        neo-show-updir-line nil
        ;; neo-theme 'nerd ; fallback
        neo-theme 'icons
        neo-banner-message nil
        neo-confirm-create-file #'off-p
        neo-confirm-create-directory #'off-p
        neo-show-hidden-files nil
        neo-keymap-style 'concise
        neo-hidden-regexp-list
        '(;; vcs folders
          "^\\.\\(git\\|hg\\|svn\\)$"
          ;; compiled files
          "\\.\\(pyc\\|o\\|elc\\|lock\\|css.map\\)$"
          ;; generated files, caches or local pkgs
          "^\\(node_modules\\|vendor\\|.\\(project\\|cask\\|yardoc\\|sass-cache\\)\\)$"
          ;; org-mode folders
          "^\\.\\(sync\\|export\\|attach\\)$"
          "~$"
          "^#.*#$"))

  (add-hook 'neo-after-create-hook
            (lambda (_window)
              (set-window-fringes neo-global--window 0 0)
              (setq buffer-face-mode-face 'project-explorer-default-face)
              (buffer-face-mode)
              (set-face-foreground 'vertical-border "#F7F2E9")
              (set-face-background 'fringe "#F7F2E9")
              ))
  (neotree)
  )

(defun layout-project ()
  "Render default project layout, when press 'project' link."
  (interactive)
  (let* ((buf-name "*Empty Code Layout*")
         (window (selected-window))
         (window-width (window-body-width))
         (window-height (window-body-height)))
    (maximize-or-restore-emacs)
    (save-current-buffer
      (generate-new-buffer buf-name)
      (switch-to-buffer (get-buffer-create buf-name))
      (setq test1 (split-window window 30))
      ;; (require 'eshell)
      (require-or-install 'projectile)
      (select-window test1)
      ;; (eshell)
      ;; (projectile-run-eshell)
      (configure-neotree)
      (buffer-face-mode)
      ;; (split-window neo-global--window 20)
      ;; (set-window-dedicated-p neo-global--window nil)
      (print (window-list))
      )
    ))

;; (require 'ansi-color)

;; (defadvice display-message-or-buffer (before ansi-color activate)
;;   "Process ANSI color codes in shell output."
;;   (let ((buf (ad-get-arg 0)))
;;     (and (bufferp buf)
;;          (string= (buffer-name buf) "*Shell Command Output*")
;;          (with-current-buffer buf
;;            (ansi-color-apply-on-region (point-min) (point-max))))))

(define-derived-mode hairy-mode
  fundamental-mode "Hairy"
  "Hairy Rabbit emacs greeting."
  (read-only-mode 1)
  (setq mode-line-format nil)
  (font-lock-mode nil)
  (define-key hairy-mode-map (kbd "p") 'layout-project))

(defun configure-greeting ()
  "Render startup screen."
  (setq inhibit-startup-screen t)
  (let ((hairy-buffer-name "*Hairy*")
        (window (selected-window))
        (window-width (window-body-width))
        (window-height (window-body-height))
        (body-point 0))
    (save-current-buffer
      (when (get-buffer hairy-buffer-name)
        (kill-buffer hairy-buffer-name))
      (generate-new-buffer hairy-buffer-name)
      (set-buffer (get-buffer-create hairy-buffer-name))
      (newline (- (/ window-height 2) 1))
      (insert (s-center window-width (render-banner)))
      (newline)
      (insert (s-center window-width (render-hr)))
      (newline)
      (insert (s-center window-width (render-small)))
      (newline 4)
      (insert (s-repeat (/ (- window-width 36) 2) " "))
      (render-nav)
      (newline)
      ;; TODO Add package upgrade info.
      ;; (setq body-point (point))
      ;; (delete-region body-point (buffer-end 1))
      (hairy-mode))
    (setq initial-buffer-choice (lambda () (get-buffer "*Hairy*")))))

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
  (configure-greeting)
  (configure-restart-emacs)
  (setq visible-bell t))

(defun configure-emms ()
  "Play music."
  (require-or-install 'emms)
  (require 'emms-setup)
  (require 'emms-player-simple)
  (require 'emms-player-mplayer)
  (emms-standard)
  (emms-default-players)
  (define-emms-simple-player mplayer '(file url)
    (regexp-opt '(".ogg" ".mp3" ".wav" ".mpg" ".mpeg" ".wmv" ".wma"
                  ".mov" ".avi" ".divx" ".ogm" ".asf" ".mkv" "http://" "mms://"
                  ".rm" ".rmvb" ".mp4" ".flac" ".vob" ".m4a" ".flv" ".ogv" ".pls"))
    "mplayer" "-slave" "-quiet" "-really-quiet" "-fullscreen")
  (setq emms-playlist-buffer-name "*Music*")
  (setq emms-player-list '(emms-player-mplayer))
  (setq emms-stream-default-action "play")
  (emms-player-for '(*track* (type . file) (name . "d:/MPlayer/test.mp3")))
  )

(deftask editor-delay
  "Reset editor after init."
  ;; (run-with-timer (ms 100) nil 'configure-emms)
  )



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

(defun configure-icons ()
  "Configure icon font"
  (require-or-install 'all-the-icons)
  (setq inhibit-compacting-font-caches t))

(defun configure-perspective ()
  "Configure perspective."
  ;;()
  )

(defun create-eshell-alias (&rest args)
  "Define eshell alias."
  (let ((name (car args)))
    (unless (eshell-command-aliased-p name)
      (apply 'eshell/alias args))))

(defun configure-eshell ()
  (require 'eshell)
  (require-or-install 'eshell-fixed-prompt)
  (require-or-install 'eshell-prompt-extras)
  (setq eshell-highlight-prompt nil
        eshell-prompt-function 'epe-theme-lambda)

  (require 'em-alias)
  ;; commons
  (create-eshell-alias "l" "ls")
  (create-eshell-alias "la" "ls -lAFh")
  (create-eshell-alias "lr" "ls -tRFh")
  (create-eshell-alias "lt" "ls -ltFh")
  (create-eshell-alias "ll" "ls -l")
  (create-eshell-alias "ldot" "ls -ld .*")
  (create-eshell-alias "lart" "ls -1FSsh")
  (create-eshell-alias "lart" "ls -1Fcart")
  (create-eshell-alias "lrt" "ls -1Fcrt")
  ;; git
  (create-eshell-alias "g" "git")
  (create-eshell-alias "ga" "git add")
  (create-eshell-alias "gaa" "git add --all")
  (create-eshell-alias "gau" "git add --update")
  (create-eshell-alias "gb" "git branch")
  (create-eshell-alias "gba" "git branch -a")
  (create-eshell-alias "gbd" "git branch -d")
  (create-eshell-alias "gbda" "git branch --no-color --merged | command grep -vE \"^(\*|\s*(master|develop|dev)\s*$)\" | command xargs -n 1 git branch -d")
  )

(defun repl-open ()
  "Open REPL buffer"
  (interactive)
  (let ((buf-name "*REPL*"))
    (eshell)
    ))

(defun configure-repl ()
  "Configure REPL
1. eshell/cmd/powershell/bashOnWindows/gitbash/cygwin
2. lang layer, nodejs python3 etc..
"
  (global-set-key (kbd "C-M-'") 'repl-open)
  )

(defun configure-project ()
  ""
  ;; (configure-perspective)
  ;; (configure-icons)
  (configure-eshell)
  (require-or-install 'projectile)
  (require-or-install 'neotree)
  (require-or-install 'ag)
  (configure-repl)
  ;; (setq projectile-cache-file t)
  )

(deftask project
  "Apply project configs."
  ;; (setq SHELL "/bin/bash emacs")
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

(defun configure-electric-operator ()
  "Configure electric operator."
  (require-or-install 'electric-operator)
  (electric-operator-add-rules-for-mode 'js-mode
                                        (cons "let"   "let ")
                                        (cons "const" "const ")
                                        (cons "var"   "var ")
                                        ;; (cons "if" "if ")
                                        ;; (cons "for" "for ")
                                        ;; (cons "while" "while ")
                                        (cons "switch" "switch ")
                                        (cons "case" "case ")
                                        (cons "new" "new ")
                                        (cons "type" "type ")
                                        (cons "interface" "interface ")
                                        )
  (add-hook 'js-mode-hook 'electric-operator-mode)
  ;; (add-hook 'js-mode-hook 'electric-layout-mode)
  (add-hook 'js-mode-hook 'electric-pair-mode))

(defun lang-javascript ()
  "Configure javascript mode."
  ;; Nodejs-repl
  (configure-nodejs-repl)
  ;; Json
  (configure-json-mode)
  (configure-electric-operator)
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


;; + ac-alchemist (ELPA)
;; + ace-link (ELPA)
;; + ace-window (ELPA)
;; + alchemist (ELPA)
;; + all-the-icons (ELPA)
;; + anaconda-mode (ELPA)
;; + android-mode (ELPA)
;; + async (ELPA)
;; + auctex (ELPA)
;; + auth-password-store (ELPA)
;; + auto-compile (ELPA)
;; + auto-yasnippet (ELPA)
;; + avy (ELPA)
;; + centered-window-mode (ELPA)
;; + circe (ELPA)
;; + circe-notifications (ELPA)
;; + cmake-mode (ELPA)
;; + coffee-mode (ELPA)
;; + command-log-mode (ELPA)
;; + company (ELPA)
;; + company-anaconda (ELPA)
;; + company-auctex (ELPA)
;; + company-dict (ELPA)
;; + company-ghc (ELPA)
;; + company-glsl (QUELPA)
;; + company-go (ELPA)
;; + company-inf-ruby (ELPA)
;; + company-irony (ELPA)
;; + company-irony-c-headers (ELPA)
;; + company-lua (ELPA)
;; + company-php (ELPA)
;; + company-quickhelp (ELPA)
;; + company-racer (ELPA)
;; + company-restclient (ELPA)
;; + company-shell (ELPA)
;; + company-sourcekit (ELPA)
;; + company-statistics (ELPA)
;; + company-tern (ELPA)
;; + company-web (ELPA)
;; + counsel (ELPA)
;; + counsel-css (QUELPA)
;; + counsel-projectile (ELPA)
;; + crystal-mode (QUELPA)
;; + csharp-mode (ELPA)
;; + cuda-mode (ELPA)
;; + demangle-mode (ELPA)
;; + dired-k (ELPA)
;; + disaster (ELPA)
;; + dockerfile-mode (ELPA)
;; + doom-themes (ELPA)
;; + dumb-jump (ELPA)
;; + editorconfig (ELPA)
;; + eldoc-eval (ELPA)
;; + elfeed (ELPA)
;; + elfeed-org (ELPA)
;; + elixir-mode (ELPA)
;; + elm-mode (ELPA)
;; + emmet-mode (ELPA)
;; + ensime (ELPA)
;; + eslintd-fix (ELPA)
;; + evil (ELPA)
;; + evil-anzu (ELPA)
;; + evil-args (ELPA)
;; + evil-commentary (ELPA)
;; + evil-easymotion (ELPA)
;; + evil-embrace (ELPA)
;; + evil-escape (ELPA)
;; + evil-exchange (ELPA)
;; + evil-goggles (ELPA)
;; + evil-indent-plus (ELPA)
;; + evil-ledger (ELPA)
;; + evil-matchit (ELPA)
;; + evil-mc (ELPA)
;; + evil-multiedit (ELPA)
;; + evil-numbers (ELPA)
;; + evil-snipe (ELPA)
;; + evil-surround (ELPA)
;; + evil-textobj-anyblock (ELPA)
;; + evil-vimish-fold (ELPA)
;; + evil-visualstar (ELPA)
;; + expand-region (ELPA)
;; + f (ELPA)
;; + flycheck (ELPA)
;; + flycheck-cask (ELPA)
;; + flycheck-elm (ELPA)
;; + flycheck-irony (ELPA)
;; + flycheck-ledger (ELPA)
;; + flycheck-perl6 (ELPA)
;; + flycheck-plantuml (ELPA)
;; + flycheck-pos-tip (ELPA)
;; + flycheck-rust (ELPA)
;; + flyspell-correct (ELPA)
;; + flyspell-correct-ivy (ELPA)
;; + fringe-helper (ELPA)
;; + gist (ELPA)
;; + git-gutter-fringe (ELPA)
;; + git-link (ELPA)
;; + git-timemachine (ELPA)
;; + gitconfig-mode (ELPA)
;; + gitignore-mode (ELPA)
;; + glsl-mode (ELPA)
;; + go-eldoc (ELPA)
;; + go-guru (ELPA)
;; + go-mode (ELPA)
;; + gorepl-mode (ELPA)
;; + groovy-mode (ELPA)
;; + gxref (ELPA)
;; + haml-mode (ELPA)
;; + haskell-mode (ELPA)
;; + haxor-mode (ELPA)
;; + help-fns+ (ELPA)
;; + highlight-indentation (ELPA)
;; + highlight-numbers (ELPA)
;; + highlight-quoted (ELPA)
;; + hindent (ELPA)
;; + hl-todo (ELPA)
;; + htmlize (ELPA)
;; + hy-mode (ELPA)
;; + hydra (ELPA)
;; + imenu-anywhere (ELPA)
;; + imenu-list (ELPA)
;; + impatient-mode (ELPA)
;; + inf-ruby (ELPA)
;; + intero (ELPA)
;; + irony (ELPA)
;; + irony-eldoc (ELPA)
;; + ivy (ELPA)
;; + ivy-bibtex (ELPA)
;; + ivy-hydra (ELPA)
;; + js2-mode (ELPA)
;; + js2-refactor (ELPA)
;; + json-mode (ELPA)
;; + julia-mode (ELPA)
;; + ledger-mode (ELPA)
;; + less-css-mode (ELPA)
;; + lua-mode (ELPA)
;; + macrostep (ELPA)
;; + magit (ELPA)
;; + makefile-executor (ELPA)
;; + markdown-mode (ELPA)
;; + markdown-toc (ELPA)
;; + meghanada (ELPA)
;; + merlin (ELPA)
;; + mips-mode (ELPA)
;; + modern-cpp-font-lock (ELPA)
;; + moonscript (ELPA)
;; + mu4e-maildirs-extension (ELPA)
;; + multi-term (ELPA)
;; + nasm-mode (ELPA)
;; + nav-flash (ELPA)
;; + neotree (ELPA)
;; + nlinum (ELPA)
;; + nlinum-hl (ELPA)
;; + nlinum-relative (ELPA)
;; + nodejs-repl (ELPA)
;; + nose (ELPA)
;; + ob-go (ELPA)
;; + ob-mongo (ELPA)
;; + ob-redis (ELPA)
;; + ob-restclient (ELPA)
;; + ob-rust (QUELPA)
;; + ob-sql-mode (ELPA)
;; + ob-translate (ELPA)
;; + omnisharp (ELPA)
;; + opencl-mode (ELPA)
;; + org-bullets (QUELPA)
;; + org-download (ELPA)
;; + org-plus-contrib (QUELPA)
;; + org-tree-slide (ELPA)
;; + overseer (ELPA)
;; + ox-pandoc (ELPA)
;; + ox-reveal (ELPA)
;; + pass (ELPA)
;; + password-store (ELPA)
;; + pcre2el (ELPA)
;; + perl6-mode (ELPA)
;; + persp-mode (ELPA)
;; + php-boris (ELPA)
;; + php-extras (QUELPA)
;; + php-mode (ELPA)
;; + php-refactor-mode (ELPA)
;; + phpunit (ELPA)
;; + pip-requirements (ELPA)
;; + plantuml-mode (ELPA)
;; + prodigy (ELPA)
;; + projectile (ELPA)
;; + psc-ide (ELPA)
;; + pug-mode (ELPA)
;; + purescript-mode (ELPA)
;; + quickrun (ELPA)
;; + racer (ELPA)
;; + rainbow-delimiters (ELPA)
;; + rainbow-mode (ELPA)
;; + rake (ELPA)
;; + restclient (ELPA)
;; + rjsx-mode (ELPA)
;; + rotate-text (QUELPA)
;; + rspec-mode (ELPA)
;; + ruby-refactor (ELPA)
;; + rust-mode (ELPA)
;; + s (ELPA)
;; + sass-mode (ELPA)
;; + sbt-mode (ELPA)
;; + scala-mode (ELPA)
;; + shackle (ELPA)
;; + shader-mode (ELPA)
;; + shrink-path (ELPA)
;; + skewer-mode (ELPA)
;; + slime (ELPA)
;; + smart-forward (ELPA)
;; + smartparens (ELPA)
;; + smex (ELPA)
;; + solaire-mode (ELPA)
;; + ssh-deploy (ELPA)
;; + stripe-buffer (ELPA)
;; + stylus-mode (ELPA)
;; + swift-mode (ELPA)
;; + swiper (ELPA)
;; + tern (ELPA)
;; + tide (ELPA)
;; + toc-org (ELPA)
;; + toml-mode (ELPA)
;; + tuareg (ELPA)
;; + twittering-mode (ELPA)
;; + typescript-mode (ELPA)
;; + undo-tree (ELPA)
;; + vi-tilde-fringe (ELPA)
;; + vimrc-mode (ELPA)
;; + visual-fill-column (ELPA)
;; + web-beautify (ELPA)
;; + web-mode (ELPA)
;; + wgrep (ELPA)
;; + which-key (ELPA)
;; + xref-js2 (ELPA)
;; + yaml-mode (ELPA)
;; + yard-mode (ELPA)
;; + yasnippet (ELPA)
