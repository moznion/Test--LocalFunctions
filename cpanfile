requires 'perl',                  '5.008006';
requires 'PPI',                   '1.215';
requires 'Test::Builder::Module', '0.98';
requires 'Sub::Identify',         0;
requires 'Module::Load',          0;
requires 'Exporter',              0;
requires 'parent',                0;
requires 'Carp',                  0;
requires 'ExtUtils::Manifest',    0;
recommends 'Compiler::Lexer',     '0.12';

on 'test' => sub {
    requires 'Test::Builder::Tester', '1.22';
    requires 'Test::More',            '0.98';
    requires 'FindBin',               0;
};

on 'configure' => sub {
    requires 'Module::Build', 0;
};
