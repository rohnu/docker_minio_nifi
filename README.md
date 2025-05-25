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

