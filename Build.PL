use strict;
use warnings;
use Module::Build;

use 5.008;

my $builder = Module::Build->new(
    module_name         => 'Currency::Exchange::IMF',
    license             => 'perl',
    dist_author         => 'Guillermo Martinez <guillermo.marcial@gmail.com>',
    dist_abstract       => 'IMF SDR Exchange rate extraction',
    create_makefile_pl  => 1,     #'traditional',
    script_files        => 'script/currency-exchange-imf',
    create_readme       => 0,
    requires            => {
        'Modern::Perl'                => '0',
        'Moose'                       => '0',
        'DateTime::Format::DateParse' => '0',
        'WWW::Mechanize'              => '0',
        'File::Util::Tempdir'         => '0',
        'File::Util'                  => '0',
        'String::Random'              => '0',
        'XML::LibXML::Simple'         => '0',
        'Try::Tiny'                   => '0',
        'LWP::Protocol::https'        => '0'
    },
    build_requires      => {
        'Test::More'          => '0.47',
    },
);

$builder->create_build_script();
