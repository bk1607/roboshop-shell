source common.sh
print_head "Installing repo file"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>"${log_file}"
error_check $?

print_head "Enable redis 6.2 module"
dnf module enable redis:remi-6.2 -y &>>"${log_file}"
error_check $?

print_head "Installing redis"
yum install redis -y &>>"${log_file}"
error_check $?

print_head "updating ip address"
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>"${log_file}"
error_check $?

print_head "Enable and start the service"
systemctl enable redis &>>"${log_file}"
systemctl start redis &>>"${log_file}"
error_check $?