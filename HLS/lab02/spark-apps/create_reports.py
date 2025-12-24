from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sum as _sum, avg, count, desc
import requests

POSTGRES_URL = "jdbc:postgresql://postgres:5432/postgres"
POSTGRES_PROPERTIES = {"user": "postgres", "password": "postgres", "driver": "org.postgresql.Driver"}
CLICKHOUSE_HOST = "clickhouse"
CLICKHOUSE_PORT = 8123
CLICKHOUSE_USER = "default"
CLICKHOUSE_PASSWORD = "default"

def create_spark_session():
    return SparkSession.builder.appName("ETL_Reports_to_ClickHouse").config("spark.jars", "/opt/spark-jars/postgresql-42.7.1.jar").getOrCreate()

def load_star_schema(spark):
    fact_sales = spark.read.jdbc(POSTGRES_URL, "fact_sales", properties=POSTGRES_PROPERTIES)
    dim_customer = spark.read.jdbc(POSTGRES_URL, "dim_customer", properties=POSTGRES_PROPERTIES)
    dim_product = spark.read.jdbc(POSTGRES_URL, "dim_product", properties=POSTGRES_PROPERTIES)
    dim_store = spark.read.jdbc(POSTGRES_URL, "dim_store", properties=POSTGRES_PROPERTIES)
    dim_supplier = spark.read.jdbc(POSTGRES_URL, "dim_supplier", properties=POSTGRES_PROPERTIES)
    dim_seller = spark.read.jdbc(POSTGRES_URL, "dim_seller", properties=POSTGRES_PROPERTIES)
    dim_date = spark.read.jdbc(POSTGRES_URL, "dim_date", properties=POSTGRES_PROPERTIES)
    return fact_sales, dim_customer, dim_product, dim_store, dim_supplier, dim_seller, dim_date

def insert_to_clickhouse(df, table_name):
    csv_data = df.toPandas().to_csv(index=False, header=False, sep='\t')
    url = f"http://{CLICKHOUSE_HOST}:{CLICKHOUSE_PORT}/"
    params = {
        'user': CLICKHOUSE_USER,
        'password': CLICKHOUSE_PASSWORD,
        'query': f"INSERT INTO {table_name} FORMAT TabSeparated"
    }
    response = requests.post(url, params=params, data=csv_data.encode('utf-8'))
    if response.status_code != 200:
        raise Exception(f"Failed to insert data into {table_name}: {response.text}")

def create_report_1_product_sales(fact_sales, dim_product, spark):
    report = fact_sales.join(dim_product, "product_key").groupBy(
        col("product_id"), col("product_name"), col("category"), col("rating"), col("reviews")
    ).agg(_sum("quantity").alias("total_quantity_sold"), _sum("total_price").alias("total_revenue"),
         count("*").alias("number_of_sales"), avg("unit_price").alias("avg_unit_price")).orderBy(desc("total_quantity_sold"))
    insert_to_clickhouse(report, "report_product_sales")
    return report

def create_report_2_customer_sales(fact_sales, dim_customer, spark):
    report = fact_sales.join(dim_customer, "customer_key").groupBy(
        col("customer_id"), col("customer_first_name"), col("customer_last_name"), col("customer_email"), col("customer_country"), col("customer_age")
    ).agg(_sum("total_price").alias("total_purchase_amount"), count("*").alias("number_of_purchases"),
         avg("total_price").alias("avg_check")).orderBy(desc("total_purchase_amount"))
    insert_to_clickhouse(report, "report_customer_sales")
    return report

def create_report_3_time_sales(fact_sales, dim_date, spark):
    report = fact_sales.join(dim_date, "date_key").groupBy(
        col("year"), col("month"), col("quarter"), col("month_name"), col("year_month")
    ).agg(_sum("total_price").alias("total_revenue"), _sum("quantity").alias("total_quantity_sold"),
         count("*").alias("number_of_orders"), avg("total_price").alias("avg_order_size")).orderBy("year", "month")
    insert_to_clickhouse(report, "report_time_sales")
    return report

def create_report_4_store_sales(fact_sales, dim_store, spark):
    report = fact_sales.join(dim_store, "store_key").groupBy(
        col("store_name"), col("city"), col("state"), col("country")
    ).agg(_sum("total_price").alias("total_revenue"), _sum("quantity").alias("total_quantity_sold"),
         count("*").alias("number_of_sales"), avg("total_price").alias("avg_check")).orderBy(desc("total_revenue"))
    insert_to_clickhouse(report, "report_store_sales")
    return report

def create_report_5_supplier_sales(fact_sales, dim_supplier, dim_product, spark):
    report = fact_sales.join(dim_supplier, "supplier_key").join(dim_product, "product_key").groupBy(
        col("supplier_name"), col("country"), col("city")
    ).agg(_sum("total_price").alias("total_revenue"), _sum("quantity").alias("total_quantity_sold"),
         count("*").alias("number_of_sales"), avg("unit_price").alias("avg_product_price")).orderBy(desc("total_revenue"))
    insert_to_clickhouse(report, "report_supplier_sales")
    return report

def create_report_6_product_quality(fact_sales, dim_product, spark):
    report = fact_sales.join(dim_product, "product_key").groupBy(
        col("product_id"), col("product_name"), col("category"), col("brand"), col("rating"), col("reviews")
    ).agg(_sum("quantity").alias("total_quantity_sold"), _sum("total_price").alias("total_revenue"),
         count("*").alias("number_of_sales")).orderBy(desc("rating"), desc("reviews"))
    insert_to_clickhouse(report, "report_product_quality")
    return report

def main():
    spark = create_spark_session()
    try:
        fact_sales, dim_customer, dim_product, dim_store, dim_supplier, dim_seller, dim_date = load_star_schema(spark)
        create_report_1_product_sales(fact_sales, dim_product, spark)
        create_report_2_customer_sales(fact_sales, dim_customer, spark)
        create_report_3_time_sales(fact_sales, dim_date, spark)
        create_report_4_store_sales(fact_sales, dim_store, spark)
        create_report_5_supplier_sales(fact_sales, dim_supplier, dim_product, spark)
        create_report_6_product_quality(fact_sales, dim_product, spark)
    finally:
        spark.stop()

if __name__ == "__main__":
    main()
