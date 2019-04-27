FROM alpine:3.9
###
ARG PW_VER=2.9.5
ARG PW_URL=https://github.com/Piwigo/Piwigo/archive/
ARG DROP_FONT_CACHE=true
ENV HTTP_PORT=8001 \
    PW_DIR=/piwigo \
    PW_SRC=/usr/local/piwigo \
    RESTORE_PW_VOL=true \
    GMAP_PLUGIN_FIX=true \
    SEC_COOKIES=Off \
    PW_VERS=$PW_VER
# install the PHP extensions we need. some parts are documented. others were found by testing.
RUN set -ex; \
    apk add --no-cache \
# required packages
    php7-gd \
    php7-xml \
    php7-mbstring \
    php7-simplexml \
    php7-exif \
    php7-pear \
    php7-xmlrpc \
    php7-xsl \
    php7-imagick \
    php7-session \
    php7-json \
    imagemagick \
    php7-ctype \
#needed for video thumbnail generation
    ffmpeg \
# for db
    php7-mysqli \
# php itself
    php7 \
# a health monitor needs curl
    curl \
# webserver and php
    php7-apache2; \
#drop fontcache to allow easier image comparison between staging and prod image during CID tests
    if [ ${DROP_FONT_CACHE} = "true" ]; \
      then rm -rf /var/cache/fontconfig; \
    fi
RUN set -ex; \
    apk add --no-cache --virtual build-dependencies \
    # this is for downloading
    ca-certificates \
    openssl \
    curl \
    gnupg ;\
    update-ca-certificates ; \
    #no signature check for piwigo zip files. where are they ?
    curl -L --output /tmp/piwigo.tar.gz ${PW_URL}${PW_VER}.tar.gz ; \
    mkdir ${PW_DIR} ; \
    mkdir ${PW_SRC} ; \
    cd /piwigo ; \
    tar zxvf /tmp/piwigo.tar.gz --strip 1 ; \
    rm /tmp/piwigo.tar.gz; \
    for i in galleries plugins themes template-extension local ; \
      do cp -a ${PW_DIR}/${i} ${PW_SRC}/ ; \
    done; \
    apk del --purge build-dependencies
COPY httpd-pw.conf cis.conf /etc/apache2/conf.d/
COPY limitexcept /root/
COPY checkcontainer_install.sh php-entry.sh /usr/local/bin/
RUN set -ex; \
    chmod +x /usr/local/bin/php-entry.sh /usr/local/bin/checkcontainer_install.sh; \
    APACHECONF=/etc/apache2/httpd.conf; \
    sed -i "s/80/\$\{HTTP_PORT\}/g" /etc/apache2/httpd.conf ; \
    cat /etc/apache2/httpd.conf | grep Listen ; \
    sed -i 's/logs\/error.log/\/proc\/self\/fd\/2/' /etc/apache2/httpd.conf ; \
    sed -i 's/logs\/access.log/\/proc\/self\/fd\/1/' /etc/apache2/httpd.conf; \
    chown apache:apache /run/apache2; \
    chmod 700 /run/apache2
RUN set -ex; \
    chmod -R g-s /var/log/apache2 /var/www/localhost/htdocs; \
    chmod -R u-s /usr/sbin/suexec; \
#CIS stuff for apache
#apply some cis baseline items for apache. piwigo does not need most auth related modules:
    APACHECONF=/etc/apache2/httpd.conf; \
    sed -i 's/^LoadModule auth_basic_module/#LoadModule auth_basic_module/' ${APACHECONF}; \
    sed -i 's/^LoadModule authn_file_module/#LoadModule authn_file_module/' ${APACHECONF}; \
    sed -i 's/^LoadModule authz_user_module/#LoadModule authz_user_module/' ${APACHECONF}; \
    sed -i 's/^LoadModule authz_groupfile_module/#LoadModule authz_groupfile_module/' ${APACHECONF}; \
#deactivate status
    sed -i 's/^LoadModule status_module/#LoadModule status_module/' ${APACHECONF}; \
#deactivate autoindex
    sed -i 's/^LoadModule autoindex_module/#LoadModule autoindex_module/' ${APACHECONF}; \
#drop some config files related to modules not needed:
    rm /etc/apache2/conf.d/userdir.conf; \
    rm /etc/apache2/conf.d/info.conf; \
#set options to none for default directories as recommended in 1.5
    sed -i 's/^    Options .*/    Options None/' ${APACHECONF}; \
#1.5.6 removal of test-cgi
    rm /var/www/localhost/cgi-bin/test-cgi; \
#1.5.7: set limit to valid http requests
    sed -i '/\<Directory /r /root/limitexcept' ${APACHECONF}; \
    rm /root/limitexcept; \
#1.6 increase logging verbosity
    sed -i 's/^LogLevel.*/LogLevel notice core:info/' ${APACHECONF}; \
#1.7 ssl is done elsewhere (not in this container)
#1.8
    sed -i 's/^ServerTokens.*/ServerTokens Prod/' ${APACHECONF}; \
    sed -i 's/^ServerSignature.*/ServerSignature Off/' ${APACHECONF}; \
    sed -i 's/^Timeout.*/Timeout 10/' /etc/apache2/conf.d/default.conf; \
# some php items
PHPCONF=/etc/php7/php.ini; \
#hide php version from headers:
sed -i 's/expose_php = On/expose_php = Off/' $PHPCONF; \
#make secure cookies configurable as a docker environment variable:
sed -i 's/\;session.cookie_secure =/session.cookie_secure\ = "${SEC_COOKIES}"/' $PHPCONF; \
#create directory to store piwigo version. needs to be defined as volume to allow some piwigo files to be upgraded
mkdir /pw_built; \
chown apache /pw_built

USER apache
EXPOSE $HTTP_PORT
LABEL description="Piwigo Docker container without root gosu sudo or other wrappers that use root" \
      piwigo="Piwigo v${PW_VER}" \
      maintainer="Appelo Solutions <tob@nice.eu>"
ENTRYPOINT ["php-entry.sh"]
CMD ["httpd", "-DFOREGROUND"]
