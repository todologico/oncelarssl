## Oncelar SSL Localhost - Laravel 11 - MariaDB - phpMyAdmin - Docker  
##### - Last update 19/mayo/2024.
  

<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

**Instalación no productiva:**  

Clonar el repositorio.  

Generar el certificado dentro de la carpeta ssl:

openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048  
openssl req -new -key private.pem -out request.csr  
openssl x509 -req -days 365 -in request.csr -signkey private.pem -out certificate.pem  


Situados en /oncelar, desde la consola ejecutar el siguiente comando, el cual creara las carpeta "db" (volumen mariadb) y "src" (codigo laravel) y levantará los contenedores de los tres servicios.

**mkdir -p src && mkdir -p db && docker-compose up -d**  

El contenedor de laravel se visualiza en http://localhost:83/  

El contenedor de phpmyadmin se visualiza en http://localhost:89/  accediendo con host oncelar-db, usuario: oncelar, pass: 00000000  

Configuracion acceso DB en file .env que se ingresa automaticamente desde el file entrypoint 

DB_CONNECTION=mysql  
DB_HOST=oncelar-db  
DB_PORT=3310  
DB_DATABASE=oncelar  
DB_USERNAME=oncelar  
DB_PASSWORD=00000000  

**COMANDOS CON PHP ARTISAN DENTRO DEL CONTENEDOR CON USUARIO APPUSER**

Al construir el contenedor se da de alta un usuario no root (appuser), con el cual es necesario loguearse.
Este usuario pertenece al grupo 1000, por lo cual puede acceder a realizar comandos artisan.  

Para dar de alta este usuario, en el Dockerfile estoy agregando:

ARG USER_NAME=appuser
ARG USER_UID=1000
RUN useradd -u $USER_UID -ms /bin/bash $USER_NAME
RUN usermod -aG 1000 $USER_NAME
RUN usermod -aG www-data $USER_NAME

y para poder correr comandos, se ingresa al contenedor y se cambia de usuario, corriendo:

**docker exec -it oncelar bash**  

revisamos todos los usuarios, verificando que el nuestro se encuentra activo:

**cat /etc/passwd**  

cambiamos al usuario no root:

**su appuser** 

verificamos que accedemos a artisan:

**php artisan**  

Opcionalmente puede hacerse directamente desde el interior del contenedor:  

**docker exec -it oncelar bash**  
**adduser appuser**  
**usermod -aG 1000 appuser**  
**id appuser**  

lo que muestra:  

root@oncelar:/var/www/app# su appuser  
appuser@oncelar:/var/www/app$ id appuser  
uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)  

--------------------------------------

PRUEBAS DE CONECTIVIDAD DB  

**docker exec -it oncelar php artisan tinker**  
**use Illuminate\Support\Facades\DB; DB::connection()->getPdo();**  

O tambien es posible correr migraciones y hacer rollback, las cuales se muestran mediante phpmyadmin
Dentro del contenedor, con usuario no root (appuser), corremos:  

**php artisan migrate**  

Y para retroceder:  

**php artisan migrate:rollback**    

--------------------------------------

SUPERVISORD

**service supervisor status**  

supervisord log:  

**logfile=/var/log/supervisor/supervisord.log**  
