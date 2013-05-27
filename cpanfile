requires 'perl',                  '5.008006';
requires 'PPI',                   '1.215';
requires 'Test::Builder::Module', '0.98';
requires 'Sub::Identify',         0;
requires 'parent';
recommends 'Compiler::Lexer';

on 'test' => sub {
    requires 'Test::Builder::Tester', '1.22';
    requires 'Test::More',            '0.98';
};

on 'configure' => sub {
    requires 'Module::Build';
};
