# Purpose

These steps are for configuring the full integration of the Headless Browser for Automated Test Framework with a ServiceNow instance.
For simplified steps for development of the docker image and related automation files see the REAMDE. 

# Prereqs
1. Port 2376 accessible from outside the host
2. Host can access the Service Now instance
3. Docker is installed https://docs.docker.com/get-docker/

# Set Environment Variables
```
PASSWORD="password"
SERVERIP="172.16.252.128"
HOSTNAME="example.com"
```

### Create Certificate Authority PEM
```
openssl genrsa -aes256 -passout pass:$PASSWORD -out ca-key.pem 4096
openssl req -passin pass:$PASSWORD -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
chmod 0400 ca-key.pem
chmod 0444 ca.pem
```

###  Create the Server PEM
```
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=$HOSTNAME" -new -key server-key.pem -out server.csr
echo "subjectAltName = DNS:$HOSTNAME,IP:$SERVERIP,IP:127.0.0.1" > extfile.cnf
openssl x509 -passin pass:$PASSWORD -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf

rm server.csr extfile.cnf ca.srl
chmod 0400 server-key.pem
chmod 0444 server-cert.pem
```

#  Create the Client PEM
```
openssl genrsa -out client-key.pem 4096
openssl req -subj "/CN=example.com" -new -key client-key.pem -out client.csr
echo "extendedKeyUsage = clientAuth" > extfile.cnf
openssl x509 -passin pass:$PASSWORD -req -days 365 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -extfile extfile.cnf

rm client.csr extfile.cnf ca.srl
chmod 0400 client-key.pem
chmod 0444 client-cert.pem
```

# Create the Java Keystore
```
yum install -y java-1.8.0-openjdk
keytool -genkey -keyalg RSA -alias dse -keystore my.keystore
keytool -delete -alias dse -keystore my.keystore
```

# Import the CA certificate to the keystore
```
keytool -import -keystore my.keystore -trustcacerts -alias ca -file ca.pem
```

# Import the Client Cert/Key pair
```
openssl pkcs12 -export -name clientkeypair -in client-cert.pem -inkey client-key.pem -out clientkeypair.p12
keytool -importkeystore -destkeystore my.keystore -srckeystore clientkeypair.p12 -srcstoretype pkcs12 -alias clientkeypair

rm clientkeypair.p12
```

### Add the server keys to docker config

1. Run: `sudo systemctl edit docker.service`
2. Paste the following
```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2376"
```

3. Run
```
touch /etc/docker/daemon.json
nano /etc/docker/daemon.json
```

4. Paste the following (correct the paths)
```
{
  "tlscacert": "/home/ben.meeder/ca.pem",
  "tlscert": "/home/ben.meeder/server-cert.pem",
  "tlskey": "/home/ben.meeder/server-key.pem",
  "tlsverify": true
}
```

5. Run the following
```
systemctl daemon-reload
systemctl restart docker.service
systemctl enable docker
```

### Add the client keys to docker client
```
mkdir -pv ~/.docker
cp ca.pem ~/.docker
cp client-key.pem ~/.docker/key.pem
cp client-cert.pem ~/.docker/cert.pem
echo "export DOCKER_HOST=tcp://${SERVERIP}:2376 DOCKER_TLS_VERIFY=1" >> ~/.bash_profile
source ~/.bash_profile
```

### Following Commands should be successful
* `docker ps `
* `curl https://$SERVERIP:2376/images/json \
  --cert ~/.docker/cert.pem \
  --key ~/.docker/key.pem \
  --cacert ~/.docker/ca.pem`

### Set ServiceNow password with docker secrets
```
docker swarm init
echo "ServiceNow password" | docker secret create sn_password -
```
