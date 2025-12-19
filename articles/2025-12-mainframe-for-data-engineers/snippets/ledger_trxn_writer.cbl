       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LEDGER-TRXN-WRITER.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRXN-FILE ASSIGN TO WS-FILE-PATH
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       *> File Schema(Copybook) Section Starts
       FD  TRXN-FILE.
       01  TRXN-REC.
           05 TRXN-ID         PIC X(10).
           05 ACCT-ID         PIC X(10).
           05 TRXN-AMT        PIC S9(7)V99 COMP-3.
           05 TRXN-TYPE       PIC X(1).

           05 TRXN-DATE       PIC 9(8).   *> YYYYMMDD (event date)
           05 TRXN-TIME       PIC 9(6).   *> HHMMSS   (event time)

           05 POST-DATE       PIC 9(8).   *> YYYYMMDD (posting date)
           05 POST-TIME       PIC 9(6).   *> HHMMSS   (posting time)

           05 CURRENCY-CODE   PIC X(3).
           05 CHANNEL-CODE    PIC X(3).
           05 TRXN-DESC       PIC X(20).
       *> File Schema(Copybook) Section Ends


       WORKING-STORAGE SECTION.
       01 WS-FILE-STATUS     PIC XX.
       01 WS-ARG-COUNT       PIC 9(4).
       01 WS-ARG-VALUE       PIC X(300).

       01 WS-TRXN-ID         PIC X(10).
       01 WS-ACCT-ID         PIC X(10).

       01 WS-AMT-TXT         PIC X(50).
       01 WS-AMT-N           PIC S9(7)V99.

       01 WS-TYPE-TXT        PIC X(10).

       01 WS-TRXN-DATE-N     PIC 9(8).
       01 WS-TRXN-TIME-N     PIC 9(6).
       01 WS-POST-DATE-N     PIC 9(8).
       01 WS-POST-TIME-N     PIC 9(6).

       01 WS-CURR            PIC X(3).
       01 WS-CHANNEL         PIC X(3).
       01 WS-DESC            PIC X(20).

       01 WS-FILE-PATH       PIC X(200).

       PROCEDURE DIVISION.
       MAIN-PARA.

           ACCEPT WS-ARG-COUNT FROM ARGUMENT-NUMBER

           IF WS-ARG-COUNT < 12
               DISPLAY "Usage:"
               DISPLAY "  ./ledger_trxn_writer_args TRXN_ID ACCT_ID AMT TYPE TRXN_DT TRXN_TM POST_DT POST_TM CURR CHNL DESC OUTPUT_FILE"
               DISPLAY "Example:"
               DISPLAY "  ./ledger_trxn_writer_args TRX0000003 ACCT123456 1800.25 D 20250919 235840 20250920 001510 INR MOB ""LATE NIGHT TXN"" /Users/aarvi/Ravi/DataEngineering/data/transactions.dat"
               STOP RUN
           END-IF

           *> Arg 1: TRXN_ID
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           MOVE WS-ARG-VALUE(1:10) TO WS-TRXN-ID

           *> Arg 2: ACCT_ID
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           MOVE WS-ARG-VALUE(1:10) TO WS-ACCT-ID

           *> Arg 3: AMOUNT (text -> numeric)
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           MOVE FUNCTION TRIM(WS-ARG-VALUE) TO WS-AMT-TXT
           COMPUTE WS-AMT-N = FUNCTION NUMVAL(WS-AMT-TXT)

           *> Arg 4: TYPE (D/C)
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           MOVE WS-ARG-VALUE(1:1) TO TRXN-TYPE

           *> Arg 5: TRXN_DATE (YYYYMMDD)
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           COMPUTE WS-TRXN-DATE-N = FUNCTION NUMVAL(WS-ARG-VALUE)

           *> Arg 6: TRXN_TIME (HHMMSS)
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           COMPUTE WS-TRXN-TIME-N = FUNCTION NUMVAL(WS-ARG-VALUE)

           *> Arg 7: POST_DATE (YYYYMMDD)
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           COMPUTE WS-POST-DATE-N = FUNCTION NUMVAL(WS-ARG-VALUE)

           *> Arg 8: POST_TIME (HHMMSS)
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           COMPUTE WS-POST-TIME-N = FUNCTION NUMVAL(WS-ARG-VALUE)

           *> Arg 9: CURRENCY (3)
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           MOVE WS-ARG-VALUE(1:3) TO WS-CURR

           *> Arg 10: CHANNEL (3)
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           MOVE WS-ARG-VALUE(1:3) TO WS-CHANNEL

           *> Arg 11: DESC (<= 20)
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           MOVE WS-ARG-VALUE(1:20) TO WS-DESC

           *> Arg 12: OUTPUT FILE PATH
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           MOVE FUNCTION TRIM(WS-ARG-VALUE) TO WS-FILE-PATH

           *> Build record (move all WS values into record)
           MOVE WS-TRXN-ID       TO TRXN-ID
           MOVE WS-ACCT-ID       TO ACCT-ID
           MOVE WS-AMT-N         TO TRXN-AMT
           MOVE WS-TRXN-DATE-N   TO TRXN-DATE
           MOVE WS-TRXN-TIME-N   TO TRXN-TIME
           MOVE WS-POST-DATE-N   TO POST-DATE
           MOVE WS-POST-TIME-N   TO POST-TIME
           MOVE WS-CURR          TO CURRENCY-CODE
           MOVE WS-CHANNEL       TO CHANNEL-CODE
           MOVE WS-DESC          TO TRXN-DESC

           *> Directory does not exist; fail
           *> File does not exist; Create
           *> File exists; Append
           OPEN EXTEND TRXN-FILE
           IF WS-FILE-STATUS NOT = "00"
               OPEN OUTPUT TRXN-FILE
           END-IF

           WRITE TRXN-REC
           CLOSE TRXN-FILE

           DISPLAY "Wrote 1 transaction to: " WS-FILE-PATH
           STOP RUN.
