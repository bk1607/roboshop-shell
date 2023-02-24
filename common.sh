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

app_prereq_setup() {
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

  print_head "Downloading $1 content"
  curl -L -o /tmp/"$1.zip" https://roboshop-artifacts.s3.amazonaws.com/"$1.zip" &>>"${log_file}"
  error_check $?

  print_head "change to app directory"
  cd /app
  error_check $?

  print_head "extracting app content"
  unzip /tmp/"$1.zip" &>>${log_file}
  error_check $?

}

systemd_setup(){
  print_head "copying systemd service file"
  cp "${code_dir}"/configs/"$1.service" /etc/systemd/system/"$1.service" &>>"${log_file}"
  error_check $?

  print_head "reload systemd"
  systemctl daemon-reload
  error_check $?
}
node_js(){
  print_head "setting up nodejs repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>"${log_file}"
  error_check $?

  print_head "installing nodejs"
  yum install nodejs -y &>>"${log_file}"
  error_check $?

  app_prereq_setup

  print_head "install nodejs dependencies"
  npm install &>>$"{log_file}"

  systemd_setup

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

}
restart(){
  systemctl enable $1 &>>${log_file}
  error_check $?

  systemctl restart $1 &>>${log_file} &>>${log_file}
  error_check $?
}
schema(){
  password = $1
  if [ -z password ];then
    echo -e "\e[35mPlease enter the password[0m"
    exit 1
  else
    mysql -h mysql.devops2023.online -uroot -p"${password}" < /app/schema/shipping.sql
  fi
}
