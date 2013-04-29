(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

;; add themes folder to theme load path
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

(load-theme 'wombat t)

;; desired starter-kit packages
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages '(starter-kit starter-kit-lisp starter-kit-eshell
                                  starter-kit-js starter-kit-bindings
                                  clojure-mode clojure-test-mode nrepl
                                  projectile rainbow-delimiters rainbow-mode)
  "A list of packages to ensure are installed at launch.")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(projectile-global-mode)
(global-rainbow-delimiters-mode)
(setq projectile-globally-ignored-files '("TAGS" "*.js"))

;; Terminal specific configurations
(unless window-system
  ;; Enable mouse support
  (require 'mouse)
  (xterm-mouse-mode t)
  
  (defun up-slightly () (interactive) (scroll-up 5))
  (defun down-slightly () (interactive) (scroll-down 5))
  
  (global-set-key (kbd "<menu-bar> <mouse-4>") 'down-slightly)
  (global-set-key (kbd "<menu-bar> <mouse-5>") 'up-slightly)
  
  (defun track-mouse (e))
  (setq mouse-sel-mode t)

  ;; Enable copy and paste with Mac
  ;; requires https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard
  (defun copy-from-osx ()
    (shell-command-to-string "pbpaste"))

  (defun paste-to-osx (text &optional push)
    (let ((process-connection-type nil))
      (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
        (process-send-string proc text)
        (process-send-eof proc))))

  (setq interprogram-cut-function 'paste-to-osx)
  (setq interprogram-paste-function 'copy-from-osx))

;; Window system specific configurations
(when window-system
  ;; font size
  (set-face-attribute 'default nil :font "Droid Sans Mono" :height 150)
  (server-start))

;; (eshell)

;; Bindings
(global-set-key (kbd "C-c m") 'magit-status)
(global-set-key (kbd "C-x N") 'nrepl-jack-in)
(global-set-key (kbd "C-x B") 'projectile-find-file)
(global-set-key (kbd "C-x T") 'ns-toggle-fullscreen)

;; Paredit in the terminal
(global-set-key "\C-c0" 'paredit-forward-slurp-sexp)
(global-set-key "\C-c9" 'paredit-backward-slurp-sexp)
(global-set-key "\C-c]" 'paredit-forward-barf-sexp)
(global-set-key "\C-c[" 'paredit-backward-barf-sexp)

;; clojure-mode
(add-to-list 'auto-mode-alist '("\.cljs$" . clojure-mode))
(add-hook 'clojure-mode-hook 'paredit-mode)
(add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)
(setq inferior-lisp-program "lein trampoline cljsbuild repl-listen")

;; cosmetics
;; lose the stupid pipe chars on the split-screen bar
(set-face-foreground 'vertical-border "white")
(set-face-background 'vertical-border "white")

;; markdown
;; add file extentions to mode auto load
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))

;; other options
;; set ispell program name to aspell (brew install aspell)
(setq-default ispell-program-name "aspell")

;; turn off annoying visual-bell
(setq visible-bell nil)

;; save backup files to ~/.saves
(setq backup-directory-alist `(("." . "~/.saves")))

;; projectile
(eval-after-load "grep"
  '(progn
     (add-to-list 'grep-find-ignored-directories ".lein*")
     (add-to-list 'grep-find-ignored-directories "resources")
     (add-to-list 'grep-find-ignored-directories "migrations")
     (add-to-list 'grep-find-ignored-directories "target")
     (add-to-list 'grep-find-ignored-directories "out")))

;; Teach compile the syntax of the kibit output
(require 'compile)
(add-to-list 'compilation-error-regexp-alist-alist
         '(kibit "At \\([^:]+\\):\\([[:digit:]]+\\):" 1 2 nil 0))
(add-to-list 'compilation-error-regexp-alist 'kibit)

;; A convenient command to run "lein kibit" in the project to which
;; the current emacs buffer belongs to.
(defun kibit ()
  "Run kibit on the current project.
Display the results in a hyperlinked *compilation* buffer."
  (interactive)
  (compile "lein kibit"))

(defun kibit-current-file ()
  "Run kibit on the current file.
Display the results in a hyperlinked *compilation* buffer."
  (interactive)
  (compile (concat "lein kibit " buffer-file-name)))

(remove-hook 'prog-mode-hook 'esk-turn-on-hl-line-mode)
