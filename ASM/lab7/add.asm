CSEG SEGMENT PARA PUBLIC 'CODE'
    OVERLAY PROC FAR
        ASSUME CS:CSEG
        PUSH DS
        
        ADD AX, CX
        
        POP DS
        RETF
        OVERLAY ENDP
    CSEG ENDS
END