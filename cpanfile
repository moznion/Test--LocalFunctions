on 'configure' => sub {
    requires 'Module::Build' => '0.40';
    requires 'Module::Build::Pluggable' => '0.09';
};

on 'build' => sub {
    requires 'Test::More' => '0.98';
};
