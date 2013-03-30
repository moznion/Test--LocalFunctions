use strict;
use warnings;
use Module::Build::Pluggable ( '+Module::Build::Pluggable::CPANfile', );

my $builder = Module::Build::Pluggable->new(
    name              => 'Test-LocalFunctions',
    module_name       => 'Test::LocalFunctions',
    license           => 'perl',
    dist_author       => 'moznion <moznion@gmail.com>',
    dist_version_from => 'lib/Test/LocalFunctions.pm',
    requires => {
        # TODO
        # perl => '',
    },
    add_to_cleanup => ['Test-LocalFunctions-*'],
    no_index       => { 'directory' => ['inc'] },
    meta_merge     => {
        'resource' => {
            'license' => 'http://dev.perl.org/licenses/',

            # 'repository' => '',
        },
    },
    test_files => ( -d '.git' || $ENV{RELEASE_TESTING} ) ? 't/ xt/' : 't/',
    recursive_test_files => 1,
    create_license       => 1,
    create_readme        => 1,
);

$builder->create_build_script();
