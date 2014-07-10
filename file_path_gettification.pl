#!/usr/bin/env perl
use File::Basename;
my $dirname = dirname(__FILE__);
my $linename = dirname(__LINE__);

print "test: $dirname\n";
print "test: $linename\n";

use Cwd;
my $abs_path = Cwd::abs_path($0);
print $abs_path."\n";
