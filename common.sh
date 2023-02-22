#it is used to print the output with colour
code_dir=$(pwd)
log_file=/tmp/roboshop.log
rm -f ${log_file}
print_head(){
  echo -e "\e[35m$1 \e[0m"
}

error_check(){
  if [ $1 -eq 0 ]; then
    echo SUCCESS
  else
    echo FAILURE
    echo READ the log file ${log_file} for more information about error_check
    exit 1
  fi
}

node_js(){
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
  curl -L -o /tmp/"$1.zip" https://roboshop-artifacts.s3.amazonaws.com/"$1.zip" &>>"${log_file}"
  error_check $?

  print_head "change to app directory"
  cd /app
  error_check $?

  print_head "unzipping the file"
  unzip /tmp/"$1.zip" &>>${log_file}
  error_check $?

  print_head "install nodejs dependencies"
  npm install &>>$"{log_file}"

  print_head "copying catalogue service file"
  cp "${code_dir}"/configs/"$1.service" /etc/systemd/system/"$1.service" &>>"${log_file}"
  error_check $?

}
mongodb() {
  print_head "copying mongodb repo file "
  cp "${code_dir}"/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>"${log_file}"
  error_check $?

  print_head "installing mongodb"
  yum install mongodb-org-shell -y &>>"${log_file}"
  error_check $?

  print_head "loading the schema"
  mongo --host mongodb.devops2023.online </app/schema/"$1".js &>>"${log_file}"
  error_check $?

  print_head "daemon-reload and restart the catalogue service "
  systemctl daemon-reload
  systemctl enable $1 &>>${log_file}
  systemctl restart $1 &>>${log_file}

}