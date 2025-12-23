import argparse
from pyspark.sql import SparkSession


def main():
    p = argparse.ArgumentParser(description="Read COBOL (Cobrix) and write Parquet")
    p.add_argument("--input", required=True, help="Input COBOL file path (file:/... or /...)")
    p.add_argument("--copybook", required=True, help="Copybook .cpy path (local path)")
    p.add_argument("--record-length", default="24", help="Fixed record length in bytes (default 24)")
    p.add_argument("--output", required=True, help="Output Parquet path (file:/... or /...)") 
    p.add_argument("--encoding", default="EBCDIC", help="Text encoding for PIC X fields (default cp037)")
    args = p.parse_args()

    spark = (
        SparkSession.builder
        .appName("COBOL-to-Parquet")
        .getOrCreate()
    )

    # Cobrix reader
    df = (
        spark.read.format("cobol")
        .option("copybook", args.copybook)
        .option("record_length", args.record_length)
        .option("encoding", args.encoding)
        .load(args.input)
    )

    df.printSchema()
    #df.show(10, truncate=False)

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
# Provide all paths as absolute paths here
spark-submit \
  --packages za.co.absa.cobrix:spark-cobol_2.13:2.9.4 \
  cobol_to_parquet.py \
  --input "file:/Users/aarvi/Ravi/DataEngineering/article/TRXN_COBOL_DATA.ebcdic" \
  --copybook "/Users/aarvi/Ravi/DataEngineering/article/trxn_writer_simple.cpy" \
  --record-length 24 \
  --output "file:/Users/aarvi/Ravi/DataEngineering/article/trxn_parquet"
'''
