Install this plugin:
```sh
apt-get install ruby ruby-sinatra
mkdir -p /etc/docker/plugins

addgroup --system docker-ca
adduser --system --no-create-home --ingroup docker-ca docker-auth-crl

cp docker-auth-crl.spec /etc/docker/plugins/
cp docker-auth-crl.service /etc/systemd/system/
systemctl enable docker-auth-crl.service
```


Install easy-rsa:
```sh
mkdir /etc/docker-ca
cd /etc/docker-ca
git clone https://github.com/OpenVPN/easy-rsa.git
cd /etc/docker-ca/easy-rsa/easyrsa3
bash ./easyrsa init-pki
chmod 750 pki
chgrp docker-ca pki
bash ./easyrsa build-ca nopass
bash ./easyrsa build-server-full YOUR-HOSTNAME nopass
bash ./easyrsa build-client-full client1 nopass
bash ./easyrsa build-client-full client2 nopass
bash ./easyrsa gen-crl
chmod 644 pki/crl.pem
```

Configure docker:
```sh
systemctl edit docker.service
```

Set `ExecStart`:

```sh
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// --authorization-plugin=docker-auth-crl --host tcp://0.0.0.0:2367 --tlsverify --tlscacert /etc/docker-ca/easy-rsa/easyrsa3/pki/ca.crt --tlscert /etc/docker-ca/easy-rsa/easyrsa3/pki/issued/YOUR-HOSTNAME.crt --tlskey /etc/docker-ca/easy-rsa/easyrsa3/pki/private/YOUR-HOSTNAME.key
```


Restart docker:
```sh
systemctl restart docker.service
```


Deny access for `client1`:
```sh
cd /etc/docker-ca/easy-rsa/easyrsa3
bash ./easyrsa revoke client1
bash ./easyrsa gen-crl
chmod 644 pki/crl.pem
systemctl restart docker-auth-crl
```
