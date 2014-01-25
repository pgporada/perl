#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;
use Date::Calc qw(Today);

my ($y1,$m1,$d1) = Today();
if($m1 < 10) { $m1 = 0 . $m1; } # adds a 0 to the month if it's < 10
my $TS = $y1.$m1.$d1;
my $file;


copytodropbox();
movetobackup();


# copies stuff to the dropboxdir from maindir
sub copytodropbox {
	chdir "/Users/SneakyPhil/Dropbox/Scripts/michelle/";
	my @maindir = glob("*.QBW*");
	foreach $file (@maindir) {
		my $newfile = "/Users/SneakyPhil/Dropbox/Scripts/michelledropbox/" . $TS . "_" . $file;
		copy($file,$newfile) or die "FAILED TO COPY";
	}
}


# gets the oldest date assuming it's the first position in the array in the dropboxdir and moves it to the backupdir
sub movetobackup {
	chdir "/Users/SneakyPhil/Dropbox/Scripts/michelledropbox/";
	my @dropboxdir = glob("*.QBW*");
	my $oldest = $dropboxdir[0];
	foreach my $x (@dropboxdir) {
		my $oldTS = substr($oldest,0,8);
		my $oldEnd = substr($x,8);
		if( -e $oldTS . $oldEnd) {
			my $backup = "/Users/SneakyPhil/Dropbox/Scripts/michellebackups/" . $oldTS . $oldEnd;
			move($x,$backup) or die "FAILED TO MOVE";
		}
	}
	copytodropbox();
}
