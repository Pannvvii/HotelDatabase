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
	<br>
	  <?php
		$cn = pg_connect("host=localhost port=5432 dbname=HotelTest user=postgres password=password");
		$result = pg_query($cn, "SELECT * FROM employee");
		$arr = pg_fetch_all($result);
	  ?>
	  <!--
	  <table>
	  <tr>
		<th>Name</th>
		<th>SSN</th>
		<th>Address</th>
	  </tr>
	  <tr>
		<td><?php
			/*echo $arr[0]['first_name'];
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
			echo $arr[1]['address'];*/
		?></td>
	  </tr>
	</table>
	-->
	
	<?php
		$result = pg_query($cn, "SELECT * FROM available_room");
		$roomsview = pg_fetch_all($result);
		$result = pg_query($cn, "SELECT * FROM hotel_room_capacity");
		$capacityview = pg_fetch_all($result);
		/*print_r($capacityview);
		echo "<br>";
		echo "<br>";
		echo "<br>";
		print_r($roomsview);*/
	  ?>
	<table>

                <tr>
                    <th>HotelID</th>
                    <th>Total Room Capacity</th>
                </tr>
                <?php
                    foreach ($capacityview as $akey => $item)
                    {
                        ?>
                        <tr>
                            <td> <?php echo $item['hotelid'];?></td>
							<td> <?php echo $item['sum']; ?></td>
                        </tr>
                    <?php
					}
                ?>	
  </table>
  <br>
  <table>

                <tr>
                    <th>Area</th>
                    <th>Hotel Count</th>
                </tr>
                <?php
                    foreach ($roomsview as $akey => $item)
                    {
                        ?>
                        <tr>
                            <td> <?php echo $item['area'];?></td>
							<td> <?php echo $item['count']; ?></td>
                        </tr>
                    <?php
					}
                ?>	
  </table>
  <br>
	
	
	Enter Customer Payment:
	<input type="number" id="nothing">
	<input type="button" value="Submit" id="btnsubmit" onclick="submitForm()">
<script>
function submitForm() {
   document.getElementById('nothing').value='';
}
</script>
	
	
	
	<br>
	<br>
  </div>
  <button class="accordion">
    Customer<span class="accordion__indicator"></span>
  </button>
  <div class="accordion-panel">
	
    <p>
	Pick Your Options (Hold Ctrl while clicking for multiple):
<form action="" method="post">
	<select name="hotelsearch[]" multiple>
	  <option value="">Select...</option>
	  <option value="True">--HOTEL CHAINS--</option>
	  <?php
        $alreadyA = array();
		$result = pg_query($cn, "SELECT * FROM hotel_chain");
		$chains = pg_fetch_all($result);
        
        for($i = 0; $i < count($chains); $i++) {
			foreach ($chains[$i] as $key => $item){
				if ($key == 'chain_name'){
					$test = strval($key)."#";
					$test = $test.strval($item);
					if((in_array($test, $alreadyA)) == False){
						echo "<option value='$key#$item'>$item</option>";
						array_push($alreadyA, $test);
					}
				}
			}
        }
		print_r($alreadyA);
		?>
		<option value="True">--HOTEL AREA--</option>
		<?php
		$alreadyA = array();
		$result = pg_query($cn, "SELECT * FROM hotel");
		$hotels = pg_fetch_all($result);
        
        for($i = 0; $i < count($hotels); $i++) {
			foreach ($hotels[$i] as $key => $item){
				if ($key == 'area'){
					$test = strval($key)."#";
					$test = $test.strval($item);
					if((in_array($test, $alreadyA)) == False){
						echo "<option value='$key#$item'>$item</option>";
						array_push($alreadyA, $test);
					}
				}
			}
        }
		?>
		<option value="True">--CAPACITY--</option>
		<?php
		$alreadyA = array();
		$result = pg_query($cn, "SELECT * FROM room");
		$rooms = pg_fetch_all($result);
        
        for($i = 0; $i < count($rooms); $i++) {
			foreach ($rooms[$i] as $key => $item){
				if ($key == 'capacity'){
					$test = strval($key)."#";
					$test = $test.strval($item);
					if((in_array($test, $alreadyA)) == False){
						echo "<option value='$key#$item'>$item</option>";
						array_push($alreadyA, $test);
					}
				}
			}
        }
        ?>
		<option value="True">--PRICE--</option>
		<?php
		$alreadyA = array();
		$result = pg_query($cn, "SELECT * FROM room");
		$rooms = pg_fetch_all($result);
        
        for($i = 0; $i < count($rooms); $i++) {
			foreach ($rooms[$i] as $key => $item){
				if ($key == 'price'){
					$test = strval($key)."#";
					$test = $test.strval($item);
					if((in_array($test, $alreadyA)) == False){
						echo "<option value='$key#$item'>$item</option>";
						array_push($alreadyA, $test);
					}
				}
			}
        }
        ?>
		<option value="True">--VIEW--</option>
		<option value="sea_view#true">Yes View</option>
	    <option value="sea_view#false">No View</option>
	</select>
	<br>
	<br>
	<label for="book">Date to Book:</label>
	<input type="date" name="book" min="2023-01-01" max="2033-12-31">
	
	<input type="submit" value="Submit" name="submit">
	
	
</form>





	</p>
	<?php
	if(isset($_POST['submit']) )
	{
		$result = pg_query($cn, "SELECT * FROM room");
		$rooms = pg_fetch_all($result);
		$result = pg_query($cn, "SELECT * FROM hotel join room on hotel.hotelID = room.hotelID join hotel_chain on hotel.hotel_chainID = hotel_chain.hotel_chainID");
		$hotelchains = pg_fetch_all($result);
		/*
		echo "<br>";
		echo "<br>";
		print_r($hotelchains);
		echo "<br>";
		echo "<br>";
		*/
		$validrooms = array();
		$validroomstemp = array();
		foreach ($_POST['hotelsearch'] as $dumbkey => $toexplode){
			array_push($validroomstemp, array());
			$searchitem = explode("#", $toexplode);
			foreach ($hotelchains as $key => $curr){
				foreach ($curr as $category => $thing){
					if ($searchitem[0] == $category){
						if ($searchitem[1] == $thing){
							$toadd = $curr['room_number']."-";
							$toadd = $toadd.$curr['hotelid'];
							/*
							$toadd = $toadd."-";
							$toadd = $toadd.$curr['hotel_chainid'];
							*/
							array_push($validroomstemp[$dumbkey], $toadd);
						}
					}
				}
			}
		}

		$validrooms = call_user_func_array('array_intersect', $validroomstemp);
		
		echo "The search criteria are: ";
		echo "<br>";
		echo "<br>";
		foreach ($_POST['hotelsearch'] as $dumbkey => $toexplode){
			$searchitem = explode("#", $toexplode);
			$toprint = $searchitem[0]." => ";
			$toprint = $toprint.$searchitem[1];
			echo $toprint;
			echo "<br>";
		}
		

		/*date check*/
		
		$dvalidrooms = array();
		$fvalidrooms = array();
		$result = pg_query($cn, "SELECT * FROM archived_room");
		$arooms = pg_fetch_all($result);
		$result = pg_query($cn, "SELECT * FROM room");
		$drooms = pg_fetch_all($result);
		$date = $_POST['book'];

		foreach ($arooms as $key => $curr){
			if ($curr['date_booked'] == $date){
				$toadd = $curr['room_number']."-";
				$toadd = $toadd.$curr['hotelid'];
				array_push($dvalidrooms, $toadd);
			}
		}

		foreach ($drooms as $key => $curr){
			foreach ($dvalidrooms as $bkey => $remove){
				$toadd = $curr['room_number']."-";
				$toadd = $toadd.$curr['hotelid'];
				if ($toadd == $remove){
					unset($drooms[$key]);
				} 
			}
		}
		
		foreach ($drooms as $key => $curr){
			$toadd = $curr['room_number']."-";
			$toadd = $toadd.$curr['hotelid'];
			array_push($fvalidrooms, $toadd);		
		}
		/*
		echo "<br>";
		echo "<br>";
		print_r($fvalidrooms);
		echo "<br>";
		print_r($validrooms);
		echo "<br>";
		echo "<br>";
		*/
		$finalrooms = array_intersect($fvalidrooms, $validrooms);
		/*
		foreach ($validrooms as $key => $curr){
			if (
		}*/
		echo "<br>";
		echo "<br>";
		echo "Here is a list of compatible rooms in the form 'Room Number'-'Hotel ID' available on ".$date;
		echo "<br>";
		echo "<br>";
		foreach ($finalrooms as $curr){
			echo $curr;
			echo "<br>";
		}
		if (empty($finalrooms)){
			echo "No Rooms found. Try searching a different date or with more general criteria.";
		}
		echo "<br>";
		
	}
	/*
	if(isset($_POST['dateSearch'])){
		
	}*/
	?>
	
	
  </div>
  <button class="accordion">
    Edit<span class="accordion__indicator"></span>
  </button>
  
  
  
  
  
  
  
  <div class="accordion-panel">
	<h3>Hotel insert/delete/update</h3>
	<br>

	<label for="hotelId">Hotel ID:</label><br>
	<input type="number" id="hotelId"><br>
	<label for="chainName">Chain ID:</label><br>
	<input type="text" id="chainNname"><br>
	<label for="rate">Rating:</label><br>
	<input type="number" id="rate"><br>
	<label for="email">Contact Email:</label><br>
	<input type="text" id="email"><br>
	<label for="phoneNum">Phone Number:</label><br>
	<input type="number" id="phoneNum"><br>
	<label for="add">Address:</label><br>
	<input type="text" id="add"><br>
	<label for="areaHotel">Area:</label><br>
	<input type="text" id="areaHotel"><br>
<br>
	<form method="post">
    	<input type="submit" name="insertHotel" value="insert"/>
	</form>
	<br>
	<form method="post">
    	<input type="submit" name="deleteHotel" value="delete"/>
	</form>
	<br>
	<form method="post">
    	<input type="submit" name="updateHotel" value="update"/>
	</form>

	<br>
	<br>

	<h3>Customer insert/delete/update</h3>
	<br>

	<label for="ssn_sin_cust">SSN/SIN:</label><br>
	<input type="number" id="ssn_sin_emp"><br>
	<label for="first_name_cust">First Name:</label><br>
	<input type="text" id="first_name_cust"><br>
	<label for="last_name_cust">Last Name:</label><br>
	<input type="text" id="last_name_cust"><br>
	<label for="address_cust">Address:</label><br>
	<input type="text" id="address_cust"><br>
<br>
	<form method="post">
    	<input type="submit" name="insertCust" value="insert"/>
	</form>
	<br>
	<form method="post">
    	<input type="submit" name="deleteCust" value="delete"/>
	</form>
	<br>
	<form method="post">
    	<input type="submit" name="updateCust" value="update"/>
	</form>

	<br>
	<br>

	<h3>Employee insert/delete/update</h3>
	<br>

	<label for="ssn_sin_emp">SSN/SIN:</label><br>
	<input type="number" id="ssn_sin_emp"><br>
	<label for="first_name_emp">First Name:</label><br>
	<input type="text" id="first_name_emp"><br>
	<label for="last_name_emp">Last Name:</label><br>
	<input type="text" id="last_name_emp"><br>
	<label for="address_emp">Address:</label><br>
	<input type="text" id="address_emp"><br>
	<label for="role_position">Role/Position:</label><br>
	<input type="text" id="role_position"><br>
<br>
	<form method="post">
    	<input type="submit" name="insertEmp" value="insert"/>
	</form>
	<br>
	<form method="post">
    	<input type="submit" name="deleteEmp" value="delete"/>
	</form>
	<br>
	<form method="post">
    	<input type="submit" name="updateEmp" value="update"/>
	</form>

	<br>
	<br>

	<h3>Room insert/delete/update</h3>
	<br>

	<label for="hotelid_room">Hotel Id:</label><br>
	<input type="number" id="hotelid_room"><br>
	<label for="roomNumber">Room Number:</label><br>
	<input type="number" id="roomNumber"><br>
	<label for="availability">Availability:</label><br>
	<input type="text" id="availability"><br>
	<label for="price">Price:</label><br>
	<input type="number" id="price"><br>
	<label for="amenities">Amenities:</label><br>
	<input type="number" id="amenities"><br>
	<label for="capacity">Capacity:</label><br>
	<input type="number" id="capacity"><br>
	<label for="seaView">Sea View:</label><br>
	<select id="seaView">
		<option value="true">True</option>
		<option value="false">False</option>
	</select><br>
	<label for="mountView">Mountain View:</label><br>
	<select id="mountView">
		<option value="true">True</option>
		<option value="false">False</option>
	</select>
	<br>
	<br>
	<form method="post">
    	<input type="submit" name="insertRoom" value="insert"/>
	</form>
	<br>
	<form method="post">
    	<input type="submit" name="deleteRoom" value="delete"/>
	</form>
	<br>
	<form method="post">
    	<input type="submit" name="updateRoom" value="update"/>
	</form>
	
	<?php
		if(isset($_POST['insertHotel'])){

			$hotelid = $_POST["hotelid"];
			$hotel_chainid = $_POST["chainName"];
			$rating = $_POST["rate"];
			$contact_email = $_POST["email"];
			$phone_number = $_POST["phoneNum"];
			$address = $_POST["add"];
			$area = $_POST["areaHotel"];

			$sqlPhonenum = "INSERT INTO phone_numbers_hotel (phone_numberid, phone_number) VALUES ($hotelid, $phone_number)";
		
			$resultPhonenum = pg_query($cn, $sqlPhonenum);
			
			$sql = "INSERT INTO hotel (hotelid, hotel_chainid, rating, contact_email, address, area) VALUES ($hotelid, $hotel_chainid, $rating, '$contact_email', '$address', '$area')";
		
			$result = pg_query($cn, $sql);

			/*
			if (!$result) {
				echo "Insert failed";
				exit;
			} else {
				echo "Data inserted successfully";
			}
			*/
		}
		if(isset($_POST['deleteHotel'])){

			$hotelid = $_POST["hotelid"];
			
			$sql = "DELETE FROM hotel WHERE hotelid = $hotelid";
		
			$result = pg_query($cn, $sql);

			/*
			if (!$result) {
				echo "Delete failed";
				exit;
			} else {
				echo "Delete successful";
			}
			*/
		}
		if(isset($_POST['insertCust'])){
			$ssn_sin = $_POST["ssn_sin_cust"];
			$first_name = $_POST["first_name_cust"];
			$last_name = $_POST["last_name_cust"];
			$address = $_POST["address_cust"];

			$sql = "INSERT INTO customer (ssn_sin, first_name, last_name, address) VALUES ($ssn_sin, '$first_name', '$last_name', '$address')";
		
			$result = pg_query($cn, $sql);
		}
		if(isset($_POST['deleteCust'])){
			$ssn_sin = $_POST["ssn_sin_cust"];
			
			$sql = "DELETE FROM customer WHERE ssn_sin = $ssn_sin";
		
			$result = pg_query($cn, $sql);
		}
		if(isset($_POST['insertEmp'])){
			$ssn_sin = $_POST["ssn_sin_emp"];
			$first_name = $_POST["first_name_emp"];
			$last_name = $_POST["last_name_emp"];
			$address = $_POST["address_emp"];
			$role_positions = $_POST["role_position"];

			$sql = "INSERT INTO employee (ssn_sin, address, role_positions, first_name, last_name) VALUES ($ssn_sin, '$address', '$role_positions','$first_name', '$last_name',)";
		
			$result = pg_query($cn, $sql);
		}
		if(isset($_POST['deleteEmp'])){
			$ssn_sin = $_POST["ssn_sin_emp"];

			$sql = "DELETE FROM employee WHERE ssn_sin = $ssn_sin";
		
			$result = pg_query($cn, $sql);
		}
		if(isset($_POST['insertRoom'])){
			$hotelid = $_POST["hotelid_room"];
			$room_number = $_POST["roomNumber"];
			$price = $_POST["price"];
			$amenities = $_POST["amenitites"];
			$capacity = $_POST["capacity"];
			$sea_view = $_POST["seaView"];
			$mountain_view = $_POST["mountView"];

			$sql = "INSERT INTO room (hotelid, room_number, price, amenitites, capacity, sea_view, mountain_view) VALUES ($hotelid, $room_number, $price, '$amenities', $capacity, '$sea_view', '$mountain_view')";
		
			$result = pg_query($cn, $sql);
		}
		if(isset($_POST['deleteRoom'])){
			$hotelid = $_POST["hotelid_room"];
			$room_number = $_POST["roomNumber"];

			$sql = "DELETE FROM room WHERE hotelid = $hotelid AND room_number = $room_number";
		}

		//Update button functionality
		if(isset($_POST['updateHotel'])){

			$hotelid = $_POST["hotelid"];
			$hotel_chainid = $_POST["chainName"];
			$rating = $_POST["rate"];
			$contact_email = $_POST["email"];
			$phone_number = $_POST["phoneNum"];
			$address = $_POST["add"];
			$area = $_POST["areaHotel"];

			$str = "UPDATE hotel SET ";
			$counter = 0;

			if(!empty($hotel_chainid)){
				if($counter == 0){
					$str += "hotel_chainid = $hotel_chainid";
				}
				else{
					$str += ", hotel_chainid = $hotel_chainid";
				}

				$counter++;
			}
			if(!empty($rating)){
				if($counter == 0){
					$str += "rating = $rating";
				}
				else{
					$str += ", rating = $rating";
				}
				
				$counter++;
			}
			if(!empty($contact_email)){
				if($counter == 0){
					$str += "contact_email = $contact_email";
				}
				else{
					$str += ", contact_email = $contact_email";
				}

				$counter++;
			}
			if(!empty($phone_number)){
				$sqlphone = "UPDATE hotel SET phone_number = $phone_number  WHERE phone_numberid = $hotelid";
				$result = pg_query($cn, $sqlphone);
			}
			if(!empty($address)){
				if($counter == 0){
					$str += "address = $address";
				}
				else{
					$str += ", address = $address";
				}

				$counter++;
			}
			if(!empty($area)){
				if($counter == 0){
					$str += "area = $area";
				}
				else{
					$str += ", area = $area";
				}

				$counter++;
			}
			if(counter > 0 ){
				$str += " WHERE hotelid = $hotelid";
				$sql = str;
				$result = pg_query($cn, $sql);
			}
		}
		if(isset($_POST['updateCust'])){
			$ssn_sin = $_POST["ssn_sin_cust"];
			$first_name = $_POST["first_name_cust"];
			$last_name = $_POST["last_name_cust"];
			$address = $_POST["address_cust"];

			$str = "UPDATE customer SET ";
			$counter = 0;

			if(!empty($first_name)){
				if($counter == 0){
					$str += "first_name = $first_name";
				}
				else{
					$str += ", first_name = $first_name";
				}

				$counter++;
			}
			if(!empty($last_name)){
				if($counter == 0){
					$str += "last_name = $last_name";
				}
				else{
					$str += ", last_name = $last_name";
				}

				$counter++;
			}
			if(!empty($address)){
				if($counter == 0){
					$str += "address = $address";
				}
				else{
					$str += ", address = $address";
				}

				$counter++;
			}
			if(counter > 0 ){
				$str += " WHERE ssn_sin = $ssn_sin";
				$sql = str;
				$result = pg_query($cn, $sql);
			}
		}
		if(isset($_POST['updateEmp'])){
			$ssn_sin = $_POST["ssn_sin_emp"];
			$first_name = $_POST["first_name_emp"];
			$last_name = $_POST["last_name_emp"];
			$address = $_POST["address_emp"];
			$role_positions = $_POST["role_position"];

			$str = "UPDATE employee SET ";
			$counter = 0;

			if(!empty($first_name)){
				if($counter == 0){
					$str += "first_name = $first_name";
				}
				else{
					$str += ", first_name = $first_name";
				}

				$counter++;
			}
			if(!empty($last_name)){
				if($counter == 0){
					$str += "last_name = $last_name";
				}
				else{
					$str += ", last_name = $last_name";
				}

				$counter++;
			}
			if(!empty($address)){
				if($counter == 0){
					$str += "address = $address";
				}
				else{
					$str += ", address = $address";
				}

				$counter++;
			}
			if(!empty($role_positions)){
				if($counter == 0){
					$str += "role_positions = $role_positions";
				}
				else{
					$str += ", role_positions = $role_positions";
				}

				$counter++;
			}
			if(counter > 0 ){
				$str += " WHERE ssn_sin = $ssn_sin";
				$sql = str;
				$result = pg_query($cn, $sql);
			}
		}
		if(isset($_POST['insertRoom'])){
			$hotelid = $_POST["hotelid_room"];
			$room_number = $_POST["roomNumber"];
			$price = $_POST["price"];
			$amenities = $_POST["amenitites"];
			$capacity = $_POST["capacity"];
			$sea_view = $_POST["seaView"];
			$mountain_view = $_POST["mountView"];

			$str = "UPDATE room SET ";
			$counter = 0;

			if(!empty($price)){
				if($counter == 0){
					$str += "price = $price";
				}
				else{
					$str += ", price = $price";
				}

				$counter++;
			}
			if(!empty($amenities)){
				if($counter == 0){
					$str += "amenities = $amenities";
				}
				else{
					$str += ", amenities = $amenities";
				}

				$counter++;
			}
			if(!empty($capacity)){
				if($counter == 0){
					$str += "capacity = $capacity";
				}
				else{
					$str += ", capacity = $capacity";
				}

				$counter++;
			}
			if(!empty($sea_view)){
				if($counter == 0){
					$str += "sea_view = $sea_view";
				}
				else{
					$str += ", sea_view = $sea_view";
				}

				$counter++;
			}
			if(!empty($mountain_view)){
				if($counter == 0){
					$str += "mountain_view = $mountain_view";
				}
				else{
					$str += ", mountain_view = $mountain_view";
				}

				$counter++;
			}
			if(counter > 0 ){
				$str += " WHERE room_number = $room_number AND hotelid = $hotelid";
				$sql = str;
				$result = pg_query($cn, $sql);
			}
		}
	?>
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