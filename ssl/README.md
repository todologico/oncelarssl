Generar el certificado dentro de la carpeta ssl:

openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048  
openssl req -new -key private.pem -out request.csr  
openssl x509 -req -days 365 -in request.csr -signkey private.pem -out certificate.pem  
