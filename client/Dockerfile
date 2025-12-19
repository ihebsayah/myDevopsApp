FROM alpine:latest AS build
RUN apk add --no-cache build-base
WORKDIR /app
COPY . .
RUN gcc -o client client.c

FROM alpine:latest
WORKDIR /usr/local/bin
COPY --from=build /app/client .
CMD ["./client", "serveur-service", "6000"]
