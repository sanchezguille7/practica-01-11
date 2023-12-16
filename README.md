# Practica 01-11

```
├── README.md
├── conf
│   ├── load-balancer.conf
│   └── 000-default.conf
├── htaccess
│   └── .htaccess
├── php
│   └── index.php
└── scripts
    ├── .env
    ├── install_load_balancer.sh
    ├── install_lamp_frontend.sh
    ├── install_lamp_backend.sh
    ├── setup_letsencrypt_https.sh
    ├── install_wordpress.sh
    ├── install_nfs_client.sh
    └── install_nfs_server.sh
```
**Balanceador de carga**
-   Instalar el software necesario.
-   Habilitar los módulos necesarios y configurar  [Apache HTTP Server](https://www.apache.org/)  como  [proxy inverso](https://httpd.apache.org/docs/trunk/es/howto/reverse_proxy.html).
-   Instalar y configurar  [Certbot](https://certbot.eff.org/)  para solicitar un certificado HTTPS.

**NFS Server (Capa de Frontend)**
-   Instalar el software necesario.
-   Crear el directorio que utilizará para compartir el contenido con los servidores web.
-   Configurar el archivo  `/etc/exports`  para permitir el acceso al directorio compartido solo a los servidores web.

**Servidores web (Capa de Frontend)**
-   Instalar el software necesario.
-   Configurar el archivo de Apache para incluir la directiva  `AllowOverride All`.
-   Habilitar el módulo  `rewrite`.
-   Sincronizar el contenido estático en la capa de  _Front-End_.
    -   Crear un punto de montaje con el directorio compartido del servidor NFS.
    -   Configurar el archivo  `/etc/fstab`  para montar automáticamente el directorio al iniciar el sistema.
-   Descargar la última versión de  [WordPress](https://wordpress.org/)  y descomprimir en el directorio apropiado.
-   [Configurar WordPress para que pueda conectar con MySQL](https://codex.wordpress.org/Editing_wp-config.php#Configure_Database_Settings).
-   Configuración de las  _Security Keys_.

**Servidor de base de datos (Capa de Backend)**
-   Instalar el software necesario.
-   Configurar  [MySQL](https://www.mysql.com/)  para que acepte conexiones que no sean de  _localhost_.
-   Crear una base de datos para  [WordPress](https://wordpress.org/).
-   Crear un usuario para la base de datos de  [WordPress](https://wordpress.org/)  y asignarle los permisos apropiados.
- 
## install_lamp_frontend
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt upgrade -y`: Actualizar el sistema operativo y los paquetes instalados.
    
4.  `apt install apache2 -y`: Instala el servidor web **Apache**.
    
5.  `cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf`: Copia el archivo de configuración **000-default.conf** desde el directorio *../conf/* al directorio */etc/apache2/sites-available/*.
    
6.  `sudo apt install php libapache2-mod-php php-mysql -y`: Instala **PHP** y el módulo de **Apache** para **PHP**, así como el soporte de **MySQL** para **PHP**.
    
7.  `systemctl restart apache2`: Reinicia el servicio **Apache** para aplicar los cambios en la configuración.

8.   `chown -R www-data:www-data /var/www/html/`: Asigna el **ownership** del directorio */var/www/html/* al usuario y grupo **www-data.**


## install_lamp_backend
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt-get update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt-get upgrade -y`: Realiza la actualización del sistema operativo y paquetes instalados.
    
4.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
5.  `apt-get install mysql-server -y`: Instala el servidor **MySQL**.
    
6.  `sed -i "s/127.0.0.1/$MYSQL_PRIVATE_IP/" /etc/mysql/mysql.conf.d/mysqld.cnf`: Modifica el archivo de configuración de **MySQL** para usar la dirección IP especificada en lugar de 127.0.0.1.
    
7.  `sudo mysql -u root <<< "DROP USER IF EXISTS '$WORDPRESS_DB_USER'@'$IP_CLIENTE_MYSQL';"`: Elimina el usuario de la base de datos si ya existe.
    
8.  `sudo mysql -u root <<< "CREATE USER '$WORDPRESS_DB_USER'@'$IP_CLIENTE_MYSQL' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';"`: Crea un nuevo usuario de base de datos.
    
9.  `sudo mysql -u root <<< "GRANT ALL PRIVILEGES ON \`$WORDPRESS_DB_NAME`.* TO '$WORDPRESS_DB_USER'@'$IP_CLIENTE_MYSQL';"`: Concede todos los privilegios al nuevo usuario sobre la base de datos especificada.
    
10.  `sudo mysql -u root <<< "FLUSH PRIVILEGES;"`: Recarga los privilegios de **MySQL** para aplicar los cambios.
    
11.  `systemctl restart mysql`: Reinicia el servicio **MySQL** para que los cambios en la configuración y privilegios tengan efecto.

## install_load_balancer
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt upgrade -y`: Actualizar el sistema operativo y los paquetes instalados.
    
4.  `apt install apache2 -y`: Instala el servidor web **Apache**.

5.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
6.  `cp ../load-balancer.conf /etc/apache2/sites-available`: Copia el archivo de configuración **load-balancer.conf** desde un directorio específico a */etc/apache2/sites-available/.*
    
7.  -   `s/\$IP_HTTP_SERVER1/$IP_HTTP_SERVER1/`: Reemplaza la variable `$IP_HTTP_SERVER1` con el valor actual de la variable en el archivo **load-balancer.conf.**
    
-   `s/\$IP_HTTP_SERVER2/$IP_HTTP_SERVER2/`: Reemplaza la variable `$IP_HTTP_SERVER2` con el valor actual de la variable en el archivo **load-balancer.conf.**
    
7.  `a2enmod proxy`: Habilita el módulo **proxy** de **Apache**.
    
8.  `a2enmod proxy_http`: Habilita el módulo **proxy_http** de **Apache**.
    
9.  `a2enmod proxy_balancer`: Habilita el módulo **proxy_balancer** de **Apache**.

10. `a2dissite 000-default.conf`: Deshabilita el sitio predeterminado 
    
11.  `a2ensite load-balancer.conf`: Habilita el sitio configurado en el archivo **load-balancer.conf**.
    
12. `systemctl restart apache2`: Reinicia el servicio **Apache** para aplicar los cambios después de habilitar y deshabilitar sitios.

## install_wordpress
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt upgrade -y`:  Actualizar el sistema operativo y los paquetes instalados.
    
4.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
5.  `rm -rf /tmp/wp-cli.phar`: Elimina el archivo **wp-cli.phar** en el directorio temporal */tmp*.
    
6.  `wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp`: Descarga el archivo **wp-cli.phar** desde **GitHub** al directorio */tmp*.
    
7.  `chmod +x wp-cli.phar`: Otorga permisos de ejecución al archivo **wp-cli.phar**.
    
8.  `mv /tmp/wp-cli.phar /usr/local/bin/wp`: Mueve el archivo **wp-cli.phar** al directorio */usr/local/bin/* con el nombre **'wp'**, haciéndolo ejecutable globalmente.
    
9.  `rm -rf /var/www/html/*`: Elimina el contenido del directorio */var/www/html/*.
    
10.  `wp core download --locale=es_ES --path=/var/www/html --allow-root`: Descarga el núcleo de **WordPress** en español al directorio */var/www/html/*.
    
11.  `wp config create ...`: Crea el archivo de configuración de **WordPress** con la información proporcionada.
    
12.  `wp core install ...`: Instala **WordPress** con la configuración y credenciales proporcionadas.
    
13.  `cp ../htaccess/.htaccess /var/www/html/`: Copia el archivo **.htaccess** desde el directorio *../htaccess/* al directorio */var/www/html/*.
14. `wp plugin install wp-staging --activate --path=/var/www/html --allow-root`Descarga e instala el plugin "**wp-staging**" desde el repositorio de **WordPress**.
      `--activate`: Activa el plugin recién instalado.
     `--path=/var/www/html`: Especifica el directorio donde está instalado **WordPress**.
    `--allow-root`: Permite ejecutar el comando como el usuario root.
    
15.  `wp plugin install ...`: Instala y activa el plugin **"wps-hide-login"**.
          `--activate`: Activa el plugin recién instalado.
     `--path=/var/www/html`: Especifica el directorio donde está instalado **WordPress**.
    `--allow-root`: Permite ejecutar el comando como el usuario root.
16.  `wp option update whl_page "NotFound" --path=/var/www/html --allow-root`: Utiliza **WP-CLI** para actualizar la opción (option) llamada "**whl_page**" a "**NotFound**" en la instalación de **WordPress** ubicada en */var/www/html*.
    
17.  `wp rewrite structure '/%postname%/' --path=/var/www/html --allow-root`: Utiliza **WP-CLI** para cambiar la estructura de las URL de **WordPress** a *'/%postname%/'*.
    
18.  `chown -R www-data:www-data /var/www/html`: Asigna el ownership del directorio */var/www/html/* y su contenido al usuario y grupo **www-data.**
    
19.  `sed -i "/COLLATE/a \$_SERVER['HTTPS'] = 'on';" /var/www/html/wp-config.php`: Utiliza el comando `sed` para agregar la línea `$_SERVER['HTTPS'] = 'on';` después de la línea que contiene "**COLLATE**" en el archivo *wp-config.php* ubicado en */var/www/html/*. Esto se utiliza para forzar la conexión segura **(HTTPS)** en **WordPress**.
    
  
## setup_letsencrypt_https.sh
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
3.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
4.  `snap install core`: Instala el paquete core de **Snap**.
    
5.  `snap refresh core`: Actualiza el paquete core de **Snap** a la última versión disponible.
    
6.  `apt remove certbot`: Desinstala el paquete **certbot**.
    
7.  `snap install --classic certbot`: Instala **certbot** como un paquete **Snap** en modo clásico.
    
8.  `ln -fs /snap/bin/certbot /usr/bin/certbot`: Crea un enlace simbólico para que el ejecutable **certbot** en */snap/bin/* esté disponible en */usr/bin/.*
    
9.  `certbot --apache -m $CERTIFICATE_EMAIL --agree-tos --no-eff-email -d $CERTIFICATE_DOMAIN --non-interactive`: Utiliza **certbot** para obtener y configurar certificados **SSL/TLS** para el dominio especificado utilizando el método de autenticación de **Apache**. Las opciones proporcionan el correo electrónico del propietario del certificado y aceptan los términos del servicio sin efectuar emails.

## .env
#Configuramos las variables

    WORDPRESS_DB_NAME=wordpress
    WORDPRESS_DB_USER=wp_user
    WORDPRESS_DB_PASSWORD=wp_pass
    WORDPRESS_DB_HOST=172.31.91.133
    
    IP_CLIENTE_MYSQL=172.31.%
    
    CERTIFICATE_EMAIL=guilleemail@demo.es
    CERTIFICATE_DOMAIN=practicagsm0109.hopto.org
    
    WORDPRESS_TITTLE="Sitio Web GSM de IAW"
    WORDPRESS_ADMIN_USER=admin
    WORDPRESS_ADMIN_PASS=admin
    WORDPRESS_ADMIN_EMAIL=demo@demo.es
    
    MYSQL_PRIVATE_IP=172.31.91.133
    
    IP_HTTP_SERVER1=172.31.94.123
    IP_HTTP_SERVER2=172.31.80.68
    
    NFS_FRONTEND_NETWORK=172.31.0.0/16
    NFS_SERVER_PRIVATE_IP=172.31.83.15

