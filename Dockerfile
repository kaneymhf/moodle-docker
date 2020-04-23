FROM centos:7

LABEL Maintainer="Maykon Facincani <facincani.maykon@gmail.com>"
LABEL Description="Moodle Container Apache 2.4 & PHP 7.2 based on CentOS Linux."

# Replace for build versions
ARG VERSION=38
ARG	DB_TYPE="all"

# ENVIRONMENTS VARIABLES
ENV MOODLE_DB_TYPE="${DB_TYPE}"
ENV MOODLE_URL http://0.0.0.0
ENV MOODLE_ADMIN admin
ENV MOODLE_ADMIN_PASSWORD Admin~1234
ENV MOODLE_ADMIN_EMAIL admin@example.com
ENV MOODLE_DB_HOST ''
ENV MOODLE_DB_PASSWORD ''
ENV MOODLE_DB_USER ''
ENV MOODLE_DB_NAME ''
ENV MOODLE_DB_PORT '3306'
ENV TIMEZONE 'Etc/GMT+3'

RUN echo "Build moodle version ${VERSION}"

RUN curl 'https://setup.ius.io/' | sh 

RUN yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm 
RUN yum -y install epel-release yum-utils

RUN if [ $VERSION = '38' ] ; then yum-config-manager --enable remi-php74 ; fi

RUN yum -y install \
    bzip2 \
    httpd mod_ssl \
    rsync \
    nc \
    mod_php \
    php-cli \
    php-common \
    php-devel \
    httpd-devel \ 
    jq \
    gcc \
    make \
    unzip

RUN if [ $DB_TYPE = 'mysqli' ] || [ $DB_TYPE = 'all' ]; \
    then echo "Setup mysql and mariadb support" && \
    yum -y install php-mysql ; fi

RUN if [ $DB_TYPE = 'pgsql' ] || [ $DB_TYPE = 'all' ]; \
    then echo "Setup pgsql support" && \
    yum -y install php-pgsql ; fi
 
RUN yum -y install \
    php-json \
    php-mbstring \
    php-xmlrpc \
    php-intl \
    php-domxml \
    php-soap \
    php-opcache \
    php-gd \
    php-curl \
    php-ldap

RUN yum -y clean all \
	&& rm -rf /var/cache/yum

RUN echo "Installing moodle" && \
	curl https://download.moodle.org/download.php/direct/stable${VERSION}/moodle-latest-${VERSION}.zip -o /tmp/moodle-latest.zip  && \
	rm -rf /var/www/html/index.html && \
	cd /tmp &&	unzip /tmp/moodle-latest.zip && cd / \
	mkdir -p /usr/src/moodle && \
	mv /tmp/moodle /usr/src/

RUN chown apache:apache -R /usr/src/moodle

ADD ./configs/php.d /etc/php.d
ADD ./configs/conf.d /etc/httpd/conf.d

COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./configs/moodle-config.php /usr/src/moodle/config.php
COPY ./scripts/detect_mariadb.php /opt/detect_mariadb.php

RUN chmod 775 /usr/local/bin/entrypoint.sh

RUN echo 

VOLUME ["/var/moodledata"]
VOLUME ["/var/www/html"]

EXPOSE 80/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]