# HotelDatabase
CSI2132 Database

Download and install PHP on your pc.
Add php to your PATH in order to be able to call it from CMD.
Enable extension=php_pgsql.dll (windows) in php.ini


Open and create a database in pgAdmin 4.
Run provided .sql in Query Tool, refresh.

Open HotelsSite.php in a text editor. 
Go to line 48 where “$cn = …”
Ensure that all variables in the pg_connect function match what appears when you right click the server and go to the connection tab in pgAdmin. Also ensure that the dbname is identical to yours in pgAdmin.

Open CMD Prompt.
Enter the line: “CD ” followed by the path to where you have HotelsSite.php saved. 

Run the following line:
“php -S localhost:8000 HotelsSite.php”

Open your browser and type localhost:8000 into the address bar. 

You should now see the web app and be able to use its functionality.
