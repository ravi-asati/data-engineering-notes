0BEGIN* 
      * About fixed-layout source code format-
      * Fixed-layout was originally designed for 80-column punched cards.
      * That physical constraint became a language rule, and for decades:

      * COBOL programs (.cbl)
      * COBOL copybooks (.cpy)
      
      * both followed the same column rules and still follows.

      * Note- Now, it is possible to write code in free-form format
      * but fixed-layout is still widely used.

      * First 6 columns are ignored by compiler
      * Asterisk in 7th indicates this is comment
      * Columns 8 to 11 are "A" margin columns, used for section names, 01 and 77 level items
      * Columns 12 to 72 are "B" margin columns, contain the remainder code
      * Columns 73 to 80 are again typically ignored by compiler


LEVELS* 
      * Levels (01, 05, 10, 15, …) describe a hierarchical data structure. 
      * Levels do NOT define size. They define structure and relationship. They only define how bytes are interpreted.

       01  CUSTOMER-REC. *> Top-Level Structure

           05 CUST-ID PIC X(10). *> This is a sub-field under CUSTOMER_REC (01). A string of size 10.
           05 CUST-NM.
              10 CUST-FST-NM PIC X(50). *> This is a sub-field under CUST-NM (05)
              10 CUST-LST-NM PIC X(50). *> This is a sub-field under CUST-NM (05)

           05 CUST-DOB PIC X(8). 

           05 CUST-PHONE-NUMBERS OCCURS 2 TIMES. *> An array of phone numbers
              10 CUST-PHONE-NO PIC X(12).

           05 CUST-INCOME PIC 9(10) COMP. *> An integer

      * 01	  - Record / top-level structure
      * 05–49 -	Normal data hierarchy
      * 66	  - RENAMES (aliasing)
      * 77	  - Standalone field (no hierarchy)
      * 88	  - Condition name (value-level meaning)

      * Levels describe “contains” relationships, not physical layout.

000END*
