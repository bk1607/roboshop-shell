source common.sh

mysql_root_password=$1
if [ -z "${mysql_root_password}" ];then
  echo -e "\e[31mMissing mysql server root password\e[0m"
  exit 1
fi

print_head "disable mysql 8 version"
dnf module disable mysql -y &>>"${log_file}"
error_check $?

print_head "copy mysql.repo file"
cp "${code_dir}"/configs/mysql.repo /etc/yum.repos.d/mysql.repo &>>"${log_file}"
error_check $?

print_head "install mysql server"
yum install mysql-community-server -y &>>"${log_file}"
error_check $?

print_head "enable mysql service"
systemctl enable mysqld &>>"${log_file}"
error_check $?

print_head "restart mysql service"
systemctl restart mysqld &>>"${log_file}"
error_check $?

print_head "set root password for mysql database"
echo show databases | mysql -uroot -p"$mysql_root_password" &>>"${log_file}"
if [ $? -ne 0 ];then
  mysql_secure_installation --set-root-pass "${mysql_root_password}" &>>"${log_file}"
fi
error_check $?

