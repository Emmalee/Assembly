;Look up Table used by analog to digital converter
$NOLIST

CSEG 

;------------------------------------------------
; x = x * y
;------------------------------------------------
mul16:
        push acc
        push b
        push psw
        push AR0
        push AR1
                
        ; R0 = x+0 * y+0
        ; R1 = x+1 * y+0 + x+0 * y+1
        
        ; Byte 0
        mov        a,x+0
        mov        b,y+0
        mul        ab                ; x+0 * y+0
        mov        R0,a
        mov        R1,b
        
        ; Byte 1
        mov        a,x+1
        mov        b,y+0
        mul        ab                ; x+1 * y+0
        add        a,R1
        mov        R1,a
        clr        a
        addc a,b
        mov        R2,a
        
        mov        a,x+0
        mov        b,y+1
        mul        ab                ; x+0 * y+1
        add        a,R1
        mov        R1,a
        
        mov        x+1,R1
        mov        x+0,R0

        pop AR1
        pop AR0
        pop psw
        pop b
        pop acc
        
        ret

;------------------------------------------------
; x = x + y
;------------------------------------------------
add16:
        push acc
        push psw
        mov a, x+0
        add a, y+0
        mov x+0, a
        mov a, x+1
        addc a, y+1
        mov x+1, a
        pop psw
        pop acc
        ret

;----------------------------------------------------
; Converts the 16-bit hex number in 'x' to a 
; 5-digit packed BCD in 'bcd' using the
; double-dabble algorithm.
;---------------------------------------------------
hex2bcd:
        push acc
        push psw
        push AR0
        
        clr a
        mov bcd+0, a ; Initialize BCD to 00-00-00 
        mov bcd+1, a
        mov bcd+2, a
        mov r0, #16  ; Loop counter.

hex2bcd_L0:
        ; Shift binary left        
        mov a, x+1
        mov c, acc.7 ; This way x remains unchanged!
        mov a, x+0
        rlc a
        mov x+0, a
        mov a, x+1
        rlc a
        mov x+1, a
    
        ; Perform bcd + bcd + carry using BCD arithmetic
        mov a, bcd+0
        addc a, bcd+0
        da a
        mov bcd+0, a
        mov a, bcd+1
        addc a, bcd+1
        da a
        mov bcd+1, a
        mov a, bcd+2
        addc a, bcd+2
        da a
        mov bcd+2, a

        djnz r0, hex2bcd_L0

        pop AR0
        pop psw
        pop acc
ret

myVoltTable:
dw    0 ;0
dw   13 ;1
dw   26 ;2
dw   39 ;3
dw   52 ;4
dw   65 ;5
dw   78 ;6
dw   91 ;7
dw  104 ;8
dw  116 ;9
dw  129 ;10
dw  142 ;11
dw  155 ;12
dw  168 ;13
dw  181 ;14
dw  194 ;15
dw  207 ;16
dw  220 ;17
dw  233 ;18
dw  246 ;19
dw  259 ;20
dw  272 ;21
dw  285 ;22
dw  298 ;23
dw  311 ;24
dw  324 ;25
dw  336 ;26
dw  349 ;27
dw  362 ;28
dw  375 ;29
dw  388 ;30
dw  401 ;31
dw  414 ;32
dw  427 ;33
dw  440 ;34
dw  453 ;35
dw  466 ;36
dw  479 ;37
dw  492 ;38
dw  505 ;39
dw  518 ;40
dw  531 ;41
dw  544 ;42
dw  556 ;43
dw  569 ;44
dw  582 ;45
dw  595 ;46
dw  608 ;47
dw  621 ;48
dw  634 ;49
dw  647 ;50
dw  660 ;51
dw  673 ;52
dw  686 ;53
dw  699 ;54
dw  712 ;55
dw  725 ;56
dw  738 ;57
dw  751 ;58
dw  764 ;59
dw  776 ;60
dw  789 ;61
dw  802 ;62
dw  815 ;63
dw  828 ;64
dw  841 ;65
dw  854 ;66
dw  867 ;67
dw  880 ;68
dw  893 ;69
dw  906 ;70
dw  919 ;71
dw  932 ;72
dw  945 ;73
dw  958 ;74
dw  971 ;75
dw  984 ;76
dw  996 ;77
dw 1009 ;78
dw 1022 ;79
dw 1035 ;80
dw 1048 ;81
dw 1061 ;82
dw 1074 ;83
dw 1087 ;84
dw 1100 ;85
dw 1113 ;86
dw 1126 ;87
dw 1139 ;88
dw 1152 ;89
dw 1165 ;90
dw 1178 ;91
dw 1191 ;92
dw 1204 ;93
dw 1216 ;94
dw 1229 ;95
dw 1242 ;96
dw 1255 ;97
dw 1268 ;98
dw 1281 ;99
dw 1294 ;100
dw 1307 ;101
dw 1320 ;102
dw 1333 ;103
dw 1346 ;104
dw 1359 ;105
dw 1372 ;106
dw 1385 ;107
dw 1398 ;108
dw 1411 ;109
dw 1424 ;110
dw 1436 ;111
dw 1449 ;112
dw 1462 ;113
dw 1475 ;114
dw 1488 ;115
dw 1501 ;116
dw 1514 ;117
dw 1527 ;118
dw 1540 ;119
dw 1553 ;120
dw 1566 ;121
dw 1579 ;122
dw 1592 ;123
dw 1605 ;124
dw 1618 ;125
dw 1631 ;126
dw 1644 ;127
dw 1656 ;128
dw 1669 ;129
dw 1682 ;130
dw 1695 ;131
dw 1708 ;132
dw 1721 ;133
dw 1734 ;134
dw 1747 ;135
dw 1760 ;136
dw 1773 ;137
dw 1786 ;138
dw 1799 ;139
dw 1812 ;140
dw 1825 ;141
dw 1838 ;142
dw 1851 ;143
dw 1864 ;144
dw 1876 ;145
dw 1889 ;146
dw 1902 ;147
dw 1915 ;148
dw 1928 ;149
dw 1941 ;150
dw 1954 ;151
dw 1967 ;152
dw 1980 ;153
dw 1993 ;154
dw 2006 ;155
dw 2019 ;156
dw 2032 ;157
dw 2045 ;158
dw 2058 ;159
dw 2071 ;160
dw 2084 ;161
dw 2096 ;162
dw 2109 ;163
dw 2122 ;164
dw 2135 ;165
dw 2148 ;166
dw 2161 ;167
dw 2174 ;168
dw 2187 ;169
dw 2200 ;170
dw 2213 ;171
dw 2226 ;172
dw 2239 ;173
dw 2252 ;174
dw 2265 ;175
dw 2278 ;176
dw 2291 ;177
dw 2304 ;178
dw 2316 ;179
dw 2329 ;180
dw 2342 ;181
dw 2355 ;182
dw 2368 ;183
dw 2381 ;184
dw 2394 ;185
dw 2407 ;186
dw 2420 ;187
dw 2433 ;188
dw 2446 ;189
dw 2459 ;190
dw 2472 ;191
dw 2485 ;192
dw 2498 ;193
dw 2511 ;194
dw 2524 ;195
dw 2536 ;196
dw 2549 ;197
dw 2562 ;198
dw 2575 ;199
dw 2588 ;200
dw 2601 ;201
dw 2614 ;202
dw 2627 ;203
dw 2640 ;204
dw 2653 ;205
dw 2666 ;206
dw 2679 ;207
dw 2692 ;208
dw 2705 ;209
dw 2718 ;210
dw 2731 ;211
dw 2744 ;212
dw 2756 ;213
dw 2769 ;214
dw 2782 ;215
dw 2795 ;216
dw 2808 ;217
dw 2821 ;218
dw 2834 ;219
dw 2847 ;220
dw 2860 ;221
dw 2873 ;222
dw 2886 ;223
dw 2899 ;224
dw 2912 ;225
dw 2925 ;226
dw 2938 ;227
dw 2951 ;228
dw 2964 ;229
dw 2976 ;230
dw 2989 ;231
dw 3002 ;232
dw 3015 ;233
dw 3028 ;234
dw 3041 ;235
dw 3054 ;236
dw 3067 ;237
dw 3080 ;238
dw 3093 ;239
dw 3106 ;240
dw 3119 ;241
dw 3132 ;242
dw 3145 ;243
dw 3158 ;244
dw 3171 ;245
dw 3184 ;246
dw 3196 ;247
dw 3209 ;248
dw 3222 ;249
dw 3235 ;250
dw 3248 ;251
dw 3261 ;252
dw 3274 ;253
dw 3287 ;254
dw 3300 ;255
$LIST