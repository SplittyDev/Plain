section .rodata

;
; Keyboard responses
;
; Terminology:
; ACK = Acknowledge
; ST = Self test
;

%define KBD_RES_ACK         0xFA
%define KBD_RES_ECHO        0xEE
%define KBD_RES_RESEND      0xFE
%define KBD_RES_ERROR_A     0x00
%define KBD_RES_ERROR_B     0xFF
%define KBD_RES_ST_PASS     0xAA
%define KBD_RES_ST_FAIL_A   0xFC
%define KBD_RES_ST_FAIL_B   0xFD

;
; Keyboard command constants
;
; Terminology:
; TM = Typematic
; AR = Autorepeat
; MK = Make
; RE = Release
;

%define KBD_COM_LED                 0xED
%define KBD_COM_ECHO                0xEE
%define KBD_COM_SCANCODE            0xF0
%define KBD_COM_IDENTIFY            0xF2
%define KBD_COM_TYPEMATIC           0xF3
%define KBD_COM_SCAN_ON             0xF4
%define KBD_COM_SCAN_OFF            0xF5
%define KBD_COM_SET_DEFAULT         0xF6
%define KBD_COM_TM_AR_ALL           0xF7
%define KBD_COM_MK_RE_ALL           0xF8
%define KBD_COM_MK_ALL              0xF9
%define KBD_COM_TM_AR_MK_RE_ALL     0xFA
%define KBD_COM_TM_AR_SINGLE        0xFB
%define KBD_COM_MK_RE_SINGLE        0xFC
%define KBD_COM_MK_SINGLE           0xFD
%define KBD_COM_RESEND              0xFE
%define KBD_COM_SELF_TEST           0xFF