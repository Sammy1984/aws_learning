#!/bin/bash

#SSH demon

file=/etc/ssh/sshd_config
echo $1
permit[1]="PermitRootLogin"
permit[2]="PasswordAuthentication"

for P in ${permit[@]}
do
        sed -i "/^$P/d" ${file}
        echo "${P} no" >> ${file}
done
systemctl restart sshd

amazon-linux-extras install epel -y
yum-config-manager --enable epel

#fail2ban
amazon-linux-extras install epel -y
yum -y install fail2ban
systemctl start fail2ban
systemctl enable fail2ban
systemctl restart fail2ban

#NGINX demon
yum -y install nginx
systemctl start nginx

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
    <p>We have just configured our Nginx web server on Amazon Linux 2 Server!</p>
</body>
</html>
EOF

cat > /etc/nginx/conf.d/tutorial.conf << EOF

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
systemctl enable nginx
systemctl restart nginx

#ll
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-port=81/tcp
firewall-cmd --reload
#USER

systemctl reload nginx

useradd -m -G wheel -s /bin/bash tutor-a
mkdir -p /home/tutor-a/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIChvBKAJbIt0H0O26DbZnu2I0kHG+OJBEvR0UkgqWwFb tutor-a" > /home/tutor-a/.ssh/authorized_keys
chown -R tutor-a:tutor-a /home/tutor-a/
chown -R tutor-a:tutor-a /home/tutor-a/.ssh/authorized_keys
sed -i '/%wheel/d' /etc/sudoers
echo "%wheel   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

echo "!!!!!!!!set hostname!!!!!!!!" 

echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
region="$(aws configure list | grep region | awk '{print $2}')"
account_id="$(aws sts get-caller-identity --query Account --output text)"
instance_id="$(curl http://169.254.169.254/latest/meta-data/instance-id)"
my_hostname="$(aws ec2 describe-instances --region ${region} --instance-ids ${instance_id} \
	--query "Reservations[].Instances[].[Tags[?Key==\`Name\`].Value | [0]]" --output text)"


hostnamectl set-hostname ${my_hostname}"."${account_id}".cirruscloud.click"

<<comments
#noip2_install

yum install -y noip

echo "MC4wLjAuMAAAAAAAAAAAAAUAoyVMMkpBaAAAAAEBAQBldGgwAAAAAAAAAAAAAAAAZFhObGNtNWhiV1U5Y3pnNU5qVTFOemMwTkRjNUpUUXdaMjFoYVd3dVkyOXRKbkJoYzNNOU1USlBZM1J2WW1WeU1UazROQ1pvVzEwOVlXd3lkV1ExYzJWdFpXNHVaR1J1Y3k1dVpYUT0=" | base64 -d > /etc/no-ip2.conf

sysremctl enable noip.service
systemctl restart noip.service

comments

systemctl daemon-reload
sudo systemctl enable assume_role.service
/usr/local/bin/assume_role.sh
