use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;


my %WriteMakefileArgs = (
    NAME             => 'Currency::Exchange::IMF',
    AUTHOR           => q{Guillermo Martinez <guillermo.marcial@gmail.com>},
    VERSION_FROM     => 'lib/Currency/Exchange/IMF.pm',
    ABSTRACT_FROM    => 'lib/Currency/Exchange/IMF.pm',
    LICENSE          => 'artistic_2',
    MIN_PERL_VERSION => '5.006',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    TEST_REQUIRES => {
        'Test::More' => '0',
    },
    PREREQ_PM => {
        'Modern::Perl' => '0',
        'Moose' => '0',
        'DateTime::Format::DateParse' => '0',
        'WWW::Mechanize' => '0',
        'File::Util::Tempdir' => '0',
        'File::Util' => '0',
        'String::Random' => '0',
        'XML::LibXML::Simple' => '0',
        'Try::Tiny' => '0'
    },
    EXE_FILES => [ qw(script/currency-exchange-imf) ],
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Currency-Exchange-IMF-*' },
);

# Compatibility with old versions of ExtUtils::MakeMaker
unless (eval { ExtUtils::MakeMaker->VERSION('6.64'); 1 }) {
    my $test_requires = delete $WriteMakefileArgs{TEST_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$test_requires} = values %$test_requires;
}

unless (eval { ExtUtils::MakeMaker->VERSION('6.55_03'); 1 }) {
    my $build_requires = delete $WriteMakefileArgs{BUILD_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$build_requires} = values %$build_requires;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION('6.52'); 1 };
delete $WriteMakefileArgs{MIN_PERL_VERSION}
    unless eval { ExtUtils::MakeMaker->VERSION('6.48'); 1 };
delete $WriteMakefileArgs{LICENSE}
    unless eval { ExtUtils::MakeMaker->VERSION('6.31'); 1 };

WriteMakefile(%WriteMakefileArgs);
