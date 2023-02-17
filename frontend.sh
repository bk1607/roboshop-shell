#configuring frontend web server

code_dir=$(pwd)
echo -e "\e[31mInstalling nginx server \e[0m"

sudo yum install nginx -y

echo -e "\e[31mRemoving the default html content \e[0m"

rm -rf /usr/share/nginx/html/*

echo -e "\e[31mDownloading and extracting the frontend content \e[0m"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip

cd /usr/share/nginx/html
unzip /tmp/frontend.zip

cp ${code_dir}/configs/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf

echo -e "\e[31mEnable and start the nginx server \e[0m"

systemctl enable nginx
systemctl start nginx
