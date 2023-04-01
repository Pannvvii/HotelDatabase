# HotelDatabase
CSI2132 Database

Download and install PHP on your pc from https://www.php.net/downloads.
(x64 nts version for windows.)
Add php to your PATH in order to be able to call it from CMD.
php.ini-production should be renamed to php.ini
Uncomment the line:
extension=pgsql
in the newly renamed php.ini

Open and create a database in pgAdmin 4.
Run provided .sql in Query Tool, refresh.

Copy the php code provided in this document and paste it into a new php file named “HotelsSite.php”.
Open HotelsSite.php in a text editor. 
Go to around line 53 where “$cn = pg_connect(…”
Ensure that all variables in the pg_connect function match what appears when you right click the server and go to the connection tab in pgAdmin (making sure the dbname, username and password are correct). Also ensure that the dbname is identical to yours in pgAdmin.

Open CMD Prompt.
Enter the line: “CD ” followed by the path to where you have HotelsSite.php saved. (Make sure HotelsSite.php is on the same drive as your PHP install.) 

Run the following line:
“php -S localhost:8000 HotelsSite.php”

Open your browser and type localhost:8000 into the address bar. 

You should now see the web app and be able to use its functionality.
