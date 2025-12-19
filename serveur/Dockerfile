FROM gcc:11 AS build
WORKDIR /app
COPY . .
RUN gcc -static -o serveur serveur.c

FROM alpine:latest
WORKDIR /usr/local/bin
COPY --from=build /app/serveur .
CMD ["./serveur", "6000"]
