#!/usr/bn/perl
use strict;
use warnings;

  #Phil Porada E01118381
  #To generate the correct amount of change from a transaction

my $check = 1;

 #for loop to automatically continue the program until some variation of quit is typed
for(; $check == 1;){
  #Prompt for and read the amount of sale
print "\nType \"Quit\" to exit\n";
print "Please enter the amount of sale: \$";
my $amtSale = <>;
  #exit loop check
if($amtSale =~ /^[Qq][Uu][Ii][Tt]/) {exit 0;}

  #Prompt for and read the amount tendered
print "Please enter the amount tendered: \$";
my $amtTnd = <>;
  #exit loop check
if($amtTnd =~ /^[Qq][Uu][Ii][Tt]/) {exit 0;}

 #check for negative change
if ($amtSale > $amtTnd){
  print"
   The amount tendered was less than the amount of the sale
   ======================
";
}
else{
  #calculate total change
my $totalChange = sprintf "%0.2f" , $amtTnd - $amtSale;

  #convert total change to pennies
my $pennies = int($totalChange * 100 + .05);

  #compute dollar bills
my $dollarBills = int($pennies / 100);

  #compute quarters
my $remainder = $pennies % 100;
my $quarters = int($remainder / 25);

  #compute dimes
$remainder %= 25;
my $dimes = int($remainder / 10);

  #compute nickels
$remainder %= 10;
my $nickels = int($remainder / 5);

  #compute pennies and remainder
$remainder %= 5;
$pennies = $remainder;
$remainder %= 1;

  #Print the results
print"
   Total change: \$$totalChange
   Dollars: $dollarBills
   Quarters: $quarters
   Dimes: $dimes
   Nickels: $nickels
   Pennies: $pennies
   The remainder is:    $remainder
   ======================
";
 } #end the else statement 
}  #end the for loop

