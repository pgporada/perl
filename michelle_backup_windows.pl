#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;
use Date::Calc qw(Today);

my ($y1,$m1,$d1) = Today();
if($m1 < 10) { $m1 = 0 . $m1; } # adds a 0 to the month if it's < 10
my $TS = $y1.$m1.$d1;
my $file;
my @maindir = <D:\\Scripts\\Michelle\\*.QBW*>;
my @dropboxdir = <D:\\Scripts\\Testing\\*.QBW*>;
my @backupdir = <D:\\Scripts\\backup\\*.QBW*>;

# gets the oldest date assuming it's the first position in the array in the dropboxdir and moves it to the backupdir
my $oldest = $dropboxdir[0];
foreach $oldest (@dropboxdir) {
	my $x = $oldest;
	# strips some junk
	$x =~ s/D:\\Scripts\\Testing\\//g;
	my $backup = "D:\\Scripts\\backup\\" . $x;
	move($oldest,$backup) or die "FAILED TO MOVE";
}
 
# copies stuff to the dropboxdir from maindir
foreach $file (@maindir) {
	my $y = $file;
	# strips some junk
	$y =~ s/D:\\Scripts\\Michelle\\//g;
	my $newfile = "D:\\Scripts\\Testing\\" . $TS . "_" . $y;
	copy($file,$newfile) or die "FAILED TO COPY";
}
