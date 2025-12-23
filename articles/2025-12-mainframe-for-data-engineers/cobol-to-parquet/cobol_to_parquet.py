import argparse
from pyspark.sql import SparkSessio


def main():
    p = argparse.ArgumentParser(description="Read COBOL (Cobrix) and write Parquet")
    p.add_argument("--input", required=True, help="Input COBOL file path (file:/... or /...)")
    p.add_argument("--copybook", required=True, help="Copybook .cpy path (local path)")
    p.add_argument("--output", required=True, help="Output Parquet path (file:/... or /...)")
    p.add_argument("--record-length", default="24", help="Fixed record length in bytes (default 24)")
    p.add_argument("--encoding", default="EBCDIC", help="Text encoding for PIC X fields (e.g., EBCDIC/cp037)")
    p.add_argument("--print-charset", action="store_true", help="Print JVM charset resolution and exit?")
    args = p.parse_args()

    spark = (
        SparkSession.builder
        .appName("COBOL-to-Parquet")
        .getOrCreate()
    )

    if args.print_charset:
        spark.stop()
        return

    # Cobrix reader
    df = (
        spark.read.format("cobol")
        .option("copybook", args.copybook)
        .option("record_length", str(args.record_length))
        .option("encoding", args.encoding)
        .load(args.input)
    )

    df.printSchema()

    # Write Parquet
    (
        df.write
        .mode("overwrite")
        .parquet(args.output)
    )

    print(f"Wrote Parquet to: {args.output}")
    spark.stop()


if __name__ == "__main__":
    main()

'''
spark-submit \
  --packages za.co.absa.cobrix:spark-cobol_2.13:2.9.4 \
  convert_cobol_to_parquet_v2.py \
  --input "file:./TRXN_COBOL_DATA.ebcdic" \
  --copybook "./trxn_writer_simple.cpy" \
  --output "file:./trxn_parquet" \
  --record-length 24
'''
