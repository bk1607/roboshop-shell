source common.sh

print_head "setting up nodejs repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>"${log_file}"
error_check $?

print_head "installing nodejs"
yum install nodejs -y &>>"${log_file}"
error_check $?

print_head "add application user"
id roboshop &>>"${log_file}"
if [ $? -ne 0 ];then
  useradd roboshop &>>"${log_file}"
fi
error_check $?

print_head "creating app directory"
if [ ! -d /app ];then
  mkdir /app &>>"${log_file}"
elif [ -d /app ];then
  rm -rf /app/* &>>${log_file}
fi
error_check $?

print_head "Downloading catalogue files"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>"${log_file}"
error_check $?

print_head "change to app directory"
cd /app
error_check $?

print_head "unzipping the file"
unzip /tmp/catalogue.zip &>>${log_file}
error_check $?

print_head "install nodejs dependencies"
npm install &>>$"{log_file}"
error_check $?

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