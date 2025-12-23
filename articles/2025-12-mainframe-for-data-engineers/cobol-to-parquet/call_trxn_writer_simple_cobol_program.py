from __future__ import annotations

import argparse
import os
import random
import subprocess
from datetime import datetime, timedelta
from pathlib import Path


# Record layout (bytes) for the COBOL file:
# TRXN-ID   PIC 9(9) COMP-3      -> 5 bytes
# TRXN-DT   PIC X(8)             -> 8 bytes (ASCII in base file)
# TRXN-TM   PIC X(6)             -> 6 bytes (ASCII in base file)
# TRXN-AMNT PIC S9(7)V99 COMP-3  -> 5 bytes
RECLEN = 5 + 8 + 6 + 5  # = 24 bytes

# Slice locations
ID_SLICE = slice(0, 5)
DT_SLICE = slice(5, 13)
TM_SLICE = slice(13, 19)
AMT_SLICE = slice(19, 24)


def rand_dt_tm() -> tuple[str, str]:
    now = datetime.now()
    dt = now - timedelta(seconds=random.randint(0, 30 * 24 * 3600))
    return dt.strftime("%Y%m%d"), dt.strftime("%H%M%S")


def rebuild_ebcdic_file(base_path: str, ebcdic_path: str, codepage: str = "cp037") -> None:
    """
    Convert only the text field slices (DT, TM) to EBCDIC, leaving COMP-3 bytes untouched.
    This is the correct way to create mixed binary+EBCDIC files.
    """
    data = Path(base_path).read_bytes()
    if len(data) % RECLEN != 0:
        raise ValueError(f"Base file size {len(data)} is not multiple of record length {RECLEN}")

    out = bytearray()
    for i in range(0, len(data), RECLEN):
        rec = data[i : i + RECLEN]

        # Keep packed decimals as-is
        trxn_id_packed = rec[ID_SLICE]
        trxn_amt_packed = rec[AMT_SLICE]

        # Convert ASCII date/time to EBCDIC bytes
        dt_ascii = rec[DT_SLICE].decode("ascii")
        tm_ascii = rec[TM_SLICE].decode("ascii")

        dt_ebc = dt_ascii.encode(codepage)
        tm_ebc = tm_ascii.encode(codepage)

        out.extend(trxn_id_packed)
        out.extend(dt_ebc)
        out.extend(tm_ebc)
        out.extend(trxn_amt_packed)

    Path(ebcdic_path).write_bytes(out)


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("num_records", type=int, help="Number of records to generate")
    p.add_argument("file_name", help="Output file path (base binary file)")
    p.add_argument("mode", choices=["rewrite", "append"], help="rewrite or append")
    p.add_argument("--exe", default="./trxn_writer_simple", help="Path to COBOL executable")
    args = p.parse_args()

    exe = args.exe
    out_file = args.file_name
    mode = args.mode

    if not os.path.exists(exe):
        raise SystemExit(f"COBOL executable not found: {exe} (compile first)")

    Path(out_file).parent.mkdir(parents=True, exist_ok=True)

    base_id = random.randint(1_000_000_00, 9_999_999_99)

    # rewrite means: first record uses R, then always A for remaining
    first_mode = "R" if mode == "rewrite" else "A"

    for i in range(args.num_records):
        trxn_id = base_id + i
        trxn_dt, trxn_tm = rand_dt_tm()

        # signed amount with 2 decimals (as text), COBOL NUMVAL will parse it
        amt = round(random.uniform(-5000, 5000), 2)
        amt_txt = f"{amt:.2f}"

        cob_mode = first_mode if i == 0 else "A"

        cmd = [
            exe,
            str(trxn_id),
            trxn_dt,
            trxn_tm,
            amt_txt,
            out_file,
            cob_mode,
        ]

        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            print("FAILED:", " ".join(cmd))
            print("STDOUT:", res.stdout)
            print("STDERR:", res.stderr)
            raise SystemExit(res.returncode)

    ebcdic_file = out_file + ".ebcdic"
    rebuild_ebcdic_file(out_file, ebcdic_file, codepage="cp037")

    print(f"Done.")
    print(f"Base file (ASCII text + COMP-3): {out_file}")
    print(f"EBCDIC file (EBCDIC text + COMP-3): {ebcdic_file}")


if __name__ == "__main__":
    main()


#python3 call_trxn_writer_simple_cobol_program.py 50 ./TRXN_COBOL_DATA rewrite 
