       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TRXN-WRITER-SIMPLE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRXN-FILE ASSIGN TO WS-FILE-PATH
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       *> File Schema (Copybook) section starts here
       FD  TRXN-FILE.
       01  TRXN-REC.
           05 TRXN-ID     PIC 9(9)       COMP-3.    *> 9 digits packed integer => 5 bytes
           05 TRXN-DT     PIC X(8).                 *> YYYYMMDD text (ASCII here)
           05 TRXN-TM     PIC X(6).                 *> HHMMSS   text (ASCII here)
           05 TRXN-AMNT   PIC S9(7)V99   COMP-3.    *> signed amount => 5 bytes
       *> File Schema (Copybook) section ends here 

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS   PIC XX.
       01  WS-ARG-COUNT     PIC 9(4).
       01  WS-ARG           PIC X(200).

       01  WS-ID-N          PIC 9(9).
       01  WS-AMNT-N        PIC S9(7)V99.

       01  WS-DT            PIC X(8).
       01  WS-TM            PIC X(6).

       01  WS-FILE-PATH     PIC X(200).
       01  WS-MODE          PIC X(1).   *> 'R' = rewrite, 'A' = append

       PROCEDURE DIVISION.
       MAIN.

           ACCEPT WS-ARG-COUNT FROM ARGUMENT-NUMBER

           IF WS-ARG-COUNT < 6
               DISPLAY "Usage:"
               DISPLAY "  ./trxn_writer_simple <TRXN_ID> <TRXN_DT> <TRXN_TM> <TRXN_AMNT> <FILE_NAME> <MODE>"
               DISPLAY "Where MODE = R (rewrite) or A (append)"
               DISPLAY "Example:"
               DISPLAY "  ./trxn_writer_simple 000000001 20251220 213010 -250.75 ./TRXN_COBOL_DATA R"
               STOP RUN
           END-IF

           *> Arg1: TRXN_ID (digits)
           ACCEPT WS-ARG FROM ARGUMENT-VALUE
           COMPUTE WS-ID-N = FUNCTION NUMVAL(WS-ARG)

           *> Arg2: TRXN_DT (YYYYMMDD)
           ACCEPT WS-ARG FROM ARGUMENT-VALUE
           MOVE WS-ARG(1:8) TO WS-DT

           *> Arg3: TRXN_TM (HHMMSS)
           ACCEPT WS-ARG FROM ARGUMENT-VALUE
           MOVE WS-ARG(1:6) TO WS-TM

           *> Arg4: TRXN_AMNT (e.g. -250.75)
           ACCEPT WS-ARG FROM ARGUMENT-VALUE
           COMPUTE WS-AMNT-N = FUNCTION NUMVAL(WS-ARG)

           *> Arg5: FILE_NAME
           ACCEPT WS-ARG FROM ARGUMENT-VALUE
           MOVE WS-ARG TO WS-FILE-PATH

           *> Arg6: MODE
           ACCEPT WS-ARG FROM ARGUMENT-VALUE
           MOVE WS-ARG(1:1) TO WS-MODE

           *> Build record
           MOVE WS-ID-N   TO TRXN-ID
           MOVE WS-DT     TO TRXN-DT
           MOVE WS-TM     TO TRXN-TM
           MOVE WS-AMNT-N TO TRXN-AMNT

           *> Open with rewrite/append behaviour
           IF WS-MODE = "A" OR WS-MODE = "a"
               OPEN EXTEND TRXN-FILE
               IF WS-FILE-STATUS NOT = "00"
                   OPEN OUTPUT TRXN-FILE
               END-IF
           ELSE
               OPEN OUTPUT TRXN-FILE
           END-IF

           WRITE TRXN-REC
           CLOSE TRXN-FILE

           STOP RUN.
