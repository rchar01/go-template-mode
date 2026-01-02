;;; go-template-mode.el --- Major mode for Go templates -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Robert Charusta

;; Author: Robert Charusta <rch-public@posteo.net>
;; Maintainer: Robert Charusta <rch-public@posteo.net>
;; URL: https://codeberg.org/rch/go-template-mode
;; Version: 1.0.0
;; Keywords: languages, tools
;; Package-Requires: ((emacs "28.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Lightweight, fast major mode for Go text/template files.  Focuses on
;; cheap, incremental font-lock without custom parsers/caches.

;;; Code:

(defgroup go-template nil
  "Editing Go text/template files."
  :group 'languages
  :prefix "go-template-")

(defvar go-template-mode-syntax-table
  (let ((st (make-syntax-table)))
    ;; Treat underscore as word constituent.
    (modify-syntax-entry ?_ "w" st)
    st)
  "Syntax table for `go-template-mode'.")

(defconst go-template-mode-keywords
  '("define" "else" "end" "if" "range" "template" "with")
  "Go template control keywords.")

(defconst go-template-mode-builtins
  '("and" "html" "index" "js" "len" "not" "or" "print" "printf"
    "println" "urlquery")
  "Go template builtin functions.")

(defconst go-template-mode-pair-tag
  (regexp-opt
   '("a" "abbr" "acronym" "address" "applet" "b" "bdo"
     "big" "blockquote" "body" "button" "caption" "center" "cite"
     "code" "colgroup" "dd" "del" "dfn" "div" "dl"
     "dt" "em" "fieldset" "font" "form" "frame" "frameset" "h1"
     "header" "nav" "footer" "section"
     "h2" "h3" "h4" "h5" "h6" "head" "html" "i" "iframe" "ins"
     "kbd" "label" "legend" "li" "map" "menu" "noframes"
     "noscript" "object" "ol" "optgroup" "option" "p" "pre" "q"
     "s" "samp" "script" "select" "small" "span" "strike"
     "strong" "style" "sub" "sup" "table" "tbody" "td" "textarea"
     "tfoot" "th" "thead" "title" "tr" "tt" "u" "ul" "var")
   t)
  "Regexp matching basic paired HTML tag names for cheap highlighting.")

(defconst go-template-mode-standalone-tag
  (regexp-opt
   '("area" "base" "br" "col" "hr" "img" "input" "link" "meta" "param")
   t)
  "Regexp matching basic standalone HTML tag names for cheap highlighting.")

(defun go-template-mode--font-lock-comments (limit)
  "Match Go template comments up to LIMIT.
This highlights constructs of the form {{/* ... */}}."
  (let (start)
    (when (re-search-forward "{{/\\*" limit t)
      (setq start (match-beginning 0))
      (if (search-forward "*/}}" limit t)
          (progn
            (set-match-data (list start (point)))
            (put-text-property start (point) 'font-lock-multiline t)
            t)
        (goto-char limit)
        nil))))

(defconst go-template-mode-font-lock-keywords
  `((go-template-mode--font-lock-comments 0 font-lock-comment-face t)
    (,(regexp-opt '("{{" "}}")) . font-lock-preprocessor-face)
    ("\\$[A-Za-z0-9_]+" . font-lock-variable-name-face)
    (,(regexp-opt go-template-mode-keywords 'words) . font-lock-keyword-face)
    (,(regexp-opt go-template-mode-builtins 'words) . font-lock-builtin-face)
    (,(concat "</?" go-template-mode-pair-tag ">?") . font-lock-function-name-face)
    (,(concat "<" go-template-mode-standalone-tag ">?") . font-lock-function-name-face))
  "Font-lock rules for `go-template-mode'.")

;;;###autoload
(define-derived-mode go-template-mode text-mode "Go-Template"
  "Major mode for editing Go text/template files."
  :syntax-table go-template-mode-syntax-table
  ;; Comments for M-; convenience (not syntactically enforced).
  (setq-local comment-start "{{/* ")
  (setq-local comment-end " */}}")
  ;; Lightweight font-lock.
  (setq-local font-lock-defaults
              '(go-template-mode-font-lock-keywords nil nil nil nil))
  ;; Tabs are common in Go codebases; keep user default here.
  (setq-local indent-tabs-mode t))

;;;###autoload
(add-to-list 'auto-mode-alist
             '("\\.\\(gotmpl\\|tpl\\|tmpl\\)\\'" . go-template-mode))

(provide 'go-template-mode)
;;; go-template-mode.el ends here
