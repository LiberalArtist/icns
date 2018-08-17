#lang racket/base

(require racket/contract
         racket/match
         pict
         pict/convert
         file/convertible)

(provide (contract-out
          [pict->icns-bytes
           (-> pict-convertible? any)]
          ))

(module+ test
  (require rackunit
           (submod "..")))

(module+ main
  (require racket/runtime-path))

;; Thanks https://en.wikipedia.org/wiki/Apple_Icon_Image_format
;; TODO post-MVP: Support TOC section

(struct spec (effective-size type@2x type)
  #:transparent)

(define all-specs
  (list (spec 512 #"ic10" #"ic09")
        (spec 256 #"ic14" #"ic08")
        (spec 128 #"ic13" #"ic07")
        (spec 32 #"ic12" #"icp5")
        (spec 16 #"ic11" #"icp4")))

(define (pict->icns-bytes pict)
  (define bs
    (for/fold ([bs #""])
              ([s (in-list all-specs)])
      (match-define (spec size type@2x type)
        s)
      (define scaled-pict
        (cc-superimpose (blank size size)
                        (scale-to-fit pict size size)))
      (bytes-append bs
                    (make-1-type scaled-pict type@2x 'png@2x-bytes)
                    (make-1-type scaled-pict type 'png-bytes))))
  (define len
    (+ 8 (bytes-length bs)))
  (bytes-append #"icns"
                (integer->size-bytes len)
                bs))

(define (integer->size-bytes x)
  (integer->integer-bytes x 4 #f 'big-endian))

(define (make-1-type scaled-pict type convert-sym)
  (define png-bytes
    (convert scaled-pict convert-sym))
  (define len
    (+ 8 (bytes-length png-bytes)))
  (bytes-append type (integer->size-bytes len) png-bytes))

(module+ test
  (check-not-exn
   (λ ()
     (struct non-native ()
       #:property prop:pict-convertible
       (λ (this) (standard-fish 100 50)))
     (pict->icns-bytes (non-native)))))

(module+ main
  (define standard-fish-icns-bytes
    (pict->icns-bytes (standard-fish 100 50)))

  (define-runtime-path standard-fish.icns
    "standard-fish.icns")

  (with-output-to-file standard-fish.icns
    #:exists 'replace
    (λ () (void (write-bytes standard-fish-icns-bytes)))))



