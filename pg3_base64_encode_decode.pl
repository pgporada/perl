#!/usr/bin/perl
use strict;
use warnings;

# By Phil Porada & Don Musser
# Due: 3/08/12
# Base64 Encoder/Decoder

my @m_ascii;   # Create array for storing ASCII characters
$m_ascii[9] = ("\t");
$m_ascii[10] = ("\n");
$m_ascii[13] = ("\r");
@m_ascii[32..47] = (" ",'!','"','#','$','%','&',"'",'(',')','*','+',",",'-','.','/');
@m_ascii[48..57] = ('0'..'9');
@m_ascii[58..64] = (':',';','<','=','>','?','@');
@m_ascii[65..90] = ('A'..'Z');
@m_ascii[91..96] = ('[',"\\",']','^','_','`');
@m_ascii[97..122] = ('a'..'z');
@m_ascii[123..126] = ('{','|','}','~');

my @p_6bitTob64; # Array for storing 6bit to b64 character
@p_6bitTob64[0..25] = ('A'..'Z');
@p_6bitTob64[26..51] = ('a'..'z');
@p_6bitTob64[52..61] = ('0'..'9');
$p_6bitTob64[62] = ("+");
$p_6bitTob64[63] = ("\\");

# Create hash for storing B64 characters to corresponding decimal values 
my %m_b64_dec = ("A",0,"B",1,"C",2,"D",3,"E",4,"F",5,"G",6,"H",7,"I",8,"J",9,"K",10,"L",11,"M",12,"N",13,"O",14,"P",15,
"Q",16,"R",17,"S",18,"T",19,"U",20,"V",21,"W",22,"X",23,"Y",24,"Z",25,"a",26,"b",27,"c",28,"d",29,"e",30,"f",31,
"g",32,"h",33,"i",34,"j",35,"k",36,"l",37,"m",38,"n",39,"o",40,"p",41,"q",42,"r",43,"s",44,"t",45,"u",46,"v",47,
"w",48,"x",49,"y",50,"z",51,"0",52,"1",53,"2",54,"3",55,"4",56,"5",57,"6",58,"7",59,"8",60,"9",61,"+",62,"\\",63);

my $m_chunk = 0;

# Get input file name
print "Please enter input file name: ";
chomp(my $filename = <>);

# break up file name into name and extension part
# e.g. in mail.txt, the name is mail and the extension is txt
my $i = index($filename, ".", 0);  # search for . in filename starting at POS 0
if ($i < 0) {
   print "Invalid filename. name.ext expected\n";
   exit;
}
my $name= substr($filename, 0, $i);
my $ext = substr($filename, $i+1);
if ((uc $ext) eq "B64") {   # decode the file
   print "decode content of $filename\n";
   
   open (my $m_infile, "<", $filename) or die "Unable to open $filename for read\n";
   open (my $m_outfile, ">", $name.".6BDEC") or die "Unable to open $name.6BDEC for write\n"; # .6BDEC for 6-bit decimal of B64 chars
   
   my $m_eq_count = 0;
   while (read($m_infile, $m_chunk, 1)) { # Read B64 string one character at a time
      if ($m_chunk eq "=") { # Checking for = characters, will not actually write these to the file
         $m_eq_count++;
         print "$m_eq_count instance(s) of the = character detected\n";
         next;
      }
      else {
         my $m_dec_b64 = $m_b64_dec{$m_chunk}; # Find the decimal representation of the B64 character
         print $m_outfile $m_dec_b64."\n";     # and print to outfile one line at a time
      }
   }
   
   close $m_infile or die "Unable to close $filename\n";    # We close the files
   close $m_outfile or die "Unable to close $name.6BDEC\n"; # now that we are done
   
   open ($m_infile, "<", $name.".6BDEC") or die "Unable to open $name.6BDEC for read\n";
   open ($m_outfile, ">", $name.".6BBIN") or die "Unable to open $name.6BBIN for write\n"; # .6BBIN for decimal value of 6-bit b64 chars
   
   while (<$m_infile>) { # Read the B64 decimal values on line at a time
      chomp($_);
      my $m_bin = sprintf("%b", $_); # Give us binary equivalent of each integer in file
      my $m_bin_length = length($m_bin);   # Measure length
      if ($m_bin_length < 6) {
          $m_bin_length = 6 - $m_bin_length;            # Length of the binary digits must be 6
          $m_bin = "0" x $m_bin_length . "$m_bin";      # Prepend 0s if length < 6
          print $m_outfile $m_bin;                      # and print to the outfile
       }
      else {
         print $m_outfile $m_bin;
      }
   }

   close $m_infile or die "Unable to close $name.6BDEC\n";
   close $m_outfile or die "Unable to close $name.6BBIN\n";
   
   open ($m_infile, "<", $name.".6BBIN") or die "Unable to open $name.6BBIN for read\n";
   open ($m_outfile, ">", $name.".8BBIN") or die "Unable to open $name.8BBIN for write\n";  # .8BBIN for decimal value of 8 binary bits
   
   my $m_read_infile = <$m_infile>;                     # Determine length of infile
   my $m_eq_length = $m_eq_count * 2;                   # The amount of 0s that may need to be chopped, based on presence of = character(s)
   my $m_length_infile = length($m_read_infile);        
   my $m_true_length = $m_length_infile;                # The amount of characters we will read prior to ASCII conversion
   
   if ($m_eq_length > 0) {                              # Decrement the number of characters to read from infile, if needed.
      print "Stripping 0s from = character(s)...\n";
      print "Infile length is $m_length_infile\n";
      print "Stripping $m_eq_length 0s...\n";
      $m_true_length = $m_length_infile - $m_eq_length;
      print "Will only read $m_true_length characters from infile\n";
   }
   
   else {      
      print "No = characters detected; no stripping of 0s is needed\n";
   }
   
   close $m_infile or die "Unable to close $name.6BBIN\n";
   open ($m_infile, "<", $name.".6BBIN") or die "Unable to open $name.6BBIN for read\n";
   
   for ( ; $m_true_length > 0; $m_true_length--) {
      read ($m_infile, $m_chunk, 1);
      print $m_outfile $m_chunk;
   }            
   
   close $m_infile or die "Unable to close $name.6BBIN\n";
   close $m_outfile or die "Unable to close $name.8BBIN\n";
   
   open ($m_infile, "<", $name.".8BBIN") or die "Unable to open $name.8BBIN for read\n";
   open ($m_outfile, ">", $name.".DECODED.txt") or die "Unable to open $name.DECODED.txt for write\n";
   
   while (read($m_infile, $m_chunk, 8)) {       # Read 8 bits of binary at a time
      my $m_ascii_dec = oct("0b$m_chunk");
      my $m_ascii_char = $m_ascii[$m_ascii_dec];
      print $m_outfile $m_ascii_char;
   }
   
   close $m_infile or die "Unable to close $name.8BBIN\n";
   close $m_outfile or die "Unable to close $name.DECODED.txt\n";  
   print "Decoding completed: " . $name . ".DECODED.txt\n";
}
else {   # encode the file
   print "Encode content of $filename\n";

   # Opens files, the while loop reads in the characters 1 by 1
   open (my $infile, "<", $filename) or die "Unable to open $filename for read";
   open (my $outfile, ">", $name.".COPY") or die "Unable to open $name.COPY for write";

   while (read($infile, my $chunk, 1)) { # read in chunks of 1-char at a time
      print $outfile $chunk;
   }

   close $infile;
   close $outfile or die "NO CLOSE";



#####################################################################
#done# Now reopen the copy of the input file and
#done# another output file with the extension .TMP1 instead of .COPY
#done# In a while Loop,
#done#     read 1 character at a time from the input file and
#done#     a. get the ASCII code of the character using ord function
#done#     b. get the binary value for the ascii code using sprintf("%08b", $asciiCode)
#done#     c. Write this 8-bit code to the output file.
#done# Upon exit from the while loop, close both I/O files
#####################################################################
 
  open ($infile, "<", $name.".COPY");
  open ($outfile, ">", $name.".TMP1") or die "Unable to open $name.TMP1 for write";

   my $asciiCode;
   while (read($infile, my $chunk, 1)) {    # read in chunks of 1-char at a time
      $asciiCode = ord($chunk);             # gets the ascii value
      $chunk = sprintf("%08b", $asciiCode); # converts ascii to binary
      print $outfile $chunk
   }
   close $infile;
   close $outfile or die "NO CLOSE";



#####################################################################
#done# Now open the .TMP1 file i.e. the one with the binary values for input and
#done# another output file with the extension .6BITS
#done# In a while Loop,
#done#     read 6 characters at a time from the input file and
#done#     write to the output file. Also write a "\n" to the output file
#done#     every time you write a 6-bit chunk. In other words, the 6-bit chunks
#done#     will be in separate lines.
#done# Upon exit from the while loop, close both I/O files  
#####################################################################

  open ($infile, "<", $name.".TMP1");
  open ($outfile, ">", $name.".6BITS") or die "Unable to open $name.6BITS for write";

   while (read($infile, my $chunk, 6)) {  # read in chunks of 6-char at a time
   print $outfile $chunk."\n";            # adds the newline char to each line
   }

   close $infile;
   close $outfile or die "NO CLOSE";


#####################################################################
#done# HERE IS THE LAST STEP
#done# Now open the .6BITS file i.e. the one with the 6-bit chunks for input and
#done# another output file with the extension .B64
#done# In a while Loop,
#done#     read one line at a time from the input file and
#done#     a. strip the carriage-return at the end of the input using chomp
#done#     b. if the length of the stripped line is less than 6-bits {
#done#            append enough 00's to make it 6-bits long
#done#            Also remember how many pairs of 00's were appended.
#done#        }
#done#     c. Using a very long if/elsif/else [unless you know arrays or hashes],
#done#        Find the base64 character for the stripped line.
#done#     d. Write the base 64 character to the output file
#done# Upon exit from the while loop,
#done# If you appended 00's to the last chunk in the above loop,
#done# write a "=" to the output file for each 00 appended.
#done# close both I/O files
#####################################################################

  open ($infile, "<", $name.".6BITS");
  open ($outfile, ">", $name.".B64") or die "Unable to open $name.B64 for write";
      
   my $i = 0, my $p_ArrayValue = 0, my $chunk, my $bintodec;
   my @p_CharArray;                               # creates array
 
   while (<$infile>) {   
      chomp($_);                     # remove newline char from current line
      if (length($_) == 6) {         # checks all lines but the last
         $bintodec = oct( "0b$_" );  # changes the 6bit binary back to decimal
         push(@p_CharArray,$_);      # add data to the array
       }
      else {                            
         $i = (6 - length($_)) / 2;     # gets # of 00's for last line
         $chunk = $_ . "00"x$i;         # adds the 00's to the last line
         $bintodec = oct( "0b$chunk" ); # changes the 6bit binary back to decimal
         push(@p_CharArray,$chunk);     # add data to the array
       }

      foreach my $j (@p_CharArray) {        # loop to find b64 char for stripped line
        if ( oct( "0b$j" ) == $bintodec ) { # get the dec equivalent for read-in line
            print $outfile $p_6bitTob64[$bintodec];
            last;                           # exit loop early if found
          }
        }
      $p_ArrayValue++;
    }
   
   for( ; $i > 0 ; $i-- ) { # prints ='s to the .B64 file
   print $outfile '=';
   }   

   print "Encoding completed: " . $name . ".B64\n";
   close $infile;
   close $outfile or die "NO CLOSE"; 

}


