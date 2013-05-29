package Test::LocalFunctions::Fast;

use strict;
use warnings;
use Test::LocalFunctions::Util;
use Compiler::Lexer;

our @EXPORT = qw/all_local_functions_ok local_functions_ok/;

use parent qw/Test::Builder::Module/;

use constant _VERBOSE => ( $ENV{TEST_VERBOSE} || 0 );

sub all_local_functions_ok {
    my (%args) = @_;
    return Test::LocalFunctions::Util::all_local_functions_ok( __PACKAGE__,
        %args );
}

sub local_functions_ok {
    my ( $lib, %args ) = @_;
    return Test::LocalFunctions::Util::test_local_functions( __PACKAGE__,
        __PACKAGE__->builder, $lib, \%args );
}

sub is_in_use {
    my ( undef, $builder, $file ) = @_;

    my $fail = 0;

    my $module = Test::LocalFunctions::Util::extract_module_name($file);
    my @local_functions =
      Test::LocalFunctions::Util::list_local_functions($module);
    my @tokens = _fetch_tokens($file);

  LOCAL_FUNCTION: for my $local_function (@local_functions) {
        for my $token (@tokens) {
            if ( $token->{data} eq $local_function ) {
                last LOCAL_FUNCTION;
            }
        }
        $builder->diag(
            "Test::LocalFunctions failed: '$local_function' is not used.");
        $fail++;
    }

    return $fail;
}

sub _fetch_tokens {
    my $file = shift;

    open( my $fh, '<', $file ) or die("Error");
    my $code = do { local $/; <$fh> };
    my $lexer = Compiler::Lexer->new($file);
    my @tokens =
      grep { _remove_tokens($_) } map { @$$_ } ( $lexer->tokenize($code) );

    return @tokens;
}

sub _remove_tokens {
    my $token = shift;

    if ( $token->{name} eq 'Key' || $token->{name} eq 'Call' ) {
        return 1;
    }
    return 0;
}
1;
__END__

=encoding utf-8

=head1 NAME

Test::LocalFunctions::Fast - Detects unused local function faster

=head1 SYNOPSIS

    use Test::LocalFunctions::Fast;

    all_local_functions_ok(); # check modules that are listed in MANIFEST

=head1 DESCRIPTION

Test::LocalFunctions::Fast is finds unused local functions to clean up the source code. (Local function means the function which name starts from underscore.)
This module is faster than Test::LocalFunction because using Compiler::Lexer.

=head1 METHODS

=over

=item C<< all_local_functions_ok >>

This is a test function which finds unused variables from modules that are listed in MANIFEST file.

=item C<< local_functions_ok >>

This is a test function which finds unused variables from specified source code.
This function requires an argument which is the path to source file.

=back

=head1 SEE ALSO

L<Test::LocalFunctions>

=cut
