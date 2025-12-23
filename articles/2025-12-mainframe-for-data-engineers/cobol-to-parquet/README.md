# COBOL → Parquet (Mainframe Data File Processing)

This directory contains a **hands-on, end-to-end example** of reading a **COBOL data file** (mainframe-style, copybook-driven, fixed-length records) and converting it into **Parquet** using **Apache Spark + Cobrix**.

The goal of this exercise is **not** to showcase Spark features, but to help data engineers **build intuition** around how mainframe-generated data is processed in modern analytics pipelines.

---

## Why This Exists

In real-world enterprises—especially in **Banking, Financial Services, and Insurance (BFSI)**—

- Mainframes are still **systems of record**
- Analytics data often arrives as **COBOL data files**
- These files:
  - Have **no embedded schema**
  - Contain **binary numerics (COMP / COMP-3)**
  - Use **EBCDIC encoding** for text
  - Require a **copybook** to interpret

This folder demonstrates how such files can be ingested into a **modern Spark-based data platform** and converted into analytics-friendly formats like **Parquet**.

---

## What You Will Find Here

### 1. COBOL Data Generator (One record per execution)

A COBOL program (compiled using **GnuCOBOL**) that generates a fixed-length, record-based data file representing **ledger transactions**.

The file includes:
- Binary numeric fields (`COMP-3`)
- Character fields (`PIC X`)
- Fixed record length
- No delimiters
- No schema embedded in the file

This simulates how a **mainframe analytics extract** looks in practice.

---

## 2. Python Generator (Calls COBOL Executable + Converts to EBCDIC)

1. **Calls the compiled COBOL executable in a loop** to generate many records
2. Writes the output as a **fixed-length COBOL data file**
3. Converts character fields from **ASCII/UTF-8 → EBCDIC** to simulate how a real mainframe extract looks

**Why do this?**

- On an actual mainframe, text fields are typically stored in **EBCDIC**
- On macOS/Linux, **GnuCOBOL writes text using the OS-native encoding (ASCII/UTF-8)**
- If we want a realistic pipeline experience (copybook + EBCDIC + COMP-3), we need this conversion step

This keeps the demo honest: we generate the file locally, but we process it as if it came from a mainframe.

**What the Python script typically does?**

- Generates random values for each record:
  - `TRXN_ID`, `TRXN_DT`, `TRXN_TM`, `TRXN_AMNT`, etc.
- Invokes the COBOL writer executable using `subprocess.run(...)`
- Chooses whether to `WRITE` (overwrite) or `APPEND` based on CLI args
- After record generation:
  - Converts the **character segments** of each record into EBCDIC
  - Leaves **binary numeric segments** untouched (critical!)
  - Produces a final `.ebcdic` file used for Spark ingestion

**Why not convert the whole file blindly?**

COBOL files often contain **mixed storage formats**:

- `PIC X(...)` fields → character bytes → safe to encode (UTF-8 ↔ EBCDIC)
- `COMP` / `COMP-3` fields → binary numerics → must NOT be re-encoded

So conversion must be **schema-aware** (or at least offset-aware), otherwise the numeric fields get corrupted.

### 3. Copybook (`.cpy`)

A COBOL copybook that defines the **record layout**, including:
- Field names
- Field lengths
- Storage formats (binary vs character)
- Decimal precision

The copybook acts as the **schema contract** required to interpret the file.

---

### 4. PySpark + Cobrix Reader

A PySpark program that:
- Uses **Cobrix** (copybook-aware COBOL reader for Spark)
- Reads the COBOL data file using the copybook
- Decodes binary and character fields correctly
- Writes the result as **Parquet**

This mirrors how modern analytics pipelines handle mainframe data.

---

## How to run?

**1> Compile COBOL program**
```
cobc -x ./trxn_writer_simple.cbl
```
This will generate an executable ./trxn_writer_simple

**2> Run Python Generator**
```
python3 call_trxn_writer_simple_cobol_program.py 100 ./TRXN_COBOL_DATA rewrite
```

This should generate two files-
**./TRXN_COBOL_DATA** - Base file generate by **GnuCOBOL**
**./TRXN_COBOL_DATA.ebcdic** - **EBCDIC** files by converting encoding for text fields to ebcdic


**3> Run PySpark Converter**

```
spark-submit \
  --packages za.co.absa.cobrix:spark-cobol_2.13:2.9.4 \
  cobol_to_parquet.py \
  --input "file:/path/to/TRXN_COBOL_DATA.ebcdic" \
  --copybook "/path/to/trxn_writer_simple.cpy" \
  --record-length 24 \
  --output "file:/path/to/output/trxn_parquet" \  
```

This program will read COBOL data file and convert it to Parquet file.

## Setup I used
