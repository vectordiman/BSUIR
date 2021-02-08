CSEG SEGMENT PARA PUBLIC 'CODE'
    OVERLAY PROC 
        ASSUME CS:CSEG
        PUSH DS
        
        MUL CX
        
        POP DS
        RETF
        OVERLAY ENDP
    CSEG ENDS
END