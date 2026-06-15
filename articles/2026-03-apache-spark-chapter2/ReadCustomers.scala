import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.{col, lower, when}
import org.apache.spark.sql.types.{StringType, StructField, StructType}

object ReadCustomers {

  def main(args: Array[String]): Unit = {

    if (args.length != 2) {
      System.err.println(
        """
          |Usage:
          |  ReadCustomers <input_file> <output_dir>
          |
          |Example:
          |  spark-submit ... customers.csv output/
          |""".stripMargin
      )
      System.exit(1)
    }

    val inputFile = args(0)
    val outputDir = args(1)

    println(s"Input File : $inputFile")
    println(s"Output Dir : $outputDir")

    val spark = SparkSession.builder()
      .appName("Read Customers Scala")
      .config("spark.sql.files.maxPartitionBytes", "64m")
      .getOrCreate()

    val customerSchema = StructType(
      Seq(
        StructField("customer_id", StringType, nullable = true),
        StructField("name", StringType, nullable = true),
        StructField("country", StringType, nullable = true),
        StructField("status", StringType, nullable = true)
      )
    )

    val customersDf = spark.read
      .option("header", "true")
      .schema(customerSchema)
      .csv(inputFile)

    val activeCustomersDf = customersDf
      .filter(col("status") === "active")
      .withColumn(
        "status",
        when(lower(col("status")) === "active", "A")
          .when(lower(col("status")) === "inactive", "I")
          .otherwise(col("status"))
      )

    activeCustomersDf.write
      .mode("overwrite")
      .option("header", "true")
      .csv(outputDir)

    println("Sleeping for 300 seconds...")
    Thread.sleep(300000) // 1st Sleep

    spark.stop()
    println("SparkContext stopped. Entering final 300 seconds cooldown...")
    Thread.sleep(300000) // 2nd Sleep

    println("Final sleep over. Exiting Driver JVM now!!!")
  }
}
