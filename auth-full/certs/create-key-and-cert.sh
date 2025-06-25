#!/bin/sh

set -e

# Shell script used to create your rsa key and certificate

CA_CERT="dev-ca.crt"
CA_KEY="dev-ca.key"
CN=$1

KEYNAME="${CN}.key"
REQNAME="${CN}.csr"
CERTNAME="${CN}.crt"
CONF_FILE="${CN}.conf"

echo "Generating key..."
openssl genrsa -out $KEYNAME
echo "Done"

echo "Generating request..."
openssl req -new \
	-key $KEYNAME \
	-out $REQNAME \
	-config $CONF_FILE
echo "Done"

echo "Generating certificate..."
openssl x509 -req \
	-CA $CA_CERT \
	-CAkey $CA_KEY \
	-in $REQNAME \
	-out $CERTNAME \
	-days 365 \
	-extfile $CONF_FILE \
	-extensions server_cert
echo "Done"

echo "Cleaning up..."
rm -f *.csr
echo "Done"
