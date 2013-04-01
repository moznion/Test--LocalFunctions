package Test::LocalFunctions;

use strict;
use warnings;
use ExtUtils::Manifest qw/maniread/;
use Sub::Identify qw/stash_name/;
use PPI::Document;
use PPI::Dumper;

our $VERSION = '0.01';
our @EXPORT  = qw/all_local_functions_ok local_functions_ok/;

use parent qw/Test::Builder::Module/;

use constant _VERBOSE => ( $ENV{TEST_VERBOSE} || 0 );

sub all_local_functions_ok {
    my (%args) = @_;

    my $builder = __PACKAGE__->builder;
    my @libs    = _fetch_modules_from_manifest($builder);

    $builder->plan( tests => scalar @libs );

    my $fail = 0;
    foreach my $lib (@libs) {
        _local_functions_ok( $builder, $lib, \%args ) or $fail++;
    }

    return $fail == 0;
}

sub local_functions_ok {
    my ( $lib, %args ) = @_;
    return _local_functions_ok( __PACKAGE__->builder, $lib, \%args );
}

sub _local_functions_ok {
    my ( $builder, $file, $args ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $pid = fork();
    if ( defined $pid ) {
        if ( $pid != 0 ) {
            wait;
            return $builder->ok( $? == 0, $file );
        }
        else {
            exit _check_local_functions( $builder, $file, $args );
        }
    }
    else {
        die "failed forking: $!";
    }
}

sub _check_local_functions {
    my ( $builder, $file ) = @_;    # append $args later?

    my $fail = 0;

    my $module          = _get_module_name($file);
    my @local_functions = _fetch_local_functions($module);
    my $ppi_document    = _fetch_PPI_document($file);
    foreach my $local_function (@local_functions) {
        unless ( $ppi_document =~ /$local_function\'/ ) {
            $builder->diag( "Test::LocalFunctions failed: "
                  . "'$local_function' is not used." );
            $fail++;
        }
    }

    return $fail;
}

sub _fetch_PPI_document {
    my $file = shift;

    my $document = PPI::Document->new($file);
    $document = _prune_from_PPI_document($document);

    my $dumper = PPI::Dumper->new($document);
    $document = _remove_declarations_sub($dumper->string());

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

sub _prune_from_PPI_document {
    my $document = shift;

    my @surpluses_token = (
        'Operator', 'Number', 'Comment', 'Pod',
        'BOM',      'Data',   'End',     'Prototype',
        'Separator', 'Quote',
    );

    # for token
    foreach my $surplus (@surpluses_token) {
        $document->prune('PPI::Token::' . $surplus);
    }

    return $document;
}

sub _fetch_modules_from_manifest {
    my $builder = shift;

    if ( not -f $ExtUtils::Manifest::MANIFEST ) {
        $builder->plan(
            skip_all => "$ExtUtils::Manifest::MANIFEST doesn't exist" );
    }
    my $manifest = maniread();
    my @libs = grep { m!\Alib/.*\.pm\Z! } keys %{$manifest};
    return @libs;
}

sub _fetch_local_functions {
    my $module = shift;

    my @local_functions;

    no strict 'refs';

    while ( my ( $key, $value ) = each %{"${module}::"} ) {
        next unless $key =~ /^_/;
        next unless *{"${module}::${key}"}{CODE};
        next if $module ne stash_name($module->can($key));
        push @local_functions, $key;
    }

    return @local_functions;
}

sub _get_module_name {
    my $file = shift;

    my $package = $file;
    if ( $file =~ /\./ ) {
        $package =~ s!\A.*\blib/!!;
        $package =~ s!\.pm\Z!!;
        $package =~ s!/!::!g;
    }
    else {
        $file .= '.pm';
        $file =~ s!/!::!g;
    }

    return $file, $package;
}
1;
__END__

=encoding utf8

=head1 NAME

Test::LocalFunctions - Detects unused local functions


=head1 VERSION

This document describes Test::LocalFunctions version 0.01


=head1 SYNOPSIS

    use Test::LocalFunctions;

    all_local_functions_ok(); # check modules that are listed in MANIFEST


=head1 DESCRIPTION

Test::LocalFunctions finds unused local functions to clean up the source code.
(Local function means the function which name starts from underscore.)


=head1 METHODS

=over

=item C<< all_local_functions_ok >>

This is a test function which finds unused variables from modules that are listed in MANIFEST file.

=item C<< local_functions_ok >>

This is a test function which finds unused variables from specified source code.
This function requires an argument which is the path to source file.

=back


=head1 CONFIGURATION AND ENVIRONMENT

Test::LocalFunctions requires no configuration files or environment variables.


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


=head1 AUTHOR

moznion  C<< <moznion@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, moznion C<< <moznion@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
