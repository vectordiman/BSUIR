.MODEL TINY
ORG 100h 

sizeRezident EQU start - $
screenEnd EQU 0FA0h
screenBegin EQU 0B800h
JMP start
rezidentFlag DB "flag"

messageReset DB 10, 13, "Interrupts was reseted", 10, 13
sizeMessageReset  EQU 24
messageFound DB 10, 13, "String was founded", 10, 13
sizeMessageFound EQU 20
errorCMD DB 0
messageErrorCMD DB "Bad parametrs", '$'                                                         
messageEnd DB "Shift+S) Find string", 10, 13, "Shift+R) Reset old interrupts",  '$'
messageAlready DB "Attempt to run the program more than once", '$'
endl DB 10, 13, '$'

foundFlag DB 0
old_x0 dd ?
old_x1 dd ?

buffer DB ?
saveFlag DB 0
resetFlag DB 0

string DB 126 dup (0)
pathFile DB "F000.txt", 0
counterFile DW 0
descriptorFile DW 0
stringSize DW 4
pointCursor DW 0

getVector MACRO oldHandler
  	MOV AH, 35h
    INT 21h
    MOV WORD PTR oldHandler, BX
    MOV WORD PTR oldHandler + 2, ES
ENDM

setVector MACRO newHandler
  	MOV AH, 25h
    MOV DX, OFFSET newHandler
    INT 21h       
ENDM

coutString MACRO string
  	MOV AH, 09h
	MOV DX, OFFSET string
	INT 21h       
ENDM

cout MACRO string
    coutString string
    coutString endl 
ENDM

puts MACRO string size 
    MOV AH, 03h
    MOV BH, 0
    INT 10h
    
    MOV AH, 13h
    MOV AL, 1
    MOV BH, 0
    MOV BL, 07h
    MOV CX, size
    LEA BP, string
    INT 10h 
ENDM

fileCloser MACRO file
    MOV BX, file
    MOV AH, 3Eh  
    INT 21h   
ENDM

filePathCreater MACRO
    MOV AX, counterFile
    MOV DL, 100
    DIV DL
    ADD AL, '0'
    MOV pathFile + 1, AL
    MOV AL, AH
    XOR AH, AH
    MOV DL, 10
    DIV DL
    ADD AL, '0'
    ADD AH, '0'
    MOV pathFile + 2, AL
    MOV pathFile + 3, AH
ENDM

newHandler_x0 PROC FAR
    PUSHA
    PUSH DS
    PUSH ES
    
    MOV AX, CS
    MOV DS, AX
    
    MOV foundFlag, 0
    
    CMP resetFlag, 1
    JNE dontReset
    
    MOV AH, 25h
    MOV AL, 08h    
    MOV DX, CS:old_x0
    MOV DS, CS:old_x0 + 2
    INT 21h
    
    MOV AH, 25h
    MOV AL, 09h    
    MOV DX, CS:old_x1
    MOV DS, CS:old_x1 + 2
    INT 21h
    
    MOV AX, CS
    MOV ES, AX
    puts messageReset sizeMessageReset 
    JMP end_x0

    dontReset:
    MOV AX, screenBegin
    MOV ES, AX
    MOV pointCursor, 0
    
    findLoop_0:
    XOR CX, CX
    MOV DI, pointCursor
    LEA SI, string
    
    findLoop_1:
    MOV BL, ES:DI
    CMP BL, [SI]
    JNE dontFound:
    ADD DI, 2
    SHR DI, 1
    MOV BX, pointCursor
    SHR BX, 1
    ADD BX, stringSize
    CMP DI, BX
    JE found
    SHL DI, 1
    INC SI
    JMP findLoop_1
    
    found:
    
    CMP saveFlag, 1
    JNE dontSave
    
    CALL findString
    MOV foundFlag, 1

    dontSave:
    MOV CX, stringSize
    MOV DI, pointCursor
    saveLoop:
    ADD DI, 2
    LOOP saveLoop
    MOV AX, stringSize
    SHL AX, 1
    ADD pointCursor, AX
    JMP controlLoop
    
    dontFound:
    MOV DI, pointCursor 
    INC DI
    ADD pointCursor, 2
    
    controlLoop:
    
    CMP pointCursor, screenEnd
    JB findLoop_0
    
    end_x0:
    MOV saveFlag, 0
    
    CMP foundFlag, 1
    JNE dontFoundScreen
    MOV AX, CS
    MOV ES, AX
    puts messageFound sizeMessageFound 
    dontFoundScreen:
    
    PUSHF
    CALL CS:DWORD PTR old_x0
    
    POP ES
    POP DS
    POPA
    IRET
newHandler_x0 ENDP

newHandler_x1 PROC FAR
    PUSHA
    
    PUSHF
    CALL CS:DWORD PTR old_x1
    
    MOV AH, 01h     ; kbhit
    INT 16h
    MOV BH, AH
    JZ dontPressKey
    MOV AH, 02h
    INT 16h
    AND AL, 2       ;shift
    CMP AL, 0
    JE dontPressKey
    CMP BH, 1Fh     ;S
    JNE notKeyS
    MOV CS:saveFlag, 1
    MOV AH, 00h
    INT 16h
    notKeyS:
    CMP BH, 13h     ; R
    JNE dontPressKey
    MOV CS:resetFlag, 1
    MOV AH, 00h
    INT 16h
    dontPressKey:
    
    POPA 
    IRET 
newHandler_x1 ENDP

findString PROC
    PUSHA
    PUSH DI
    PUSH SI
    MOV AH, 34h   ;бит занятости dos
    INT 21h
    CLI
    
    MOV AL, ES:BX
    DEC BX
    MOV AH, ES:BX
    CMP AL, 0
    JNE endFindScreen
    CMP AH, 0
    JNE endFindScreen
    
    MOV AX, screenBegin
    MOV ES, AX
    
    MOV counterFile, 0
    
    openFindLoop:
    filePathCreater
    LEA DX, pathFile
    XOR CX, CX
    MOV AH, 5Bh
    INT 21h
    JNC normalFile

    INC counterFile
    CMP AX, 50h
    JE openFindLoop
    
    normalFile:
    MOV descriptorFile, AX
    
    MOV AX, pointCursor
    MOV BL, 160
    DIV BL
    XOR AH, AH
    MUL BL
    MOV DI, AX 
    MOV CX, 80     
    
    writeScreenLoop:
    
    MOV BX, descriptorFile
    MOV AH, 40h
    PUSH CX
    MOV CL, ES:DI
    MOV buffer, CL
    LEA DX, buffer
    MOV CX, 1
    INT 21h   
    POP CX 
    
    ADD DI, 2
    CMP DI, screenEnd
    JAE writeScreenLoopEnd
    
    LOOP writeScreenLoop
     
    writeScreenLoopEnd:
    
    fileCloser descriptorFile
        
    endFindScreen:
    STI
    POP SI
    POP DI
    POPA
    RET
findString ENDP

start:
    CALL controlCMD
    
    MOV AL, 08h
    getVector old_x0
    
    LEA DI, rezidentFlag      
    LEA SI, rezidentFlag
    MOV CX, 4
    REPE CMPSB
    JE runAlready
    
    CMP errorCMD, 1
    JE errorCMDExit
   
    MOV AL, 08h
    setVector newHandler_x0 

    MOV AL, 09h
    getVector old_x1

    MOV AL, 09h
    setVector newHandler_x1
    
    cout messageEnd
    MOV AX, 3100h
    MOV DX, (sizeRezident + 100h) / 16 + 1
    INT 21h
    
    errorCMDExit:
    cout messageErrorCMD
    JMP endProgram:

    runAlready:
    cout messageAlready

    endProgram:
    .EXIT                  

controlCMD PROC
    MOV SI, 80h
    LEA DI, string
    LODSB
    
    skipSpacesCMD:
    LODSB
    CMP AL, ' '
    JE skipSpacesCMD
    
    CMP AL, 0dh
    JE errorCMD_
    
    MOV ES:DI, AL
    INC DI
    
    controlCMDLoop:
    LODSB
    CMP AL, ' '
    JE endReadCMD
    CMP AL, 0dh
    JE endReadCMD
    MOV ES:DI, AL
    INC DI
    JMP controlCMDLoop
    
    errorCMD_:
    MOV errorCMD, 1
    
    endReadCMD:
    SUB DI, OFFSET string
    MOV stringSize, DI
       
	RET	
ENDP  
        
END start