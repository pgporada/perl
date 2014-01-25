#!/usr/bin/perl
use warnings;
use strict;

open(my $file,"<","excuses") or die "Excuse file is on a break, please leave a message.";
rand;
my $line = undef;
rand($.) < 1 && ($line = $_) while <$file>;
print $line;
close $file;
