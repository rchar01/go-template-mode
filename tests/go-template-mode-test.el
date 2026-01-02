;;; go-template-mode-test.el --- Tests for go-template-mode -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Robert Charusta

;; Author: Robert Charusta <rch-public@posteo.net>
;; URL: https://codeberg.org/rch/go-template-mode
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

;; Minimal ERT tests for go-template-mode.
;; These tests enable the mode in a temp buffer, run font-lock, and
;; assert that expected faces are applied.

;;; Code:

(require 'ert)
(require 'go-template-mode)

(defun go-template-mode-test--has-face-p (pos face)
  "Return non-nil if text at POS has FACE (symbol) applied."
  (let ((f (get-text-property pos 'face)))
    (cond
     ((eq f face) t)
     ((listp f) (memq face f))
     (t nil))))

(ert-deftest go-template-mode-fontifies-basic-tokens ()
  "Ensure delimiters, variables, keywords, builtins, and comments are fontified."
  (with-temp-buffer
    (insert "{{ if $x }} {{ printf \"hi\" }} {{/* c1\nc2 */}} <div> <br>\n")
    (go-template-mode)
    (font-lock-ensure)

    ;; Delimiter {{
    (should (go-template-mode-test--has-face-p
             (point-min)
             'font-lock-preprocessor-face))
    ;; Keyword "if" (starts at pos 4 in the inserted string)
    (should (go-template-mode-test--has-face-p
             (+ (point-min) 3)
             'font-lock-keyword-face))
    ;; Variable "$x"
    (should (go-template-mode-test--has-face-p
             (+ (point-min) 6)
             'font-lock-variable-name-face))
    ;; Builtin "printf"
    (should (go-template-mode-test--has-face-p
             (+ (point-min) 17)
             'font-lock-builtin-face))
    ;; Comment start {{/*
    (let ((i (string-match "{{/\\*" (buffer-string))))
      (should i)
      (should (go-template-mode-test--has-face-p
               (+ (point-min) i)
               'font-lock-comment-face)))
    ;; Simple HTML tag <div
    (let ((j (string-match "<div" (buffer-string))))
      (should j)
      (should (go-template-mode-test--has-face-p
               (+ (point-min) j)
               'font-lock-function-name-face)))))

(ert-deftest go-template-mode-sets-comment-delimiters ()
  "Ensure comment delimiters are set for `M-;' convenience."
  (with-temp-buffer
    (go-template-mode)
    (should (equal comment-start "{{/* "))
    (should (equal comment-end " */}}"))))

(provide 'go-template-mode-test)
;;; go-template-mode-test.el ends here
