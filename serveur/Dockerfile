FROM alpine:latest AS build
RUN apk add --no-cache build-base
WORKDIR /app
COPY . .
RUN gcc -o serveur serveur.c

FROM alpine:latest
WORKDIR /usr/local/bin
COPY --from=build /app/serveur .
CMD ["./serveur", "6000"]
