global compute_acceleration

section .data
kmh_to_ms: dd 0.27777778        ; Conversion factor from KM/H to m/s
round: dd 0.5                   ; Rounding constant (0.5 for rounding to nearest integer)
threshold: dd 0.1               ; Minimum threshold for small accelerations

section .text
compute_acceleration:
    push rbp                    ; Save the base pointer (function prologue)
    mov rbp, rsp                ; Set up stack frame
    sub rsp, 32                 ; Allocate 32 bytes for shadow space

    xor r9, r9                  ; Initialize row index (R9 = 0)

.loop:
    cmp r9, rdx                 ; Compare row index with number of rows (RDX)
    jge .done                   ; If row index >= num_rows, jump to done

    mov r10, r9                 ; Copy row index to R10
    imul r10, r10, 12           ; R10 = row index * 12 (size of one row in bytes)

    ; Load values into xmm registers
    movss xmm0, [rcx + r10]        ; Load Vi (initial velocity) into xmm0
    movss xmm1, [rcx + r10 + 4]    ; Load Vf (final velocity) into xmm1
    movss xmm2, [rcx + r10 + 8]    ; Load T (time) into xmm2

    ; Convert from KM/H to m/s
    mulss xmm0, [kmh_to_ms]        ; Vi * 0.27777778 (in m/s)
    mulss xmm1, [kmh_to_ms]        ; Vf * 0.27777778 (in m/s)

    ; Calculate acceleration: (Vf - Vi) / T
    subss xmm1, xmm0               ; Vf - Vi
    divss xmm1, xmm2               ; (Vf - Vi) / T (acceleration)

    ; Round the result
    addss xmm1, dword [round]      ; Add 0.5 for rounding

    ; Handle small accelerations (below threshold)
    movss xmm3, [threshold]       ; Load threshold value (e.g., 0.1)
    comiss xmm1, xmm3             ; Compare acceleration with threshold
    jl .apply_threshold           ; If less than threshold, apply threshold
    jmp .check_negative           ; Otherwise, proceed to check for negativity

.apply_threshold:
    movss xmm1, xmm3              ; Set acceleration to threshold value (e.g., 0.1)

.check_negative:
    xorps xmm3, xmm3              ; Clear xmm3 (set to zero)
    comiss xmm1, xmm3             ; Compare acceleration (xmm1) with zero
    jb .set_to_zero               ; Jump if xmm1 < 0 (negative value)
    jmp .store_result             ; Otherwise, skip to store result

.set_to_zero:
    movss xmm1, xmm3              ; Set acceleration to zero

.store_result:
    ; Convert to integer (rounded)
    cvttss2si eax, xmm1            ; Convert the result to an integer
    mov [r8 + r9*4], eax           ; Store result in the result array

    inc r9                         ; Increment row index
    jmp .loop                      ; Repeat for the next row

.done:
    add rsp, 32                    ; Restore the stack
    pop rbp                        ; Restore base pointer
    ret                            ; Return to caller
