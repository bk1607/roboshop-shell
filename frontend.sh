source common.sh
print_head "installing nginx"
yum install nginx -y &>>"${log_file}"
error_check $?

print_head "Removing default content"
rm -rf /usr/share/nginx/html/* &>>"${log_file}"
error_check $?

print_head "Downloading frontend content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>"${log_file}"
error_check $?

print_head "extracting frontend content"
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>"${log_file}"
error_check $?

print_head "copying reverse proxy files"
cp "${code_dir}"/configs/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>"${log_file}"
error_check $?

print_head "Enabling and restarting the service"
systemctl enable nginx &>>"${log_file}"
systemctl start nginx &>>"${log_file}"
error_check $?
