source common.sh

print_head "copying the mongodb repo file"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${log_file}

print_head "installing mongodb"
yum install mongodb-org -y &>>${log_file}

print_head "enable and start the mongodb service"
systemctl enable mongod &>>${log_file}
systemctl start mongod &>>${log_file}

#print_head "edit the ip address to 0.0.0.0"
