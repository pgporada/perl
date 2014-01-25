#!/usr/bin/perl
use warnings;

# By Phil Porada and Mark Cooke
# COSC 146 
# Program 4 Encode/Decode Columnar Transposition Cipher
# Due 3/27/12

open INFILE, "4.dat" or die "Unable to open 4.dat for read\n";

while (my $Line = <INFILE>) {
  $EorD = substr($Line,0,6);           # searchs from position 0 forward 6 chars, range is 0..5
    if ((uc $EorD) eq "EXIT\n") { 
       print "EXIT found\n";  
       last; 
      }
    elsif ((uc $EorD) eq "ENCODE") {   # Encode the file
       $Key = substr($Line,7,1);       # searchs from position 7 which is the key value
       print "Encode with key of " . $Key . "\n";
       
       my $lines = substr $Line, 9,;             #starts at position after the key and saves to $lines       
       
       my $i=0;                                  #reset values for variable to ensure previous value
       my $x=0;                                  #not within new lines value
       my @rows;                                 #needs to be reset each time to make sure @ is clear
       my @message;
       
       $size=int(length($lines)/$Key);
       if ($size<=1){                     	     #adjustment to make sure it is a number greater than 1
           $size=$size+1;}
       else{$size=$size;}
      
       while($i< $size){						 #breaks the string into segments of the key's length
       $fragment = substr $lines, $x , $Key;
       push(@rows, $fragment);
       $i++;
       $x=$x+$Key;                               #increments x in sizes of Key
       }                              		     #end of while loop
    
       chomp($rows[$size-1]);					 #remove carriage return from line
       my $arraysize= length($rows[$size-1]);   
       while ($arraysize<$Key){
          $arraysize= length($rows[$size-1]);    #increments the value of arraysize to test for length
          if($arraysize<$Key){
             $rows[$size-1]=$rows[$size-1]."=";} #add = as many times till length equals $Key
          else{ last; }                          #else exit loop
       }
      
       for($i=0; $i<$Key; $i++){
           foreach my $letter(@rows){            #places value in rows into $letter
           my $frag = substr $letter,$i,1;       #stores value of the letter showing only 1 incremented by position $Key
           push(@message, $frag);                #pushes above value to the @message
           }#end of foreach loop
      
       }#end of for loop
        
      print @message, "\n";                #prints encoded message
      
	 } # end encode elsif
     elsif ((uc $EorD) eq "DECODE") {   # Decode the file
	   $Key = substr($Line,7,1);        # searchs from position 7 which is the key value
       print "Decode with key of " . $Key . "\n";
	   $p_Char = substr($Line,9);
	   my @p_CharArray = split(//, $p_Char); # Each array position has 1 character stored in it
	   
	   my $p_Count = 0;
	   foreach (@p_CharArray) { $p_Count++; }    	  
	   $p_colLength = int($p_Count/$Key);
	   chomp($p_CharArray[$p_Count-1]);	
	   
	   # Actual decode statement ============================================
	   # p_Pos is the position in the array, p_Count2 is the key check, 
	   # p_Count3 checks whether we should stop decoding and exit the loop, 
	   # p_Count4 resets p_Pos so I can go from a position of 23 to 30 and 
	   # not be exited from the loop. Position 30 is not actually displayed because
	   # p_Pos gets set to p_Count4 which can only go to a max of $Key.
	   my $p_Pos = 0, my $p_Count2 = 0, my $p_Count3 = 0, my $p_Count4 = 1;
	   while ($p_Pos < $p_Count-1) {
	      if ( $p_CharArray[$p_Pos] ne "=") { # disregard equals so they aren't printed out
	         print $p_CharArray[$p_Pos];
	         $p_Pos += $p_colLength;
		     $p_Count2++;
	      }
	      else {
		     $p_Pos += $p_colLength;
		     $p_Count2++;
	      }
		  if ($p_Count2 == $Key) {
             $p_Pos = $p_Count4; 
		     $p_Count2 = 0;
		     $p_Count3++; 
		     $p_Count4++;
		  }
		  if ($p_Count3 == $p_colLength) { print "\n"; last; }	# exit loop   
	    } #end while
		
    } # end decode elsif
	
} # end program
