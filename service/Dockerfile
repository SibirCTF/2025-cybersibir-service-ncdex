FROM crystallang/crystal:1.15-alpine AS builder

RUN apk update && apk add --no-cache \
    gcc \
    musl-dev \
    libevent-static \
    openssl-libs-static \
    openssl-dev \
    zlib-static \
    sqlite-static \
    yaml-static

WORKDIR /app

COPY shard.yml shard.lock ./
RUN shards install --production --ignore-crystal-version

COPY ./ ./
RUN shards build --production --release --static --no-debug --progress --verbose

FROM alpine:3.21 AS production

RUN apk update && apk add --no-cache tzdata ca-certificates

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /home/appuser

COPY --from=builder /app/bin/nightcity-data-exchange .
COPY --from=builder /app/config ./config
COPY --from=builder /app/public ./public
COPY --from=builder /app/src/views ./src/views

RUN chown -R appuser:appgroup /home/appuser

USER appuser

EXPOSE 7331

ENV KEMAL_ENV=production

CMD ["./nightcity-data-exchange"]
