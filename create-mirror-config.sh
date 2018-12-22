#!/usr/bin/env bash

mkdir docker-config
cat <<EOF > "docker-config/daemon.json"
{
  "insecure-registries" : [
    "10.0.0.0/8"
  ],
  "debug" : true,
  "experimental" : false,
  "registry-mirrors" : [
    "https://your-1st-mirror.localdomain:5001",
    "https://your-2nd-mirror.localdomain:5002"
  ]
}
EOF

mkdir -p "docker-config/certs.d/your-1st-mirror.localdomain:5001"


cat <<EOF > "docker-config/certs.d/your-1st-mirror.localdomain:5001/domain.crt"
-----BEGIN CERTIFICATE-----
<your certificate data>
-----END CERTIFICATE-----
EOF

mkdir -p "docker-config/certs.d/your-1st-mirror.localdomain:5002"
cat <<EOF > "docker-config/certs.d/your-1st-mirror.localdomain:5002/domain.crt"
-----BEGIN CERTIFICATE-----
<your certificate data>
-----END CERTIFICATE-----
EOF

cd docker-config
tar -czvf ../config.tar.gz .
cd ..

base64 config.tar.gz > config.tar.gz.txt

rm -Rf docker-config
rm config.tar.gz

printf "\n\ncopy the base 64 encoded text that was just put intoo config.tar.gz.txt into your \ncloud-init YAML file in the section for writing files. \nIt will be decoded and land as binary file in your machine.\n\n"
