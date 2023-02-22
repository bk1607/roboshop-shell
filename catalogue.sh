source common.sh
component = 'catalogue'


print_head "copying catalogue service file"
cp "${code_dir}"/configs/catalogue.service /etc/systemd/system/catalogue.service &>>"${log_file}"
error_check $?

print_head "copying mongodb repo file "
cp "${code_dir}"/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>"${log_file}"
error_check $?

print_head "installing mongodb"
yum install mongodb-org-shell -y &>>"${log_file}"
error_check $?

print_head "loading the schema"
mongo --host mongodb.devops2023.online </app/schema/catalogue.js &>>"${log_file}"
error_check $?


print_head " do daemon-reload and restart the catalogue service "
systemctl daemon-reload
systemctl enable catalogue
systemctl restart catalogue
error_check $?