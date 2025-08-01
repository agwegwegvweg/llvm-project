; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mipsel-unknown-linux-gnu -O3 -relocation-model=pic < %s \
; RUN:   | FileCheck %s -check-prefix=NOLONGBRANCH

; RUN: llc -mtriple=mipsel-unknown-linux-gnu -force-mips-long-branch -O3 -relocation-model=pic < %s \
; RUN:   | FileCheck %s -check-prefix=O32-PIC
; RUN: llc -mtriple=mipsel-unknown-linux-gnu -force-mips-long-branch -O3 -relocation-model=static < %s \
; RUN:   | FileCheck %s -check-prefix=O32-STATIC
; RUN: llc -mtriple=mipsel-unknown-linux-gnu -mcpu=mips32r6 -force-mips-long-branch -O3 \
; RUN:   -relocation-model=pic < %s | FileCheck %s -check-prefix=O32-R6-PIC

; RUN: llc -mtriple=mips64el-unknown-linux-gnu -mcpu=mips4 -target-abi=n64 -force-mips-long-branch -O3 -relocation-model=pic \
; RUN:   < %s | FileCheck %s -check-prefix=MIPS4
; RUN: llc -mtriple=mips64el-unknown-linux-gnu -mcpu=mips64 -target-abi=n64 -force-mips-long-branch -O3 -relocation-model=pic \
; RUN:   < %s | FileCheck %s -check-prefix=MIPS64
; RUN: llc -mtriple=mips64el-unknown-linux-gnu -mcpu=mips64r6 -target-abi=n64 -force-mips-long-branch -O3 \
; RUN:   -relocation-model=pic < %s | FileCheck %s -check-prefix=N64-R6

; RUN: llc -mtriple=mipsel-unknown-linux-gnu -mcpu=mips32r2 -mattr=micromips \
; RUN:   -force-mips-long-branch -O3 -relocation-model=pic < %s | FileCheck %s -check-prefix=MICROMIPS
; RUN: llc -mtriple=mipsel-unknown-linux-gnu -mcpu=mips32r2 -mattr=micromips \
; RUN:   -force-mips-long-branch -O3 -relocation-model=static < %s | FileCheck %s -check-prefix=MICROMIPSSTATIC

; RUN: llc -mtriple=mipsel-unknown-linux-gnu -mcpu=mips32r6 -mattr=micromips \
; RUN:   -force-mips-long-branch -O3 -relocation-model=static < %s | FileCheck %s -check-prefix=MICROMIPSR6STATIC
; RUN: llc -mtriple=mipsel-unknown-linux-gnu -mcpu=mips32r6 -mattr=micromips \
; RUN:   -force-mips-long-branch -O3 -relocation-model=pic < %s | FileCheck %s -check-prefix=MICROMIPSR6PIC

@x = external global i32

define void @test1(i32 signext %s) {
; NOLONGBRANCH-LABEL: test1:
; NOLONGBRANCH:       # %bb.0: # %entry
; NOLONGBRANCH-NEXT:    lui $2, %hi(_gp_disp)
; NOLONGBRANCH-NEXT:    addiu $2, $2, %lo(_gp_disp)
; NOLONGBRANCH-NEXT:    beqz $4, $BB0_2
; NOLONGBRANCH-NEXT:    addu $2, $2, $25
; NOLONGBRANCH-NEXT:  # %bb.1: # %then
; NOLONGBRANCH-NEXT:    lw $1, %got(x)($2)
; NOLONGBRANCH-NEXT:    addiu $2, $zero, 1
; NOLONGBRANCH-NEXT:    sw $2, 0($1)
; NOLONGBRANCH-NEXT:  $BB0_2: # %end
; NOLONGBRANCH-NEXT:    jr $ra
; NOLONGBRANCH-NEXT:    nop
;
; O32-PIC-LABEL: test1:
; O32-PIC:       # %bb.0: # %entry
; O32-PIC-NEXT:    lui $2, %hi(_gp_disp)
; O32-PIC-NEXT:    addiu $2, $2, %lo(_gp_disp)
; O32-PIC-NEXT:    bnez $4, $BB0_3
; O32-PIC-NEXT:    addu $2, $2, $25
; O32-PIC-NEXT:  # %bb.1: # %entry
; O32-PIC-NEXT:    addiu $sp, $sp, -8
; O32-PIC-NEXT:    sw $ra, 0($sp)
; O32-PIC-NEXT:    lui $1, %hi($BB0_4-$BB0_2)
; O32-PIC-NEXT:    bal $BB0_2
; O32-PIC-NEXT:    addiu $1, $1, %lo($BB0_4-$BB0_2)
; O32-PIC-NEXT:  $BB0_2: # %entry
; O32-PIC-NEXT:    addu $1, $ra, $1
; O32-PIC-NEXT:    lw $ra, 0($sp)
; O32-PIC-NEXT:    jr $1
; O32-PIC-NEXT:    addiu $sp, $sp, 8
; O32-PIC-NEXT:  $BB0_3: # %then
; O32-PIC-NEXT:    lw $1, %got(x)($2)
; O32-PIC-NEXT:    addiu $2, $zero, 1
; O32-PIC-NEXT:    sw $2, 0($1)
; O32-PIC-NEXT:  $BB0_4: # %end
; O32-PIC-NEXT:    jr $ra
; O32-PIC-NEXT:    nop
;
; O32-STATIC-LABEL: test1:
; O32-STATIC:       # %bb.0: # %entry
; O32-STATIC-NEXT:    bnez $4, $BB0_2
; O32-STATIC-NEXT:    nop
; O32-STATIC-NEXT:  # %bb.1: # %entry
; O32-STATIC-NEXT:    j $BB0_3
; O32-STATIC-NEXT:    nop
; O32-STATIC-NEXT:  $BB0_2: # %then
; O32-STATIC-NEXT:    lui $1, %hi(x)
; O32-STATIC-NEXT:    addiu $2, $zero, 1
; O32-STATIC-NEXT:    sw $2, %lo(x)($1)
; O32-STATIC-NEXT:  $BB0_3: # %end
; O32-STATIC-NEXT:    jr $ra
; O32-STATIC-NEXT:    nop
;
; O32-R6-PIC-LABEL: test1:
; O32-R6-PIC:       # %bb.0: # %entry
; O32-R6-PIC-NEXT:    lui $2, %hi(_gp_disp)
; O32-R6-PIC-NEXT:    addiu $2, $2, %lo(_gp_disp)
; O32-R6-PIC-NEXT:    bnez $4, $BB0_3
; O32-R6-PIC-NEXT:    addu $2, $2, $25
; O32-R6-PIC-NEXT:  # %bb.1: # %entry
; O32-R6-PIC-NEXT:    addiu $sp, $sp, -8
; O32-R6-PIC-NEXT:    sw $ra, 0($sp)
; O32-R6-PIC-NEXT:    lui $1, %hi($BB0_4-$BB0_2)
; O32-R6-PIC-NEXT:    addiu $1, $1, %lo($BB0_4-$BB0_2)
; O32-R6-PIC-NEXT:    balc $BB0_2
; O32-R6-PIC-NEXT:  $BB0_2: # %entry
; O32-R6-PIC-NEXT:    addu $1, $ra, $1
; O32-R6-PIC-NEXT:    lw $ra, 0($sp)
; O32-R6-PIC-NEXT:    addiu $sp, $sp, 8
; O32-R6-PIC-NEXT:    jrc $1
; O32-R6-PIC-NEXT:  $BB0_3: # %then
; O32-R6-PIC-NEXT:    lw $1, %got(x)($2)
; O32-R6-PIC-NEXT:    addiu $2, $zero, 1
; O32-R6-PIC-NEXT:    sw $2, 0($1)
; O32-R6-PIC-NEXT:  $BB0_4: # %end
; O32-R6-PIC-NEXT:    jrc $ra
;
; O32-R6-STATIC-LABEL: test1:
; O32-R6-STATIC:       # %bb.0: # %entry
; O32-R6-STATIC-NEXT:    bnezc $4, $BB0_2
; O32-R6-STATIC-NEXT:    nop
; O32-R6-STATIC-NEXT:  # %bb.1: # %entry
; O32-R6-STATIC-NEXT:    bc $BB0_3
; O32-R6-STATIC-NEXT:  $BB0_2: # %then
; O32-R6-STATIC-NEXT:    lui $1, %hi(x)
; O32-R6-STATIC-NEXT:    addiu $2, $zero, 1
; O32-R6-STATIC-NEXT:    sw $2, %lo(x)($1)
; O32-R6-STATIC-NEXT:  $BB0_3: # %end
; O32-R6-STATIC-NEXT:    jrc $ra
;
; MIPS4-LABEL: test1:
; MIPS4:       # %bb.0: # %entry
; MIPS4-NEXT:    lui $1, %hi(%neg(%gp_rel(test1)))
; MIPS4-NEXT:    bnez $4, .LBB0_3
; MIPS4-NEXT:    daddu $2, $1, $25
; MIPS4-NEXT:  # %bb.1: # %entry
; MIPS4-NEXT:    daddiu $sp, $sp, -16
; MIPS4-NEXT:    sd $ra, 0($sp)
; MIPS4-NEXT:    daddiu $1, $zero, %hi(.LBB0_4-.LBB0_2)
; MIPS4-NEXT:    dsll $1, $1, 16
; MIPS4-NEXT:    bal .LBB0_2
; MIPS4-NEXT:    daddiu $1, $1, %lo(.LBB0_4-.LBB0_2)
; MIPS4-NEXT:  .LBB0_2: # %entry
; MIPS4-NEXT:    daddu $1, $ra, $1
; MIPS4-NEXT:    ld $ra, 0($sp)
; MIPS4-NEXT:    jr $1
; MIPS4-NEXT:    daddiu $sp, $sp, 16
; MIPS4-NEXT:  .LBB0_3: # %then
; MIPS4-NEXT:    daddiu $1, $2, %lo(%neg(%gp_rel(test1)))
; MIPS4-NEXT:    addiu $2, $zero, 1
; MIPS4-NEXT:    ld $1, %got_disp(x)($1)
; MIPS4-NEXT:    sw $2, 0($1)
; MIPS4-NEXT:  .LBB0_4: # %end
; MIPS4-NEXT:    jr $ra
; MIPS4-NEXT:    nop
;
; MIPS64-LABEL: test1:
; MIPS64:       # %bb.0: # %entry
; MIPS64-NEXT:    lui $1, %hi(%neg(%gp_rel(test1)))
; MIPS64-NEXT:    bnez $4, .LBB0_3
; MIPS64-NEXT:    daddu $2, $1, $25
; MIPS64-NEXT:  # %bb.1: # %entry
; MIPS64-NEXT:    daddiu $sp, $sp, -16
; MIPS64-NEXT:    sd $ra, 0($sp)
; MIPS64-NEXT:    daddiu $1, $zero, %hi(.LBB0_4-.LBB0_2)
; MIPS64-NEXT:    dsll $1, $1, 16
; MIPS64-NEXT:    bal .LBB0_2
; MIPS64-NEXT:    daddiu $1, $1, %lo(.LBB0_4-.LBB0_2)
; MIPS64-NEXT:  .LBB0_2: # %entry
; MIPS64-NEXT:    daddu $1, $ra, $1
; MIPS64-NEXT:    ld $ra, 0($sp)
; MIPS64-NEXT:    jr $1
; MIPS64-NEXT:    daddiu $sp, $sp, 16
; MIPS64-NEXT:  .LBB0_3: # %then
; MIPS64-NEXT:    daddiu $1, $2, %lo(%neg(%gp_rel(test1)))
; MIPS64-NEXT:    addiu $2, $zero, 1
; MIPS64-NEXT:    ld $1, %got_disp(x)($1)
; MIPS64-NEXT:    sw $2, 0($1)
; MIPS64-NEXT:  .LBB0_4: # %end
; MIPS64-NEXT:    jr $ra
; MIPS64-NEXT:    nop
;
; N64-R6-LABEL: test1:
; N64-R6:       # %bb.0: # %entry
; N64-R6-NEXT:    lui $1, %hi(%neg(%gp_rel(test1)))
; N64-R6-NEXT:    bnez $4, .LBB0_3
; N64-R6-NEXT:    daddu $2, $1, $25
; N64-R6-NEXT:  # %bb.1: # %entry
; N64-R6-NEXT:    daddiu $sp, $sp, -16
; N64-R6-NEXT:    sd $ra, 0($sp)
; N64-R6-NEXT:    daddiu $1, $zero, %hi(.LBB0_4-.LBB0_2)
; N64-R6-NEXT:    dsll $1, $1, 16
; N64-R6-NEXT:    daddiu $1, $1, %lo(.LBB0_4-.LBB0_2)
; N64-R6-NEXT:    balc .LBB0_2
; N64-R6-NEXT:  .LBB0_2: # %entry
; N64-R6-NEXT:    daddu $1, $ra, $1
; N64-R6-NEXT:    ld $ra, 0($sp)
; N64-R6-NEXT:    daddiu $sp, $sp, 16
; N64-R6-NEXT:    jrc $1
; N64-R6-NEXT:  .LBB0_3: # %then
; N64-R6-NEXT:    daddiu $1, $2, %lo(%neg(%gp_rel(test1)))
; N64-R6-NEXT:    addiu $2, $zero, 1
; N64-R6-NEXT:    ld $1, %got_disp(x)($1)
; N64-R6-NEXT:    sw $2, 0($1)
; N64-R6-NEXT:  .LBB0_4: # %end
; N64-R6-NEXT:    jrc $ra
;
; MICROMIPS-LABEL: test1:
; MICROMIPS:       # %bb.0: # %entry
; MICROMIPS-NEXT:    lui $2, %hi(_gp_disp)
; MICROMIPS-NEXT:    addiu $2, $2, %lo(_gp_disp)
; MICROMIPS-NEXT:    bnez $4, $BB0_3
; MICROMIPS-NEXT:    addu $2, $2, $25
; MICROMIPS-NEXT:  # %bb.1: # %entry
; MICROMIPS-NEXT:    addiu $sp, $sp, -8
; MICROMIPS-NEXT:    sw $ra, 0($sp)
; MICROMIPS-NEXT:    lui $1, %hi($BB0_4-$BB0_2)
; MICROMIPS-NEXT:    bal $BB0_2
; MICROMIPS-NEXT:    addiu $1, $1, %lo($BB0_4-$BB0_2)
; MICROMIPS-NEXT:  $BB0_2: # %entry
; MICROMIPS-NEXT:    addu $1, $ra, $1
; MICROMIPS-NEXT:    lw $ra, 0($sp)
; MICROMIPS-NEXT:    jr $1
; MICROMIPS-NEXT:    addiu $sp, $sp, 8
; MICROMIPS-NEXT:  $BB0_3: # %then
; MICROMIPS-NEXT:    lw $2, %got(x)($2)
; MICROMIPS-NEXT:    li16 $3, 1
; MICROMIPS-NEXT:    sw16 $3, 0($2)
; MICROMIPS-NEXT:  $BB0_4: # %end
; MICROMIPS-NEXT:    jrc $ra
;
; MICROMIPSSTATIC-LABEL: test1:
; MICROMIPSSTATIC:       # %bb.0: # %entry
; MICROMIPSSTATIC-NEXT:    bnezc $4, $BB0_2
; MICROMIPSSTATIC-NEXT:  # %bb.1: # %entry
; MICROMIPSSTATIC-NEXT:    j $BB0_3
; MICROMIPSSTATIC-NEXT:    nop
; MICROMIPSSTATIC-NEXT:  $BB0_2: # %then
; MICROMIPSSTATIC-NEXT:    lui $1, %hi(x)
; MICROMIPSSTATIC-NEXT:    li16 $2, 1
; MICROMIPSSTATIC-NEXT:    sw $2, %lo(x)($1)
; MICROMIPSSTATIC-NEXT:  $BB0_3: # %end
; MICROMIPSSTATIC-NEXT:    jrc $ra
;
; MICROMIPSR6STATIC-LABEL: test1:
; MICROMIPSR6STATIC:       # %bb.0: # %entry
; MICROMIPSR6STATIC-NEXT:    bnezc $4, $BB0_2
; MICROMIPSR6STATIC-NEXT:  # %bb.1: # %entry
; MICROMIPSR6STATIC-NEXT:    bc $BB0_3
; MICROMIPSR6STATIC-NEXT:  $BB0_2: # %then
; MICROMIPSR6STATIC-NEXT:    lui $1, %hi(x)
; MICROMIPSR6STATIC-NEXT:    li16 $2, 1
; MICROMIPSR6STATIC-NEXT:    sw $2, %lo(x)($1)
; MICROMIPSR6STATIC-NEXT:  $BB0_3: # %end
; MICROMIPSR6STATIC-NEXT:    jrc $ra
;
; MICROMIPSR6PIC-LABEL: test1:
; MICROMIPSR6PIC:       # %bb.0: # %entry
; MICROMIPSR6PIC-NEXT:    lui $2, %hi(_gp_disp)
; MICROMIPSR6PIC-NEXT:    addiu $2, $2, %lo(_gp_disp)
; MICROMIPSR6PIC-NEXT:    addu $2, $2, $25
; MICROMIPSR6PIC-NEXT:    bnezc $4, $BB0_3
; MICROMIPSR6PIC-NEXT:  # %bb.1: # %entry
; MICROMIPSR6PIC-NEXT:    addiu $sp, $sp, -8
; MICROMIPSR6PIC-NEXT:    sw $ra, 0($sp)
; MICROMIPSR6PIC-NEXT:    lui $1, %hi($BB0_4-$BB0_2)
; MICROMIPSR6PIC-NEXT:    addiu $1, $1, %lo($BB0_4-$BB0_2)
; MICROMIPSR6PIC-NEXT:    balc $BB0_2
; MICROMIPSR6PIC-NEXT:  $BB0_2: # %entry
; MICROMIPSR6PIC-NEXT:    addu $1, $ra, $1
; MICROMIPSR6PIC-NEXT:    lw $ra, 0($sp)
; MICROMIPSR6PIC-NEXT:    addiu $sp, $sp, 8
; MICROMIPSR6PIC-NEXT:    jic $1, 0
; MICROMIPSR6PIC-NEXT:  $BB0_3: # %then
; MICROMIPSR6PIC-NEXT:    lw $2, %got(x)($2)
; MICROMIPSR6PIC-NEXT:    li16 $3, 1
; MICROMIPSR6PIC-NEXT:    sw16 $3, 0($2)
; MICROMIPSR6PIC-NEXT:  $BB0_4: # %end
; MICROMIPSR6PIC-NEXT:    jrc $ra

entry:
  %cmp = icmp eq i32 %s, 0
  br i1 %cmp, label %end, label %then

then:
  store i32 1, ptr @x, align 4
  br label %end

end:
  ret void

}
