source common.sh
print_head "installing maven"
yum install maven -y &>>"${log_file}"
error_check $?

app_preq_setup shipping

print_head "download dependencies"
mvn clean package &>>"${log_file}"
mv target/shipping-1.0.jar shipping.jar &>>"${log_file}"
error_check $?

systemd_setup shipping

print_head "installing mysql"
yum install mysql -y &>>"${log_file}"
error_check $?

