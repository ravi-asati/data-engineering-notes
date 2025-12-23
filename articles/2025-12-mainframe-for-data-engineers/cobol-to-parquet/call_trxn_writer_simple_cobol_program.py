from __future__ import annotations

import argparse
import os
import random
import subprocess
from datetime import datetime, timedelta
from pathlib import Path


def rand_dt_tm() -> tuple[str, str]:
    # Random datetime within last 30 days
    now = datetime.now()
    dt = now - timedelta(seconds=random.randint(0, 30 * 24 * 3600))
    return dt.strftime("%Y%m%d"), dt.strftime("%H%M%S")


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("num_records", type=int, help="How many records to generate")
    p.add_argument("file_name", help="Output file path (e.g., ./trxn_cobol.dat)")
    p.add_argument("mode", choices=["rewrite", "append"], help="File mode")
    p.add_argument("--exe", default="./trxn_writer_simple", help="Path to COBOL executable")
    args = p.parse_args()

    exe = args.exe
    out_file = args.file_name

    if not os.path.exists(exe):
        raise SystemExit(f"COBOL executable not found: {exe} (compile first)")

    # Ensure parent directory exists
    Path(out_file).parent.mkdir(parents=True, exist_ok=True)

    # Decide first-write mode
    first_mode = "R" if args.mode == "rewrite" else "A"

    base_id = random.randint(100000, 999999)

    for i in range(args.num_records):
        trxn_id = base_id + i
        trxn_dt, trxn_tm = rand_dt_tm()

        # Signed integer amount (+/-), keep it simple
        trxn_amt = random.randint(-5000, 5000)

        # Only the first record uses rewrite if requested; rest must append
        cob_mode = first_mode if i == 0 else "A"

        cmd = [
            exe,
            str(trxn_id),
            trxn_dt,
            trxn_tm,
            str(trxn_amt),
            out_file,
            cob_mode,
        ]

        # Run COBOL writer
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            print("Command failed:", " ".join(cmd))
            print("STDOUT:", res.stdout)
            print("STDERR:", res.stderr)
            raise SystemExit(res.returncode)

    print(f"Done. Wrote {args.num_records} records to {out_file}")


if __name__ == "__main__":
    main()

 # python3 call_trxn_writer_simple_cobol_program.py 50 ./trxn_cobol.dat rewrite
