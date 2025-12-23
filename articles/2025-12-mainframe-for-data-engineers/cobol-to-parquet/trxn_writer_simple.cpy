       01 TRXN-REC.
          05 TRXN-ID     PIC 9(9)       COMP-3. 
                         *> Binray numeric. Unsigned Integer
          05 TRXN-DT     PIC X(8).              
                         *> character-based date (YYYMMDD)
          05 TRXN-TM     PIC X(6).              
                         *> character-based timestamp (HHMMSS)
          05 TRXN-AMNT   PIC S9(7)V99   COMP-3. 
                         *> Binary numeric. Signed Real

       *> This is fixed-size records file
       *> Record size is 24 bytes
