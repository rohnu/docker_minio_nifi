#!/bin/bash
## Import MinIO cert into Java truststore if not already imported
if ! keytool -list -cacerts -storepass changeit | grep -q "minio-edms"; then
        echo "Importing MinIO SSL cert into Java truststore..."
        keytool -importcert -alias minio-edms -file /opt/minio/certs/CAs/public.crt -cacerts -storepass changeit -noprompt
fi
