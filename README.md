# docker_minio_nifi

This repository contains a secure **Docker Compose** setup for deploying **MinIO** and **Apache NiFi** using **self-signed TLS certificates**.

![image](https://github.com/user-attachments/assets/c9835ee6-44ef-4764-a89d-98a29233a4ba)


---

## ✅ Features

- 🔐 HTTPS TLS via custom CA (self-signed)
- 🔁 PKCS#12 → JKS certificate support for NiFi
- 📦 JDBC driver integration (MS SQL Server ready)
- 🛡️ Initial admin identity for secure NiFi access
- 🔗 Custom Docker network: `minio_nifi_network` for Single Node Single Drive

---

## 🎯 Why TLS for MinIO & NiFi?

Both MinIO and NiFi benefit from TLS in these ways:

- Encrypt communication between client and server
- Protect against man-in-the-middle attacks
- Enable mutual authentication
- Comply with secure data pipeline practices

▶️ **Reference Video**: [MinIO TLS & Docker - YouTube](https://www.youtube.com/watch?v=Mc_sWPaTHO8)

---

## 🔧 Certificate Setup (Local CA)

### Step 1: Create Root Key & Certificate Authority

```bash
mkdir ~/edms_certs
cd ~/edms_certs
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem

Step 2: Create Server Certificate
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr

Edit a file called localhost.ext:

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = <FQDN or HOSTNAME>
IP.1  = <X.X.X.X>

Sign with CA:

openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile server.ext

Step 3: Create PKCS12 & JKS for NiFi

openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12
keytool -importkeystore -srckeystore server.p12 -srcstoretype PKCS12 -destkeystore server.jks -deststoretype JKS

Step 4: Create NiFi Truststore

keytool -import -file rootCA.pem -alias cacert -keystore truststore.jks -storepass <password>

📁 Copy Certs to Docker Paths
	•	For NiFi:
	•	server.jks → /opt/nifi/certs/
	•	truststore.jks → /opt/nifi/certs/
	•	For MinIO:
	•	Rename:
	•	server.crt → public.crt
	•	server.key → private.key
	•	Copy both to /opt/minio/certs/CAs/

🔑 MinIO Certificate Trust Script

Save the following as /opt/minio/certs/minio-keystore.sh:

#!/bin/bash
## Import MinIO cert into Java truststore if not already imported
if ! keytool -list -cacerts -storepass changeit | grep -q "minio-edms"; then
    echo "Importing MinIO SSL cert into Java truststore..."
    keytool -importcert -alias minio-edms -file /opt/minio/certs/CAs/public.crt -cacerts -storepass changeit -noprompt
fi

Then make it executable:

chmod +x /opt/minio/certs/minio-keystore.sh

🐳 Next Steps

👉 Add the docker-compose.yml file (provided in this repo)
👉 Run the Docker containers:

docker network create minio_nifi_network
docker compose up -d minio
docker compose up -d nifi

🧪 Open the following URLs in your browser (after uploading the .pfx cert):
	•	MinIO: https://:9001
	•	NiFi: https://:9443/nifi
