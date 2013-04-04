requires 'parent',                0;
requires 'PPI',                   '1.215';
requires 'Sub::Identify',         '0.04';
requires 'Test::Builder::Module', '0.98';

on 'configure' => sub {
    requires 'Module::Build',            '0.40';
    requires 'Module::Build::Pluggable', '0.09';
};

on 'build' => sub {
    requires 'Test::More',            '0.98';
    requires 'Test::Builder::Tester', '1.22';
};
