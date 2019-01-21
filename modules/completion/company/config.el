;;; completion/company/config.el -*- lexical-binding: t; -*-

(def-package! company
  :commands (company-complete-common company-manual-begin company-grab-line)
  :init
  (setq company-tooltip-limit 14
        company-dabbrev-downcase nil
        company-dabbrev-ignore-case nil
        company-dabbrev-code-other-buffers t
        company-tooltip-align-annotations t
        company-require-match 'never
        company-global-modes
        '(not erc-mode message-mode help-mode gud-mode eshell-mode)
        company-backends '(company-capf)
        company-frontends
        '(company-echo-strip-common-frontend))
  :config
  (add-hook 'company-mode-hook #'+company|init-backends)
  (global-company-mode +1)
  (defadvice eldoc-display-message-no-interference-p
      (after dont-show-when-isearching activate)
    "Prevents eldoc from interfering with company-echo."
    (setq ad-return-value (and ad-return-value
                               (not company-candidates)))))


(def-package! company
  :when (featurep! +auto)
  :defer 2
  :after-call post-self-insert-hook
  :config (setq company-idle-delay 0.1))


(def-package! company-tng
  :when (featurep! +tng)
  :defer 2
  :after-call post-self-insert-hook
  :config
  (add-to-list 'company-frontends 'company-tng-frontend)
  (define-key! company-active-map
    "RET"       nil
    [return]    nil
    "TAB"       #'company-select-next
    [tab]       #'company-select-next
    "<backtab>" #'company-select-previous
    [backtab]   #'company-select-previous))


;;
;; Packages

(def-package! company-prescient
  :hook (company-mode . company-prescient-mode)
  :config
  (setq prescient-save-file (concat doom-cache-dir "prescient-save.el"))
  (prescient-persist-mode +1))

(def-package! company-dict
  :defer t
  :config
  (defun +company|enable-project-dicts (mode &rest _)
    "Enable per-project dictionaries."
    (if (symbol-value mode)
        (add-to-list 'company-dict-minor-mode-list mode nil #'eq)
      (setq company-dict-minor-mode-list (delq mode company-dict-minor-mode-list))))
  (add-hook 'doom-project-hook #'+company|enable-project-dicts))

