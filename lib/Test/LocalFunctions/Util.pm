package Test::LocalFunctions::Util;

use strict;
use warnings;
use ExtUtils::Manifest qw/maniread/;
use Sub::Identify qw/stash_name/;
use Module::Load;

sub all_local_functions_ok {
    my ( $caller, %args ) = @_;

    my $builder = $caller->builder;
    my @libs = _list_modules_in_manifest($builder);

    $builder->plan( tests => scalar @libs );

    my $fail = 0;
    for my $lib (@libs) {
        test_local_functions( $caller, $builder, $lib, \%args ) or $fail++;
    }

    return $fail == 0;
}

sub test_local_functions {
    my ( $caller, $builder, $file, $args ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $pid = fork();
    if ( defined $pid ) {
        if ( $pid != 0 ) {
            wait;
            return $builder->ok( $? == 0, $file );
        }
        else {
            exit $caller->is_in_use( $builder, $file, $args );
        }
    }
    else {
        die "failed forking: $!";
    }
}

sub list_local_functions {
    my $module = shift;

    my @local_functions;

    no strict 'refs';
    load $module;
    while ( my ( $key, $value ) = each %{"${module}::"} ) {
        next unless $key =~ /^_/;
        next unless *{"${module}::${key}"}{CODE};
        next unless $module eq stash_name( $module->can($key) );
        push @local_functions, $key;
    }
    use strict 'refs';

    return @local_functions;
}

sub extract_module_name {
    my $file = shift;

    # e.g.
    #   If file name is `lib/Foo/Bar.pm` then module name will be `Foo::Bar`
    if ( $file =~ /\.pm/ ) {
        my $module = $file;
        $module =~ s!\A.*\blib/!!;
        $module =~ s!\.pm\Z!!;
        $module =~ s!/!::!g;
        return $module;
    }

    return $file;
}

sub _list_modules_in_manifest {
    my $builder = shift;

    if ( not -f $ExtUtils::Manifest::MANIFEST ) {
        $builder->plan(
            skip_all => "$ExtUtils::Manifest::MANIFEST doesn't exist" );
    }
    my $manifest = maniread();
    my @libs = grep { m!\Alib/.*\.pm\Z! } keys %{$manifest};
    return @libs;
}
1;
