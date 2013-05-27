#!perl

use strict;
use warnings;
use utf8;
use FindBin;
push @INC, "$FindBin::Bin/lib";

use Test::LocalFunctions::Fast;

use Test::More;
use Test::Builder::Tester;

foreach my $lib (map{"t/lib/Fail$_.pm"} 1..3) {
    if ($lib =~ /Fail\d*.pm/) {
        require $&;
    }
    test_out "not ok 1 - $lib";
    test_fail +1;
    local_functions_ok($lib);
    test_test "testing local_functions_ok($lib)";
}

done_testing;
