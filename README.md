# docker_minio_nifi

The Docker Compose setup for a fresh MinIO + NiFi TLS-secured deployment is now complete and saved as a reusable GitHub-style YAML textdoc. This setup includes:
	•	HTTPS TLS (self-signed certs via custom CA)
	•	PKCS12 → JKS support for NiFi
	•	JDBC driver mounting
	•	Secure initial admin config
	•	Custom Docker network (minio_nifi_network)

Securing Access to MinIO & NIFI Server with a Self-Signed Certificate using custom CA certificate
MinIO and NIFI require Transport Layer Security (TLS) configuration for multiple reasons.
To encrypt communication between clients and server (this provides confidentiality and integrity over transmitted data)
To prevent malicious users from intercepting data or impersonating the server
To enable any authentication & authorization mechanisms

Training video: https://www.youtube.com/watch?v=Mc_sWPaTHO8

Install production SSL certs and keystores.

Step-by-Step: Create a Local Certificate Authority (CA)

Step 1: Create a Root Key
This is the private key for your CA.
mkdir ~/edms_certs
cd edms_certs
openssl genrsa -out rootCA.key 2048

Step 2: Create the Root Certificate (Self-Signed)
This certifies your root key as a Certificate Authority.
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem

Step 3: Create a Certificate for Your Local Server
Create a Private Key
openssl genrsa -out server.key 2048
Create a Certificate Signing Request (CSR)
openssl req -new -key server.key -out server.csr

Note: Ensure FQDN or hostname is changed according to the production server

Step 4: Create a Config File for the Certificate (SAN Support)
Create a file server.ext with the following content:
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = <FQDN or HOSTNAME>
IP.1=<X.X.X.X>

Step 5: Sign the Certificate Using Your Root CA
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile server.ext
openssl x509 -in rootCA.pem -text -noout
Ensure Subject Alternative Name is added as below in the server.crt like DNS and IP 

The easiest is probably to create a PKCS#12 file using OpenSSL:
openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12
You should be able to use the resulting file directly using the PKCS12 keystore type or convert it to JKS using keytool -importkeystore
JKS Support: NiFi can utilize JKS files for both keystores (containing private keys and certificates) and truststores (containing trusted certificates). 
Preferred Format: While NiFi can also handle PKCS12 keystores, JKS is generally the preferred format for NiFi as it is handled more robustly and causes fewer edge cases. 
keytool -importkeystore -srckeystore server.p12  -srcstoretype PKCS12  -destkeystore server.jks  -deststoretype JKS

Step 6: Create a truststore.jks
keytool -import -file rootCA.pem -alias cacert -keystore truststore.jks -storepass /password/

Step 7: Copy all certificate files in the respective folders for MinIO & Nifi
Nifi: server.jks and truststore.jks files to /opt/nifi/certs
MinIO: server.crt and server.key files to /opt/minio/certs/CAs
Rename server.crt as public.crt
Rename server.key as private.key

##Create minio-keystore.sh (place it inside your image at /opt/minio/certs/)

The below script will be used in the docker compose file to trust the minio server from Nifi 
#!/bin/bash
 Import MinIO cert into Java truststore if not already imported
if ! keytool -list -cacerts -storepass changeit | grep -q "minio-edms"; then
        echo "Importing MinIO SSL cert into Java truststore..."
        keytool -importcert -alias minio-edms -file /opt/minio/certs/CAs/public.crt -cacerts -storepass changeit -noprompt
fi

Make this executable:
chmod +x /opt/minio/certs/minio-keystore.sh


