#!perl

use strict;
use warnings;
use utf8;
use FindBin;
push @INC, "$FindBin::Bin/../lib";

# Test::LocalFunctions::Fast uses Compiler::Lexer.
# It is not up to user to install Compiler::Lexer.
BEGIN {
    use Test::More;
    eval 'use Compiler::Lexer';
    plan skip_all => "Compiler::Lexer required for testing Test::LocalFunctions::Fast" if $@;
}

use Test::LocalFunctions::Fast;

use Test::Builder::Tester;

foreach my $lib (map{"t/lib/Fail$_.pm"} 1..3) {
    if ($lib =~ /Fail\d*.pm/) {
        require $&;
    }
    test_out "not ok 1 - $lib";
    local_functions_ok($lib);
    test_test (name => "testing local_functions_ok($lib)", skip_err => 1);
}

done_testing;
