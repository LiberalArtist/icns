#lang racket

(require pict
         adjutor
         racket/runtime-path
         file/convertible)

;; Thanks https://en.wikipedia.org/wiki/Apple_Icon_Image_format

;; TODO post-MVP: Support TOC section

(struct spec (real-size type@2x type)
  #:transparent)

(define all-specs
  (list
   (spec 1024 #"ic10" #f)
   (spec 512 #"ic14" #"ic09")
   (spec 256 #"ic13" #"ic08")
   (spec 128 #f #"ic07")
   (spec 64 #"ic12" #"icp6") ;; icp6 not recommended in https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/Optimizing/Optimizing.html#//apple_ref/doc/uid/TP40012302-CH7-SW4
   (spec 32 #"ic11" #"icp5")
   (spec 16 #f #"icp4")))

(define (pict->icns-bytes pict)
  (for/fold/define ([bs #""])
                   ([s (in-list all-specs)])
    (match-define (spec size type@2x type)
      s)
    (define scaled-pict
      (cc-superimpose (blank size size)
                      (scale-to-fit pict size size)))
    (bytes-append bs
                  (make-1-type scaled-pict type@2x 'png@2x-bytes)
                  (make-1-type scaled-pict type 'png-bytes)))
  (define len
    (+ 8 (bytes-length bs)))
  (bytes-append #"icns"
                (integer->size-bytes len)
                bs))

(define (integer->size-bytes x)
  (integer->integer-bytes x 4 #f 'big-endian))

(define (make-1-type scaled-pict type convert-sym)
  (cond
    [type
     (define png-bytes
       (convert scaled-pict convert-sym))
     (define len
       (+ 8 (bytes-length png-bytes)))
     (bytes-append type (integer->size-bytes len) png-bytes)]
    [else
     #""]))

(define standard-fish-icns-bytes
  (pict->icns-bytes (standard-fish 100 50)))

(define-runtime-path standard-fish.icns
  "standard-fish.icns")

(with-output-to-file standard-fish.icns
  #:exists 'replace
  (λ () (write-bytes standard-fish-icns-bytes)))


