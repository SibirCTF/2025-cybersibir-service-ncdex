IMAGE_NAME=cybersibir-service-ncdex-checker

build:
	docker build -t $(IMAGE_NAME) .

run-check:
	docker run --network=host --volume=./:/app --rm $(IMAGE_NAME) 127.0.0.1 check

run-put:
	docker run --network=host --volume=./:/app --rm $(IMAGE_NAME) 127.0.0.1 put

run:
	docker run --network=host --volume=./:/app --rm $(IMAGE_NAME) $(ARGS)
