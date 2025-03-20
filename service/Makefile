database-run:
	@if [ $$(docker ps -a -q -f name=nde) ]; then \
		echo "Container nde already exists. Restarting..."; \
		docker start nde; \
	else \
		echo "Creating and starting container nde..."; \
		docker run --rm -d \
			-v nde_data:/var/lib/postgresql/data/ \
			--name nde \
			-e POSTGRES_DB=nde \
			-e POSTGRES_USER=postgres \
			-e POSTGRES_PASSWORD=postgres \
			-e PGPORT=7432 \
			-p 7432:7432 postgres:17-alpine; \
        fi

database-attach:
	docker exec -it nde psql -U postgres -d postgres

test:
	KEMAL_ENV=testing crystal spec

docker-build:
	docker build -t nightcity-data-exchange:latest .
