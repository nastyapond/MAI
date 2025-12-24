.PHONY: run

run:
	@mkdir -p spark-jars
	@if [ ! -f spark-jars/postgresql-42.7.1.jar ]; then \
		curl -sL -o spark-jars/postgresql-42.7.1.jar https://jdbc.postgresql.org/download/postgresql-42.7.1.jar; \
	fi
	@if [ ! -f spark-jars/clickhouse-jdbc-0.6.0-all.jar ]; then \
		curl -sL -o spark-jars/clickhouse-jdbc-0.6.0-all.jar https://github.com/ClickHouse/clickhouse-java/releases/download/v0.6.5/clickhouse-jdbc-0.6.5-all.jar; \
	fi
	docker-compose -f docker-compose.yml -p bigdataspark up -d
	@sleep 15
	@until docker exec postgres_db pg_isready -U postgres > /dev/null 2>&1; do sleep 2; done
	@until docker exec clickhouse_db clickhouse-client --query "SELECT 1" > /dev/null 2>&1; do sleep 2; done
	docker exec -i postgres_db psql -U postgres < star_schema.sql
	docker exec -i clickhouse_db clickhouse-client --user default --password default < clickhouse_schema.sql
	docker exec -u root spark_master pip install -q requests pandas || true
	docker exec spark_master /opt/spark/bin/spark-submit --master spark://spark-master:7077 --deploy-mode client --driver-memory 2g --executor-memory 2g --jars /opt/spark-jars/postgresql-42.7.1.jar /opt/spark-apps/etl_to_star_schema.py
	docker exec spark_master /opt/spark/bin/spark-submit --master spark://spark-master:7077 --deploy-mode client --driver-memory 2g --executor-memory 2g --jars /opt/spark-jars/postgresql-42.7.1.jar /opt/spark-apps/create_reports.py
