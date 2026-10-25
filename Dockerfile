FROM golang:1.27.3-alpine@sha256:b8c9b82affbbb82a020bbcf998dad2ba9516944ac7e883524642a481a9505e9c AS build

RUN apk add --no-cache build-base sqlite-dev

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY cmd ./cmd
COPY internal ./internal
COPY static ./static

RUN go build -o /app/shortslug ./cmd/shortslug

FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a
RUN apk add --no-cache ca-certificates sqlite-libs

WORKDIR /app
COPY --from=build /app/shortslug /app/shortslug
COPY --from=build /app/static /app/static

ENV FRONTEND_DIR=/app/static
EXPOSE 8080

CMD ["/app/shortslug"]
