;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2021 Raghav Gururajan <rg@raghavgururajan.name>
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

(define-module (gnu packages telegram)
  #:use-module (gnu packages)
  #:use-module (gnu packages aidc)
  #:use-module (gnu packages animation)
  #:use-module (gnu packages assembly)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages check)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages digest)
  #:use-module (gnu packages fcitx)
  #:use-module (gnu packages fcitx5)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages jemalloc)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages language)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libreoffice)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages lxqt)
  #:use-module (gnu packages lua)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-check)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages telephony)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages video)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xiph)
  #:use-module (gnu packages xorg)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system python)
  #:use-module (guix build-system qt))

(define %telegram-version "2.9.3")

(define libvpx-for-telegram-desktop
  (let ((commit "5b63f0f821e94f8072eb483014cfc33b05978bb9")
        (revision "112"))
    (origin
      (method git-fetch)
      (uri (git-reference
            (url "https://chromium.googlesource.com/webm/libvpx")
            (commit commit)))
      (file-name (git-file-name
                  "libvpx-for-telegram-desktop"
                  (git-version "1.9.0" revision commit)))
      (sha256
       (base32
        "1psvxaddihlw1k5n0anxif3qli6zyw2sa2ywn6mkb8six9myrp68")))))

(define libyuv-for-telegram-desktop
  (let ((commit "ad890067f661dc747a975bc55ba3767fe30d4452")
        (revision "2211"))
    (origin
      (method git-fetch)
      (uri (git-reference
            (url "https://chromium.googlesource.com/libyuv/libyuv")
            (commit commit)))
      (file-name (git-file-name
                  "libyuv-for-telegram-desktop"
                  (git-version "0" revision commit)))
      (sha256
       (base32
        "01knnk4h247rq536097n9n3s3brxlbby3nv3ppdgsqfda3k159ll")))))

(define cmake-helpers-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/cmake_helpers.git")
          (commit "4d44d822e01b3b5fbec3ce824e01f56aa35d7f72")))
    (file-name
     (git-file-name "cmake-helpers-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "0h6cjiqy014h2mz90h1z5a7plb3ihbnds4bja8994ybr1dy3m7m5"))))

(define codegen-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/codegen.git")
          (commit "248614b49cd7d5aff69d75a737f2e35b79fbb119")))
    (file-name
     (git-file-name "codegen-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "00f7g2z6xmkbkrmi3q27hscjl44mg66wf9q0mz3rhy3jaa6cfdrk"))))

(define lib-base-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_base.git")
          (commit "a23c05c44e4f01dc4428f4d75d4db98c59d313a6")))
    (file-name
     (git-file-name "lib-base-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "0vh5zgxwalmbnvz8lzlnba87ch8vnpmcz6nvf56w09f3nlxvvq78"))))

(define lib-crl-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_crl.git")
          (commit "3ccf2ed5095442e5874bba8852cb7dc4efeae29f")))
    (file-name
     (git-file-name "lib-crl-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "11my7q54m4lvvlgma6pbdyjxi1cv1adk1gph2j50mh18sqlm8myz"))))

(define lib-lottie-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_lottie.git")
          (commit "0770df009db7928df1d0cad0900dc5110106d229")))
    (file-name
     (git-file-name "lib-lottie-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "1gj56ymlbk5dnk82jw674808m511lv9dky8891a5wm4gp3pph5jb"))))

(define lib-qr-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_qr.git")
          (commit "2b08c71c6edcfc3e31f7d7f518cc963493b6e189")))
    (file-name
     (git-file-name "lib-qr-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "05hrkmwgrczyjv87r507i2r7m1zr6k2i43mq3my0s6j4szr1rjq0"))))

(define lib-rlottie-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_rlottie.git")
          (commit "0671bf70547381effcf442ec9618e04502a8adbc")))
    (file-name
     (git-file-name "lib-rlottie-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "05qnza7j15356s8jq16pkbyp4zr586lssmd86lz5jq23lcb3raxv"))))

(define lib-rpl-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_rpl.git")
          (commit "df721be3fa14a27dfc230d2e3c42bb1a7c9d0617")))
    (file-name
     (git-file-name "lib-rpl-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "15fnv3ssn7rn5d0j52gggdvyqc2wm464678dj7v2x9h8lka2jjxn"))))

(define lib-spellcheck-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_spellcheck.git")
          (commit "68c9b788958904aea7de79f986a0f82ec8c5b094")))
    (file-name
     (git-file-name "lib-spellcheck-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "0d8s4wwk6fxf536mhzq2vb9qw3j0m8nqia7ylvvpsbc4kh09dadn"))))

(define lib-storage-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_storage.git")
          (commit "403df6c4a29562bd417c92d410e49819f5a48cc1")))
    (file-name
     (git-file-name "lib-storage-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "1zxvzfrxbj4d395fzyb5pm9wn3n8jyimxx88cyqjcdd46sx4h7r5"))))

(define lib-tl-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_tl.git")
          (commit "45faed44e7f4d11fec79b7a70e4a35dc91ef3fdb")))
    (file-name
     (git-file-name "lib-tl-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "0h43xvzklda02494d466jp52hl8c1kmav9f12dyld10dpf1w6c7m"))))

(define lib-ui-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_ui.git")
          (commit "1b590f9e16eb9571a039f072d6fea66c607e419f")))
    (file-name
     (git-file-name "lib-ui-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "0ighyhfp29h9h8c7vr70pnhcv2xnsr9ln084pssn8hb5z4pmb62f"))))

(define lib-waylandshells-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_waylandshells.git")
          (commit "59b0ee55a68976d27f1bf7cec0e11d5939e185e7")))
    (file-name
     (git-file-name "lib-waylandshells-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "0l2xrpc5mvvdlsj333pmkgfvn9wi1ijfdaaz8skfnw9icw52faaf"))))

(define lib-webrtc-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_webrtc.git")
          (commit "ef49f953f12b112008a094a719f40939aaf39db4")))
    (file-name
     (git-file-name "lib-webrtc-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "15k4xs3462p3ddp5cn9im3nvdiaijmxir8wxsf5yrj70ghy26ibw"))))

(define lib-webview-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/desktop-app/lib_webview.git")
          (commit "e06427c624515485774e2e2181d4afeb05ad5a67")))
    (file-name
     (git-file-name "lib-webview-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "148z7xzfscynwwwqssdsd97npax6yn8zrd64xw8qzbwff2g2r7k4"))))

(define tgcalls-for-telegram-desktop
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/TelegramMessenger/tgcalls.git")
          (commit "81e97fa52e25b7775b62ce07bb653533d81e91b3")))
    (file-name
     (git-file-name "tgcalls-for-telegram-desktop" %telegram-version))
    (sha256
     (base32
      "0fvad87hyxli83xn19mgf8jjrrh6y6iaig14pckpbkg33vf4wqkj"))))

(define-public webrtc-for-telegram-desktop
  (let ((commit "621f3da55331733bf0d1b223786b96b68c03dca1")
        (revision "327"))
    (hidden-package
     (package
       (name "webrtc-for-telegram-desktop")
       (version
        (git-version "0" revision commit))
       (source
        (origin
          (method git-fetch)
          (uri
           (git-reference
            (url "https://github.com/desktop-app/tg_owt.git")
            (commit commit)))
          (file-name
           (git-file-name name version))
          (sha256
           (base32 "1ks1572k1jj7pmzwm79p2gdgi31dd4bs761bphnx32zyq4c6skxk"))
          (patches
           (search-patches
            ;; https://github.com/desktop-app/tg_owt/pull/101
            "webrtc-for-telegram-desktop-fix-gcc12-cstdint.patch"))
          (modules '((guix build utils)
                     (ice-9 ftw)
                     (srfi srfi-1)))
          (snippet
           #~(begin
               (let ((keep
                      '("abseil-cpp" "libsrtp" "rnnoise"
                        ;; Not available in Guix.
                        "pffft")))
                 (with-directory-excursion "src/third_party"
                   (for-each delete-file-recursively
                             (lset-difference string=?
                                              (scandir ".")
                                              (cons* "." ".." keep)))))
               ;; Unbundle openh264.
               (substitute* "CMakeLists.txt"
                 (("\\include\\(cmake\\/libopenh264\\.cmake\\)")""))))))
       (build-system cmake-build-system)
       (arguments
        (list
         #:tests? #f                    ; No target
         #:phases
         #~(modify-phases %standard-phases
             (add-after 'unpack 'unpack-additional-sources
               (lambda _
                 (let* ((third-party (string-append (getcwd) "/src/third_party"))
                        (crc32c-to (string-append third-party "/crc32c/src"))
                        (libyuv-to (string-append third-party "/libyuv")))
                   (copy-recursively #$(package-source crc32c) crc32c-to)
                   (copy-recursively #$libyuv-for-telegram-desktop
                                     libyuv-to)))))))
       (native-inputs (list pkg-config python-wrapper yasm))
       (inputs
        (list abseil-cpp-cxxstd17
              ffmpeg
              glib
              libdrm
              libglvnd
              libjpeg-turbo
              libvpx
              libxcomposite
              libxdamage
              libxext
              libxfixes
              libxrandr
              libxrender
              libxtst
              mesa
              openh264
              openssl
              opus
              pipewire-0.3
              protobuf))
       (synopsis "WebRTC support for Telegram Desktop")
       (description "WebRTC-for-Telegram-Desktop is a custom WebRTC fork by
Telegram project, for its use in telegram desktop client.")
       (home-page "https://github.com/desktop-app/tg_owt")
       (license
        (list
         ;; Abseil-CPP
         license:asl2.0
         ;; LibYuv
         (license:non-copyleft "file:///src/third_party/libyuv/LICENSE")
         ;; PFFFT
         (license:non-copyleft "file:///src/third_party/pffft/LICENSE")
         ;; RnNoise
         license:gpl3
         ;; LibSRTP, Crc32c and Others
         license:bsd-3))))))

(define-public rlottie-for-telegram-desktop
  (let ((commit "cbd43984ebdf783e94c8303c41385bf82aa36d5b")
        (revision "671"))
    (hidden-package
     (package
       (inherit rlottie)
       (version
        (git-version "0.0.1" revision commit))
       (source
        (origin
          (method git-fetch)
          (uri
           (git-reference
            (url "https://github.com/desktop-app/rlottie.git")
            (commit commit)))
          (file-name
           (git-file-name "rlottie-for-telegram-desktop" version))
          (sha256
           (base32 "1lxpbgbhps9rmck036mgmiknqrzpjxpas8n7qxykv6pwzn0c8n0c"))))
       (arguments
        `(#:configure-flags
          (list
           "-Dlog=true"
           "-Ddumptree=true"
           "-Dtest=true")
          #:phases
          (modify-phases %standard-phases
            (add-after 'unpack 'patch-cxx-flags
              (lambda _
                (substitute* "meson.build"
                  (("werror=true")
                   "werror=false"))
                #t)))))))))

(define-public libtgvoip-for-telegram-desktop
  (let ((commit "13a5fcb16b04472d808ce122abd695dbf5d206cd")
        (revision "88"))
    (hidden-package
     (package
       (inherit libtgvoip)
       (version
        (git-version "2.4.4" revision commit))
       (source
        (origin
          (method git-fetch)
          (uri
           (git-reference
            (url "https://github.com/telegramdesktop/libtgvoip.git")
            (commit commit)))
          (file-name
           (git-file-name "libtgvoip-for-telegram-desktop" version))
          (sha256
           (base32 "12p6s7vxkf1gh1spdckkdxrx7bjzw881ds9bky7l5fw751cwb3xd"))))
       (arguments
        `(#:configure-flags
          (list
           "--disable-static"
           "--disable-dsp"              ; FIXME
           "--enable-audio-callback"
           "--with-alsa"
           "--with-pulse")
          #:phases
          (modify-phases %standard-phases
            (add-after 'unpack 'patch-linkers
              (lambda _
                (substitute* "Makefile.am"
                  (("\\$\\(CRYPTO_LIBS\\) \\$\\(OPUS_LIBS\\)")
                   "$(CRYPTO_LIBS) $(OPUS_LIBS) $(ALSA_LIBS) $(PULSE_LIBS)"))
                (substitute* "tgvoip.pc.in"
                  (("libcrypto opus")
                   "libcrypto opus alsa libpulse"))
                #t)))))
       (native-inputs
        (list autoconf automake libtool pkg-config))))))

(define-public telegram-desktop
  (package
    (name "telegram-desktop")
    (version %telegram-version)
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/telegramdesktop/tdesktop.git")
         (commit
          (string-append "v" version))))
       (file-name
        (git-file-name name version))
       (sha256
        (base32 "0dzf1y3xhqvizg29bd1kya48cjbkq073d2x10ynwcmmx396l4nd8"))
       (modules '((guix build utils)
                  (ice-9 ftw)
                  (srfi srfi-1)))
       (snippet
        #~(begin
            (let ((keep
                   '( ;; Not available in Guix.
                     "SPMediaKeyTap" "statusnotifieritem" "tgcalls")))
              (with-directory-excursion "Telegram/ThirdParty"
                (for-each delete-file-recursively
                          (lset-difference string=?
                                           (scandir ".")
                                           (cons* "." ".." keep)))))))))
    (build-system qt-build-system)
    (arguments
     (list #:tests? #f                      ; No target
           #:imported-modules
           `(,@%qt-build-system-modules
             (guix build glib-or-gtk-build-system))
           #:modules
           '((guix build qt-build-system)
             ((guix build glib-or-gtk-build-system)
              #:prefix glib-or-gtk:)
             (guix build utils)
             (ice-9 match))
           #:configure-flags
           #~(list
              ;; Client applications must provide their own API-ID and API-HASH,
              ;; see also <https://core.telegram.org/api/obtaining_api_id>.
              ;; Here, we snarf the keys from the official Snaps, which are
              ;; also stored in <#$source/snap/snapcraft.yaml>.
              "-DTDESKTOP_API_ID=611335"
              "-DTDESKTOP_API_HASH=d524b414d21f4d37f08684c1df41ac9c"
              ;; Disable WebkitGTK support as it fails to link
              "-DDESKTOP_APP_DISABLE_WEBKITGTK=ON"
              ;; Use bundled fonts as fallback.
              "-DDESKTOP_APP_USE_PACKAGED_FONTS=OFF")
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'make-writable
                 (lambda _
                   (for-each make-file-writable (find-files "."))))
               (add-after 'make-writable 'copy-inputs
                 (lambda _
                   (for-each
                    (match-lambda
                      ((dst src)
                       (copy-recursively src dst)
                       (for-each make-file-writable (find-files dst))))
                    '(("cmake" #$cmake-helpers-for-telegram-desktop)
                      ("Telegram/codegen" #$codegen-for-telegram-desktop)
                      ("Telegram/lib_base" #$lib-base-for-telegram-desktop)
                      ("Telegram/lib_crl" #$lib-crl-for-telegram-desktop)
                      ("Telegram/lib_lottie" #$lib-lottie-for-telegram-desktop)
                      ("Telegram/lib_qr" #$lib-qr-for-telegram-desktop)
                      ("Telegram/lib_rlottie" #$lib-rlottie-for-telegram-desktop)
                      ("Telegram/lib_rpl" #$lib-rpl-for-telegram-desktop)
                      ("Telegram/lib_spellcheck" #$lib-spellcheck-for-telegram-desktop)
                      ("Telegram/lib_storage" #$lib-storage-for-telegram-desktop)
                      ("Telegram/lib_tl" #$lib-tl-for-telegram-desktop)
                      ("Telegram/lib_ui" #$lib-ui-for-telegram-desktop)
                      ("Telegram/lib_waylandshells" #$lib-waylandshells-for-telegram-desktop)
                      ("Telegram/lib_webrtc" #$lib-webrtc-for-telegram-desktop)
                      ("Telegram/lib_webview" #$lib-webview-for-telegram-desktop)
                      ("Telegram/ThirdParty/tgcalls" #$tgcalls-for-telegram-desktop)))))
               (add-before 'configure 'patch-cxx-flags
                 (lambda _
                   (substitute* "cmake/options_linux.cmake" (("class-memaccess") "all"))))
               (add-after 'install 'glib-or-gtk-compile-schemas
                 (assoc-ref glib-or-gtk:%standard-phases 'glib-or-gtk-compile-schemas))
               (add-after 'glib-or-gtk-compile-schemas 'glib-or-gtk-wrap
                 (assoc-ref glib-or-gtk:%standard-phases 'glib-or-gtk-wrap)))))
    (native-inputs
     (list cmake-shared
           extra-cmake-modules
           `(,glib "bin")
           `(,gtk+ "bin")
           pkg-config
           python-wrapper
           qttools-5))
    (inputs
     (list alsa-lib
           c++-gsl
           catch2
           libexpected
           fcitx-qt5
           fcitx5-qt
           ffmpeg
           glib
           glibmm-2.64
           gtk+
           hime
           hunspell
           jemalloc
           kwayland
           libdbusmenu-qt
           libjpeg-turbo
           libtgvoip-for-telegram-desktop
           lz4
           materialdecoration
           minizip
           nimf
           openal
           openssl
           opus
           pulseaudio
           qrcodegen-cpp
           qtbase-5
           qtsvg-5
           qt5ct
           qtimageformats
           qtwayland
           range-v3
           rlottie-for-telegram-desktop
           rnnoise
           webrtc-for-telegram-desktop
           libx11
           libxcb
           xcb-util-keysyms
           xxhash
           zlib))
    (propagated-inputs (list dconf))
    (synopsis "Telegram Desktop")
    (description "Telegram desktop is the official desktop version of the
Telegram instant messenger.")
    (home-page "https://desktop.telegram.org/")
    (license
     (list
      ;; ThirdParty
      license:lgpl2.1+
      ;; Others
      license:gpl3+))))

(define-public tl-parser
  (let ((commit "1933e76f8f4fb74311be723b432e4c56e3a5ec06")
        (revision "21"))
    (package
      (name "tl-parser")
      (version
       (git-version "0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri
          (git-reference
           (url "https://github.com/vysheng/tl-parser.git")
           (commit commit)))
         (file-name
          (git-file-name name version))
         (sha256
          (base32 "13cwi247kajzpkbl86hnwmn1sn2h6rqndz6khajbqj0mlw9mv4hq"))))
      (build-system cmake-build-system)
      (arguments
       `(#:tests? #f                    ; No target
         #:imported-modules
         ((guix build copy-build-system)
          ,@%cmake-build-system-modules)
         #:modules
         (((guix build copy-build-system)
           #:prefix copy:)
          (guix build cmake-build-system)
          (guix build utils))
         #:phases
         (modify-phases %standard-phases
           (replace 'install
             (lambda args
               (apply (assoc-ref copy:%standard-phases 'install)
                      #:install-plan
                      '(("." "bin"
                         #:include ("tl-parser"))
                        ("../source" "include/tl-parser"
                         #:include-regexp ("\\.h$")))
                      args))))))
      (synopsis "Parse tl scheme to tlo")
      (description "TL-Parser is a tl scheme to tlo file parser.  It was
formerly a part of telegram-cli, but now being maintained separately.")
      (home-page "https://github.com/vysheng/tl-parser")
      (license license:gpl2+))))

(define-public tgl
  (let ((commit "ffb04caca71de0cddf28cd33a4575922900a59ed")
        (revision "181"))
    (package
      (name "tgl")
      (version
       (git-version "2.0.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri
          (git-reference
           (url "https://github.com/vysheng/tgl.git")
           (commit commit)))
         (file-name
          (git-file-name name version))
         (sha256
          (base32 "0cf5s7ygslb5klg1qv9qdc3hivhspmvh3zkacyyhd2yyikb5p0f9"))))
      (build-system gnu-build-system)
      (arguments
       `(#:tests? #f                    ; No target
         #:imported-modules
         ((guix build copy-build-system)
          ,@%gnu-build-system-modules)
         #:modules
         (((guix build copy-build-system)
           #:prefix copy:)
          (guix build gnu-build-system)
          (guix build utils))
         #:configure-flags
         (list
          ;; Use gcrypt instead of openssl.
          "--disable-openssl"
          ;; Enable extended queries system.
          "--enable-extf"
          ;; Include libevent-based net and timers.
          "--enable-libevent")
         #:phases
         (modify-phases %standard-phases
           (add-after 'unpack 'trigger-bootstrap
             (lambda _
               (delete-file "configure")
               #t))
           (add-after 'trigger-bootstrap 'patch-tl-parser
             (lambda _
               (delete-file "Makefile.tl-parser")
               (substitute* "Makefile.in"
                 (("include \\$\\{srcdir\\}/Makefile\\.tl-parser")
                  "")
                 (("\\$\\{EXE\\}/tl-parser")
                  "tl-parser"))
               #t))
           (replace 'install
             (lambda args
               (apply (assoc-ref copy:%standard-phases 'install)
                      #:install-plan
                      '(("bin" "bin")
                        ("." "include/tgl"
                         #:include-regexp ("\\.h$"))
                        ("libs" "lib/tgl"))
                      args))))))
      (native-inputs
       (list autoconf automake libtool pkg-config))
      (inputs
       (list libevent libgcrypt tl-parser zlib))
      (synopsis "Telegram Library")
      (description "TGL is the telegram library for telegram-cli.")
      (home-page "https://github.com/vysheng/tgl")
      (license license:lgpl2.1+))))

(define-public telegram-cli
  (let ((commit "6547c0b21b977b327b3c5e8142963f4bc246187a")
        (revision "324"))
    (package
      (name "telegram-cli")
      (version
       (git-version "1.3.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri
          (git-reference
           (url "https://github.com/vysheng/tg.git")
           (commit commit)))
         (file-name
          (git-file-name name version))
         (sha256
          (base32 "0c1w7jgska71jjbvg1y09v52549pwa4zkdjly18yxywn7gayd2p6"))))
      (build-system gnu-build-system)
      (arguments
       `(#:tests? #f                    ; No target
         #:imported-modules
         ((guix build copy-build-system)
          ,@%gnu-build-system-modules)
         #:modules
         (((guix build copy-build-system)
           #:prefix copy:)
          (guix build gnu-build-system)
          (guix build utils))
         #:configure-flags
         (list
          ;; Use gcrypt instead of openssl.
          "--disable-openssl")
         #:phases
         (modify-phases %standard-phases
           (add-after 'unpack 'trigger-bootstrap
             (lambda _
               (delete-file "configure")
               #t))
           (add-after 'trigger-bootstrap 'patch-tgl-and-tlparser
             (lambda* (#:key inputs #:allow-other-keys)
               (for-each delete-file
                         (list
                          "Makefile.tgl"
                          "Makefile.tl-parser"))
               (substitute* "Makefile.in"
                 (("include \\$\\{srcdir\\}/Makefile\\.tl-parser")
                  "")
                 (("include \\$\\{srcdir\\}/Makefile\\.tgl")
                  "")
                 (("-I\\$\\{srcdir\\}/tgl")
                  (string-append "-I" (assoc-ref inputs "tgl")
                                 "/include/tgl"))
                 (("AUTO=auto")
                  (string-append "AUTO=" (assoc-ref inputs "tgl")
                                 "/include/tgl/auto"))
                 (("LIB=libs")
                  (string-append "LIB=" (assoc-ref inputs "tgl")
                                 "/lib/tgl")))
               #t))
           (replace 'install
             (lambda args
               (apply (assoc-ref copy:%standard-phases 'install)
                      #:install-plan
                      '(("bin" "bin")
                        ("." "etc/telegram-cli"
                         #:include-regexp ("\\.pub$")
                         #:exclude ("tg-server.pub")))
                      args))))))
      (native-inputs
       (list autoconf automake libtool pkg-config))
      (inputs
       (list jansson
             libconfig
             libevent
             libgcrypt
             lua
             openssl
             perl
             python
             readline
             tgl
             tl-parser
             zlib))
      (synopsis "Telegram Messenger CLI")
      (description "TG is the command-line interface for Telegram Messenger.")
      (home-page "https://github.com/vysheng/tg")
      (license license:gpl2+))))

(define-public tgcli
  (package
    (name "tgcli")
    (version "0.3.1")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/erayerdin/tgcli")
         (commit (string-append "v" version))))
       (file-name
        (git-file-name name version))
       (sha256
        (base32 "082zim7rh4r8qyscqimjh2sz7998vv9j1i2y2wwz2rgrlhkhly5r"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         ;; Test requirements referes to specific versions of packages,
         ;; which are too old. So we patch them to refer to any later versions.
         (add-after 'unpack 'patch-test-requirements
           (lambda _
             (substitute* "dev.requirements.txt"
               (("==") ">="))))
         (replace 'check
           (lambda* (#:key inputs outputs tests? #:allow-other-keys)
             (when tests?
               (add-installed-pythonpath inputs outputs)
               (invoke "pytest" "tests")))))))
    (native-inputs
     `(("coveralls" ,python-coveralls)
       ("pytest" ,python-pytest)
       ("pytest-click" ,python-pytest-click)
       ("pytest-cov" ,python-pytest-cov)
       ("mkdocs" ,python-mkdocs)
       ("mkdocs-material" ,python-mkdocs-material)
       ("requests-mock" ,python-requests-mock)))
    (propagated-inputs
     `(("click" ,python-click)
       ("colorful" ,python-colorful)
       ("requests" ,python-requests)
       ("yaspin" ,python-yaspin)))
    (home-page "https://tgcli.readthedocs.io")
    (synopsis "Telegram Terminal Application")
    (description "TgCli is a telegram client to automate repetitive tasks.")
    (license license:asl2.0)))
