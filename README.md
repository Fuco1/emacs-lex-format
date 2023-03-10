# lex-format [![test](https://github.com/Fuco1/lex-format/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/Fuco1/lex-format/actions/workflows/test.yml)

Lexical scope aware format strings with {{mustache}} templating.

(a.k.a. f-strings for Emacs)

# Usage

This package only works with [lexical
binding](https://www.gnu.org/software/emacs/manual/html_node/elisp/Lexical-Binding.html)
turned on.  To enable lexical binding, place:

``` emacs-lisp
;; -*- lexical-binding: t -*-
```

at the top of the file.

`lex-format` uses mustache-like syntax for interpolation parameters.
Any sequence `{{name}}` will be replaced by the value of variable
`name` in the scope where `lex-format` is called.

For example:

``` emacs-lisp
(let ((a 1))
  (lex-format "a is {{a}}"))

  ;; => "a is 1"
```

will result in string `"a is 1"`.

Note that the format string itself doesn't have to be known at the
time this is called, so:

``` emacs-lisp
(defun my-format (fmt)
  (let ((x 5))
    (lex-format fmt)))

(my-format "one format with {{x}}")
;; => "one format with 5"

(my-format "different format with {{x}}")
;; => "different format with 5".
```

Variables are by default replaced with `(format "%s" value)`, but you
can customize how custom or more complicated types are printed by
defining a new `cl-defmethod` `lex-format-to-string` for your type.

For example, to change how symbols are printed, you can define

``` emacs-lisp
(cl-defmethod lex-format-to-string ((obj symbol))
  (format "symbol %s" obj))
```

Then:

``` emacs-lisp
(let ((a 1) (b 'hello))
  (lex-format "a is {{a}} and b is {{b}}"))
;; => "a is 1 and b is symbol hello".
```

The `lex-format-to-string` method is most useful for EIEIO `defclass`
or `cl-defstruct` to provide more human-readable string
representation.

# Acknowledgments

While [s.el](https://github.com/magnars/s.el) provides `s-lex-format`,
it does not rely on `lexical-binding` and so is less flexible, most
notably, the format string to `s-lex-format` must be a constant string
and can not be passed in as a variable.

``` emacs-lisp
(let ((a 1)
      (fmt "a is ${a}"))
  (s-lex-format fmt))
```

results in

    (wrong-type-argument sequencep fmt)
