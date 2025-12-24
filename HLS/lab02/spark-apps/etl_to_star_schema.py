from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_date, year, month, dayofmonth, quarter, dayofweek, date_format

POSTGRES_URL = "jdbc:postgresql://postgres:5432/postgres"
POSTGRES_PROPERTIES = {"user": "postgres", "password": "postgres", "driver": "org.postgresql.Driver"}

def create_spark_session():
    return SparkSession.builder.appName("ETL_to_Star_Schema").config("spark.jars", "/opt/spark-jars/postgresql-42.7.1.jar").getOrCreate()

def load_mock_data(spark):
    return spark.read.jdbc(url=POSTGRES_URL, table="mock_data", properties=POSTGRES_PROPERTIES)

def create_dim_customer(df, spark):
    dim_customer = df.select(
        col("sale_customer_id").alias("customer_id"), col("customer_first_name"),
        col("customer_last_name"), col("customer_age"),
        col("customer_email"), col("customer_country"),
        col("customer_postal_code"), col("customer_pet_type"),
        col("customer_pet_name"), col("customer_pet_breed")
    ).dropDuplicates(["customer_id"])
    dim_customer.write.jdbc(url=POSTGRES_URL, table="dim_customer", mode="append", properties=POSTGRES_PROPERTIES)
    return dim_customer

def create_dim_product(df, spark):
    dim_product = df.select(
        col("sale_product_id").alias("product_id"), col("product_name"), col("product_category").alias("category"),
        col("product_price").alias("price"), col("product_weight").alias("weight"), col("product_color").alias("color"),
        col("product_size").alias("size"), col("product_brand").alias("brand"), col("product_material").alias("material"),
        col("product_description").alias("description"), col("product_rating").alias("rating"),
        col("product_reviews").alias("reviews"), to_date(col("product_release_date"), "M/d/yyyy").alias("release_date"),
        to_date(col("product_expiry_date"), "M/d/yyyy").alias("expiry_date"), col("pet_category")
    ).dropDuplicates(["product_id"])
    dim_product.write.jdbc(url=POSTGRES_URL, table="dim_product", mode="append", properties=POSTGRES_PROPERTIES)
    return dim_product

def create_dim_store(df, spark):
    dim_store = df.select(
        col("store_name"), col("store_location").alias("location"), col("store_city").alias("city"),
        col("store_state").alias("state"), col("store_country").alias("country"),
        col("store_phone").alias("phone"), col("store_email").alias("email")
    ).dropDuplicates(["store_name"])
    dim_store.write.jdbc(url=POSTGRES_URL, table="dim_store", mode="append", properties=POSTGRES_PROPERTIES)
    return dim_store

def create_dim_supplier(df, spark):
    dim_supplier = df.select(
        col("supplier_name"), col("supplier_contact").alias("contact"), col("supplier_email").alias("email"),
        col("supplier_phone").alias("phone"), col("supplier_address").alias("address"),
        col("supplier_city").alias("city"), col("supplier_country").alias("country")
    ).dropDuplicates(["supplier_name"])
    dim_supplier.write.jdbc(url=POSTGRES_URL, table="dim_supplier", mode="append", properties=POSTGRES_PROPERTIES)
    return dim_supplier

def create_dim_seller(df, spark):
    dim_seller = df.select(
        col("sale_seller_id").alias("seller_id"), col("seller_first_name").alias("first_name"),
        col("seller_last_name").alias("last_name"), col("seller_email").alias("email"),
        col("seller_country").alias("country"), col("seller_postal_code").alias("postal_code")
    ).dropDuplicates(["seller_id"])
    dim_seller.write.jdbc(url=POSTGRES_URL, table="dim_seller", mode="append", properties=POSTGRES_PROPERTIES)
    return dim_seller

def create_dim_date(df, spark):
    dates_df = df.select(to_date(col("sale_date"), "M/d/yyyy").alias("full_date")).distinct().filter(col("full_date").isNotNull())
    dim_date = dates_df.select(
        col("full_date"), dayofmonth(col("full_date")).alias("day"), month(col("full_date")).alias("month"),
        year(col("full_date")).alias("year"), quarter(col("full_date")).alias("quarter"),
        dayofweek(col("full_date")).alias("day_of_week"), date_format(col("full_date"), "MMMM").alias("month_name"),
        date_format(col("full_date"), "yyyy-MM").alias("year_month")
    )
    dim_date.write.jdbc(url=POSTGRES_URL, table="dim_date", mode="append", properties=POSTGRES_PROPERTIES)
    return dim_date

def create_fact_sales(df, spark):
    dim_customer = spark.read.jdbc(POSTGRES_URL, "dim_customer", properties=POSTGRES_PROPERTIES)
    dim_product = spark.read.jdbc(POSTGRES_URL, "dim_product", properties=POSTGRES_PROPERTIES)
    dim_store = spark.read.jdbc(POSTGRES_URL, "dim_store", properties=POSTGRES_PROPERTIES)
    dim_supplier = spark.read.jdbc(POSTGRES_URL, "dim_supplier", properties=POSTGRES_PROPERTIES)
    dim_seller = spark.read.jdbc(POSTGRES_URL, "dim_seller", properties=POSTGRES_PROPERTIES)
    dim_date = spark.read.jdbc(POSTGRES_URL, "dim_date", properties=POSTGRES_PROPERTIES)
    sales_data = df.select(
        col("sale_customer_id"), col("sale_product_id"), col("store_name"), col("supplier_name"),
        col("sale_seller_id"), to_date(col("sale_date"), "M/d/yyyy").alias("sale_date"),
        col("sale_quantity").alias("quantity"), col("sale_total_price").alias("total_price"),
        col("product_price").alias("unit_price")
    )
    fact_sales = sales_data.join(dim_customer, sales_data.sale_customer_id == dim_customer.customer_id, "left") \
        .join(dim_product, sales_data.sale_product_id == dim_product.product_id, "left") \
        .join(dim_store, sales_data.store_name == dim_store.store_name, "left") \
        .join(dim_supplier, sales_data.supplier_name == dim_supplier.supplier_name, "left") \
        .join(dim_seller, sales_data.sale_seller_id == dim_seller.seller_id, "left") \
        .join(dim_date, sales_data.sale_date == dim_date.full_date, "left") \
        .select(dim_customer.customer_key, dim_product.product_key, dim_store.store_key,
                dim_supplier.supplier_key, dim_seller.seller_key, dim_date.date_key,
                sales_data.quantity, sales_data.total_price, sales_data.unit_price)
    fact_sales.write.jdbc(url=POSTGRES_URL, table="fact_sales", mode="append", properties=POSTGRES_PROPERTIES)
    return fact_sales

def main():
    spark = create_spark_session()
    try:
        mock_data = load_mock_data(spark)
        create_dim_customer(mock_data, spark)
        create_dim_product(mock_data, spark)
        create_dim_store(mock_data, spark)
        create_dim_supplier(mock_data, spark)
        create_dim_seller(mock_data, spark)
        create_dim_date(mock_data, spark)
        create_fact_sales(mock_data, spark)
    finally:
        spark.stop()

if __name__ == "__main__":
    main()
