source common.sh
node_js catalogue
mongodb catalogue


print_head "daemon-reload and restart the catalogue service "
systemctl daemon-reload
systemctl enable catalogue
systemctl restart catalogue
error_check $?