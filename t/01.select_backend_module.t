#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    *CORE::GLOBAL::require = sub {
        my $file = shift;

        if ($file =~ m!Compiler/Lexer\.pm!) {
            die 'NOT HERE';
        }
        CORE::require($file)
    };
}

subtest 'Environment variable of "T_LF_PPI" is enabled' => sub {
    $ENV{T_LF_PPI} = 1;
    require Test::LocalFunctions;
    ok $INC{'Test/LocalFunctions/PPI.pm'};
    ok not $INC{'Test/LocalFunctions/Fast.pm'};

    $ENV{T_LF_PPI} = undef;
    delete $INC{'Test/LocalFunctions.pm'};
    delete $INC{'Test/LocalFunctions/PPI.pm'};
};

subtest 'Should select Test::LocalFunctions::PPI' => sub {
    require Test::LocalFunctions;

    ok $INC{'Test/LocalFunctions/PPI.pm'};
    ok not $INC{'Test/LocalFunctions/Fast.pm'};

    delete $INC{'Test/LocalFunctions.pm'};
    delete $INC{'Test/LocalFunctions/PPI.pm'};
};
done_testing;
