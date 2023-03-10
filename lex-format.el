;;; lex-format.el --- Lexical scope aware f-strings with {{mustache}} templating -*- lexical-binding: t -*-

;; Copyright (C) 2023 Matúš Goljer

;; Author: Matúš Goljer <matus.goljer@gmail.com>
;; Maintainer: Matúš Goljer <matus.goljer@gmail.com>
;; Version: 0.1.0
;; Created: 10th March 2023
;; Package-requires: ((emacs "26.1"))
;; URL: https://github.com/Fuco1/emacs-lex-format
;; Keywords: convenience, lisp

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Lexical scope aware format strings with {{mustache}} templating.
;; See docstring for `lex-format'.

;;; Code:

(require 'eieio)

;; This is copied from s.el `s-match-strings-all' to avoid that
;; dependency.
(defun lex-format--match-strings-all (regex string)
  "Return a list of matches for REGEX in STRING.

Each element itself is a list of matches, as per `match-string'.
Multiple matches at the same position will be ignored after the
first."
  (declare (side-effect-free t))
  (save-match-data
    (let ((all-strings ())
          (i 0))
      (while (and (< i (length string))
                  (string-match regex string i))
        (setq i (1+ (match-beginning 0)))
        (let (strings
              (num-matches (/ (length (match-data)) 2))
              (match 0))
          (while (/= match num-matches)
            (push (match-string match string) strings)
            (setq match (1+ match)))
          (push (nreverse strings) all-strings)))
      (nreverse all-strings))))

(cl-defgeneric lex-format-to-string (obj)
  "Format OBJ as string."
  (format "%s" obj))

(defun lex-format--internal (fmt env)
  "Perform the substitution in FMT using ENV.

ENV is a closure created at the moment this function was called
capturing the local environment."
  (let ((subst (lex-format--match-strings-all "{{\\([^}]+\\)}}" fmt)))
    (let ((result fmt))
      (dolist (sub subst)
        (setq result
              (replace-regexp-in-string
               (regexp-quote (car sub))
               (lex-format-to-string (eval (intern (cadr sub)) (cadr env)))
               result)))
      result)))

(defmacro lex-format (fmt)
  "Replace interpolation parameters in FMT from the lexical environment.

An interpolation parameter has a format {{name}}, where name is a
variable in the lexical scope where this is called.

For example:

  (let ((a 1))
    (lex-format \"a is {{a}}\"))

will result in string \"a is 1\".

Note that the fmt itself doesn't have to be known at the time
this is called, so:

  (defun my-format (fmt)
    (let ((x 5))
      (lex-format fmt)))

  (my-format \"one format with {{x}}\")
  ;; => \"one format with 5\"

  (my-format \"different format with {{x}}\")
  ;; => \"different format with 5\".

Variables are by default replaced with `(format \"%s\" value)',
but you can customize how custom or more complicated types are
printed by defining a new `cl-defmethod' `lex-format-to-string'
for your type.

For example, to change how symbols are printed, you can define

  (cl-defmethod lex-format-to-string ((obj symbol))
    (format \"symbol %s\" obj))

Then:

  (let ((a 1) (b 'hello))
    (lex-format \"a is {{a}} and b is {{b}}\"))
  ;; => \"a is 1 and b is symbol hello\".

The `lex-format-to-string' method is most useful for EIEIO
`defclass' or `cl-defstruct' to provide more human-readable
string representation."
  (declare (debug sexp))
  (unless lexical-binding (error "Function lex-format requires lexical binding to be on"))
  `(lex-format--internal ,fmt (lambda () t)))

(provide 'lex-format)
;;; lex-format.el ends here
