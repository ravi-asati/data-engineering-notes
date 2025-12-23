       01 LEDGER-REC.
          05 REC-TYPE                PIC X(1).

          05 LEDGER-HDR REDEFINES LEDGER-REC.
             10 HDR-REC-TYPE         PIC X(1).
             10 HDR-INST-CODE        PIC X(5).
             10 HDR-LEDGER-DATE      PIC 9(8).
             10 HDR-EXTRACT-ID       PIC X(10).
             10 HDR-SEQ-NO           PIC 9(6).
             10 FILLER               PIC X(50).

          05 LEDGER-DTL REDEFINES LEDGER-REC.
             10 DTL-REC-TYPE         PIC X(1).
             10 DTL-ACCT-NO          PIC X(16).
             10 DTL-TRXN-ID          PIC X(12).
             10 DTL-DR-CR-FLAG       PIC X(1).
             10 DTL-AMOUNT           PIC S9(9)V99 COMP-3.
             10 DTL-CURRENCY         PIC X(3).
             10 DTL-POST-DATE        PIC 9(8).
             10 FILLER               PIC X(39).

          05 LEDGER-TRL REDEFINES LEDGER-REC.
             10 TRL-REC-TYPE         PIC X(1).
             10 TRL-RECORD-COUNT     PIC 9(9).
             10 TRL-TOTAL-DEBITS     PIC S9(11)V99 COMP-3.
             10 TRL-TOTAL-CREDITS    PIC S9(11)V99 COMP-3.
             10 FILLER               PIC X(38).
