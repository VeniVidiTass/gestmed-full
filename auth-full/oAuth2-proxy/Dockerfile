FROM quay.io/oauth2-proxy/oauth2-proxy:latest-alpine

COPY certs/dev-ca.crt /ca-certs/

RUN apk update && \
	apk add curl

ENV OAUTH2_PROXY_PROVIDER_CA_FILES="/ca-certs/dev-ca.crt"
