#lang info

(define pkg-name "icns")
(define collection "icns")
(define pkg-desc "Library for Apple .icns icon format")
(define version "0.0")
(define pkg-authors '(philip))

(define scribblings '(("scribblings/icns.scrbl" ())))

(define deps '("base"
               "pict-lib"
               ))
(define build-deps '("scribble-lib"
                     "racket-doc"
                     "rackunit-lib"
                     "pict-doc"
                     ))


