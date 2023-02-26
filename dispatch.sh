source common.sh
roboshop_password=$1
if [ -z "${roboshop_password}" ];then
  echo -e "\e[31mMissing password argument\e[0m"
  exit 1
fi

component='dispatch'
golang