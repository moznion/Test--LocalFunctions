package Test::LocalFunctions::Fast;
use strict;
use warnings;

use Carp;
use ExtUtils::Manifest qw/maniread/;
use Sub::Identify qw/stash_name/;
use Compiler::Lexer;

our @EXPORT  = qw/all_local_functions_ok local_functions_ok/;

use parent qw/Test::Builder::Module/;

use constant _VERBOSE => ($ENV{TEST_VERBOSE} || 0);

sub all_local_functions_ok {
    my (%args) = @_;

    my $builder = __PACKAGE__->builder;
    my @libs    = _fetch_modules_from_manifest($builder);
    warn "_fetch_modules_from_manifest: @libs\n";

    $builder->plan(tests => scalar @libs);

    my $fail = 0;
    for my $lib (@libs) {
        _local_functions_ok($builder, $lib, \%args) or $fail++;
    }

    return $fail == 0;
}

sub local_functions_ok {
    my ($lib, %args) = @_;
    return _local_functions_ok(__PACKAGE__->builder, $lib, \%args);
}

sub _local_functions_ok {
    my ($builder, $file, $args) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $pid = fork();
    if (defined $pid) {
        if ($pid != 0) {
            wait;
            return $builder->ok($? == 0, $file);
        } else {
            exit _check_local_functions($builder, $file, $args);
        }
    } else {
        die "failed forking: $!";
    }
}

sub _check_local_functions {
    my ($builder, $file) = @_;

    my $fail = 0;

    my $module = _get_module_name($file);
    my @local_functions = _fetch_local_functions($module);
    my @tokens = _fetch_tokens($file);

    LOCAL_FUNCTION: for my $local_function (@local_functions) {
        for my $token (@tokens) {
            if ($token->{data} eq $local_function) {
                last LOCAL_FUNCTION;
            }
        }
        $builder->diag("Test::LocalFunctions failed: '$local_function' is not used.");
        $fail++;
    }

    return $fail;
}

sub _fetch_tokens {
    my $file = shift;

    open(my $fh, '<', $file) or die("Error");
    my $code = do { local $/; <$fh> };
    my $lexer = Compiler::Lexer->new($file);
    my @tokens = grep { _remove_tokens($_) } map { @$$_ } ($lexer->tokenize($code));

    return @tokens;
}

sub _remove_tokens {
    my $token = shift;

    if ($token->{name} eq 'Key' || $token->{name} eq 'Call') {
        return 1;
    }
    return 0;
}

sub _fetch_modules_from_manifest {
    my $builder = shift;

    if (not -f $ExtUtils::Manifest::MANIFEST) {
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

    while (my ($key, $value) = each %{"${module}::"}) {
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
    if ($file =~ /\./) {
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
