source common.sh

mysql_root_password=$1
if [ -z "${mysql_root_password}" ];then
  echo -e "\e[31mMissing password argument\e[0m"
  exit 1
fi

print_head "Disable mysql 8 version"
dnf module disable mysql -y &>>"${log_file}"
error_check $?

print_head "Setup mysql 5.7 version repo file"
cp "${code_dir}"/configs/mysql.repo /etc/yum.repos.d/mysql.repo &>>"${log_file}"
error_check $?

print_head "Installing mysql"
yum install mysql-community-server -y &>>"${log_file}"
error_check $?

print_head "enable and start the mysql service"
systemctl enable mysqld &>>"${log_file}"
systemctl start mysqld &>>"${log_file}"
error_check $?

print_head "changing default root password"
mysql_secure_installation --set-root-pass "${mysql_root_password}" &>>"${log_file}"
error_check $?

print_head "checking password"
mysql -uroot -p"${mysql_root_password}"
error_check $?


