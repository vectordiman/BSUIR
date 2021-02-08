CSEG SEGMENT PARA PUBLIC 'CODE'
    OVERLAY PROC 
        ASSUME CS:CSEG
        PUSH DS
        
        XOR DX, DX
        DIV CX
        
        POP DS
        RETF
        OVERLAY ENDP
    CSEG ENDS
END