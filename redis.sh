source common.sh

print_head "installing redis"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>${log_file}
error_check $?

print_head "enable redis 6.2"
dnf module enable redis:remi-6.2 -y &>>${log_file}
error_check $?

print_head "Installing redis"
yum install redis -y &>>${log_file}
error_check $?

print_head "Changing IP address in config file"
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>>${log_file}
error_check $?

print_head "Enable and restart redis service"
systemctl enable redis &>>${log_file}
systemctl restart redis &>>${log_file}
error_check &?

