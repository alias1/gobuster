FROM golang:alpine AS build-env
WORKDIR /go/src/app
RUN apk add --no-cache git
COPY main.go /go/src/app/
RUN go get
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o gobuster

#FROM scratch as scratch
#COPY --from=build-env /go/src/app/gobuster /gobuster
#ENTRYPOINT ["/gobuster"]

FROM alpine:edge AS pack-env
WORKDIR /
RUN apk add --no-cache upx
COPY --from=build-env /go/src/app/gobuster /
RUN upx --brute gobuster -ogobuster.upx

FROM scratch as scratch-packed
# Install ca root certificates
#   https://curl.haxx.se/docs/caextract.html
#   http://blog.codeship.com/building-minimal-docker-containers-for-go-applications/
ADD https://curl.haxx.se/ca/cacert.pem /etc/ssl/certs/ca-certificates.crt
COPY --from=pack-env /gobuster.upx /gobuster
ENTRYPOINT ["/gobuster"]

#FROM alpine as alpine-packed
#RUN apk add --no-cache ca-certificates
#COPY --from=pack-env /gobuster.upx /gobuster
#ENTRYPOINT ["/gobuster"]
