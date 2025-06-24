FROM nginx:latest AS keybuilder

COPY certs/ nginx/gestmed.conf nginx/keycloak-idp.conf /certs/

WORKDIR /certs

RUN ./create-key-and-cert.sh gestmed
RUN ./create-key-and-cert.sh keycloak-idp

###################################################

FROM nginx:latest

COPY --from=keybuilder /certs/gestmed.key /certs/gestmed.crt /certs/keycloak-idp.crt /certs/keycloak-idp.key /etc/nginx/certs/
