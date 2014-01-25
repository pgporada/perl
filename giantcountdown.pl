#!/usr/bin/env perl
use warnings;
use Date::Calc qw(Today Delta_Days);

my ($Y1,$M1,$D1) = Today();

if ($D1 == 19) { print "Tomorrow is your anniversary!\n" }
if ($D1 == 20) {
  #figure out how many months since we started dating
  my $anniv = abs(int(Delta_Days(2012,7,20,$Y1,$M1,$D1)/30));
  my $end = "th";
  #checks if it's a year anniversary
  if ($anniv % 12 == 0) { $anniv /= 12; $end = " year"; }
  elsif ($anniv == 2) { $end = "nd"; }
  elsif ($anniv == 3) { $end = "rd"; }
  print "It's our " . $anniv . $end . " anniversary!\n";
}

print "----------------------------------------------------\n";
my $place = Delta_Days($Y1,$M1,$D1,2013,10,12);
print "$place days until we get our own place!\n";
# days until we gtfo of STL
my $place = Delta_Days($Y1,$M1,$D1,2014,10,12);
print "$place days until we GTFO!\n";
print "----------------------------------------------------\n";

print "\n\t\"3 years, 2 months, 1 week, 4 days, I am always counting down\n\t'Cause there ain't no easier way\"\n"; 
