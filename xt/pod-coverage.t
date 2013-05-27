#!perl

use Test::More;

eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

eval "use Compiler::Lexer";
if ($@) {
    # Ignore Test::LocalFunctions::Fast
    pod_coverage_ok('Test::LocalFunctions');
}
else {
    all_pod_coverage_ok();
}

done_testing;
