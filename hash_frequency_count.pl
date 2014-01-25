#!/usr/bin/perl
use warnings;

open ($infile,"<","hashinfile.dat") or die "Unable to open hashinfile.dat for read\n";

my %myHash;
my @tempArray;
my $key, my $count = 01, my $word;

# The regex removes punctuation
# It makes each word uppercase and enters the foreach loop
# to increment the number of occurences --> value, $_ is the key
while ($word = <$infile>){
	$word =~ s/[[:punct:]]//g;
	@tempArray = split(" ",uc($word));
	foreach (@tempArray) { 
		if ( exists $myHash{$_} ) { $myHash{$_} = ++$myHash{$_}; }
		else { $myHash{$_} = 1; }
	}
}

print "   COUNT WORDS\n";
print "   ===== =====\n";

# sort {$myHash{$b} <=> $myHash{$a}} (keys %myHash) 
# This works by sorting the entire hash explicitly for $key
# http://perldoc.perl.org/functions/sort.html
foreach $key ( sort {$myHash{$b} <=> $myHash{$a}} (keys %myHash) ) {
  printf '%2d',$count;
  print ".  " . $myHash{$key} . "\t " . $key . "\n";
  $count++;
}

print "\n";
close $infile;
