#Step 1: Create a Certificate for Your Local Server -Create a Private Key
#Create a Certificate Signing Request (CSR)
openssl genrsa -out server.key 2048 && openssl req -new -key server.key -out server.csr

#Sign the Certificate Using Your Root CA
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile localhost.ext && openssl x509 -in rootCA.pem -text -noout

openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12

#You should be able to use the resulting file directly using the PKCS12 keystore type or convert it to JKS using keytool -importkeystore
#JKS Support: NiFi can utilize JKS files for both keystores (containing private keys and certificates) and truststores (containing trusted certificates). 

keytool -importkeystore -srckeystore server.p12  -srcstoretype PKCS12  -destkeystore server.jks  -deststoretype JKS
keytool -import -file rootCA.pem -alias cacert -keystore truststore.jks -storepass /password/

