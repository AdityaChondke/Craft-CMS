FROM registry.access.redhat.com/ubi8/ubi:8.1

ENV php_conf='/etc/php.ini'

RUN yum install -y ngnix httpd php php-pdo php-common php-mcrypt php-mbstring  php-mysql php-gd php-curl elinks mariadb \
    && systemctl enable nginx \
    && systemctl enable mariadb \
    && echo "<?php phpinfo() ?>" > /usr/share/nginx/html/info.php

RUN sed -i '$ a extension=mysql.so' $php_conf \
    && sed -i '$ a extension=pdo.so' $php_conf \
    && sed -i '$ a extension=mbstring.so' $php_conf

WORKDIR /var/www/html/

RUN wget https://download.craftcdn.com/craft/2.6/2.6.2993/Craft-2.6.2993.zip \
    && unzip Craft-2.6.2993.zip \

WORKDIR /var/www/html/craft/config

RUN cat /etc/httpd/conf.d/craft.conf \ 
    && cat craft/config/db.php \
    && cat /etc/php.ini 

RUN sed -i -e 's/ server/ localhost/g' db.php \
    && sed -i -e 's/ user/ craftuser/g' db.php \
    && sed -i -e 's/ password/ Redhat@123_000/g' db.php \
    && sed -i -e 's/ database/ craft/g' db.php \
    && sed -i -e 's/ tableprfix/ craft/g' db.php

WORKDIR /var/www/html/public 
mv htaccess .htaccess




# RUN yum --disableplugin=subscription-manager -y module enable php:7.3 \
#   && yum --disableplugin=subscription-manager -y install httpd php \
#   && yum --disableplugin=subscription-manager clean all

# ADD index.php /var/www/html

# RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf \
#   && sed -i 's/listen.acl_users = apache,nginx/listen.acl_users =/' /etc/php-fpm.d/www.conf \
#   && mkdir /run/php-fpm \
#   && chgrp -R 0 /var/log/httpd /var/run/httpd /run/php-fpm \
#   && chmod -R g=u /var/log/httpd /var/run/httpd /run/php-fpm

# EXPOSE 8080
# USER 1001
# CMD php-fpm & httpd -D FOREGROUND