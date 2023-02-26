print_head(){
  echo -e "\e[35m$1\e[0m"
}

log_file=/tmp/roboshop.org

code_dir=$(pwd)

error_check(){
  if [ $1 -eq 0 ];then
    echo -e "\e[33mSuccess\e[0m"
  else
    echo -e "\e[31mSomething went wrong check ${log_file} for the error details\e[0m"
  fi
}

app_setup(){
  print_head "Creating roboshop app user"
  id roboshop &>>"${log_file}"
  if [ $? -ne 0 ];then
    useradd roboshop
  fi
  error_check $?

  print_head "creating app directory"
  mkdir /app &>>"${log_file}"
  if [ $? -ne 0 ];then
    rm -rf /app/* &>>"${log_file}"
  fi

  print_head "Downloading app content"
  curl -L -o /tmp/"${component}".zip https://roboshop-artifacts.s3.amazonaws.com/"${component}".zip &>>"${log_file}"
  error_check $?

  print_head "extracting app content"
  cd /app
  unzip /tmp/"${component}".zip &>>"${log_file}"
  error_check $?

  print_head "Downloading Dependencies"
  npm install &>>"${log_file}"
  error_check $?

}

systemd_setup(){
  print_head "Configuring systemctl file"
  cp "${code_dir}"/configs/"${component}".service /etc/systemd/system/"${component}".service &>>"${log_file}"
  error_check $?

  print_head "Daemon reloading"
  systemctl daemon-reload &>>"${log_file}"
  error_check $?

  print_head "Enable and start the service"
  systemctl enable catalogue &>>"${log_file}"
  systemctl start catalogue &>>"${log_file}"
  error_check $?

}

schema_setup(){
  if [ "${schema_type}" == 'mongo' ];then
    print_head "copying mongo repo files"
    cp "${code_dir}"/configs/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>"${log_file}"
    error_check $?

    print_head "Installing Mongodb"
    yum install mongodb-org-shell -y &>>"${log_file}"
    error_check $?

    print_head "Loading schema"
    mongo --host mongodb.devops2023.online </app/schema/"${component}".js
    error_check $?
  fi
}

nodejs(){
  print_head "setup nodejs repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>"${log_file}"
  error_check $?

  print_head "Installing nodejs"
  yum install nodejs -y &>>"${log_file}"
  error_check $?

  app_setup

  schema_setup

  systemd_setup


}