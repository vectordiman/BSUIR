.model smALl
.stack 100h

.data 

messageErrorClose db "Error: Close", 0Dh, 0Ah, '$'
messageErrorSetPointer db "Error: Set pointer", 0Dh, 0Ah, '$'
messageErrorNumberWrite db "Error: Write", 0Dh, 0Ah, '$'
messageErrorTempToEnd db "Error: Add temp to end", 0Dh, 0Ah, '$'
messageErrorArguments db "Error: Bad arguments", 0Dh, 0Ah, '$'
messageErrorRead db "Error: Read", 0Dh, 0Ah, '$'
messageErrorOpen db "Error: Open", 0Dh, 0Ah, '$'
messageErrorDelete db "Error: Delete", 0Dh, 0Ah, '$'
messageErrorBadId db "Error: Bad id", 0Dh, 0Ah, '$'
messageErrorFileNotFound db "Error: File not found", 0Dh, 0Ah, '$'
messageErrorPathNotFound db "Error: Path not found", 0Dh, 0Ah, '$'
messageErrorIncorrectMode db "Error: Incorrect mode", 0Dh, 0Ah, '$'
messageErrorAccessDenied db "Error: Access denied", 0Dh, 0Ah, '$'
messageErrorManyFiles db "Error: Many opened files", 0Dh, 0Ah, '$'

messageEmpty db '$'
messageNewLine db 0Dh, 0Ah, '$'
messageBegin db "Begin", 0Dh, 0Ah, '$'
messageEnd db "End", 0Dh ,0Ah, '$'
_0Ah db 0Ah

sizeCommandLineMAX  equ 126
sizeCommandLine db ?
bufferCommandLine db sizeCommandLineMAX dup(?)

bufferDelete db 50 dup('$')
sizeBufferDelete db ?
deleteSymbols db 50 dup(0)
sizeDeleteSymbols db ?

_0DhSymbol equ 0Dh
_0AhSymbol equ 0Ah
spaceSymbol equ 20h
tabSymbol equ 09h 

TempFileFLAG db 0
DeletedFLAG db 0
Skip_0AhFLAG db 0
keepControlFLAG db 0
Write_0AhFLAG db 0 
DelimFLAG db 0
KeepDeleteFLAG db 0
SetPositionFLAG db 0
errorFLAG db 0

tempFile dw 0
tempFilePath db "f:\temporary.txt", 0

startFile dw 0
startFilePath db 50 dup(0)

endFile dw 0
endFilePath db 50 dup(0)

sizeBufferMAX equ 1000
tempBuffer db sizeBufferMAX dup ('$')
sizeTempBuffer dw ?
bufferPointer dw ?
sizeBuffer dw ?
buffer db sizeBufferMAX + 1 dup('$')

.code

source:
    MOV AX, @data
    MOV ES, AX
    XOR CX, CX
    MOV CL, DS:[80h]
    MOV BX, CX
    MOV SI, 81h
    MOV DI, offset bufferCommandLine
    REP MOVSB 
    
    MOV DS, AX

    PUSH DX 
    MOV DX, offset messageEmpty
    CALL cout  
    POP DX

    PUSH DX 
    MOV DX, offset messageNewLine
    CALL cout  
    POP DX

    PUSH DX 
    MOV DX, offset messageBegin
    CALL cout  
    POP DX

    MOV sizeCommandLine,BL
    CALL findCommandLine
    CMP errorFLAG, 1
    JE sourceEnd

    CALL startAndEndOpener
    CMP errorFLAG, 1
    JE sourceEnd
    
    CALL fileProcesser
    MOV BX, startFile
    CALL fileCloser
    CMP errorFLAG, 1
    JE sourceEnd

    MOV BX, endFile
    CALL fileCloser
    CMP errorFLAG, 1
    JE sourceEnd
    CMP TempFileFLAG, 1
    JNE sourceEnd
    MOV BX, tempFile
    CALL fileCloser              
    CMP errorFLAG, 1
    JE sourceEnd    
sourceEnd:
    PUSH DX 
    MOV DX, offset messageEnd
    CALL cout 
    POP DX
    .EXIT

findCommandLine PROC
    PUSH CX
    PUSH SI
    PUSH DI
    PUSH BX
    MOV errorFLAG, 0
    XOR CX, CX
    MOV CL, sizeCommandLine
    MOV SI, offset bufferCommandLine
    MOV DI, offset startFilePath
    CALL findArguments  

    MOV DI, offset endFilePath
    CALL findArguments

    MOV DI, offset deleteSymbols
    CALL findArguments
    MOV sizeDeleteSymbols, BL
    CMP CX, 0
    JE findCommandLineEnd
    PUSH DX 
    MOV DX, offset messageErrorArguments 
    CALL cout
    POP DX
    MOV errorFLAG, 1
findCommandLineEnd:
    POP BX
    POP DI
    POP SI
    POP CX
    RET
ENDP findCommandLine

controlBuffer PROC
    XOR BX, BX
    CMP keepDeleteFLAG, 1
    JNE controlBufferOne
    MOV DelimFLAG, 1
controlBufferOne:
    MOV SI, bufferPointer
    XOR DI, DI
    MOV CX, sizeBuffer         ;quantity of symbols that were readed
    XOR AX, AX
deleteControl:
    LODSB
    CMP DelimFLAG, 0
    JNE control_0Dh
    CALL controlDelete     
control_0Dh:    
    CMP AL, _0DhSymbol
    JE controlSetPositionMark
    
    LOOP deleteControl

    CMP DelimFLAG, 1
    JE setKeepDelete
    MOV BX, sizeBuffer
    CMP TempFileFLAG, 1
    JE OneControlBufferEnd
    MOV TempFileFLAG, 1
    PUSH BX
    CALL TemporaryFileOpener     
    POP BX
OneControlBufferEnd:    
    JMP controlBufferEnd
_setKeepDeleteFlagOne:
    JMP setKeepDeleteFlagOne    
setKeepDelete:    
    MOV KeepDeleteFLAG, 1

    JMP controlBufferEnd
controlSetPositionMark:
    CMP CX, 1h
    JNE _toControlSetPosition
    MOV Write_0AhFLAG, 1
_toControlSetPosition:    
    MOV BX, sizeBuffer
    SUB BX, CX
    CALL controlSetPosition            ; sets proper BX and SetPositionFLAG
    
    CMP TempFileFLAG, 0
    JE _setKeepDeleteFlagOne
    MOV TempFileFLAG, 0

    CMP KeepDeleteFLAG, 1
    JE _deleteTemp

    CMP DelimFLAG, 1
    JE _deleteTemp
    CMP Write_0AhFLAG, 1
    JNE _controlFlush
    DEC BX 
_controlFlush:
    MOV CX, BX               ; + control CLose that flushes
    MOV BX, tempFile
    MOV DX, bufferPointer
    CALL fileWriter
    CMP errorFLAG, 1
    JE OneControlBufferEnd

    CMP Write_0AhFLAG, 1
    JNE _closeTemporary
    PUSH BX
        MOV CX, 1h
        MOV BX, tempFile
        MOV DX, offset _0Ah
        MOV AH, 40h          
        INT 21h
        JB controlBufferEnd
        MOV Skip_0AhFLAG,1
        MOV Write_0AhFLAG,0
    POP BX
_closeTemporary:
    PUSH BX
    MOV BX, tempFile
    CALL fileCloser
    POP BX
    CMP errorFLAG, 1
    JE controlBufferEnd
    
    CALL cloneTemporaryToEnd
    CMP errorFLAG, 1
    JE controlBufferEnd
_deleteTemp:
    PUSH BX
    MOV BX, tempFile
    CALL fileCloser
    POP BX
    CMP errorFLAG, 1
    JE controlBufferEnd
    
    PUSH BX
    MOV DX, offset tempFilePath
    CALL fileDeleter
    POP BX
    MOV DelimFLAG, 0
    CMP errorFLAG, 1
    JE controlBufferEnd
setKeepDeleteFlagOne:
    MOV KeepDeleteFLAG, 0
controlBufferEnd:
    RET 
ENDP controlBuffer

fileReader PROC
    MOV AH, 3Fh      ;read file
    INT 21h
    JB _fileReaderErr
    JMP _fileReaderEnd
_fileReaderErr:
    MOV errorFLAG, 1
    PUSH DX 
    MOV DX, offset messageErrorRead
    CALL cout 
    POP DX
    JMP _fileReaderEnd
_fileReaderEnd:    
    RET
ENDP fileReader

fileWriter PROC        ; input: BX - num to write
    PUSH CX             ; output: DX -1 if error, AX -err code              
    MOV AH, 40h        ;write file  
    INT 21h
    POP BX
    CMP AX, BX
    JE _fileWriterEnd
    PUSH DX 
    MOV DX, offset messageErrorNumberWrite 
    CALL cout 
    POP DX
    MOV errorFLAG, 1  
_fileWriterEnd: 
    RET
ENDP fileWriter

fileCloser PROC
    XOR AX, AX
    MOV AH, 3eh    ;close file
    INT 21h
    JB _errfileCloser
    JMP _fileCloserEnd
_errfileCloser:
             
    PUSH DX 
    MOV DX, offset messageErrorClose
    CALL cout
    POP DX
    MOV errorFLAG, 1
_fileCloserEnd:
  
    RET
ENDP fileCloser

fileDeleter PROC 
    MOV AH, 41h   ;delete file
    INT 21h
    JB _errDeleteTemporary
    MOV DeletedFLAG, 1
    JMP _fileDeleterEnd
_errDeleteTemporary:
    PUSH DX 
    MOV DX, offset messageErrorDelete      
    CALL cout  
    POP DX
    MOV errorFLAG, 1
_fileDeleterEnd:
    RET
ENDP fileDeleter

cloneTemporaryToEnd PROC
    PUSH BX
    MOV AH, 3Dh		;open existing file	
    MOV AL, 20h			
    MOV DX, offset tempFilePath
    MOV CL, 01h			
    INT 21h
    JB controlBufferEnd	
    MOV tempFile, AX	

    MOV BX, tempFile
    XOR AL, AL 			
    XOR CX, CX
    XOR DX, DX			
    CALL setFilePointer
    CMP errorFLAG, 1
    JE cloneTemporaryToEndEnd
    MOV sizeTempBuffer, sizeBufferMAX
loopWriteTemporaryToEnd:

    MOV BX, tempFile
    MOV CX, sizeTempBuffer
    MOV DX, offset tempBuffer
    CALL fileReader
    CMP errorFLAG, 1
    JE _errCloneTemporaryToEnd
    CMP AX, 0000h
    JBE cloneTemporaryToEndEnd
    MOV sizeTempBuffer, AX

    MOV CX, sizeTempBuffer
    MOV BX, endFile
    MOV DX, offset tempBuffer
    CALL fileWriter
    CMP errorFLAG, 1
    JE _errCloneTemporaryToEnd
    JMP loopWriteTemporaryToEnd

    JMP cloneTemporaryToEndEnd
_errCloneTemporaryToEnd:
    PUSH DX 
    MOV DX, offset messageErrorTempToEnd
    CALL cout
    POP DX
cloneTemporaryToEndEnd:
    POP BX
    RET
ENDP cloneTemporaryToEnd

TemporaryFileOpener PROC
    MOV AH, 3Ch     ;create file
    MOV CX, 00h			    
    MOV DX, offset tempFilePath
    INT 21h
    JB _errorTemporaryOpen
    MOV tempFile, AX

    MOV BX, tempFile
    XOR AL, AL 			
    XOR CX, CX
    XOR DX, DX			
    CALL setFilePointer
    CMP errorFLAG, 1
    JE _errorTemporaryOpen
    JMP TemporaryFileOpenerEnd
_errorTemporaryOpen:
    MOV errorFLAG, 1
    CMP AX, 03h 
    JE TemporaryPath
    CMP AX, 04h
    JE TemporaryManyFiles
    CMP AX, 05h
    JE TemporaryAccessDenied
    CMP AX, 06h
    JE TemporaryId
    PUSH DX 
    MOV DX, offset messageErrorOpen 
    CALL cout
    POP DX
    JMP TemporaryFileOpenerEnd
TemporaryId:    
    PUSH DX 
    MOV DX, offset messageErrorBadId 
    CALL cout
    POP DX
    JMP TemporaryFileOpenerEnd
TemporaryPath:
    PUSH DX 
    MOV DX, offset messageErrorPathNotFound 
    CALL cout
    POP DX
    JMP TemporaryFileOpenerEnd
TemporaryManyFiles:
    PUSH DX 
    MOV DX, offset messageErrorManyFiles 
    CALL cout
    POP DX
    JMP TemporaryFileOpenerEnd
TemporaryAccessDenied:
    PUSH DX 
    MOV DX, offset messageErrorAccessDenied 
    CALL cout
    POP DX
TemporaryFileOpenerEnd:    
    RET
ENDP TemporaryFileOpener

controlSetPosition PROC
    ADD BX, 2
    CMP DelimFLAG, 1
    JE controlSetPosition_
    JMP controlSetPositionEnd
controlSetPosition_:
    CMP BX, 2
    JBE controlSetPositionEnd
    MOV SetPositionFLAG, 1
controlSetPositionEnd:
    RET
ENDP controlSetPosition

cloneDeleteToBufferDelete PROC     
    PUSH CX
    PUSH SI
    PUSH DI
    PUSH AX
    XOR DI, DI
    XOR CX, CX
    MOV SI, offset deleteSymbols
    MOV CL, sizeDeleteSymbols
    XOR AX, AX
loopCloneDelete:    
    LODSB 
    MOV bufferDelete[DI], AL
    INC DI
    CMP AL, 0000h
    JE cloneDeleteToBufferEnd
    LOOP loopCloneDelete 
cloneDeleteToBufferEnd:
    XOR CX, CX
    MOV CL, sizeDeleteSymbols
    MOV sizeBufferDelete, CL
    POP AX    
    POP DI
    POP SI
    POP CX
    RET
ENDP cloneDeleteToBufferDelete

moveBuffer PROC          ; input: CX - current pos
    PUSH DI             ; procedure sets new sizeBufferDelete
    PUSH SI
    PUSH DX
    PUSH CX

    MOV DI, offset bufferDelete
    MOV SI, DI
    XOR DX, DX
    MOV DL, sizeBufferDelete
    SUB DX, CX 
    ADD DI, DX
    INC DX
    ADD SI, DX
    REP MOVSB
    DEC sizeBufferDelete

    POP CX
    POP DX
    POP SI
    POP DI
    RET 
ENDP moveBuffer

controlDelete PROC           
    PUSH CX                 ; input: AL -symbol to be controled
    PUSH DI                  
    PUSH AX                 ; output: keepcontrolFLAG, DelimFLAG
    CMP keepControlFLAG, 1     
    JE _keepControl            
    CALL cloneDeleteToBufferDelete   
_keepControl:
    XOR DI, DI
    XOR CX, CX
    MOV CL, sizeBufferDelete
deleteControlSymbol:
    CMP AL, bufferDelete[DI]
    JNE noDeleteSymbol
    CALL moveBuffer    
noDeleteSymbol:
    INC DI
    LOOP deleteControlSymbol

    CMP sizeBufferDelete, 0000h
    JNE setKeepControlFLAG
    MOV DelimFLAG, 1
    MOV keepControlFLAG, 0

    JMP controlDeleteEnd
setKeepControlFLAG:
    MOV keepControlFLAG, 1
    MOV DelimFLAG, 0
controlDeleteEnd:
    POP AX
    POP DI 
    POP CX
    RET
ENDP controlDelete

setFilePointer PROC

    MOV AH, 42h     ;set file pointer
    INT 21h
    JB _errSetFilePtr
    
    JMP _setFilePointerEnd
_errSetFilePtr:
    PUSH DX 
    MOV DX, offset messageErrorSetPointer 
    CALL cout
    POP DX
    MOV errorFLAG, 1
_setFilePointerEnd:
    RET
ENDP setFilePointer

fileProcesser PROC

    MOV BX, startFile
    XOR AL, AL 			
    XOR CX, CX
    XOR DX, DX			
    CALL setFilePointer   
    CMP errorFLAG, 1
    JE _ProcessFileEnd
    
    MOV BX, endFile
    XOR AL, AL 			
    XOR CX, CX
    XOR DX, DX			
    CALL setFilePointer
    CMP errorFLAG, 1
    JE _ProcessFileEnd

    JMP readLoop
_ProcessFileEnd:
    JMP processFileEnd
_EndOfFile:
    JMP endOfFile
readLoop:
    MOV sizeBuffer, sizeBufferMAX
    MOV bufferPointer, offset buffer

    MOV BX, startFile
    MOV CX, sizeBufferMAX
    MOV DX, bufferPointer
    CALL fileReader    
    CMP errorFLAG, 1
    JE _ProcessFileEnd
    MOV sizeBuffer, AX
    CMP Skip_0AhFLAG, 1
    JNE controlAx
    MOV Skip_0AhFLAG, 0
    DEC sizeBuffer
    INC bufferPointer
controlAx:
    CMP AX, 0000h
    ja controlBufferer
    CMP TempFileFLAG, 1
    JNE _EndOfFile
    CMP KeepDeleteFLAG, 1
    JE _last_close

    CMP DelimFLAG, 1
    JE _last_close

    MOV BX, tempFile
    CALL fileCloser
    CMP errorFLAG, 1
    JE _ProcessFileEnd
    CALL cloneTemporaryToEnd
_last_close: 
    MOV TempFileFLAG, 0
    MOV BX, tempFile
    CALL fileCloser
    CMP errorFLAG, 1
    JE ___ProcessFileEnd
    MOV DX, offset tempFilePath
    CALL fileDeleter
    CMP errorFLAG, 1
    JE ___ProcessFileEnd  

    JMP _EndOfFile
controlBufferer:
    MOV DelimFLAG, 0
    MOV SetPositionFLAG, 0
    CALL controlBuffer          ; flags setPos, KeepDelete, Delim, BX - new pos
    CMP errorFLAG, 1
    JE ___ProcessFileEnd
    CMP TempFileFLAG, 1
    JE writeT_
    CMP KeepDeleteFLAG, 1
    JE __ReadLoop
    CMP DelimFLAG, 0
    JE writeE_
    CMP SetPositionFLAG, 1
    JE __setNewPos
    JMP readLoop
___ProcessFileEnd:
    JMP ProcessFileEnd    
__ReadLoop:
    JMP readLoop
__setNewPos:
    JMP setNewPos
writeT_:
    MOV CX, BX  
    MOV DX, bufferPointer  
    MOV BX, tempFile
    CALL fileWriter
    CMP errorFLAG, 1
    JE __processFileEnd           
    JMP readLoop
writeE_:
    CMP DeletedFLAG, 1          ; sign that last line was processed ALready
    JE _SetNewPos
    CMP Write_0AhFLAG, 1
    JNE wtd
    DEC BX 
    wtd:
    MOV CX, BX
    MOV BX, endFile
    MOV DX, bufferPointer
    CALL fileWriter
    CMP errorFLAG, 1
    JE __processFileEnd

    CMP Write_0AhFLAG, 1
    JNE controlNext
    PUSH BX
        MOV CX, 1h
        MOV BX, endFile
        MOV DX, offset _0Ah
        MOV AH, 40h          
        INT 21h
        JB __processFileEnd
        MOV Skip_0AhFLAG, 1
        MOV Write_0AhFLAG, 0
    POP BX
controlNext:
    CMP BX, sizeBufferMAX
    JE _readLoop
    JMP setNewPos
__processFileEnd:    
    JMP processFileEnd
_readLoop:
    JMP readLoop
_SetNewPos:
    MOV DeletedFLAG, 0
setNewPos:
    ADD bufferPointer, BX 
    SUB sizeBuffer, BX
    CMP sizeBuffer, 0000h
    JE bufferEnded               
    JMP controlBufferer 
bufferEnded:  
    JMP readLoop
endOfFile:
processFileEnd:
    RET 
ENDP fileProcesser

startAndEndOpener PROC
    MOV AH, 3Dh		;open existing file	
    MOV AL, 20h			
    MOV DX, offset startFilePath
    MOV CL, 01h			
    INT 21h
    JB _openErr	
    MOV startFile, AX	

    MOV AH, 3Ch    ;create file
    MOV CX, 00h			    
    MOV DX, offset endFilePath
    INT 21h
    JB _openErr	
    MOV endFile, AX

    JMP _openEnd
_openErr:
    MOV errorFLAG, 1
    CMP AX, 02h
    JE _noFile
    CMP AX, 03h
    JE _noPath
    CMP AX, 04h
    JE _manyFiles
    CMP AX, 05h
    JE _denied
    CMP AX, 0Ch
    JE _incorrect
_noFile:
    PUSH DX 
    MOV DX, offset messageErrorFileNotFound 
    CALL cout
    POP DX
    JMP _openEnd
_noPath:
    PUSH DX 
    MOV DX, offset messageErrorPathNotFound 
    CALL cout
    POP DX
    JMP _openEnd
_manyFiles:
    PUSH DX 
    MOV DX, offset messageErrorManyFiles 
    CALL cout
    POP DX
    JMP _openEnd
_denied:
    PUSH DX 
    MOV DX, offset messageErrorAccessDenied 
    CALL cout
    POP DX
    JMP _openEnd
_incorrect:
    PUSH DX 
    MOV DX, offset messageErrorIncorrectMode 
    CALL cout
    POP DX
    JMP _openEnd
_openEnd:  
    RET
ENDP startAndEndOpener

findArguments PROC
    PUSH AX
    MOV BX, 0
    CALL spaceSkipper
    DEC CX
loopArguments:    
    MOV ES:[DI], AL
    INC BX
    INC DI
    INC SI
    DEC CX

    MOV AL, DS:[SI]
    CMP AL,0
    JE findArgumentsEnd

    CMP AL, spaceSymbol     
    JE findArgumentsEnd

    CMP AL, tabSymbol
    JE findArgumentsEnd

    CMP AL, _0DhSymbol
    JE findArgumentsEnd

    CMP AL, _0AhSymbol
    JE findArgumentsEnd

    JMP loopArguments
findArgumentsEnd:
    POP AX
    RET
ENDP findArguments

spaceSkipper PROC
loopSkip:
    MOV AL, DS:[SI]
    CMP AL, spaceSymbol     
    JE skip

    CMP AL, tabSymbol
    JE skip

    CMP AL, _0DhSymbol
    JE skip

    CMP AL, _0AhSymbol
    JE skip
    JMP spaceSkipperEnd
skip:
    INC SI
    JMP loopSkip
spaceSkipperEnd:    
    RET 
ENDP spaceSkipper

cout PROC
    PUSH BX
    PUSH CX
    PUSH AX
    PUSH DI 
    MOV SI, DX
    
coutLoop:

    MOV CX, 0001h  
    MOV BX, 1
    MOV AH, 40h
    INT 21h

    LODSB
    CMP AL, '$'
    JE coutEnd 
    MOV DX, SI

    JMP coutLoop

coutEnd:
    POP DI 
    POP AX
    POP CX
    POP BX
    RET
ENDP cout

end source
