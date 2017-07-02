#!/usr/bin/env ruby

# ./docker-auth.rb -e production -p 3000 /etc/docker/ca/easy-rsa/easyrsa3/pki/crl.pem

require 'openssl'
require 'sinatra'
require 'base64'
require 'json'
# require 'pp'


CRL_FILE = ARGV[-1]
REVOKED = OpenSSL::X509::CRL::new(File.read(CRL_FILE)) . revoked


def is_revoked serial
  REVOKED.any? {|r| r.serial == serial}
end


ALLOW = '{"Allow": true}'
DENY = '{"Allow": false, "Msg": "Access denied"}'


def verify
  body = request.body.read
  req = JSON.parse(body)
  # pp req
  cs = req["RequestPeerCertificates"]
  if cs && !cs.empty?
    user = req["User"]
    cert = OpenSSL::X509::Certificate.new(Base64.decode64(cs[0]))
    # pp cert
    if is_revoked(cert.serial)
      puts "deny #{user}"
      halt DENY
    end
    puts "allow #{user}"
  end
  ALLOW
end


post '/AuthZPlugin.AuthZReq' do
  verify
end


post '/AuthZPlugin.AuthZRes' do
  verify
end


post '/Plugin.Activate' do
  '{"Implements": ["authz"]}'
end
