# Running `ledger_trxn_writer.cbl`

This section explains how to compile and run the **COBOL ledger transaction writer** program included in this repository.

The program generates a **fixed-length COBOL data file** that simulates a **core-ledger transaction feed**, similar to what a mainframe system would produce for downstream analytics.

This is intended for **learning and experimentation**, especially for data engineers who want hands-on exposure to COBOL data files.

---

## What This Program Does

The `ledger_trxn_writer.cbl` program:

- Writes **record-based, fixed-size** COBOL data files
- Mixes **binary numeric fields (COMP-3)** and **character fields (PIC X)**
- Accepts **runtime arguments**
- Supports **WRITE (overwrite)** and **APPEND** modes
- Produces a file suitable for:
  - Copybook-based parsing
  - Spark + Cobrix ingestion
  - Conversion to Parquet
 
***Note-*** Generated COBOL file is encoded with OS native character-set (ASCII or UTF8) not **EBCDIC**. 

---

## How to run?

1. Compile the program.
   ```
   cobc -x ./ledger_trxn_writer.cbl
   ```
2.  Execute the program
   ```
   ./ledger_trxn_writer \
  100000001 \
  20251220 \
  134075 \
  +12345.67 \
  ./trxn_comp3.dat \
  WRITE
   ```
