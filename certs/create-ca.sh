#Step-by-Step: Create a Local Certificate Authority (CA)
#Step 1: Create a Root Key - This is the private key for your CA.
#Step 2: Create the Root Certificate (Self-Signed) - This certifies your root key as a Certificate Authority.
mkdir ~/edms_certs
cd edms_certs
openssl genrsa -out rootCA.key 2048 && openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem
