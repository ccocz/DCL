global _start ;must be declared for linker (ld)

section .rodata
  length EQU 42

section .data
  Linv TIMES length db 0
  Rinv TIMES length db 0
  Tinv TIMES length db 0
  BUFFOR TIMES 4096 db 0

section .text

_start:
  mov     rax, qword [rsi + 32]
  movzx   ebp, byte [rax]
  movzx   ebx, byte [rax + 1]
  mov     r12, qword [rsi + 8] ;L
  mov     r13, qword [rsi + 16] ;R
  mov     r14, qword [rsi + 24] ;T
  cmp     rdi, 5 ;invalid number of arguments
  jne     .error
  movzx   eax, byte [rax + 2]
  test    al, al ;check if key has only 2 elements
  jne     .error
  push    rdi ;push current arguments to not lose them
  push    rsi
  mov     rdi, [rsi + 8] ;put arguments to make a function call
  mov     rsi, Linv
  call    .verify
  cmp     rax, 1 ;check if the given permutation L is valid
  je      .error
  mov     rdi, [rsi + 16]
  mov     rsi, Rinv
  call    .verify
  cmp     rax, 1 ;check if the given permutation R is valid
  je      .error
  mov     rdi, [rsi + 24]
  mov     rsi, Tinv
  call    .verify
  cmp     rax, 1 ;check if the given permutation T is valid
  je      .error
  mov     rax, qword [rsi + 32]
  movzx   r15d, BYTE [rax]
  movzx   r14d, BYTE [rax + 1]
  sub     r15d, 49
  cmp     r15b, 41
  ja      .error
  sub     r14d, 49
  cmp     r14b, 41
  ja      .error
  sub     ebp, '1'
  sub     ebx, '1'
  jmp     .takeinput

.l6:
  cmp     sil, 27
  je      .l7
  cmp     sil, 33
  je      .l7
  cmp     sil, 35
  jne     .l8

.l7:
  lea     ecx, [rbp + 1]
  mov     ebp, ecx
  cmp     cl, 42
  jne     .l8
  xor     ecx, ecx
  xor     ebp, ebp
  jmp     .l8

.filip:
  movzx   eax, byte [rsi]
  movzx   eax, byte [rdi + rax]
  mov     byte [rsi], al
  ret

.normalize:
  mov     r8d, edi
  movsx   edi, BYTE [rsi]
  movsx   r8d, r8b
  add     edi, r8d
  movsx   rax, edi
  mov     edx, edi
  imul    rax, rax, 818089009
  sar     edx, 31
  sar     rax, 35
  sub     eax, edx
  imul    eax, eax, 42
  sub     edi, eax
  mov     BYTE [rsi], dil
  ret

.inside:
  movzx   eax, byte [BUFFOR]
  mov     rdx, BUFFOR
  test    al, al
  je      .takeinput
.l5:
  lea     edx, [eax - 49]
  cmp     dl, 41
  ja      .error
  sub     eax, '1'
  mov     byte [rdx], al
  lea     esi, [rbx + 1]
  mov     ecx, ebp
  mov     ebx, esi
  cmp     sil, 42
  jne     .l6
  xor     esi, esi
  xor     ebx, ebx
  ;;;;;;;;;;;;;;;;;;;;;;;;first
  mov     edi, ebx
  mov     rsi, rdx
  call    .normalize
  mov     rdi, rdx
  mov     rsi, r13
  call    .filip
  mov     rsi, 0
  mov     rdi, rdx
  test    bl, bl
  je      .l9
  mov     rsi, 42
  sub     sil, bl
.l9:
  call    .normalize
  ;;;;;;;;;;;;;;;;;;;;;;;;;;second
  mov     edi, ebp
  mov     rsi, rdx
  call    .normalize
  mov     rdi, rdx
  mov     rsi, r12
  call    .filip
  mov     rsi, 0
  mov     rdi, rdx
  test    ebp, ebp
  je      .l10
  mov     rsi, 42
  sub     esi, ebp
.l10:
  call    .normalize
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;transit
  mov     rdi, rdx
  mov     rsi, r14
  call    .filip
  ;;;;;;;;;;;;;;;;;;;;;;;;;;third
  mov     edi, ebp
  mov     rsi, rdx
  call    .normalize
  mov     rdi, rdx
  mov     rsi, Linv
  call    .filip
  mov     rsi, 0
  mov     rdi, rdx
  test    ebp, ebp
  je      .l11
  mov     rsi, 42
  sub     esi, ebp
.l11:
  call    .normalize
  ;;;;;;;;;;;;;;;;;;;;;;;;fourth
  mov     edi, ebx
  mov     rsi, rdx
  call    .normalize
  mov     rdi, rdx
  mov     rsi, Rinv
  call    .filip
  mov     rsi, 0
  mov     rdi, rdx
  test    bl, bl
  je      .l12
  mov     rsi, 42
  sub     sil, bl
.l12:
  call    .normalize
.l8:
  add     byte [rdx], '1'
  add     rdx, 1
  movzx   eax, byte [rdx]
  test    al, al
  jne     .l5
  sub     rdx, BUFFOR
  xor     rax, rax
  add     rax, 1
  xor     rdi, rdi
  add     rdi, 1
  mov     rsi, BUFFOR
  syscall

.takeinput:
  xor     eax, eax ;syscall number
  xor     edi, edi ;stdin file descriptor
  mov     rsi, BUFFOR ;address of the buffer
  mov     edx, 4096 ;size of the buffer
  syscall
  test    rax, rax
  jne     .inside

  ret

.verify:
  xor     edx, edx ;current length of the given permutation
.l1:      ;start the loop
  movzx   ecx, byte [rdi] ;move the next character into ecx register
  test    cl, cl
  je      .l2 ;continue looping if there is a char
  mov     al, byte [rdi]
  sub     eax, 49 ;store difference to determine if current character lies in the valid range
  cmp     al, 41
  ja      .error
  sub     byte [rdi], '1' ;to save memory compress the characters
  add     rsi, [rdi]
  cmp     byte [rsi], 0 ;check if current character already appearead
  jne     .error
  sub     rsi, [rdi]
  inc     edx
  add     rdi, 1
  add     rsi, [rdi]
  mov     [rsi], edx ;store the inverse
  sub     rsi, [rdi]
  jmp     .l1
.l2: ;finish the loop
  cmp     edx, length
  jne     .error
  xor     rax, rax
  ret

.isvalidt:
  xor     edx, edx
  xor     rax, rax
.l3:
  cmp     edx, length
  je      .l4
  movsx   ecx,  byte[rdi]
  cmp     cl, byte [rsi] ; check if current character is in the cycle of length two
  jne     .error
  sub     byte [rdi], '1'
  cmp     byte [rdi], dl ;cycle of length one
  je      .error
  add     byte [rdi], '1'
  add     rdi, 1
  add     rsi, 1
  inc     edx
  jmp     .l3
.l4:
  ret

.error:
  xor     rax, rax
  mov     rax, 1
  ret
