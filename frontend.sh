#configuring frontend web server
source common.sh
print_head "Installing nginx server"

yum install nginx -y &>>${log_file}

print_head "Removing the default html content"

rm -rf /usr/share/nginx/html/* &>>${log_file}

print_head "Downloading and extracting the frontend content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${log_file}

print_head "nginx config for roboshop"
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>${log_file} &>>${log_file}

cp ${code_dir}/configs/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${log_file}

print_head "Enable and start the nginx server"

systemctl enable nginx &>>${log_file}
systemctl restart nginx &>>${log_file}
