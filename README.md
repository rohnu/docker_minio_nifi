# docker_minio_nifi

The Docker Compose setup for a fresh MinIO + NiFi TLS-secured deployment is now complete and saved as a reusable GitHub-style YAML textdoc. This setup includes:
	•	HTTPS TLS (self-signed certs via custom CA)
	•	PKCS12 → JKS support for NiFi
	•	JDBC driver mounting
	•	Secure initial admin config
	•	Custom Docker network (minio_nifi_network)
