;;; lang/clojure/config.el -*- lexical-binding: t; -*-

;; `clojure-mode'
(after! clojure-mode
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)

  (set-popup-rules!
    '(("^\\*cider-error*" :ignore t)
      ("^\\*cider-repl" :quit nil)
      ("^\\*cider-repl-history" :vslot 2 :ttl nil)))
 
  (def-package! cider
    ;; NOTE: if you don't have an org directory set (the dir doesn't exist),
    ;; cider jack in won't work.
    :commands (cider-jack-in cider-jack-in-clojurescript)
    :hook (clojure-mode . cider-mode)
    :init
    (set-repl-handler! 'clojure-mode #'+clojure/repl)
    (set-eval-handler! 'clojure-mode #'cider-eval-region)
    (set-lookup-handlers! 'clojure-mode
      :definition #'cider-browse-ns-find-at-point
      :documentation #'cider-browse-ns-doc-at-point)
    (add-hook 'cider-mode-hook #'eldoc-mode)
    :config
    (setq nrepl-hide-special-buffers t
          nrepl-log-messages nil
          cider-font-lock-dynamically '(macro core function var)
          cider-overlays-use-font-lock t
          cider-prompt-for-symbol nil
          cider-repl-display-help-banner nil
          cider-repl-history-display-duplicates nil
          cider-repl-history-display-style 'one-line
          cider-repl-history-file (concat doom-cache-dir "cider-repl-history")
          cider-repl-history-highlight-current-entry t
          cider-repl-history-quit-action 'delete-and-restore
          cider-repl-history-highlight-inserted-item t
          cider-repl-history-size 1000
          cider-repl-pop-to-buffer-on-connect 'display-only
          cider-repl-result-prefix ";; => "
          cider-repl-print-length 100
          cider-repl-use-clojure-font-lock t
          cider-repl-use-pretty-printing t
          cider-repl-wrap-history nil
          cider-stacktrace-default-filters '(tooling dup))

    ;; TODO: Add mode-local labels when general support is in.
    (map! (:localleader
            (:map clojure-mode-map
              "'"  #'cider-jack-in
              "\"" #'cider-jack-in-clojurescript
              "=" #'cider-format-buffer)
            (:map cider-mode-map
              ;; debug
              (:prefix "d"
                "b" #'cider-debug-defun-at-point
                "v" #'cider-inspect)

              ;; eval
              (:prefix "e"
                ";" #'cider-eval-defun-to-comment
                "f" #'cider-eval-defun-at-point
                "F" #'cider-insert-defun-in-repl
                "e" #'cider-eval-last-sexp
                "E" #'cider-insert-last-sexp-in-repl
                "m" #'cider-macroexpand-1
                "M" #'cider-macroexpand-all
                "r" #'cider-eval-region
                "P" #'cider-pprint-eval-last-sexp
                "R" #'cider-insert-region-in-repl
                "u" #'cider-undef
                "w" #'cider-eval-last-sexp-and-replace)

              ;; go/jump
              (:prefix "g"
                "b" #'cider-pop-back
                "g" #'cider-find-var
                "n" #'cider-find-ns
                "c" 'cider-classpath
                "e" 'cider-jump-to-compilation-error
                "r" 'cider-find-resource
                "s" 'cider-browse-spec
                "S" 'cider-browse-spec-all)

              ;; help
              (:prefix "h"
                "c" #'cider-cheatsheet
                "n" #'cider-browse-ns
                "N" #'cider-browse-ns-all
                "a" #'cider-apropos
                "d" #'cider-doc
                "g" #'cider-grimoire
                "j" #'cider-javadoc)

              ;; inspect
              (:prefix "i"
                "i" #'cider-inspect
                "r" #'cider-inspect-last-result)

              ;; namespace
              (:prefix "n"
                "n" #'cider-browse-ns
                "N" #'cider-browse-ns-all)
              ;; repl
              (:prefix "r"
                "n" #'cider-repl-set-ns
                "q" #'cider-quit
                "r" #'cider-ns-refresh
                "R" #'cider-restart
                "b" #'cider-switch-to-repl-buffer
                "B" #'+clojure/cider-switch-to-repl-buffer-and-switch-ns
                "c" #'cider-repl-clear-buffer)

              ;; test
              (:prefix "t"
                "b" #'cider-test-show-report
                "l" #'cider-test-run-loaded-tests
                "n" #'cider-test-run-ns-tests
                "p" #'cider-test-run-project-tests
                "r" #'cider-test-rerun-failed-tests
                "t" #'cider-test-run-test)

              ;; profile
              (:prefix "p"
                "+" #'cider-profile-samples
                "c" #'cider-profile-clear
                "n" #'cider-profile-ns-toggle
                "s" #'cider-profile-var-summary
                "S" #'cider-profile-summary
                "t" #'cider-profile-toggle
                "v" #'cider-profile-var-profiled-p)))



          (:when (featurep! :feature evil +everywhere)
            :map cider-repl-mode-map :i [S-return] #'cider-repl-newline-and-indent
            :map cider-repl-history-mode-map
            :i [return]  #'cider-repl-history-insert-and-quit
            :i "q"  #'cider-repl-history-quit
            :i "l"  #'cider-repl-history-occur
            :i "s"  #'cider-repl-history-search-forward
            :i "r"  #'cider-repl-history-search-backward
            :i "U"  #'cider-repl-history-undo-other-window)))

  (def-package! clj-refactor
    :hook (clojure-mode . clj-refactor-mode)
    :config
    (map! :map clj-refactor-map
          :localleader
          "R" #'hydra-cljr-help-menu/body))

  (def-package! flycheck-joker
    :when (featurep! :feature syntax-checker)
    :after flycheck))
