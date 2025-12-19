FROM gcc:11 AS build
WORKDIR /app
COPY . .
RUN gcc -o client client.c

FROM alpine:latest
WORKDIR /usr/local/bin
COPY --from=build /app/client .
CMD ["./client", "serveur-service", "6000"]
