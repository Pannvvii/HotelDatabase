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
  .bigboi {
        width: 150px;
        height: 300px;
        margin: 10px;
    }
  </style>
  <button class="accordion">
    Employee<span class="accordion__indicator"></span>
  </button>
  <div class="accordion-panel">
    <br>
      <?php
        $cn = pg_connect("host=localhost port=5432 dbname=v27 user=postgres password=ra2002");
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
      Select rooms to switch between rented and booked (format is hotelid room_number availability):
<form action="" method="post">
   
    <select name="bookrent[]" multiple class="bigboi">
      <option value="">--BOOKED--</option>
      <?php
        /*$alreadyAl = array();*/
        $result = pg_query($cn, "SELECT * FROM archived_room");
        $archrooms = pg_fetch_all($result);
       
        for($i = 0; $i < count($archrooms); $i++) {
            if ($archrooms[$i]['availability'] == "booked"){
                $test = strval($archrooms[$i]['hotelid'])."#";
                $test = $test.strval($archrooms[$i]['room_number']);
                $test = $test."#";
                $test = $test.strval($archrooms[$i]['availability']);
                $test = $test."#";
                $test = $test.strval($archrooms[$i]['date_booked']);
               
                $not = strval($archrooms[$i]['hotelid'])." ";
                $not = $not.strval($archrooms[$i]['room_number']);
                $not = $not." ";
                $not = $not.strval($archrooms[$i]['availability']);
                /*if((in_array($test, $alreadyAl)) == False){*/
                echo "<option value='$test'>$not</option>";
                /*array_push($alreadyAl, $test);
                }*/
            }
        }
        ?>
        <option value="">--RENTED--</option>
      <?php
        /*$alreadyAl = array();*/
        $result = pg_query($cn, "SELECT * FROM archived_room");
        $archrooms = pg_fetch_all($result);
       
        for($i = 0; $i < count($archrooms); $i++) {
            if ($archrooms[$i]['availability'] == "rented"){
                $test = strval($archrooms[$i]['hotelid'])."#";
                $test = $test.strval($archrooms[$i]['room_number']);
                $test = $test."#";
                $test = $test.strval($archrooms[$i]['availability']);
                $test = $test."#";
                $test = $test.strval($archrooms[$i]['date_booked']);
               
                $not = strval($archrooms[$i]['hotelid'])." ";
                $not = $not.strval($archrooms[$i]['room_number']);
                $not = $not." ";
                $not = $not.strval($archrooms[$i]['availability']);
                /*if((in_array($test, $alreadyAl)) == False){*/
                echo "<option value='$test'>$not</option>";
                /*array_push($alreadyAl, $test);
                }*/
            }
        }
        ?>
        <input type="submit" value="Swap" name="sub">
       
        <?php
            if(isset($_POST['sub']) ){
                foreach ($_POST['bookrent'] as $dumbkey => $toexplode){
                    $toswap = explode("#", $toexplode);
                    if ($toswap[2] == 'booked'){
                        $yup = "UPDATE archived_room SET availability = 'rented' WHERE hotelid = $toswap[0] AND room_number = $toswap[1] AND date_booked = '$toswap[3]';";
                        pg_send_query($cn, $yup);
                    }else if ($toswap[2] == 'rented'){
                        $yup = "UPDATE archived_room SET availability = 'booked' WHERE hotelid = $toswap[0] AND room_number = $toswap[1] AND date_booked = '$toswap[3]';";
                        pg_send_query($cn, $yup);
                    }
                }
                pg_get_result($cn);
            }
        ?>
</form>
      <br>
      <br>
    <table>


                <tr>
                    <th>Area</th>
                    <th>Hotel Room Count</th>
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
    <br>
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




    Enter Customer Payment:
    <br>
    <br>
    Credit Card Number:
    <br>
    <input type="number" id="nothing">
    <br>
    <br>
    Billing Address:
    <br>
    <input type="text" id="two">
    <br>
    <br>
    <input type="button" value="Submit" id="btnsubmit" onclick="submitForm()">
<script>
function submitForm() {
   document.getElementById('nothing').value='';
   document.getElementById('two').value='';
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
    <select name="hotelsearch[]" multiple class="bigboi">
      <option value="">--HOTEL CHAINS--</option>
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
        /*print_r($alreadyA);*/
        ?>
        <option value="">--HOTEL AREA--</option>
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
        <option value="">--HOTEL RATING(Category)--</option>
        <?php
        $alreadyA = array();
        $result = pg_query($cn, "SELECT * FROM hotel");
        $hotels = pg_fetch_all($result);


        for($i = 0; $i < count($hotels); $i++) {
            foreach ($hotels[$i] as $key => $item){
                if ($key == 'rating'){
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
        <option value="">--CAPACITY--</option>
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
        <option value="">--PRICE--</option>
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
        <option value="">--VIEW--</option>
        <option value="sea_view#true">Yes Sea View</option>
        <option value="sea_view#false">No Sea View</option>
        <option value="mountain_view#true">Yes Mountain View</option>
        <option value="mountain_view#false">No Mountain View</option>
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
   
    <br>
   
        <h2>---Booking---</h2><br>
    <h3>Enter the room details below</h3>
    <p>
        Hotel Id must be an integer <br>
        Room Number must be an integer <br>
        Date Booked must be in the form "year-month-day" including the dashes (eg: 2023-03-31)
    </p><br>


    <form method="post">
    <label for="hotelid_room_book">Hotel Id:</label><br>
    <input type="number" name="hotelid_room_book"><br>
    <label for="roomNumber_book">Room Number:</label><br>
    <input type="number" name="roomNumber_book"><br>
    <label for="date_booked">Date to Book:</label><br>
    <input type="text" name="date_booked"><br>


    <h3>Enter your personal information</h3><br>
    <p>
        SSN/SIN must be a 9 digit integer that starts with 1-9 (not 0)<br>
    </p><br>


    <label for="ssn_sin_book">SSN/SIN:</label><br>
    <input type="number" name="ssn_sin_book"><br>
    <label for="first_name_book">First Name:</label><br>
    <input type="text" name="first_name_book"><br>
    <label for="last_name_book">Last Name:</label><br>
    <input type="text" name="last_name_book"><br>
    <label for="address_book">Address:</label><br>
    <input type="text" name="address_book"><br>
    <br>
   
        <input type="submit" name="insertbooking" value="Book"/>


    <br>
   
        <input type="submit" name="deletebooking" value="Cancel Booking"/>
    </form>
    <p>
        To cancel you need hotel id, room number ,and date booked<br>
    </p><br>
   
    <br>
   
    <?php
   
    if(isset($_POST['insertbooking'])){
            $hotelid = $_POST['hotelid_room_book'];
            $room_number = $_POST['roomNumber_book'];
            $date_booked = $_POST['date_booked'];
            $ssn_sin = $_POST['ssn_sin_book'];
            $first_name = $_POST['first_name_book'];
            $last_name = $_POST['last_name_book'];
            $address = $_POST['address_book'];


            $sqlcustomer = "INSERT INTO customer (ssn_sin, first_name, last_name, address) VALUES ($ssn_sin, '$first_name', '$last_name', '$address')";
       
            $resultcustomer = pg_query($cn, $sqlcustomer);


            $resultrow = pg_query($cn, "SELECT * FROM room WHERE hotelid=$hotelid AND room_number = $room_number");
            $roomdata = pg_fetch_all($resultrow);
            print_r($roomdata);


            $a = $roomdata[0]['price'];
            $b = $roomdata[0]['amenities'];
            $c = $roomdata[0]['capacity'];
            $d = $roomdata[0]['sea_view'];
            $e = $roomdata[0]['mountain_view'];




            $sql = "INSERT INTO archived_room (hotelid, room_number, price, amenities, capacity, sea_view, mountain_view, date_booked) VALUES ($hotelid, $room_number, '$a', '$b', $c, '$d', '$e', '$date_booked')";
       
            $result = pg_query($cn, $sql);


            $sqlrents = "INSERT INTO rents (ssn_sin, hotelid, room_number, date_booked) VALUES ($ssn_sin, $hotelid, $room_number, '$date_booked')";
       
            $resultrents = pg_query($cn, $sqlrents);
        }
        if(isset($_POST['deletebooking'])){
            $hotelid = $_POST["hotelid_room_book"];
            $room_number = $_POST["roomNumber_book"];
            $date_booked = $_POST["date_booked"];


            $sql = "DELETE FROM archived_room WHERE hotelid = $hotelid AND room_number = $room_number AND date_booked = '$date_booked'";
            $result = pg_query($cn, $sql);
        }
   
  ?>
   
   
   
   
  </div>
  <button class="accordion">
    Edit<span class="accordion__indicator"></span>
  </button>
 
  <div class="accordion-panel">
 
 
 


 


 
 
 
 
 
  <h3>Hotel insert/delete/update</h3>
  <p>
        Hotel Id must be an integer <br>
    </p>
    <br>
    <form method="post">
    <label for="hotelId">Hotel ID:</label><br>
    <input type="number" name="hotelId"><br>
    <label for="chainName">Chain ID:</label><br>
    <input type="text" name="chainName"><br>
    <label for="rate">Rating:</label><br>
    <input type="number" name="rate"><br>
    <label for="email">Contact Email:</label><br>
    <input type="text" name="email"><br>
    <label for="phoneNum">Phone Number:</label><br>
    <input type="number" name="phoneNum"><br>
    <label for="add">Address:</label><br>
    <input type="text" name="add"><br>
    <label for="areaHotel">Area:</label><br>
    <input type="text" name="areaHotel"><br>
   
    <br>
   
        <input type="submit" name="insertHotel" value="insert"/>
   
    <br>
   
        <input type="submit" name="deleteHotel" value="delete"/>


    <br>
   
        <input type="submit" name="updateHotel" value="update"/>
    </form>
    (When Inserting a room you must have all fields filled out)<br>
        (When Deleting, only the Hotel ID is needed)<br>
        (Updates can be done to any attribute other than the Hotel ID and Room Number. Hotel ID is required for updates)


    <br>
    <br>


    <h3>Customer insert/delete/update</h3>
    <p>
        SSN/SIN is a 9 digit integer starting with 1-9 (no 0) <br>
    </p><
    <br>
    <form method="post">
    <label for="ssn_sin_cust">SSN/SIN:</label><br>
    <input type="number" name="ssn_sin_cust"><br>
    <label for="first_name_cust">First Name:</label><br>
    <input type="text" name="first_name_cust"><br>
    <label for="last_name_cust">Last Name:</label><br>
    <input type="text" name="last_name_cust"><br>
    <label for="address_cust">Address:</label><br>
    <input type="text" name="address_cust"><br>
    <br>
   
        <input type="submit" name="insertCust" value="insert"/>
   
    <br>
   
        <input type="submit" name="deleteCust" value="delete"/>
   
    <br>
   
        <input type="submit" name="updateCust" value="update"/>
    </form>
    <p>
        (When Inserting a room you must have all fields filled out)<br>
        (When Deleting, only the SSN/SIN is needed)<br>
        (Updates can be done to any attribute other than the SIN/SSN, which is required to make any updates)
    </p><br>


    <br>
    <br>


    <h3>Employee insert/delete/update</h3>
    <p>
        SSN/SIN is a 9 digit integer starting with 1-9 (no 0) <br>
        Hotel ID is the hotel id of the hotel the employee is working at <br>
    </p><br>
    <br>
    <form method="post">
    <label for="ssn_sin_emp">SSN/SIN:</label><br>
    <input type="number" name="ssn_sin_emp"><br>
    <label for="first_name_emp">First Name:</label><br>
    <input type="text" name="first_name_emp"><br>
    <label for="last_name_emp">Last Name:</label><br>
    <input type="text" name="last_name_emp"><br>
    <label for="address_emp">Address:</label><br>
    <input type="text" name="address_emp"><br>
    <label for="role_position">Role/Position:</label><br>
    <input type="text" name="role_position"><br>
    <label for="hotelid_emp">Hotel Id:</label><br>
    <input type="text" name="hotelid_emp"><br>
    <br>
   
        <input type="submit" name="insertEmp" value="insert"/>
   
    <br>
   
        <input type="submit" name="deleteEmp" value="delete"/>
   
    <br>
   
        <input type="submit" name="updateEmp" value="update"/>
    </form>
    <p>
        (When Inserting a room you must have all fields filled out)<br>
        (When Deleting, only the SSN/SIN is needed)<br>
        (Updates can be done to any attribute other than the SIN/SSN, which is required to make any updates)
    </p><br>


    <br>
    <br>


    <h3>Room insert/delete/update</h3>
    <p>
        Hotel Id must be an integer <br>
        Room Number must be an integer <br>
    </p>
    <br>
    <form method="post">
    <label for="hotelid_room">Hotel Id:</label><br>
    <input type="number" name="hotelid_room"><br>
    <label for="roomNumber">Room Number:</label><br>
    <input type="number" name="roomNumber"><br>
    <label for="price">Price:</label><br>
    <input type="double" name="price"><br>
    <label for="amenities">Amenities:</label><br>
    <input type="text" name="amenities"><br>
    <label for="capacity">Capacity:</label><br>
    <input type="number" name="capacity"><br>
    <label for="seaView">Sea View:</label><br>
    <select name="seaView">
        <option value="true">True</option>
        <option value="false">False</option>
    </select><br>
    <label for="mountView">Mountain View:</label><br>
    <select name="mountView">
        <option value="true">True</option>
        <option value="false">False</option>
    </select>
    <br>
    <br>
   
        <input type="submit" name="insertRoom" value="insert"/>
   
    <br>
   
        <input type="submit" name="deleteRoom" value="delete"/>
   
    <br>
   
        <input type="submit" name="updateRoom" value="update"/>
    </form>
    <p>
        (When Inserting a room you must have all fields filled out)<br>
        (When Deleting, only the Hotel ID and Room Number are needed)<br>
        (Updates can be done to any attribute other than the Hotel ID and Room Number. Hotel ID and Room Number are also required to make any updates)
    </p><br>
   
    <?php
        if(isset($_POST['insertHotel'])){


            $hotelid = $_POST['hotelId'];
            $hotel_chainid = $_POST['chainName'];
            $rating = $_POST['rate'];
            $contact_email = $_POST['email'];
            $phone_number = $_POST['phoneNum'];
            $address = $_POST['add'];
            $area = $_POST['areaHotel'];


            $sql = "INSERT INTO hotel (hotelid, hotel_chainid, rating, contact_email, address, area) VALUES ($hotelid, $hotel_chainid, $rating, '$contact_email', '$address', '$area')";
       
            $result = pg_query($cn, $sql);


            $sqlPhonenum = "INSERT INTO phone_numbers_hotel (phone_numberid, phone_number) VALUES ($hotelid, $phone_number)";
       
            $resultPhonenum = pg_query($cn, $sqlPhonenum);


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


            $hotelid = $_POST['hotelId'];
           
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
            $ssn_sin = $_POST['ssn_sin_cust'];
            $first_name = $_POST['first_name_cust'];
            $last_name = $_POST['last_name_cust'];
            $address = $_POST['address_cust'];


            $sql = "INSERT INTO customer (ssn_sin, first_name, last_name, address) VALUES ($ssn_sin, '$first_name', '$last_name', '$address')";
       
            $result = pg_query($cn, $sql);
        }
        if(isset($_POST['deleteCust'])){
            $ssn_sin = $_POST['ssn_sin_cust'];
           
            $sql = "DELETE FROM customer WHERE ssn_sin = $ssn_sin";
       
            $result = pg_query($cn, $sql);
        }
        if(isset($_POST['insertEmp'])){
            $ssn_sin = $_POST['ssn_sin_emp'];
            $first_name = $_POST['first_name_emp'];
            $last_name = $_POST['last_name_emp'];
            $address = $_POST['address_emp'];
            $role_positions = $_POST['role_position'];
            $hotelid = $_POST['hotelid_emp'];


            $sql = "INSERT INTO employee (ssn_sin, address, roles_positions, first_name, last_name) VALUES ($ssn_sin, '$address', '$role_positions','$first_name', '$last_name')";
       
            $result = pg_query($cn, $sql);


            $sqlworks = "INSERT INTO works_for (hotelid, ssn_sin) VALUES ($hotelid, $ssn_sin)";


            $resultworks = pg_query($cn, $sqlworks);
        }
        if(isset($_POST['deleteEmp'])){
            $ssn_sin = $_POST['ssn_sin_emp'];


            $sql = "DELETE FROM employee WHERE ssn_sin = $ssn_sin";
       
            $result = pg_query($cn, $sql);
        }
        if(isset($_POST['insertRoom'])){
            $hotelid = $_POST['hotelid_room'];
            $room_number = $_POST['roomNumber'];
            $price = $_POST['price'];
            $amenities = $_POST['amenities'];
            $capacity = $_POST['capacity'];
            $sea_view = $_POST['seaView'];
            $mountain_view = $_POST['mountView'];


            $sql = "INSERT INTO room (hotelid, room_number, price, amenities, capacity, sea_view, mountain_view) VALUES ($hotelid, $room_number, $price, '$amenities', $capacity, '$sea_view', '$mountain_view')";
       
            $result = pg_query($cn, $sql);
        }
        if(isset($_POST['deleteRoom'])){
            $hotelid = $_POST['hotelid_room'];
            $room_number = $_POST['roomNumber'];


            $sql = "DELETE FROM room WHERE hotelid = $hotelid AND room_number = $room_number";


            $result = pg_query($cn, $sql);
        }


        //Update button functionality
        if(isset($_POST['updateHotel'])){


            $hotelid = $_POST['hotelId'];
            $hotel_chainid = $_POST['chainName'];
            $rating = $_POST['rate'];
            $contact_email = $_POST['email'];
            $phone_number = $_POST['phoneNum'];
            $address = $_POST['add'];
            $area = $_POST['areaHotel'];


            $str = "UPDATE hotel SET ";
            $counter = 0;


            if(!empty($hotel_chainid)){
                if($counter == 0){
                    $str .= "hotel_chainid = $hotel_chainid";
                }
                else{
                    $str .= ", hotel_chainid = $hotel_chainid";
                }


                $counter++;
            }
            if(!empty($rating)){
                if($counter == 0){
                    $str .= "rating = $rating";
                }
                else{
                    $str .= ", rating = $rating";
                }
               
                $counter++;
            }
            if(!empty($contact_email)){
                if($counter == 0){
                    $str .= "contact_email = '$contact_email'";
                }
                else{
                    $str .= ", contact_email = '$contact_email'";
                }


                $counter++;
            }
            if(!empty($phone_number)){
                $sqlphone = "UPDATE hotel SET phone_number = $phone_number  WHERE phone_numberid = $hotelid";
                $result = pg_query($cn, $sqlphone);
            }
            if(!empty($address)){
                if($counter == 0){
                    $str .= "address = '$address'";
                }
                else{
                    $str .= ", address = '$address'";
                }


                $counter++;
            }
            if(!empty($area)){
                if($counter == 0){
                    $str .= "area = '$area'";
                }
                else{
                    $str .= ", area = '$area'";
                }


                $counter++;
            }
            if($counter > 0 ){
                $str .= " WHERE hotelid = $hotelid";
                $sql = $str;
                $result = pg_query($cn, $sql);
            }
        }
        if(isset($_POST['updateCust'])){
            $ssn_sin = $_POST['ssn_sin_cust'];
            $first_name = $_POST['first_name_cust'];
            $last_name = $_POST['last_name_cust'];
            $address = $_POST['address_cust'];


            $str = "UPDATE customer SET ";
            $counter = 0;


            if(!empty($first_name)){
                if($counter == 0){
                    $str .= "first_name = '$first_name'";
                }
                else{
                    $str .= ", first_name = '$first_name'";
                }


                $counter++;
            }
            if(!empty($last_name)){
                if($counter == 0){
                    $str .= "last_name = '$last_name'";
                }
                else{
                    $str .= ", last_name = '$last_name'";
                }


                $counter++;
            }
            if(!empty($address)){
                if($counter == 0){
                    $str .= "address = '$address'";
                }
                else{
                    $str .= ", address = '$address'";
                }


                $counter++;
            }
            if($counter > 0 ){
                $str .= " WHERE ssn_sin = $ssn_sin";
                $sql = $str;
                $result = pg_query($cn, $sql);
            }
        }
        if(isset($_POST['updateEmp'])){
            $ssn_sin = $_POST['ssn_sin_emp'];
            $first_name = $_POST['first_name_emp'];
            $last_name = $_POST['last_name_emp'];
            $address = $_POST['address_emp'];
            $role_positions = $_POST['role_position'];
            $hotelid_emp = $_POST['hotelid_emp'];


            $resultrow = pg_query($cn, "SELECT * FROM employee WHERE ssn_sin=$ssn_sin");
            $empdata = pg_fetch_all($resultrow);
           
            $resultid = pg_query($cn, "SELECT * FROM works_for WHERE ssn_sin=$ssn_sin");
            $id = pg_fetch_all($resultid);


            $a = $empdata[0]['first_name'];
            $b = $empdata[0]['last_name'];
            $c = $empdata[0]['address'];
            $d = $empdata[0]['roles_positions'];
            $e = $id[0]['hotelid'];


   


            if(empty($first_name)){
                $tempa = $a;
            }
            else{
                $tempa = $first_name;
            }
            if(empty($last_name)){
                $tempb = $b;
            }
            else{
                $tempb = $last_name;
            }
            if(empty($address)){
                $tempc = $c;
            }
            else{
                $tempc = $address;
            }
            if(empty($role_positions)){
                $tempd = $d;
            }
            else{
                $tempd = $role_positions;
            }
            if(empty($hotelid_emp)){
                $tempe = $e;
            }
            else{
                $tempe = $hotelid_emp;
            }


            $sqldel = "DELETE FROM employee WHERE ssn_sin = $ssn_sin";
           
            $resultdel = pg_query($cn, $sqldel);


            $sql = "INSERT INTO employee (ssn_sin, first_name, last_name, address, roles_positions) VALUES ($ssn_sin, '$tempa', '$tempb','$tempc', '$tempd')";
       
            $result = pg_query($cn, $sql);


            $sqlworks = "INSERT INTO works_for (hotelid, ssn_sin) VALUES ($tempe, $ssn_sin)";


            $resultworks = pg_query($cn, $sqlworks);
        }
        if(isset($_POST['updateRoom'])){
            $hotelid = $_POST['hotelid_room'];
            $room_number = $_POST['roomNumber'];
            $price = $_POST['price'];
            $amenities = $_POST['amenities'];
            $capacity = $_POST['capacity'];
            $sea_view = $_POST['seaView'];
            $mountain_view = $_POST['mountView'];


            $str = "UPDATE room SET ";
            $counter = 0;


            if(!empty($price)){
                if($counter == 0){
                    $str .= "price = $price";
                }
                else{
                    $str .= ", price = $price";
                }


                $counter++;
            }
            if(!empty($amenities)){
                if($counter == 0){
                    $str .= "amenities = '$amenities'";
                }
                else{
                    $str .= ", amenities = '$amenities'";
                }


                $counter++;
            }
            if(!empty($capacity)){
                if($counter == 0){
                    $str .= "capacity = $capacity";
                }
                else{
                    $str .= ", capacity = $capacity";
                }


                $counter++;
            }
            if(!empty($sea_view)){
                if($counter == 0){
                    $str .= "sea_view = $sea_view";
                }
                else{
                    $str .= ", sea_view = $sea_view";
                }


                $counter++;
            }
            if(!empty($mountain_view)){
                if($counter == 0){
                    $str .= "mountain_view = $mountain_view";
                }
                else{
                    $str .= ", mountain_view = $mountain_view";
                }


                $counter++;
            }
            if($counter > 0 ){
                $str .= " WHERE room_number = $room_number AND hotelid = $hotelid";
                $sql = $str;
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


