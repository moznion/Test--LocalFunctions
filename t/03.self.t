#!perl

use strict;
use warnings;
use utf8;

use Test::LocalFunctions;

use Test::More;

$ENV{TEST_PHASE} = 1;
all_local_functions_ok();

done_testing;
