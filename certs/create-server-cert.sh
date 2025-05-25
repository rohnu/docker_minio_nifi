#Step 1: Create a Certificate for Your Local Server -Create a Private Key
#Create a Certificate Signing Request (CSR)
openssl genrsa -out server.key 2048 && openssl req -new -key server.key -out server.csr

#Sign the Certificate Using Your Root CA
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile localhost.ext && openssl x509 -in rootCA.pem -text -noout

