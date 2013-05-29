package Test::LocalFunctions::PPI;

use strict;
use warnings;
use Test::LocalFunctions::Util;
use PPI::Document;
use PPI::Dumper;

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
    my ( undef, $builder, $file ) = @_;    # append $args later?

    my $fail = 0;

    my $module = Test::LocalFunctions::Util::extract_module_name($file);
    my @local_functions =
      Test::LocalFunctions::Util::list_local_functions($module);
    my $ppi_document = _generate_PPI_document($file);
    foreach my $local_function (@local_functions) {
        unless ( $ppi_document =~ /$local_function\'/ ) {
            $builder->diag( "Test::LocalFunctions failed: "
                  . "'$local_function' is not used." );
            $fail++;
        }
    }

    return $fail;
}

sub _generate_PPI_document {
    my $file = shift;

    my $document = PPI::Document->new($file);
    $document = _prune_PPI_tokens($document);

    my $dumper = PPI::Dumper->new($document);
    $document = _remove_declarations_sub( $dumper->string() );

    return $document;
}

sub _remove_declarations_sub {
    my $document = shift;

    $document =~ s/
        PPI::Statement::Sub \n
            \s*? PPI::Token::Word \s* \'sub\' \n
            \s*? PPI::Token::Whitespace .*? \n
            \s*? PPI::Token::Word .*? \n
    //gxm;

    return $document;
}

sub _prune_PPI_tokens {
    my $document = shift;

    my @surplus_tokens = (
        'Operator',  'Number', 'Comment', 'Pod',
        'BOM',       'Data',   'End',     'Prototype',
        'Separator', 'Quote',
    );

    foreach my $surplus_token (@surplus_tokens) {
        $document->prune( 'PPI::Token::' . $surplus_token );
    }

    return $document;
}
1;
__END__

=encoding utf8

=head1 NAME

Test::LocalFunctions::PPI - Detects unused local functions


=head1 SYNOPSIS

    use Test::LocalFunctions::PPI;

    all_local_functions_ok(); # check modules that are listed in MANIFEST


=head1 DESCRIPTION

Test::LocalFunctions::PPI finds unused local functions to clean up the source code.
(Local function means the function which name starts from underscore.)


=head1 METHODS

=over

=item C<< all_local_functions_ok >>

This is a test function which finds unused variables from modules that are listed in MANIFEST file.

=item C<< local_functions_ok >>

This is a test function which finds unused variables from specified source code.
This function requires an argument which is the path to source file.

=back


=head1 DEPENDENCIES

PPI (version 1.215 or later)

Sub::Identify (version 0.04 or later)

Test::Builder::Module (version 0.98 or later)

Test::Builder::Tester (version 1.22 or later)


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-test-localfunctions@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.
