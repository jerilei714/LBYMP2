global compute_acceleration

section .data
kmh_to_ms: dd 0.27777778        ; Conversion factor from KM/H to m/s
round: dd 0.5                   ; Rounding constant (0.5 for rounding to nearest integer)
threshold: dd 0.1               ; Minimum threshold for small accelerations (e.g., 0.1)
desired_acceleration: dd 4.0    ; Desired acceleration to apply if the threshold is met

section .text
compute_acceleration:
    push rbp                    ; Set up the stack frame
    mov rbp, rsp                
    sub rsp, 32                 ; Allocate 32 bytes for shadow space

    xor r9, r9                  ; Initialize row index (R9 = 0)

.loop:
    cmp r9, rdx                  ; Check if row index (r9) is greater or equal to the total number of rows
    jge .done                    ; If done, jump to the done section

    mov r10, r9                  ; Get the current index
    imul r10, r10, 12            ; Multiply index by 12 (size of each row)

    ; Load values into xmm registers
    movss xmm0, [rcx + r10]        ; Load Vi (initial velocity) into xmm0
    movss xmm1, [rcx + r10 + 4]    ; Load Vf (final velocity) into xmm1
    movss xmm2, [rcx + r10 + 8]    ; Load T (time) into xmm2

    ; Convert from KM/H to m/s
    mulss xmm0, [kmh_to_ms]        ; Vi * 0.27777778 (in m/s)
    mulss xmm1, [kmh_to_ms]        ; Vf * 0.27777778 (in m/s)

    ; Calculate acceleration: (Vf - Vi) / T
    subss xmm1, xmm0               ; Vf - Vi
    divss xmm1, xmm2               ; (Vf - Vi) / T

    ; Check if the calculated acceleration is below the threshold
    movss xmm3, [threshold]        ; Load threshold value (e.g., 0.1 m/s²)
    comiss xmm1, xmm3              ; Compare acceleration (xmm1) with threshold (xmm3)
    jl .apply_adjustment           ; If acceleration is lower than threshold, adjust it

    ; If no adjustment needed, continue normal rounding
    jmp .round_positive

.apply_adjustment:
    ; If the acceleration is too low, manually set it to 4.0 m/s² (or another desired value)
    movss xmm1, [desired_acceleration]  ; Load the desired acceleration (4.0 m/s²)

.round_positive:
    ; Check if the acceleration is positive or negative
    xorps xmm3, xmm3               ; Clear xmm3 (this will be used for comparison with zero)
    comiss xmm1, xmm3              ; Compare acceleration (xmm1) with zero
    jge .positive_acceleration     ; If acceleration is positive, round it

    ; If negative acceleration, convert directly to integer (truncate/floor)
    cvttss2si eax, xmm1            ; Convert negative value to integer (this truncates towards zero)

    ; Store the result in the result array
    mov [r8 + r9*4], eax           ; Store the result in the result array
    jmp .next_car                  ; Continue to the next car

.positive_acceleration:
    ; If positive acceleration, apply rounding
    addss xmm1, dword [round]      ; Add rounding constant (0.5) to positive acceleration
    cvttss2si eax, xmm1            ; Convert the rounded value to integer (rounding normally)

    ; Store the result in the result array
    mov [r8 + r9*4], eax           ; Store the result in the result array

.next_car:
    ; Increment row index and continue the loop
    inc r9
    jmp .loop                       ; Continue to next iteration

.done:
    add rsp, 32                    
    pop rbp                        
    ret
