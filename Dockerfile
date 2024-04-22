# Mulai dari base Alpine Linux terbaru
FROM alpine:latest

LABEL maintainer="Kommas01"
LABEL description="PHPNuxBill - PHP Mikrotik Billing"

# Atur direktori kerja ke /var/www/html
WORKDIR /var/www/html

# Buat volume di /var/www/html untuk mempertahankan data
VOLUME /var/www/html

# Buka port berikut: 
EXPOSE 1812/udp
EXPOSE 1813/udp
EXPOSE 3306/tcp
EXPOSE 80/tcp

# Pasang paket yang dibutuhkan
RUN apk add --no-cache nginx php82 php82-fpm php82-gd php82-mbstring php82-mysqli php82-session php82-pdo php82-pdo_mysql php82-zip php82-curl mysql mysql-client libzip-dev zip unzip git wget nano freeradius freeradius-mysql freeradius-utils supervisor

# Kloning PhpNuxbill
RUN git clone https://github.com/hotspotbilling/phpnuxbill.git /tmp/gitclone

# Pindahkan PhpNuxbill dari temporary ke direktori kerja
RUN mv /tmp/gitclone/* /var/www/html/

# Salin file konfigurasi
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/my.cnf /etc/mysql/my.cnf  
COPY conf/mysql.sh /app/mysql.sh
RUN chmod +x /app/mysql.sh
COPY conf/fpm-pool.conf /etc/php82/php-fpm.d/www.conf
COPY conf/php.ini /etc/php82/conf.d/custom.ini 
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Activate Cronjob for Expired and Reminder.

# Mulai layanan
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
