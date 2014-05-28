#!/usr/bin/env perl
use warnings;
use strict;

system("clear");

my @originalAoA = ( [0,1,2,3],
	            ['a','b','c','d']
	          );

# 2-level shallow copy of a 2D array
# You'll see this same map function below again
my @shiftAoA = map { [@$_] } @originalAoA;

print "OriginalAoA - Prints the initial 2D array. Also referred to as an Array of Arrays or 'AoA'\n";
print @$_, "\n" foreach ( @originalAoA );

print "\nPushAoA - Pushes a value onto the END of an Array\n";
my @pushAoA = map { [@$_] } @originalAoA;
push @{$pushAoA[0]},'Z';
print @$_, "\n" foreach ( @pushAoA );

print "\nPopAoA - Remove the END (last) value from the Push'd array\n";
my @popAoA = map { [@$_] } @pushAoA;
pop @{$popAoA[0]};
print @$_, "\n" foreach ( @popAoA );

print "\nShiftAoA - Shift removes a value from START (beginning, first element, first value, etc) of an array\n";
shift @{$shiftAoA[0]};
print @$_, "\n" foreach ( @shiftAoA );

print "\nUnshift - We add  a value back to the START (beginning) of the shift'd array\n";
unshift @{$shiftAoA[0]},9;
print @$_, "\n" foreach ( @shiftAoA );
