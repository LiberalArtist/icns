#lang scribble/manual

@title{@racketmodname[icns]: Apple Icon Files}
@author[(author+email @elem{Philip M@superscript{c}Grath}
                      "philip@philipmcgrath.com"
                      #:obfuscate? #t)]
@defmodule[icns]

@(require (for-label icns
                     pict
                     pict/convert
                     racket))

This is a (very early-stage) library for working with
Apple's @tt{.icns} icon file format.

@defproc[(pict->icns-bytes [pict pict-convertible?])
         bytes?]{
 Like @racket[pict->argb-pixels], but returns bytes in
 Apple's @tt{.icns} icon file format.
 The @racket[pict] will be scalled to various sizes,
 and, if it is not a square, it will be centered on
 a transparent square.
 There is currently no way to configure this behavior.
}

