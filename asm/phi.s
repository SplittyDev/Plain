;
; PLAIN Hardware Interface
;


;
; Verifies that a driver implements a specific label.
;
%macro PHI_VERIFY 3
    %ifnid %[%[%2].%[%3]]
        %error [PHI] %[%1] does not implement %[%3].
    %endif
%endmacro

;
; Loads a PHI-compliant driver.
;
; Usage:
; PHI_USE <driver>
;
; Looks for the interface at:
; ./drivers/<driver>.s
;
%macro PHI_USE 1
    %define PHI_IMPL PHI_%[%1]
    %define PHI_DRIVER %[%1]
    %defstr __phi_driver_location drivers/%[%1].s
    %include __phi_driver_location
    PHI_VERIFY PHI_DRIVER, PHI_IMPL, load
    PHI_VERIFY PHI_DRIVER, PHI_IMPL, unload
    PHI_VERIFY PHI_DRIVER, PHI_IMPL, irqh
%endmacro

%macro PHI_LOAD 1
    call PHI_%[%1].load
%endmacro

%macro PHI_UNLOAD 1
    call PHI_%[%1].unload
%endmacro

section .bss
align 8
phi_stack:
    resb 8
.top: