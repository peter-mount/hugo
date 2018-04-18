# ============================================================
# Docker file to create our hugo image
# ============================================================

ARG arch=amd64
ARG goos=linux

# ============================================================
# The go build container
FROM golang:alpine as build
ARG arch

# The golang alpine image is missing git so ensure we have additional tools
RUN apk add --no-cache \
      ca-certificates \
      curl \
      git

# Arm64 needs gcc as its not in the image
RUN if [ "${arch}" = "arm" -o "${arch}" = "arm64" ];\
    then \
      apk add --no-cache \
        cmake \
        gcc \
        g++ \
        libgcc \
        libstdc++ \
        linux-headers ;\
    fi

# ============================================================
# From https://gohugo.io/getting-started/installing/
RUN go get github.com/magefile/mage

RUN go get -d github.com/gohugoio/hugo

RUN cd ${GOPATH:-$HOME/go}/src/github.com/gohugoio/hugo &&\
    mage vendor &&\
    mage install

# ============================================================
# Finally build the final runtime container for the specific
# microservice
FROM alpine

# The default database directory
Volume /work
WORKDIR /work

# Install our built image
COPY --from=build /go/bin/hugo/ /bin/hugo

#ENTRYPOINT ["/nrodcif"]
#CMD [ "-c", "/config.yaml"]
CMD [ "ash" ]
