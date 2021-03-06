(add-to-list 'load-path (expand-file-name "~/.emacs.d/site-lisp"))

;; ----- Install packages ----- ;;

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(defun install-packages (packages)
  (let ((refreshed nil))
    (dolist (pack packages)
      (unless (package-installed-p pack)
        (unless refreshed
          (package-refresh-contents)
          (setq refreshed t))
        (package-install pack)))))

(install-packages '(auto-complete
                    magit
                    markdown-mode
                    paredit
                    slime
                    ac-slime
                    w3m))

;; ----- keybind ----- ;;

(mapc '(lambda (pair)
         (global-set-key (kbd (car pair)) (cdr pair)))
      '(("M-g"  . goto-line)
        ("C-h"  . delete-backward-char)
        ("C-z"  . nil)
        ("C-_"  . undo)
        ("C-\\" . undo)
        ("C-o"  . nil)
        ("C-x ;" . comment-region)
        ("C-x :" . uncomment-region)
        ("C-x C-i"   . indent-region)))

;; ----- Environment ----- ;;

(setq scroll-conservatively 1)
(set-face-foreground 'font-lock-comment-face "#ee0909")
(show-paren-mode t)

;; -- icomplete-mode -- ;;
(icomplete-mode 1)
;; enable to toggle candidates by C-f or C-b 
(add-hook 'icomplete-minibuffer-setup-hook
          '(lambda ()
             (local-set-key "\C-f" 'icomplete-forward-completions)
             (local-set-key "\C-b" 'icomplete-backward-completions)))

;; -- -- ;;

;; mode-line
(setq frame-title-format (format "emacs@%s : %%f" (system-name)))
(which-function-mode 1)

;; backup
(setq delete-auto-save-files t)
(setq backup-inhibited t)

;; use space instead of tab
(setq-default indent-tabs-mode nil)

;; dired
(defvar my-dired-before-buffer nil)
(defadvice dired-up-directory
    (before kill-up-dired-buffer activate)
  (setq my-dired-before-buffer (current-buffer)))

(defadvice dired-up-directory
    (after kill-up-dired-buffer-after activate)
  (if (eq major-mode 'dired-mode)
      (kill-buffer my-dired-before-buffer)))

(setq dired-listing-switches "-l --group-directories-first")

;; ----- Other libraries ----- ;;

;; display the directory name of the file when files that have a same name are opened
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

(require 'auto-complete-config)
(ac-config-default)

;; ----- Lisp ----- ;;

;; slime
(add-to-list 'load-path (expand-file-name "~/.emacs.d/slime"))

(require 'slime)
(setq inferior-lisp-program "ros run")
(slime-setup '(slime-repl slime-fancy slime-banner))
(slime-setup '(slime-fancy slime-repl-ansi-color))
(slime-setup)

(add-hook 'slime-mode-hook
          '(lambda ()
             (local-set-key (kbd "C-c s i") 'slime-restart-inferior-lisp)))

;; ac-slime
(require 'ac-slime)
(add-hook 'slime-mode-hook 'set-up-slime-ac)
(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)

;; HyperSpec on w3
(require 'hyperspec)
(setq common-lisp-hyperspec-root (concat "file://" (expand-file-name "~/.emacs.d/docs/HyperSpec/")))
(require 'w3m)
(setq browse-url-browser-function 'w3m-browse-url)
(global-set-key (kbd "C-c h") 'hyperspec-lookup)

;; paredit
(require 'paredit)
(eval-after-load "paredit"
  #'(define-key paredit-mode-map (kbd "C-c f") 'paredit-forward-slurp-sexp))
(eval-after-load "paredit"
  #'(define-key paredit-mode-map (kbd "C-c b") 'paredit-forward-barf-sexp))
(eval-after-load "paredit"
  #'(define-key paredit-mode-map (kbd "C-h") 'paredit-backward-delete))
(global-set-key (kbd "C-c m p") 'paredit-mode)

(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
(add-hook 'slime-mode-hook 'enable-paredit-mode)
(add-hook 'slime-repl-mode-hook 'enable-paredit-mode)

;; --------------------- ;;
;; --- auto settings --- ;;
;; --------------------- ;;

