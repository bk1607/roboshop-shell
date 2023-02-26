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


}

systemd_setup(){
  print_head "Configuring systemctl file"
  cp "${code_dir}"/configs/"${component}".service /etc/systemd/system/"${component}".service &>>"${log_file}"
  error_check $?

  print_head "Daemon reloading"
  systemctl daemon-reload &>>"${log_file}"
  error_check $?

  sed -i "s/ROBOSHOP_USER_PASSWORD/${roboshop_password}" /etc/systemd/system/"${component}".service &>>"${log_file}"

  print_head "Enable and start the service"
  systemctl enable "${component}" &>>"${log_file}"
  systemctl start "${component}" &>>"${log_file}"
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
    mongo --host mongodb.devops2023.online </app/schema/"${component}".js &>>"${log_file}"
    error_check $?
  elif [ "${schema_type}" == 'mysql' ];then
    print_head "Installing mysql"
    yum install mysql -y &>>"${log_file}"
    error_check $?

    print_head "Loading schema"
    mysql -h mysql.devops2023.online -uroot -p"${mysql_root_password}" < /app/schema/"${component}".sql &>>"${log_file}"
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

  print_head "Downloading Dependencies"
  npm install &>>"${log_file}"
  error_check $?

  schema_setup

  systemd_setup


}

java(){
  print_head "Installing maven"
  yum install maven -y
  error_check $?

  app_setup

  print_head "Downloading dependencies"
  mvn clean package
  mv target/"${component}"-1.0.jar "${component}".jar &>>"${log_file}"
  error_check $?

  schema_setup

  systemd_setup

}

python(){
  print_head "Installing python"
  yum install python36 gcc python3-devel -y &>>"${log_file}"
  error_check $?

  app_setup

  print_head "installing dependencies"
  pip3.6 install -r requirements.txt &>>"${log_file}"
  error_check $?

  systemd_setup

}

golang(){
  print_head "Installing goang"
  yum install golang -y &>>"${log_file}"
  error_check $?

  app_setup

  print_head "Installing Dependencies"
  go mod init dispatch &>>"${log_file}"
  go get &>>"${log_file}"
  go build &>>"${log_file}"
  error_check $?

  systemd_setup
}