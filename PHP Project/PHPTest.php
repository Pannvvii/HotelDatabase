<?php
	$cn = pg_connect("host=localhost port=5432 dbname=HotelTest user=postgres password=password");
	$result = pg_query($cn, "select * from hotels");
	while($row = pg_fetch_object($result))
	{
		echo "\n".$row->second;
	}
	pg_close($cn);
?>