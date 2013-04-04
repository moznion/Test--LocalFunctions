use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    name              => 'Test-LocalFunctions',
    module_name       => 'Test::LocalFunctions',
    license           => 'perl',
    dist_author       => 'moznion <moznion@gmail.com>',
    dist_version_from => 'lib/Test/LocalFunctions.pm',
    build_requires    => {
        'Test::More'            => '0.98',
        'Test::Builder::Tester' => '1.22',
    },
    configure_requires => { 'Module::Build' => '0.40' },
    requires           => {
        'parent'                => 0,
        'PPI'                   => '1.215',
        'Sub::Identify'         => '0.04',
        'Test::Builder::Module' => '0.98',
        perl                    => '5.010001',
    },
    add_to_cleanup => ['Test-LocalFunctions-*'],
    no_index       => { 'directory' => ['inc'] },
    meta_merge     => {
        'resource' => {
            'license'    => 'http://dev.perl.org/licenses/',
            'repository' => 'git://github.com/moznion/Test--LocalFunctions.git',
        },
    },
    test_files => ( -d '.git' || $ENV{RELEASE_TESTING} ) ? 't/ xt/' : 't/',
    recursive_test_files => 1,
    create_license       => 1,
    create_readme        => 1,
);

$builder->create_build_script();
