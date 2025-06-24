FROM nginx:latest AS keybuilder

COPY certs/ nginx/keycloak-idp.conf /certs/

WORKDIR /certs

RUN ./create-key-and-cert.sh keycloak-idp

#################################################

FROM quay.io/keycloak/keycloak:latest AS builder

COPY --from=keybuilder --chown=keycloak:keycloak --chmod=775 /certs/keycloak-idp.crt /certs/keycloak-idp.key /opt/keycloak/certs/

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

RUN /opt/keycloak/bin/kc.sh build

######################################################

FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs curl --releasever 9 --setopt install_weak_deps=false --nodocs -y && \
	dnf --installroot /mnt/rootfs clean all && \
	rpm --root /mnt/rootfs -e --nodeps setup

####################################################

FROM quay.io/keycloak/keycloak:latest

COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=ubi-micro-build /mnt/rootfs /
COPY ./keycloak/gestmed-realm.json /opt/keycloak/data/import/

ENV KC_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://keycloak-database:5432/keycloak
ENV KC_DB_USERNAME=keycloak
ENV KC_DB_PASSWORD=keycloak
ENV KC_BOOTSTRAP_ADMIN_USERNAME=admin
ENV KC_BOOTSTRAP_ADMIN_PASSWORD=admin
ENV KC_HTTPS_CERTIFICATE_FILE=/opt/keycloak/certs/keycloak-idp.crt
ENV KC_HTTPS_CERTIFICATE_KEY_FILE=/opt/keycloak/certs/keycloak-idp.key
ENV KC_HTTP_ENABLED=true

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
