       *> ==========================================================
       *> SAMPLE COPYBOOK
       *> Demonstrates:
       *>   - LEVEL hierarchy
       *>   - OCCURS (arrays / repeating groups)
       *>   - REDEFINES (multiple logical views of same record)
       *> ==========================================================

       01 FILE-REC.
          *> ------------------------------------------------------
          *> LEVEL 01
          *> Top-level record definition.
          *> Represents one physical record on disk.
          *> ------------------------------------------------------

          05 REC-TYPE              PIC X(1).
          *> ------------------------------------------------------
          *> LEVEL 05
          *> A field inside the record.
          *> REC-TYPE identifies logical record type:
          *>   'H' = Header
          *>   'D' = Detail
          *>   'T' = Trailer
          *> ------------------------------------------------------


          *> ================= HEADER RECORD ======================
          05 HDR-REC REDEFINES FILE-REC.
          *> ------------------------------------------------------
          *> REDEFINES:
          *> HDR-REC overlays FILE-REC.
          *> No extra bytes are allocated.
          *> Same physical record, different logical interpretation.
          *> Used when REC-TYPE = 'H'
          *> ------------------------------------------------------

             10 HDR-REC-TYPE       PIC X(1).
             *> Must contain 'H'

             10 HDR-FEED-NAME      PIC X(20).
             *> Name of the feed / extract

             10 HDR-BUS-DATE       PIC 9(8).
             *> Business date (YYYYMMDD)

             10 HDR-RUN-TIME       PIC 9(6).
             *> Batch run time (HHMMSS)

             10 FILLER             PIC X(45).
             *> Unused bytes.
             *> FILLER has no name and is never referenced in code.
             *> Exists for alignment / future expansion.


          *> ================= DETAIL RECORD ======================
          05 DTL-REC REDEFINES FILE-REC.
          *> ------------------------------------------------------
          *> Another logical view of the same record.
          *> Used when REC-TYPE = 'D'
          *> ------------------------------------------------------

             10 DTL-REC-TYPE       PIC X(1).
             *> Must contain 'D'

             10 DTL-ACCT-ID        PIC X(12).
             *> Account identifier

             10 DTL-TXN-COUNT      PIC 9(1).
             *> Number of valid transaction codes below

             10 DTL-TXN-CODES OCCURS 5 TIMES.
             *> --------------------------------------------------
             *> OCCURS:
             *> Defines a repeating group (array).
             *> Physically, space is allocated for 5 entries.
             *> Logically, only DTL-TXN-COUNT entries are meaningful.
             *> --------------------------------------------------

                15 DTL-TXN-CODE    PIC X(3).
                *> Individual transaction code

             10 DTL-AMOUNT         PIC S9(7)V99 COMP-3.
             *> Binary packed decimal amount

             10 FILLER             PIC X(22).
             *> Padding / future use


          *> ================= TRAILER RECORD =====================
          05 TRL-REC REDEFINES FILE-REC.
          *> ------------------------------------------------------
          *> Trailer record view.
          *> Used when REC-TYPE = 'T'
          *> ------------------------------------------------------

             10 TRL-REC-TYPE       PIC X(1).
             *> Must contain 'T'

             10 TRL-RECORD-COUNT   PIC 9(9).
             *> Total number of detail records

             10 TRL-TOTAL-AMOUNT   PIC S9(11)V99 COMP-3.
             *> Control total for reconciliation

             10 FILLER             PIC X(58).
             *> Padding to keep record length fixed
