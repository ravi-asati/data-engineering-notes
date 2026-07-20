import argparse
from pathlib import Path

from pyspark.sql import SparkSession
from pyspark.sql.functions import count, to_date
from pyspark.sql.types import StringType, StructField, StructType

parser = argparse.ArgumentParser(
    description="Count transactions by transaction date and merchant ID using Spark."
)
parser.add_argument("input_path", help="Input transactions CSV path.")
parser.add_argument("output_path", help="Output directory path.")
args = parser.parse_args()

spark = (
    SparkSession.builder
    .appName("Group Transactions")
    .master("local[4]")
    .config("spark.log.level", "INFO")
    .config("spark.sql.adaptive.enabled", "false")
    .config("spark.sql.files.maxPartitionBytes", "128m")
    .config("spark.sql.shuffle.partitions", "4")
    .getOrCreate()
)

transaction_schema = StructType([
    StructField("id", StringType(), True),
    StructField("date", StringType(), True),
    StructField("client_id", StringType(), True),
    StructField("card_id", StringType(), True),
    StructField("amount", StringType(), True),
    StructField("use_chip", StringType(), True),
    StructField("merchant_id", StringType(), True),
    StructField("merchant_city", StringType(), True),
    StructField("merchant_state", StringType(), True),
    StructField("zip", StringType(), True),
    StructField("mcc", StringType(), True),
    StructField("errors", StringType(), True),
])

transactions_df = (
    spark.read
    .option("header", "true")
    .schema(transaction_schema)
    .csv(args.input_path)
)

transaction_counts_df = (
    transactions_df
    .withColumn("transaction_date", to_date("date"))
    .groupBy("transaction_date", "merchant_id")
    .agg(count("*").alias("transaction_count"))
)

(
    transaction_counts_df.write
    .mode("overwrite")
    .option("header", "true")
    .csv(args.output_path)
)

input("Press Enter to stop Spark and exit...")
spark.stop()

# Command to run the script:
# spark-submit <path_to_script>/03_group_transactions.py <input_full_path>/transactions.csv <output_full_path>/grouped_transactions
# or
# python <path_to_script>/03_group_transactions.py <input_full_path>/transactions.csv <output_full_path>/grouped_transactions
