source common.sh
print_head "creating repo files"
cp "${code_dir}"/configs/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>"${log_file}"
error_check $?

print_head "Installing mongodb"
yum install mongodb-org -y &>>"${log_file}"
error_check $?

print_head "Edit the port address "
sed -i "s/127.0.0.1/0.0.0.0" /etc/mongod.conf &>>"${log_file}"
error_check $?

print_head "Enable and restart the service"
systemctl enable mongod &>>"${log_file}"
systemctl start mongod &>>"${log_file}"
error_check $?