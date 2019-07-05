	.org 0x0
.global _start
   .set noat
_start:
   ori $1,$0,0x1100        # $1 = $0 | 0x1100 = 0x1100
   ori $2,$0,0x0020        # $2 = $0 | 0x0020 = 0x0020
   ori $3,$0,0xff00        # $3 = $0 | 0xff00 = 0xff00
   ori $4,$0,0xffff        # $4 = $0 | 0xffff = 0xffff
   add  $3,$2,$1           # $3 = $2 + $1 = 0x1120
   addi $3,$3,2            # $3 = $3 + 2 = 0x1122
   and  $1,$3,$1           # $1 = $3 & $1 = 0x1100