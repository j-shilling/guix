;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2016 Danny Milosavljevic <dannym@scratchpost.org>
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

(define-module (gnu packages fpga)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages tcl)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages python)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages zip)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages libftdi))

(define-public abc
 (let ((commit "5ae4b975c49c")
       (revision "1"))
  (package
    (name "abc")
    (version (string-append "0.0-" revision "-" (string-take commit 9)))
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://bitbucket.org/alanmi/abc/get/" commit ".zip"))
              (file-name (string-append name "-" version "-checkout.zip"))
              (sha256
                (base32
                   "1syygi1x40rdryih3galr4q8yg1w5bvdzl75hd27v1xq0l5bz3d0"))))
    (build-system gnu-build-system)
    (native-inputs
     `(("unzip" ,unzip)))
    (inputs
     `(("readline" ,readline)))
    (arguments
     `(#:tests? #f ; no check target
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (out-bin (string-append out "/bin")))
               (install-file "abc" out-bin)))))))
    (home-page "http://people.eecs.berkeley.edu/~alanmi/abc/")
    (synopsis "Sequential logic synthesis and formal verification")
    (description "ABC is a program for sequential logic synthesis and
formal verification.")
    (license
      (license:non-copyleft "https://fedoraproject.org/wiki/Licensing:MIT#Modern_Variants")))))

(define-public iverilog
  (package
    (name "iverilog")
    (version "10.1.1")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "ftp://ftp.icarus.com/pub/eda/verilog/v10/"
                              "verilog-" version ".tar.gz"))
              (sha256
                (base32
                   "1nnassxvq30rnn0r2p85rkb2zwxk97p109y13x3vr365wzgpbapx"))))
    (build-system gnu-build-system)
    (native-inputs
     `(("flex" ,flex)
       ("bison" ,bison)
       ("ghostscript" ,ghostscript))) ; ps2pdf
    (home-page "http://iverilog.icarus.com/")
    (synopsis "FPGA Verilog simulation and synthesis tool")
    (description "Icarus Verilog is a Verilog simulation and synthesis tool.
It operates as a compiler, compiling source code written in Verilog
(IEEE-1364) into some target format.
For batch simulation, the compiler can generate an intermediate form
called vvp assembly.
This intermediate form is executed by the ``vvp'' command.
For synthesis, the compiler generates netlists in the desired format.")
    ;; GPL2 only because of:
    ;; - ./driver/iverilog.man.in
    ;; - ./iverilog-vpi.man.in
    ;; - ./tgt-fpga/iverilog-fpga.man
    ;; - ./vvp/vvp.man.in
    ;; Otherwise would be GPL2+.
    ;; You have to accept both GPL2 and LGPL2.1+.
    (license (list license:gpl2 license:lgpl2.1+))))

(define-public yosys
  (package
    (name "yosys")
    (version "0.6")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://github.com/cliffordwolf/yosys/archive/"
                              name "-" version ".tar.gz"))
              (sha256
                (base32
                   "02j0c0m9dfyjccynalf0aggj6gy20k7iphpkg5cn6sdirlkv8gmx"))
              (file-name (string-append name "-" version "-checkout.tar.gz"))
              (modules '((guix build utils)))
              (snippet
                '(substitute* "Makefile"
                   (("ABCREV = .*") "ABCREV = default\n")))))
    (build-system gnu-build-system)
    (arguments
     `(#:test-target "test"
       #:make-flags (list "CC=gcc"
                          "CXX=g++"
                          (string-append "PREFIX=" %output))
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda* (#:key inputs (make-flags '()) #:allow-other-keys)
             (zero? (apply system* "make" "config-gcc" make-flags))))
         (add-after 'configure 'prepare-abc
           (lambda* (#:key inputs #:allow-other-keys)
             (let* ((sourceabc (assoc-ref inputs "abc"))
                    (sourcebin (string-append sourceabc "/bin"))
                    (source (string-append sourcebin "/abc")))
                   (mkdir-p "abc")
                   (call-with-output-file "abc/Makefile"
                     (lambda (port)
                       (format port ".PHONY: all\nall:\n\tcp -f abc abc-default\n")))
                   (copy-file source "abc/abc")
                   (zero? (system* "chmod" "+w" "abc/abc")))))
          (add-before 'check 'fix-iverilog-references
             (lambda* (#:key inputs native-inputs #:allow-other-keys)
               (let* ((xinputs (or native-inputs inputs))
                      (xdirname (assoc-ref xinputs "iverilog"))
                      (iverilog (string-append xdirname "/bin/iverilog")))
                     (substitute* '("./manual/CHAPTER_StateOfTheArt/synth.sh"
                                    "./manual/CHAPTER_StateOfTheArt/validate_tb.sh"
                                    "./techlibs/ice40/tests/test_bram.sh"
                                    "./techlibs/ice40/tests/test_ffs.sh"
                                    "./techlibs/xilinx/tests/bram1.sh"
                                    "./techlibs/xilinx/tests/bram2.sh"
                                    "./tests/bram/run-single.sh"
                                    "./tests/realmath/run-test.sh"
                                    "./tests/simple/run-test.sh"
                                    "./tests/techmap/mem_simple_4x1_runtest.sh"
                                    "./tests/tools/autotest.sh"
                                    "./tests/vloghtb/common.sh")
                        (("if ! which iverilog") "if ! true")
                        (("iverilog ") (string-append iverilog " "))
                        (("iverilog_bin=\".*\"") (string-append "iverilog_bin=\""
                                                                iverilog "\"")))
                     #t))))))
    ;; TODO add xdot [patch the path to it here] as soon as I find out where it is.
    (native-inputs
     `(("pkg-config" ,pkg-config)
       ("python" ,python)
       ("bison" ,bison)
       ("flex" ,flex)
       ("gawk" , gawk) ; for the tests and "make" progress pretty-printing
       ("tcl" ,tcl) ; tclsh for the tests
       ("iverilog" ,iverilog))) ; for the tests
    (inputs
     `(("tcl" ,tcl)
       ("readline" ,readline)
       ("libffi" ,libffi)
       ("abc" ,abc)))
    (home-page "http://www.clifford.at/yosys/")
    (synopsis "FPGA Verilog RTL synthesizer")
    (description "Yosys synthesizes Verilog-2005.")
    (license license:isc)))
