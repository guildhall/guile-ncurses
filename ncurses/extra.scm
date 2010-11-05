;; -*- Mode: scheme; -*-

;; extra.scm

;; Copyright 2010 Free Software Foundation, Inc.

;; This file is part of GNU Guile-Ncurses.

;; Guile-Ncurses is free software: you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public License
;; as published by the Free Software Foundation, either version 3 of
;; the License, or (at your option) any later version.

;; Guile-Ncurses is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; Lesser General Public License for more details.

;; You should have received a copy of the GNU Lesser General Public
;; License along with Guile-Ncurses.  If not, see
;; <http://www.gnu.org/licenses/>.

(define-module (ncurses extra)
  #:use-module (ncurses curses)
  #:use-module (srfi srfi-1)
  #:export (
            BS0
            BS1
            BSDLY
            CR0
            CR1
            CR2
            CR3
            CRDLY
            FF0
            FF1
            FFDLY
            IUCLC
            NL0
            NL1
            NLDLY
            OCRNL
            OFDEL
            OFILL
            OLCUC
            ONLCR
            ONLRET
            ONOCR
            OPOST
            TAB1
            TAB2
            TAB3
            TABDLY
            TCIFLUSH
            TCIOFF
            TCIOFLUSH
            TCION
            TCOFLUSH
            TCOOFF
            TCOON
            TCSADRAIN
            TCSAFLUSH
            TCSANOW
            VT0
            VT1
            VTDLY
            XCASE

            NCCS

            VDISCARD
            VEOF
            VEOL
            VEOL2
            VERASE
            VINTR
            VKILL
            VLNEXT
            VMIN
            VQUIT
            VREPRINT
            VSTART
            VSTOP
            VSUSP
            VSWTC
            VWERASE

            BRKINT
            ICRNL
            IGNBRK
            IGNCR
            IGNPAR
            IMAXBEL
            INLCR
            INPCK
            ISTRIP
            IXANY
            IXOFF
            IXON
            PARMRK

            CLOCAL
            CREAD
            CS5
            CS6
            CS7
            CS8
            CSIZE
            CSTOPB
            HUPCL
            PARENB
            PARODD
            VTIME

            ECHO
            ECHOCTL
            ECHOE
            ECHOK
            ECHOKE
            ECHONL
            ECHOPRT
            FLUSHO
            ICANON
            IEXTEN
            ISIG
            NOFLSH
            PENDIN
            TOSTOP

            B0
            B110
            B1200
            B134
            B150
            B1800
            B19200
            B200
            B2400
            B300
            B38400
            B4800
            B50
            B600
            B75
            B9600

            termios?
            new-termios
	    sigprocmask
            cfgetispeed
            cfgetospeed
            cfmakeraw!
            cfsetispeed!
            cfsetspeed!
            cfsetospeed!
            sigprocmask
            tcdrain
            tcflow
            tcflush
            tcgetattr
            tcgetsid
            tcsendbreak
            tcsetattr!

            termios-iflag
            termios-oflag
            termios-cflag
            termios-lflag
            termios-line
            termios-cc
            termios-iflag-set!
            termios-oflag-set!
            termios-cflag-set!
            termios-lflag-set!
            termios-cc-set!

            wcwidth
            %termios-debug
            ))

;; Return the number of character cells that C takes
(define (wcwidth x)
  (cond
   ((char? x)
    (%strwidth (string x)))
   ((and (integer? x) (logtest x A_ALTCHARSET))
    1)
   ((xchar? x)
    (%strwidth (xchar-chars x)))
   ((string? x)
    (%strwidth x))
   ((and (list? x) (every xchar? x))
    (%strwidth (apply string (apply append (map xchar-chars x)))))
   (else
    (error (gettext "Invalid input ~s") x))))

(define (%termios-debug t)
  (let ((cflag (termios-cflag t))
        (iflag (termios-iflag t))
        (oflag (termios-oflag t))
        (lflag (termios-lflag t)))
    (format #t "c_iflag = ~a~%" iflag)
    (format #t "c_oflag = ~a~%" oflag)
    (format #t "c_cflag = ~a~%" cflag)
    (format #t "l_cflag = ~a~%" cflag)
    (format #t "c_ispeed = ~a~%" (cfgetispeed t))
    (format #t "c_ospeed = ~a~%" (cfgetospeed t))
    (display "Input Modes:\n")
    (if (logtest cflag IGNBRK)
        (display "IGNBRK: Break on input ignored\n"))
    (if (and (not (logtest cflag IGNBRK))
             (logtest cflag BRKINT))
        (if (= (getpgrp) (tcgetpgrp t))
            (display "BRKINT: Flush input/output queues and generate SIGINT\n")
            (display "BRKINT: Flush input/output queuest\n")))
    (if (and (not (logtest cflag IGNBRK))
             (not (logtest cflag BRKINT)))
        (if (logtest cflag PARMRK)
            (display "PARMRK: Break is read as 0xff 0x00 0x00\n")
            (display "------: Break is read as 0x00\n")))
    (if (logtest cflag IGNPAR)
        (display "IGNPAR: A byte with a parity error shall be ignored\n"))
    (if (and (logtest cflag PARMRK)
             (not (logtest cflag IGNPAR)))
        (begin
          (display "PARMRK: Prefix bytes with parity errors with 0xff 0x00\n")
          (if (logtest cflag ISTRIP)
              (display "ISTRIP: Don't prefix 0xff bytes with 0xff\n")
              (display "PARMRK: Prefix 0xff bytes with 0xff\n"))))
    (if (and (not (logtest cflag PARMRK))
             (not (logtest cflag IGNPAR)))
        (display "------: Bytes with parity errors become 0x00\n"))
    (if (logtest cflag INPCK)
        (display "INPCK: Input parity checking is enabled\n")
        (display "------: Input parity checking is disabled\n"))
    (if (logtest cflag ISTRIP)
        (display "ISTRIP: Valid input bytes are stripped to 7-bits\n")
        (display "------: All 8-bits of valid input bytes are processed\n"))
    (if (logtest cflag INLCR)
        (display "INLCR: Newline bytes translated to Carriage Return bytes\n"))
    (if (logtest cflag IGNCR)
        (display "IGNCR: Carriage Return bytes are ignored\n"))
    (if (and (not (logtest cflag IGNCR))
             (logtest cflag ICRNL))
        (display "ICRNL: Carriage Return bytes translated to Newline bytes\n"))
    (if (logtest cflag IXANY)
        (display "IXANY: Any input character restarts suspended output\n"))
    (if (logtest cflag IXON)
        (display "IXON: Start/stop output control enabled\n")
        (display "------: Start/stop output control disabled\n"))
    (if (logtest cflag IXOFF)
        (display "IXOFF: Start/stop input control enabled\n")
        (display "------: Start/stop input control disabled\n"))

    (display "Output Modes:\n")
    (if (not (logtest oflag OPOST))
        (display "------: Output data shall be transmitted unchanged\n")
        (begin
          (display "OPOST: output data shall be post-processed\n")
          (if (logtest oflag ONLCR)
              (display "ONLCR: Newline is transmitted as CR/NL\n"))
          (if (logtest oflag OCRNL)
              (display "OCRNL: Carrige Return is trasmitted as Newline\n"))
          (if (logtest oflag ONOCR)
              (display "ONOCR: No Carriage Return trasmitted when in column 0\n"))
          (if (logtest oflag ONLRET)
              (display "ONLRET: Newline also does Carriage Return\n"))
          (if (not (logior oflag (logand ONLCR OCRNL ONOCR ONLRET)))
              (begin
                (display "------: Newline does line-feed but does not Carriage Return.\n")
                (display "------: Carriage Return returns to column 0 but does not line feed\n")))))
    ))


(load-extension "libguile-ncurses" "gucu_extra_init")
