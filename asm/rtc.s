section .rodata

; RTC registers
%define RTC_REG_A           0x0A
%define RTC_REG_B           0x0B
%define RTC_REG_C           0x0C
%idefine RTC_REG_SECOND      0x00
%idefine RTC_REG_MINUTE      0x02
%idefine RTC_REG_HOUR        0x04
%idefine RTC_REG_DAYOFWEEK   0x06
%idefine RTC_REG_DAYOFMONTH  0x07
%idefine RTC_REG_MONTH       0x08
%idefine RTC_REG_YEAR        0x09
%idefine RTC_REG_CENTURY     0x32

; RTC bits
%define RTC_NMI_ENABLE  0x00
%define RTC_NMI_DISABLE 0x80

; CMOS RTC I/O ports
%define CMOS_RTC_REG    0x70
%define CMOS_RTC_RAM    0x71

;
; Macro to select a specific RTC register
; and enable or disable non-maskable interrupts.
;
%define RTC_REG(reg, nmi) (reg | nmi)

;
; Macro to set the RTC up.
;
; Usage:
; ksetuprtc
;
%macro ksetuprtc 0
    call rtc.enable_interrupts
%endmacro

;
; Macro to read a specific value from the RTC.
; OUT\ EAX = Result
;
; Usage:
; kreadrtc <register>
;
; Transformations:
; <register> => RTC_REG_<register>
;
; Note:
; Reading the hours is kinda broken.
; This assumes BCD mode.
; Everything is broken in binary mode.
;
%macro kreadrtc 1
    xor eax, eax
    koutb CMOS_RTC_REG, RTC_REG_%1
    kinb CMOS_RTC_RAM
    push ebx
    mov ebx, eax
    shr eax, 4
    and eax, 0x0F
    and ebx, 0x0F
    imul eax, 10
    add eax, ebx
    pop ebx
%endmacro

section .text
rtc:

;
; Enables RTC interrupts on IRQ 8.
; Registers are preserved.
;
.enable_interrupts:
    koutb CMOS_RTC_REG, RTC_REG(RTC_REG_B, RTC_NMI_DISABLE)
    push ax
    kinb CMOS_RTC_RAM
    koutb CMOS_RTC_REG, RTC_REG(RTC_REG_B, RTC_NMI_DISABLE)
    or al, 0x40
    koutb CMOS_RTC_RAM, al
    pop ax
    ret

;
; IRQ handler.
;
.irqh:
    koutb CMOS_RTC_REG, RTC_REG(RTC_REG_C, RTC_NMI_ENABLE)
    kinbsafe CMOS_RTC_RAM
    ret