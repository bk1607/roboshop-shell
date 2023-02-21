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