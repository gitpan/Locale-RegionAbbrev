#------------------------------------------------------------------------------
# Test script for Locale::RegionAbbrev.pm 
#                                            
# Author: Kim Ryan (kimaryan@ozemail.com.au) 
# Date  : April 2000                         
#------------------------------------------------------------------------------

use strict;
use Locale::RegionAbbrev;

# We start with some black magic to print on failure.

BEGIN { print "1..3\n"; }


my $australia = new Locale::RegionAbbrev('Australia');
print $australia->abbreviation('New South Wales ') eq 'NSW'	? "ok 1\n" : "not ok 1\n";
print $australia->full_name('S.A.') eq 'South Australia'	   ? "ok 2\n" : "not ok 2\n";

my $upper_case = 1;
print $australia->full_name('Qld',$upper_case) eq 'QUEENSLAND'	? "ok 3\n" : "not ok 3\n";




