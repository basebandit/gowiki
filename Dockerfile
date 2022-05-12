FROM golang:1.18-alpine as base

WORKDIR /gowiki

FROM aquasec/trivy:0.14.0 as trivy

RUN trivy --debug --timeout 4m golang:1.15-alpine && \
  echo "No image vulnerabilities" > result

FROM base as dev

COPY  . .

RUN go mod download
RUN go mod verify

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN go env

RUN go build -o gowiki .

EXPOSE 8080

FROM alpine:3.10 AS production
RUN apk --no-cache add ca-certificates --upgrade bash


COPY --from=dev /gowiki .
COPY --from=dev /gowiki/edit.html .
COPY --from=dev /gowiki/view.html .


CMD ["./gowiki"]