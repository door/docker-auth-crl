sudo apt-get install ruby ruby-sinatra
sudo mkdir -p /etc/docker/plugins
sudo cp docker-auth-crl.spec /etc/docker/plugins/

./docker-auth-crl.rb -e production -p 3123 /etc/docker-ca/easy-rsa/easyrsa3/pki/crl.pem
