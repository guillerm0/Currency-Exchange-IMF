#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Currency::Exchange::IMF;

plan tests => 2;
my $imf = Currency::Exchange::IMF->new('targetCurrencies' => ,['USD', 'EUR'], 'fromDate' => '2020-01-10', 'toDate' => '2020-01-10');
my $testUrl = "https://www.imf.org/external/np/fin/ert/GUI/Pages/Report.aspx?CU='USD','EUR'&EX=CSDR&P=DateRange&Fr=637142112000000000&To=637142112000000000&CF=UnCompressed&CUF=Period&DS=Ascending&DT=NA";

BEGIN {
    use_ok( 'Currency::Exchange::IMF' ) || print "Bail out!\n";
}

diag( "Testing Currency::Exchange::IMF $Currency::Exchange::IMF::VERSION, Perl $], $^X" );
#URL generated properly
ok($imf->buildUrl eq $testUrl, "Url Generation Test")


