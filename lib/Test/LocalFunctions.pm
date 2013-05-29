package Test::LocalFunctions;

use strict;
use warnings;
use Module::Load;
use parent qw/Exporter/;

our $VERSION = '0.04';
our @EXPORT  = qw/all_local_functions_ok local_functions_ok/;

my $backend_module = _select_backend_module();
load $backend_module;
$backend_module->import;

sub _select_backend_module {
    eval { require Compiler::Lexer };
    return 'Test::LocalFunctions::PPI' if ( $ENV{T_LF_PPI} || $@ );
    return 'Test::LocalFunctions::Fast';
}

1;
__END__

=encoding utf8

=head1 NAME

Test::LocalFunctions - Detects unused local functions


=head1 VERSION

This document describes Test::LocalFunctions version 0.04


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

papix


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
