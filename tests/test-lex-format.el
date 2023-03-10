;; -*- lexical-binding: t -*-

(require 'buttercup)
(require 'lex-format)

(cl-defstruct foo a)

(cl-defstruct bar a)

(cl-defmethod lex-format-to-string ((obj bar))
  (format "obj is bar with slot %s" (bar-a obj)))

(describe "lex-format"

  (describe "basic parameter test"
    (it "should replace parameter at the beginning"
      (expect (let ((a 1))
                (lex-format "{{a}} is number"))
              :to-equal "1 is number"))

    (it "should replace parameter at the end"
      (expect (let ((a 1))
                (lex-format "number is {{a}}"))
              :to-equal "number is 1"))

    (it "should replace the same parameter multiple times if present"
      (expect (let ((a 1))
                (lex-format "{{a}} = {{a}}"))
              :to-equal "1 = 1"))

    (it "should replace two parameters"
      (expect (let ((a 1) (b 2))
                (lex-format "{{a}} /= {{b}}"))
              :to-equal "1 /= 2")))

  (describe "lex-to-string"
    (it "should format simple variable from lexical scope"
      (expect (let ((a 1))
                (lex-format "a is {{a}}"))
              :to-equal "a is 1"))

    (it "should format a defstruct from lexical scope"
      (expect (let ((a (make-foo)))
                (lex-format "a is {{a}}"))
              :to-equal "a is #s(foo nil)"))

    (it "should use lex-to-string to format objects if the method is defined"
      (expect (let ((a (make-bar)))
                (lex-format "{{a}}"))
              :to-equal "obj is bar with slot nil"))))
