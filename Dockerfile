FROM golang:1.10-alpine3.7 AS builder

ARG CHECKMAKE_VERSION
ENV PANDOC_VERSION 2.2.1
ENV PANDOC_DOWNLOAD_URL https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux.tar.gz

RUN apk add --no-cache git make curl upx \
 && curl -fsSL "$PANDOC_DOWNLOAD_URL" | tar -xzf - pandoc-"$PANDOC_VERSION"/bin/pandoc --strip-components=2 -C /usr/local/bin \
 && chmod +x /usr/local/bin/pandoc \
 && go get github.com/mrtazz/checkmake

WORKDIR /go/src/github.com/mrtazz/checkmake

RUN git checkout "$CHECKMAKE_VERSION" && make
RUN upx --best --ultra-brute /go/bin/checkmake


FROM scratch AS runtime

# Build-time metadata as defined at http://label-schema.org & https://microbadger.com/labels
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION
LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="checkmake" \
      org.label-schema.description="Experimental linter/analyzer for Makefiles" \
      org.label-schema.version=${VERSION} \
      org.label-schema.url="https://github.com/mrtazz/checkmake" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.vendor="mrtazz" \
      org.label-schema.schema-version="1.0"

COPY --from=builder /go/bin/checkmake /bin/

WORKDIR /work

ENTRYPOINT ["/bin/checkmake"]
