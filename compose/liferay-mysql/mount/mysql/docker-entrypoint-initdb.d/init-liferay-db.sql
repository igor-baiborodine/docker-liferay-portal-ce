CREATE DATABASE lportal CHARACTER SET utf8;

CREATE USER 'lportal_user'@'%' IDENTIFIED BY 'lportal_user_pwd';
GRANT ALL PRIVILEGES ON lportal.* TO 'lportal_user'@'%';
FLUSH PRIVILEGES;

