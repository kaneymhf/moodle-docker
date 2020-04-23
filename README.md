docker-moodle [![Build Status](https://travis-ci.org/kaneymhf/moodle-docker.svg?branch=master)](https://travis-ci.com/github/kaneymhf/moodle-docker)
=============

A Docker image that installs and runs the latest Moodle stable, with external MySQL, Mariadb or Postgresql Database and automated installation with a default predefined administrator user. Also all the images are availalbe via [docker hub](https://hub.docker.com/r/kaneymhf/
moodle/).

## Available Images

With apache based on `centos:7` image:

**All Databases**
VERSION | TAGS
--- | ---
3.5 | `kaneymhf/moodle:35` `kaneymhf/moodle:lts`
3.8 | `kaneymhf/moodle:38` `kaneymhf/moodle:latest`

**MySQL | MariaDB**
VERSION | TAGS
--- | ---
3.5 | `kaneymhf/moodle:mysql_maria_35` `kaneymhf/moodle:mysql_maria_lts`
3.8 | `kaneymhf/moodle:mysql_maria_38` `kaneymhf/moodle:mysql_maria_latest`

**PostgreSQL**
VERSION | TAGS
--- | ---
3.5 | `kaneymhf/moodle:postgresql_35` `kaneymhf/moodle:postgresql_lts`
3.8 | `kaneymhf/moodle:postgresql_38` `kaneymhf/moodle:postgresql_latest`

### Enviromental Variables for Default user settings:

A default user is generated during installation. Please provide different credentials during installation.

Variable Name | Default value | Description
---- | ------ | ------
`MOODLE_URL` | http://0.0.0.0 | The URL the site will be served from
`MOODLE_ADMIN` | *admin* | The default administrator's username
`MOODLE_ADMIN_PASSWORD` | *Admin~1234* | The default administrator's password - **CHANGE IN PRODUCTION*
`MOODLE_ADMIN_EMAIL` | *admin@example.com* | The default dministrator's email

### Enviromental Variables for Database settings:

Variable Name | Default value | Description
---- | ------ | ------
`MOODLE_DB_HOST` | | The url that the database is accessible
`MOODLE_DB_PASSWORD` | | The password for the database
`MOODLE_DB_USER` | | The username of the database
`MOODLE_DB_NAME` | | The database name
`MOODLE_DB_PORT` | | The port that the database is accessible

### Enviromental Variables for Email settings

Variable Name | Default value | Description
---- | ------ | ------
`MOODLE_EMAIL_TYPE_QMAIL` | false | Whether will use qmail as email (MTA)[https://en.wikipedia.org/wiki/Message_transfer_agent].
`MOODLE_EMAIL_HOST` | | The host of the smtp server. If not provided then it won't send emails.

### Enviromental Variables for reverse proxy

Variable Name | Default value | Description
---- | ------ | ------
`MOODLE_REVERSE_LB` | false | Whether the moodle rins behind a load balancer or not.
`MOODLE_SSL` | false | Whether the moodle runs behind an ssl-enabled load balancer.

### Volumes

For now you can use the following volumes:

* **/var/moodledata** In order to get all the stored  data.
* **/var/www/html** Containing the moodle source code. This is used by nginx as well.

## Using SSL Reverse proxy

### Via nginx

In case you want to use the nginx as reverse http proxy is recommended to provide the following settings:

```
server {
  listen  449 ssl;
  server_name  ^your_domain^;

  ssl_certificate     ^path_to_cert^;
  ssl_certificate_key ^path_to_key^;
  ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers         HIGH:!aNULL:!MD5;

  location / {
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # In case or running another port please replace the value bellow.
        proxy_pass http://^local_url_and_port^;
  }
}
```

Where:
* `^your_domain^`: The domain that the moodle is available. Keep in mind that this value is the same in the `MOODLE_URL` enviromental variable.
* `^local_url_and_port^`: Url that the reverse proxy will forward the requests.
* `^path_to_cert^`,`^path_to_key^`: The certificate and its key.

As you can see the reverse proxy **DOES NOT** provide the http **Host** header according to [this](https://moodle.org/mod/forum/discuss.php?d=339370) issue.

Also keep in mind to set the following docker enviromental variables `MOODLE_REVERSE_LB` and `MOODLE_SSL` into **true** as well.



## Caveats

### Moodle related

The following aren't handled, considered, or need work:
* moodle cronjob (should be called from cron container)
* log handling (stdout?)
* email (does it even send?)

### Docker related

Also in case of an error that mentions:

```
UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=60)
```

Export the following enviromental variables:

```
export DOCKER_CLIENT_TIMEOUT=120
export COMPOSE_HTTP_TIMEOUT=120
```

## Credits

This repository is based on [ellakcy/moodle](https://hub.docker.com/r/ellakcy/moodle), but its not a fork.
