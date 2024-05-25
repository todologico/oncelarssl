## Oncelar SSL Localhost - Laravel 11 - MariaDB - phpMyAdmin - Docker  
## Development environment for Laravel on Linux  
##### - Last update 2024/05/24
  

<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

**Non-productive Installation:**  

Clone the repository.  

On our machine we add the domain "localhost.oncelar" to the file /etc/hosts, accessed with sudo:

**sudo nano /etc/hosts**    

With:  
**127.0.0.1 localhost.oncelar**

--------------------------------------------------------------------  

**WE GENERATE THE SECURITY CERTIFICATE WITHIN THE SSL FOLDER USING MKCERT:**  

**Create your own "virtual" certificate authority with a single command.**  
Mkcert is a small utility created by the skilled Italian programmer Filippo Valsorda. Filippo has worked at Cloudflare on cryptography-related programming, and he is currently at Google in New York on the Go language team and involved in security and cryptography projects. In June 2018, he created the utility called mkcert, which is free and Open Source. mkcert allows you to create digital certificates for any domain, including localhost, which are always valid for use on the local machine.

**sudo apt install libnss3-tools**  
**wget -O mkcert https://github.com/FiloSottile/mkcert/releases/latest/download/mkcert-v1.4.4-linux-amd64**  
**sudo chmod +x mkcert**  
**sudo mv mkcert /usr/local/bin/**  
**mkcert -install**  

Now, in the project folder, we create a folder called ssl and inside it, we run:

**mkcert localhost.oncelar**

This process generates the certificate, the key, and adds a certificate authority to our machine that the browser can recognize.

So we get:

**/ssl/localhost.oncelar.pem;**  
**/ssl/localhost.oncelar-key.pem;**  

--------------------------------------------------------------------  

**WE CREATE THE 3 SERVICES IN THEIR RESPECTIVE CONTAINERS:**  

In the /oncelar directory, execute the following command from the console. This will create the db folder (MariaDB volume) and the src folder (Laravel code), and it will start the containers for the three services. With non-root user:

**mkdir -p src && mkdir -p db && docker-compose up -d**  

UNSECURE: the Laravel container can be accessed at: http://localhost.oncelar:86  

SECURE SSL: the Laravel container can be accessed at https://localhost.oncelar:92  


The phpMyAdmin container can be accessed at: http://localhost.oncelar:89  Login with the following credentials:  

**host oncelar-db**  
**usuario: oncelar**  
**pass: 00000000**  


Database access configuration in the .env file is automatically populated from the entrypoint file.

**DB_CONNECTION=mysql**  
**DB_HOST=oncelar-db**  
**DB_PORT=3310**  
**DB_DATABASE=oncelar**  
**DB_USERNAME=oncelar**  
**DB_PASSWORD=00000000**  

--------------------------------------------------------------------  

**Commands with PHP Artisan within the container using the user appuser**  

When building the container, a non-root user (appuser) is created, which is required for login. This user belongs to group 1000, hence has access to run artisan commands. 

To add this user, in the Dockerfile, I'm including:

**ARG USER_NAME=appuser**  
**ARG USER_UID=1000**  
**RUN useradd -u $USER_UID -ms /bin/bash $USER_NAME**  
**RUN usermod -aG 1000 $USER_NAME**  
**RUN usermod -aG www-data $USER_NAME**  

To run commands, you enter the container and switch users by executing:

**docker exec -it oncelar bash**  

We check all users, ensuring that ours is active.

**cat /etc/passwd**  

We switch to the non-root user.

**su appuser** 

We verify that we have access to Artisan.

**php artisan**  

Optionally, this can be done directly from inside the container.  

**docker exec -it oncelar bash**  
**adduser appuser**  
**usermod -aG 1000 appuser**  
**id appuser**  

What it displays:  

root@oncelar:/var/www/app# su appuser  
appuser@oncelar:/var/www/app$ id appuser  
uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)  

--------------------------------------------------------------------  

Database Connectivity Tests  

**docker exec -it oncelar php artisan tinker**  
**use Illuminate\Support\Facades\DB; DB::connection()->getPdo();**  

It's also possible to run migrations and perform rollbacks, which are displayed through phpMyAdmin. Within the container, with the non-root user (appuser), we run:

**php artisan migrate**  

And to rollback: 

**php artisan migrate:rollback**   

--------------------------------------------------------------------  

Error logs for NGINX inside the container

**tail -f /var/log/nginx/error.log**  
**tail -f /var/log/nginx/access.log**  

**nginx -t  (status de nginx)**  
**nginx -s reload  (reload de nginx)**  

--------------------------------------

SUPERVISORD

**service supervisor status**  

supervisord log:  

**logfile=/var/log/supervisor/supervisord.log**  
