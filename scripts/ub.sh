#!/bin/bash

#SSH demon

file=/etc/ssh/sshd_config
echo $1
permit[1]="PermitRootLogin"
permit[2]="PasswordAuthentication"

for P in ${permit[@]}
do
        sed -i "/^$P'/d" ${file}
        echo "${P} no" >> ${file}
done

systemctl restart ssh
apt-get update -y
apt-get install fail2ban -y
systemctl enable fail2ban
systemctl restart fail2ban

#NGINX demon

apt-get install nginx -y
mkdir -p /var/www/tutorial
cat > /var/www/tutorial/index.html << EOF
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Hello, Nginx!</title>
</head>
<body>
    <h1>Hello, Nginx!</h1>
    <p>We have just configured our Nginx web server on Ubuntu Server!</p>
</body>
</html>
EOF
cat > /etc/nginx/sites-enabled/tutorial << EOF
server {
       listen 81;
       listen [::]:81;

       server_name example.ubuntu.com;

       root /var/www/tutorial;
       index index.html;

       location / {
               try_files \$uri \$uri/ =404;
       }
}
EOF

systemctl restart nginx

#USER

useradd -m -G sudo -s /bin/bash tutor-a
mkdir -p /home/tutor-a/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIChvBKAJbIt0H0O26DbZnu2I0kHG+OJBEvR0UkgqWwFb tutor-a" > /home/tutor-a/.ssh/authorized_keys
chown -R tutor-a:tutor-a /home/tutor-a/

sed -i '/%sudo/d' /etc/sudoers
echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

aws configure set default.region eu-central-1



echo "!!!!!!!!set hostname!!!!!!!!"

echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
account_id="$(aws sts get-caller-identity --query Account --output text)"
instance_id="$(curl http://169.254.169.254/latest/meta-data/instance-id)"
my_hostname="$(aws ec2 describe-instances --instance-ids ${instance_id} --query "Reservations[].Instances[].[Tags[?Key==\`Name\`].Value | [0]    ]" --output text)"


hostnamectl set-hostname ${my_hostname}"."${account_id}".cirruscloud.click"

<<comments
#noip_install

apt install make -y
apt install gcc -y

echo "MC4wLjAuMAAAAAAAAAAAAAUAkCZMMkpBbAAAAAEBAQBldGgwAAAAAAAAAAAAAAAAZFhObGNtNWhiV1U5Y3pnNU5qVTFOemMwTkRjNUpUUXdaMjFoYVd3dVkyOXRKbkJoYzNNOU1USlBZM1J2WW1WeU1UazROQ1pvVzEwOWRXSjFiblIxZFdRMWMyVnRaVzR1WkdSdWN5NXVaWFE9" | base64 -d > /usr/local/etc/no-ip2.conf


cd /usr/local/src
wget http://www.noip.com/client/linux/noip-duc-linux.tar.gz
tar xf noip-duc-linux.tar.gz
cd "noip-2.1.9-1/"
make

cp noip2 /usr/local/bin/noip2
chmod 700 /usr/local/bin/noip2
chown root:root /usr/local/bin/noip2

cat > /etc/systemd/system/noip2.service << EOF
[Unit]
Description=No-Ip Dynamic DNS Update Service
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/bin/noip2

[Install]
WantedBy=multi-user.target
EOF

systemctl enable noip2.service
systemctl restart noip2.service
comments

systemctl daemon-reload
systemctl enable assume_role.service
/usr/local/bin/assume_role.sh







