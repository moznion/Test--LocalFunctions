#!perl

use strict;
use warnings;
use utf8;
use FindBin;
push @INC, "$FindBin::Bin/resource/lib";

use Test::LocalFunctions;

use Test::More;

foreach my $lib (map{"t/resource/lib/Succ$_.pm"} 1..1) {
    if ($lib =~ /Succ\d*.pm/) {
        require $&;
    }
    local_functions_ok($lib);
}

done_testing;
