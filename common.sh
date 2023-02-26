print_head(){
  echo -e "\e[35m$1\e[0m"
}

log_file=$(touch /tmp/roboshop.org)

code_dir=$(pwd)

error_check(){
  if [ $1 -eq 0 ];then
    echo -e "\e[35mSuccess\e[0m"
  else
    echo -e "\e[31mSomething went wrong check ${log_file} for the error details\e[0m"
  fi
}