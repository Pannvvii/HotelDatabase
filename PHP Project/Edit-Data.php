<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Hotels</title>
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <meta name="description" content="" />
  <link rel="icon" href="favicon.png">
</head>
<body>
  <h1> Hotels</h1>
  <style>
  /* For best practice, move CSS below to an external CSS file. */
  .accordion {
    background-color: lightgray;
    color: #000000;
    cursor: pointer;
    padding: 18px;
    width: 100%;
    border: none;
    text-align: left;
    outline: none;
    font-size: 15px;
    transition: 0.4s; }
  .accordion-panel {
    padding: 0 18px;
    display: none;
    background-color: white;
    overflow: hidden; }
  .arrow-icon__line {
    width: 20px;
    height: 4px;
    background-color: #000000; }
  .accordion__indicator::after {
    content: "+"; }
  .accordion--open .accordion__indicator::after {
    content: "-"; }
	table, th, td {
		border: 1px solid black;
		border-collapse: collapse;}
  </style>
  <button class="accordion">
    Employee<span class="accordion__indicator"></span>
  </button>
  <div class="accordion-panel">

	  <?php
		$cn = pg_connect("host=localhost port=5432 dbname=HotelTest user=postgres password=password");
		$result = pg_query($cn, "SELECT * FROM employee");
		$arr = pg_fetch_all($result);
	  ?>
	  <table>
	  <tr>
		<th>Name</th>
		<th>SSN</th>
		<th>Address</th>
	  </tr>
	  <tr>
		<td><?php
			echo $arr[0]['first_name'];
		?></td>
		<td><?php
			echo $arr[0]['ssn_sin'];
		?></td>
		<td><?php
			echo $arr[0]['address'];
		?></td>
	  </tr>
	  <tr>
		<td><?php
			echo $arr[1]['first_name'];
		?></td>
		<td><?php
			echo $arr[1]['ssn_sin'];
		?></td>
		<td><?php
			echo $arr[1]['address'];
		
		?></td>
	  </tr>
	</table>
  </div>
  <button class="accordion">
    Customer<span class="accordion__indicator"></span>
  </button>
  <div class="accordion-panel">
	
    <p>
	Pick Your Options:
<form action="" method="post">
	<select name="hotelsearch[]" multiple>
	  <option value="">Select...</option>
	  <option value="True">--HOTEL CHAINS--</option>
	  <?php
        // A sample product array
		$result = pg_query($cn, "SELECT * FROM hotel_chain");
		$chains = pg_fetch_all($result);
        // Iterating through the product array
        for($i = 0; $i < count($chains); $i++) {
			foreach ($chains[$i] as $key => $item){
				if ($key == 'chain_name'){
					echo "<option value='$item'>$item</option>";
				}
			}
        }
		?>
		<option value="True">--HOTEL ADDRESS--</option>
		<?php
		// A sample product array
		$result = pg_query($cn, "SELECT * FROM hotel");
		$hotels = pg_fetch_all($result);
        // Iterating through the product array
        for($i = 0; $i < count($hotels); $i++) {
			foreach ($hotels[$i] as $key => $item){
				if ($key == 'address'){
					echo "<option value='$item'>$item</option>";
				}
			}
        }
		?>
		<option value="True">--CAPACITY--</option>
		<?php
		// A sample product array
		$result = pg_query($cn, "SELECT * FROM room");
		$rooms = pg_fetch_all($result);
        // Iterating through the product array
        for($i = 0; $i < count($rooms); $i++) {
			foreach ($rooms[$i] as $key => $item){
				if ($key == 'capacity'){
					echo "<option value='$item'>$item</option>";
				}
			}
        }
        ?>
		<option value="True">--VIEW--</option>
		<option value="True">Yes View</option>
	    <option value="False">No View</option>
	</select>
	<input type="submit" value="Submit" name="submit">
	
</form>
	</p>
	<?php

	
	if(isset($_POST['submit']) )
	{
		$result = pg_query($cn, "SELECT * FROM room");
		$rooms = pg_fetch_all($result);
		foreach ($_POST['hotelsearch'] as $key => $curr){
			if ($key == "0"){
			echo $key;
			echo $curr."<br>";
			
			}
			
		}
	}
	?>
	
	
  </div>
  <button class="accordion">
    Edit<span class="accordion__indicator"></span>
  </button>
  <div class="accordion-panel">
    <p>Coming Soon</p>
  </div>
  <script>
  var acc = document.getElementsByClassName("accordion");
  var i;
  for (i = 0; i < acc.length; i++) {
    acc[i].addEventListener("click", function() {
      this.classList.toggle("accordion--open");
      var panel = this.nextElementSibling;
      if (panel.style.display === "block") {
        panel.style.display = "none";
      } else {
        panel.style.display = "block";
      }
    });
  }
  </script>

</body>

</html>