### Generate private key

```
openssl genrsa -out privatekey.pem 2048
```

### Create a self-signed certificate

```
openssl req -new -x509 -key privatekey.pem -out self-signed-certificate.pem -days 1095
```