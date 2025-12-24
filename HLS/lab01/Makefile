.PHONY: run

run:
	docker-compose -f ./docker-compose.yml up -d
	sleep 10
	docker exec -i postgres_db psql -U postgres -d postgres < ddl_snowflake.sql
	docker exec -i postgres_db psql -U postgres -d postgres < dml_snowflake.sql
