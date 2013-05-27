use strict;
use Test::More;

# Test::LocalFunctions::Fast uses Compiler::Lexer.
# It is not up to user to install Compiler::Lexer.
BEGIN {
    use Test::More;
    eval 'use Compiler::Lexer';
    plan skip_all => "Compiler::Lexer required for testing Test::LocalFunctions::Fast" if $@;
}

use_ok ('Test::LocalFunctions::Fast');
diag( "Testing Test::LocalFunctions $Test::LocalFunctions::VERSION" );

done_testing;
