<?php
 $file='templatejson/post_build_ut_pkg.json';
  foreach ($_POST as $key => $value){
	     if (empty($value)) {
         $_POST[$key]="NULL";
         }   
  }
  
 $info=json_encode($_POST);
 $info= str_replace('\/', '/', $info);
 $info= str_replace('\\','\\\\',$info);
 echo $info;
file_put_contents('$file',$info);
 
 ?>