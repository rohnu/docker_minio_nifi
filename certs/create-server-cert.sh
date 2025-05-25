#Step 1: Create a Certificate for Your Local Server -Create a Private Key
#Create a Certificate Signing Request (CSR)
openssl genrsa -out server.key 2048 && openssl req -new -key server.key -out server.csr
