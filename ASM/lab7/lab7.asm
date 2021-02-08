.MODEL	SMALL
.STACK	100h  

.DATA

stringBuffer                DB  80,80 dup ('$')
endl                        DB  0Ah, 0Dh, '$'
numberBuffer                DW  ?    
numberLast                  DW  ?  
operationLast               DB  ?
flagOperation               DB  0 
flagFirst                   DB  1   

pathAdd DB "add.exe", 0         
pathSub DB "sub.exe", 0   
pathMul DB "mul.exe", 0    
pathDiv DB "div.exe", 0

errorEmptyCMD               DB 'No parametrs in cmd$'
errorManyString             DB 'Too many arguments. You should input one string$'       
errorZero                   DB 'Division by zero is forbidden!$' 
errorBadParametrs           DB 'Bad parametrs in comand line$'
errorBigNumber              DB 'Numbers are too big for two bytes$'  
errorOverflow               DB 'Overflow occured$'
errorMemory                 DB 'Error loading the memory for overlay$'

EPB            DW ?
               DW 0     
overlayOffset  DW 0
overlaySegment DW ?
codeSegment    DW ?

.CODE

coutNumber PROC

    LEA DX, endl
    CALL cout
    PUSHA
    MOV     CX, 10
    XOR     DI, DI         
    OR      AX, AX
    JNS     numberToChar
    PUSH    AX
    MOV     DX, '-'
    MOV     AH, 2           
    INT     21h
    POP     AX
    NEG     AX
 
numberToChar:
    XOR     DX, DX
    DIV     CX              
    ADD     DL, '0'         
    INC     DI
    PUSH    DX             
    OR      AX, AX
    JNZ     numberToChar
        
coutChar:
    POP     DX              
    MOV     AH, 2           
    INT     21h
    DEC     DI              
    JNZ     coutChar
 
    POPA
    RET

coutNumber ENDP 

controlSymbol PROC 

    CMP AL, '*'
    JE operationMul
    CMP AL, '/'
    JE operationDiv
    CMP AL, '+'
    JE operationAdd   
    CMP AL, '-'
    JE operationSub                   
    CMP AL, '9'                    
    JA errorNotNumber               
    CMP AL, '0'                    
    JB errorNotNumber               
    JMP endNormal               
                                  
    errorNotNumber:                  
        MOV AH, 1                  
        JMP endControl    

    operationMul:                  
        MOV AH, '*'                  
        JMP controlOverlay       
    operationDiv:                  
        MOV AH, '/'                  
        JMP controlOverlay
    operationAdd:                  
        MOV AH, '+'                  
        JMP controlOverlay     
    operationSub:                  
        MOV AH, '-'                  
        JMP controlOverlay             
                                  
    endNormal:                
        XOR AH, AH 
        JMP endControl
        
    controlOverlay:  
        MOV BH, AH
        CALL loadOverlay   
        MOV BL, 1        
                                  
    endControl:                 
        RET 
controlSymbol ENDP   

loadOverlay PROC 

    CMP operationLast, '+'
    JGE doWork
    
    MOV operationLast, AH  
    MOV AX, numberBuffer  
    MOV numberLast, AX     
    MOV numberBuffer, 0 
    JMP endLoad
    
    doWork:        
    PUSH BX
    MOV AX, numberLast 
    
    CMP operationLast, '*' 
    JE doMul
    CMP operationLast, '/' 
    JE doDiv
    CMP operationLast, '+' 
    JE doAdd
    CMP operationLast, '-' 
    JE doSub    

    doMul:
        MOV DX, offset pathMul
        JMP load     
    doDiv: 
        MOV DX, offset pathDiv  
        JMP load
    doAdd:
        MOV DX, offset pathAdd
        JMP load         
    doSub:
        MOV DX, offset pathSub 
        JMP load    
    load: 
    
    PUSH AX  
    MOV CX, numberBuffer    

    CMP flagFirst, 1         
    MOV flagFirst, 0         
    JE  controlOperation       
    PUSH AX                  
    MOV AL, operationLast    
    CMP AL, flagOperation    
    MOV flagOperation, AL    
    POP AX                   
    JE endControlOperation    

    controlOperation:          
    MOV BX, offset EPB 
    MOV AX, 4B03h 
    INT 21h
    JC errorMem
    JMP endControlOperation
    
    errorMem:
    LEA DX, errorMemory
    call cout
    .exit 
       
    
    endControlOperation:       
    POP AX
    CALL DWORD PTR overlayOffset       
    POP BX
    MOV numberLast, AX 
    MOV operationLast, BH   
    MOV numberBuffer, 0
    
    endLoad:  
       
    RET
loadOverlay ENDP

cout PROC

    PUSH AX   
    PUSH DX
    LEA DX, endl  
    MOV AH, 09h                               
    INT 21h 
   
    POP DX
    MOV AH, 09h                               
    INT 21h  
    POP AX
     
    RET
cout ENDP    

start:

MOV	AX, @DATA                       

XOR CH, CH	
MOV CL, DS:[80h]	
CMP CL, 0 
JE emptyCMD_	
MOV SI, 82h		        
LEA DI, stringBuffer
REP MOVSB

MOV DS, AX
JMP main

emptyCMD_:	
LEA DX, errorEmptyCMD
CALL cout 
.exit

main:
MOV AX, markSegment
MOV DX, ES 

SUB AX, DX 
MOV BX, AX
MOV AH, 4Ah
INT 21h        
 
MOV AH, 48h  
MOV BX, 1000h      
INT 21h     
 
MOV EPB, AX  
MOV EPB+2, AX 
MOV overlaySegment, AX 
MOV AX, DS
MOV ES, AX                  
MOV BL, 1  

firstLoop:       
    CLD               
    LODSB              
    CMP AL, 0Dh
    JE calculate
    XOR BH, BH
    CALL controlSymbol 
    secondLoop: 
        CMP AL, '/'
        JE controlZero
        JNE norm
        controlZero:
        CMP [DI], '0'
        JE divideZero
        JNE norm
        norm:
        CMP [DI], '+'
        JE toStack
        CMP [DI], '-'
        JE toStack
        JMP secondLoop
        toStack:
        PUSH AX
        PUSH [DI]
        JMP secondLoop  
        divideZero:
        LEA DX, errorZero
        CALL cout 
        .EXIT
    loop secondLoop
    POP AX
    CMP BH, 2
    JGE controlError
    PUSH AX
    MOV AX, numberBuffer
    MUL BL         
    MOV numberBuffer, AX
    POP AX              
    
    SUB AL, '0'
    XOR AH, AH
    ADD numberBuffer, AX
    
    MOV AL, BL          
    MOV BL, 10             
    MUL BL
    MOV BL, AL      
    
    controlError:        
    CMP AH, 1
    JE errorEnter
    
    JMP xorAH
            
errorEnter:      
    LEA DX, errorBadParametrs
    CALL cout
    .EXIT             
calculate:
    CALL loadOverlay
    JMP result    
xorAH:
    XOR AH, AH    

loop firstLoop    
   
result: 
    MOV AX, numberLast 
    CALL coutNumber      
    .EXIT

markSegment SEGMENT
markSegment ENDS   
END start 