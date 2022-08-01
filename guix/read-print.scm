;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2021-2022 Ludovic Courtès <ludo@gnu.org>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (guix read-print)
  #:use-module (ice-9 control)
  #:use-module (ice-9 match)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 vlist)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-34)
  #:use-module (srfi srfi-35)
  #:export (pretty-print-with-comments
            read-with-comments
            object->string*

            comment
            comment?
            comment->string
            comment-margin?
            canonicalize-comment))

;;; Commentary:
;;;
;;; This module provides a comment-preserving reader and a comment-preserving
;;; pretty-printer smarter than (ice-9 pretty-print).
;;;
;;; Code:


;;;
;;; Comment-preserving reader.
;;;

;; A comment.
(define-record-type <comment>
  (string->comment str margin?)
  comment?
  (str     comment->string)
  (margin? comment-margin?))

(define* (comment str #:optional margin?)
  "Return a new comment made from STR.  When MARGIN? is true, return a margin
comment; otherwise return a line comment.  STR must start with a semicolon and
end with newline, otherwise an error is raised."
  (when (or (string-null? str)
            (not (eqv? #\; (string-ref str 0)))
            (not (string-suffix? "\n" str)))
    (raise (condition
            (&message (message "invalid comment string")))))
  (string->comment str margin?))

(define (read-with-comments port)
  "Like 'read', but include <comment> objects when they're encountered."
  ;; Note: Instead of implementing this functionality in 'read' proper, which
  ;; is the best approach long-term, this code is a layer on top of 'read',
  ;; such that we don't have to rely on a specific Guile version.
  (define dot (list 'dot))
  (define (dot? x) (eq? x dot))

  (define (reverse/dot lst)
    ;; Reverse LST and make it an improper list if it contains DOT.
    (let loop ((result '())
               (lst lst))
      (match lst
        (() result)
        (((? dot?) . rest)
         (let ((dotted (reverse rest)))
           (set-cdr! (last-pair dotted) (car result))
           dotted))
        ((x . rest) (loop (cons x result) rest)))))

  (let loop ((blank-line? #t)
             (return (const 'unbalanced)))
    (match (read-char port)
      ((? eof-object? eof)
       eof)                                       ;oops!
      (chr
       (cond ((eqv? chr #\newline)
              (loop #t return))
             ((char-set-contains? char-set:whitespace chr)
              (loop blank-line? return))
             ((memv chr '(#\( #\[))
              (let/ec return
                (let liip ((lst '()))
                  (liip (cons (loop (match lst
                                      (((? comment?) . _) #t)
                                      (_ #f))
                                    (lambda ()
                                      (return (reverse/dot lst))))
                              lst)))))
             ((memv chr '(#\) #\]))
              (return))
             ((eq? chr #\')
              (list 'quote (loop #f return)))
             ((eq? chr #\`)
              (list 'quasiquote (loop #f return)))
             ((eq? chr #\,)
              (list (match (peek-char port)
                      (#\@
                       (read-char port)
                       'unquote-splicing)
                      (_
                       'unquote))
                    (loop #f return)))
             ((eqv? chr #\;)
              (unread-char chr port)
              (string->comment (read-line port 'concat)
                               (not blank-line?)))
             (else
              (unread-char chr port)
              (match (read port)
                ((and token '#{.}#)
                 (if (eq? chr #\.) dot token))
                (token token))))))))

;;;
;;; Comment-preserving pretty-printer.
;;;

(define-syntax vhashq
  (syntax-rules (quote)
    ((_) vlist-null)
    ((_ (key (quote (lst ...))) rest ...)
     (vhash-consq key '(lst ...) (vhashq rest ...)))
    ((_ (key value) rest ...)
     (vhash-consq key '((() . value)) (vhashq rest ...)))))

(define %special-forms
  ;; Forms that are indented specially.  The number is meant to be understood
  ;; like Emacs' 'scheme-indent-function' symbol property.  When given an
  ;; alist instead of a number, the alist gives "context" in which the symbol
  ;; is a special form; for instance, context (modify-phases) means that the
  ;; symbol must appear within a (modify-phases ...) expression.
  (vhashq
   ('begin 1)
   ('lambda 2)
   ('lambda* 2)
   ('match-lambda 1)
   ('match-lambda* 2)
   ('define 2)
   ('define* 2)
   ('define-public 2)
   ('define*-public 2)
   ('define-syntax 2)
   ('define-syntax-rule 2)
   ('define-module 2)
   ('define-gexp-compiler 2)
   ('let 2)
   ('let* 2)
   ('letrec 2)
   ('letrec* 2)
   ('match 2)
   ('when 2)
   ('unless 2)
   ('package 1)
   ('origin 1)
   ('modify-inputs 2)
   ('modify-phases 2)
   ('add-after '(((modify-phases) . 3)))
   ('add-before '(((modify-phases) . 3)))
   ('replace '(((modify-phases) . 2)))         ;different from 'modify-inputs'
   ('substitute* 2)
   ('substitute-keyword-arguments 2)
   ('call-with-input-file 2)
   ('call-with-output-file 2)
   ('with-output-to-file 2)
   ('with-input-from-file 2)
   ('with-directory-excursion 2)

   ;; (gnu system) and (gnu services).
   ('operating-system 1)
   ('bootloader-configuration 1)
   ('mapped-device 1)
   ('file-system 1)
   ('swap-space 1)
   ('user-account 1)
   ('user-group 1)
   ('setuid-program 1)
   ('modify-services 2)

   ;; (gnu home).
   ('home-environment 1)))

(define %newline-forms
  ;; List heads that must be followed by a newline.  The second argument is
  ;; the context in which they must appear.  This is similar to a special form
  ;; of 1, except that indent is 1 instead of 2 columns.
  (vhashq
   ('arguments '(package))
   ('sha256 '(origin source package))
   ('base32 '(sha256 origin))
   ('git-reference '(uri origin source))
   ('search-paths '(package))
   ('native-search-paths '(package))
   ('search-path-specification '())

   ('services '(operating-system))
   ('set-xorg-configuration '())
   ('services '(home-environment))))

(define (prefix? candidate lst)
  "Return true if CANDIDATE is a prefix of LST."
  (let loop ((candidate candidate)
             (lst lst))
    (match candidate
      (() #t)
      ((head1 . rest1)
       (match lst
         (() #f)
         ((head2 . rest2)
          (and (equal? head1 head2)
               (loop rest1 rest2))))))))

(define (special-form-lead symbol context)
  "If SYMBOL is a special form in the given CONTEXT, return its number of
arguments; otherwise return #f.  CONTEXT is a stack of symbols lexically
surrounding SYMBOL."
  (match (vhash-assq symbol %special-forms)
    (#f #f)
    ((_ . alist)
     (any (match-lambda
            ((prefix . level)
             (and (prefix? prefix context) (- level 1))))
          alist))))

(define (newline-form? symbol context)
  "Return true if parenthesized expressions starting with SYMBOL must be
followed by a newline."
  (match (vhash-assq symbol %newline-forms)
    (#f #f)
    ((_ . prefix)
     (prefix? prefix context))))

(define (escaped-string str)
  "Return STR with backslashes and double quotes escaped.  Everything else, in
particular newlines, is left as is."
  (list->string
   `(#\"
     ,@(string-fold-right (lambda (chr lst)
                            (match chr
                              (#\" (cons* #\\ #\" lst))
                              (#\\ (cons* #\\ #\\ lst))
                              (_   (cons chr lst))))
                          '()
                          str)
     #\")))

(define (string-width str)
  "Return the \"width\" of STR--i.e., the width of the longest line of STR."
  (apply max (map string-length (string-split str #\newline))))

(define (canonicalize-comment c)
  "Canonicalize comment C, ensuring it has the \"right\" number of leading
semicolons."
  (let ((line (string-trim-both
               (string-trim (comment->string c) (char-set #\;)))))
    (string->comment (string-append
                      (if (comment-margin? c)
                          ";"
                          (if (string-null? line)
                              ";;"                        ;no trailing space
                              ";; "))
                      line "\n")
                     (comment-margin? c))))

(define* (pretty-print-with-comments port obj
                                     #:key
                                     (format-comment identity)
                                     (indent 0)
                                     (max-width 78)
                                     (long-list 5))
  "Pretty-print OBJ to PORT, attempting to at most MAX-WIDTH character columns
and assuming the current column is INDENT.  Comments present in OBJ are
included in the output.

Lists longer than LONG-LIST are written as one element per line.  Comments are
passed through FORMAT-COMMENT before being emitted; a useful value for
FORMAT-COMMENT is 'canonicalize-comment'."
  (define (list-of-lists? head tail)
    ;; Return true if HEAD and TAIL denote a list of lists--e.g., a list of
    ;; 'let' bindings.
    (match head
      ((thing _ ...)                              ;proper list
       (and (not (memq thing
                       '(quote quasiquote unquote unquote-splicing)))
            (pair? tail)))
      (_ #f)))

  (let loop ((indent indent)
             (column indent)
             (delimited? #t)                  ;true if comes after a delimiter
             (context '())                    ;list of "parent" symbols
             (obj obj))
    (define (print-sequence context indent column lst delimited?)
      (define long?
        (> (length lst) long-list))

      (let print ((lst lst)
                  (first? #t)
                  (delimited? delimited?)
                  (column column))
        (match lst
          (()
           column)
          ((item . tail)
           (define newline?
             ;; Insert a newline if ITEM is itself a list, or if TAIL is long,
             ;; but only if ITEM is not the first item.  Also insert a newline
             ;; before a keyword.
             (and (or (pair? item) long?
                      (and (keyword? item)
                           (not (eq? item #:allow-other-keys))))
                  (not first?) (not delimited?)
                  (not (comment? item))))

           (when newline?
             (newline port)
             (display (make-string indent #\space) port))
           (let ((column (if newline? indent column)))
             (print tail
                    (keyword? item)      ;keep #:key value next to one another
                    (comment? item)
                    (loop indent column
                          (or newline? delimited?)
                          context
                          item)))))))

    (define (sequence-would-protrude? indent lst)
      ;; Return true if elements of LST written at INDENT would protrude
      ;; beyond MAX-WIDTH.  This is implemented as a cheap test with false
      ;; negatives to avoid actually rendering all of LST.
      (find (match-lambda
              ((? string? str)
               (>= (+ (string-width str) 2 indent) max-width))
              ((? symbol? symbol)
               (>= (+ (string-width (symbol->string symbol)) indent)
                   max-width))
              ((? boolean?)
               (>= (+ 2 indent) max-width))
              (()
               (>= (+ 2 indent) max-width))
              (_                                  ;don't know
               #f))
            lst))

    (define (special-form? head)
      (special-form-lead head context))

    (match obj
      ((? comment? comment)
       (if (comment-margin? comment)
           (begin
             (display " " port)
             (display (comment->string (format-comment comment))
                      port))
           (begin
             ;; When already at the beginning of a line, for example because
             ;; COMMENT follows a margin comment, no need to emit a newline.
             (unless (= column indent)
               (newline port)
               (display (make-string indent #\space) port))
             (display (comment->string (format-comment comment))
                      port)))
       (display (make-string indent #\space) port)
       indent)
      (('quote lst)
       (unless delimited? (display " " port))
       (display "'" port)
       (loop indent (+ column (if delimited? 1 2)) #t context lst))
      (('quasiquote lst)
       (unless delimited? (display " " port))
       (display "`" port)
       (loop indent (+ column (if delimited? 1 2)) #t context lst))
      (('unquote lst)
       (unless delimited? (display " " port))
       (display "," port)
       (loop indent (+ column (if delimited? 1 2)) #t context lst))
      (('unquote-splicing lst)
       (unless delimited? (display " " port))
       (display ",@" port)
       (loop indent (+ column (if delimited? 2 3)) #t context lst))
      (('gexp lst)
       (unless delimited? (display " " port))
       (display "#~" port)
       (loop indent (+ column (if delimited? 2 3)) #t context lst))
      (('ungexp obj)
       (unless delimited? (display " " port))
       (display "#$" port)
       (loop indent (+ column (if delimited? 2 3)) #t context obj))
      (('ungexp-native obj)
       (unless delimited? (display " " port))
       (display "#+" port)
       (loop indent (+ column (if delimited? 2 3)) #t context obj))
      (('ungexp-splicing lst)
       (unless delimited? (display " " port))
       (display "#$@" port)
       (loop indent (+ column (if delimited? 3 4)) #t context lst))
      (('ungexp-native-splicing lst)
       (unless delimited? (display " " port))
       (display "#+@" port)
       (loop indent (+ column (if delimited? 3 4)) #t context lst))
      (((? special-form? head) arguments ...)
       ;; Special-case 'let', 'lambda', 'modify-inputs', etc. so the second
       ;; and following arguments are less indented.
       (let* ((lead    (special-form-lead head context))
              (context (cons head context))
              (head    (symbol->string head))
              (total   (length arguments)))
         (unless delimited? (display " " port))
         (display "(" port)
         (display head port)
         (unless (zero? lead)
           (display " " port))

         ;; Print the first LEAD arguments.
         (let* ((indent (+ column 2
                                  (if delimited? 0 1)))
                (column (+ column 1
                                  (if (zero? lead) 0 1)
                                  (if delimited? 0 1)
                                  (string-length head)))
                (initial-indent column))
           (define new-column
             (let inner ((n lead)
                         (arguments (take arguments (min lead total)))
                         (column column))
               (if (zero? n)
                   (begin
                     (newline port)
                     (display (make-string indent #\space) port)
                     indent)
                   (match arguments
                     (() column)
                     ((head . tail)
                      (inner (- n 1) tail
                             (loop initial-indent column
                                   (= n lead)
                                   context
                                   head)))))))

           ;; Print the remaining arguments.
           (let ((column (print-sequence
                          context indent new-column
                          (drop arguments (min lead total))
                          #t)))
             (display ")" port)
             (+ column 1)))))
      ((head tail ...)
       (let* ((overflow? (>= column max-width))
              (column    (if overflow?
                             (+ indent 1)
                             (+ column (if delimited? 1 2))))
              (newline?  (or (newline-form? head context)
                             (list-of-lists? head tail))) ;'let' bindings
              (context   (cons head context)))
         (if overflow?
             (begin
               (newline port)
               (display (make-string indent #\space) port))
             (unless delimited? (display " " port)))
         (display "(" port)

         (let* ((new-column (loop column column #t context head))
                (indent (if (or (>= new-column max-width)
                                (not (symbol? head))
                                (sequence-would-protrude?
                                 (+ new-column 1) tail)
                                newline?)
                            column
                            (+ new-column 1))))
           (when newline?
             ;; Insert a newline right after HEAD.
             (newline port)
             (display (make-string indent #\space) port))

           (let ((column
                  (print-sequence context indent
                                  (if newline? indent new-column)
                                  tail newline?)))
             (display ")" port)
             (+ column 1)))))
      (_
       (let* ((str (if (string? obj)
                       (escaped-string obj)
                       (object->string obj)))
              (len (string-width str)))
         (if (and (> (+ column 1 len) max-width)
                  (not delimited?))
             (begin
               (newline port)
               (display (make-string indent #\space) port)
               (display str port)
               (+ indent len))
             (begin
               (unless delimited? (display " " port))
               (display str port)
               (+ column (if delimited? 0 1) len))))))))

(define (object->string* obj indent . args)
  "Pretty-print OBJ with INDENT columns as the initial indent.  ARGS are
passed as-is to 'pretty-print-with-comments'."
  (call-with-output-string
    (lambda (port)
      (apply pretty-print-with-comments port obj
             #:indent indent
             args))))