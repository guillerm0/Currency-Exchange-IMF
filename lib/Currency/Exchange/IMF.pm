package Currency::Exchange::IMF;

use 5.006;
use strict;
use warnings;
use Modern::Perl '2020';
use Moose;
use DateTime::Format::DateParse;
use WWW::Mechanize;
use File::Util::Tempdir qw(get_tempdir get_user_tempdir);
use File::Util;
use String::Random;
use XML::LibXML::Simple   qw(XMLin);

=head1 NAME

Currency::Exchange::IMF - Module to extract SDR exchange rates from IMF website.
The fetch process is slow, the module is intended to be used as an extraction tool to store the rates into a database
and nothing more.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '1.00';

##  Attributes ##
has 'targetCurrencies' => (
    'is' => 'rw',
    'isa'     => 'ArrayRef',
    'default' => sub { ['USD'] });
has 'sourceCurrency' => ('is' => 'rw', default => 'SDR');
has 'fromDate'  => ('is' => 'rw');
has 'toDate'  => ('is' => 'rw');
has 'url' => ('is' => 'rw', default => 'https://www.imf.org/external/np/fin/ert/GUI/Pages/');

my $tmpDir = get_tempdir();
my $randomString = String::Random->new;
=head1 SYNOPSIS

The module uses IMF Exchange Query Tool to fetch SDR exchange rates.

How to use:

    my $imf = Currency::Exchange::IMF->new('targetCurrencies' => ['USD', 'EUR'], 'sourceCurrency' => 'SDR', 'fromDate' => '2020-02-03', 'toDate' => '2020-02-03');
    my %rates = $imf->getRates;
    ...

This would return somthing like this:
    {
        03-Feb-2020   {
            EUR   1.24446,
            USD   1.37711
        }
    }

=head1 EXPORT

A list of functions that can be exported.

=head1 SUBROUTINES/METHODS

=head2 getRates

    Used to fetch rates

=cut
sub getRates{
    my $self = shift;

    my $tmpFile = $tmpDir.File::Util->SL.$randomString->randpattern("cccccccccccccccccccc").'.xml';
    my $browser = WWW::Mechanize->new();

    $browser->get($self->buildUrl);
    $browser->follow_link(url=>'ReportData.aspx?Type=XML');
    $browser->save_content($tmpFile);

    my $parser = XML::LibXML->new();
    my $data = XMLin($tmpFile);
    unlink($tmpFile); #Remove temporal file
    return generateHash($data);
}

sub generateHash {
    my ($data) = @_;
    my %structure;

    #Generate Body
    if(ref($data->{'EFFECTIVE_DATE'}) eq 'ARRAY'){
        foreach my $efectiveRate (@{$data->{'EFFECTIVE_DATE'}}){
            $structure{$efectiveRate->{'VALUE'}}={};
            if(ref($efectiveRate->{'RATE_VALUE'}) eq 'ARRAY') {
                foreach (@{$efectiveRate->{'RATE_VALUE'}}) {
                    $structure{$efectiveRate->{'VALUE'}}{$_->{'ISO_CHAR_CODE'}} = $_->{'content'};
                }
            }else{
                $structure{$efectiveRate->{'VALUE'}}{$efectiveRate->{'RATE_VALUE'}->{'ISO_CHAR_CODE'}} = $efectiveRate->{'RATE_VALUE'}->{'content'};
            }
        }
    }else{
        $structure{$data->{'EFFECTIVE_DATE'}->{'VALUE'}}={};
        if(ref($data->{'EFFECTIVE_DATE'}->{'RATE_VALUE'}) eq 'ARRAY'){
            foreach(@{$data->{'EFFECTIVE_DATE'}->{'RATE_VALUE'}}){
                $structure{$data->{'EFFECTIVE_DATE'}->{'VALUE'}}{$_->{'ISO_CHAR_CODE'}}=$_->{'content'};
            }
        }else{
            $structure{$data->{'EFFECTIVE_DATE'}->{'VALUE'}}{$data->{'EFFECTIVE_DATE'}->{'RATE_VALUE'}->{'ISO_CHAR_CODE'}}=$data->{'EFFECTIVE_DATE'}->{'RATE_VALUE'}->{'content'};
        }
    }

    return \%structure;
}

sub buildUrl{
    my $self = shift;
    return $self->url.'Report.aspx?'.$self->getQueryParams();
}

sub getQueryParams{
    my $self = shift;
    my $from = undef;
    my $to = undef;

    #Set time to IMF Format
    $from = DateTime::Format::DateParse->parse_datetime($self->fromDate, 'UTC');
    $to = DateTime::Format::DateParse->parse_datetime($self->toDate, 'UTC');

    my $yearOne = DateTime->new(
        year       => 1,
        month      => 1,
        day        => 1,
        hour       => 0,
        minute     => 0,
        second     => 0,
        nanosecond => 0,
        time_zone  => 'UTC',
    );
    my $fromSecondsSinceYearOne = $yearOne->delta_days($from)->delta_days() * 86400;
    my $toSecondsSinceYearOne = $yearOne->delta_days($to)->delta_days() * 86400;
    my $target = 'CU='.$self->serealizeCurrency;
    my $source = 'EX=C'.$self->sourceCurrency;
    my $dateRange = 'Fr='.$fromSecondsSinceYearOne.'0000000&To='.$toSecondsSinceYearOne.'0000000';
    return $target.'&'.$source.'&'.'P=DateRange&'.$dateRange.'&CF=UnCompressed&CUF=Period&DS=Ascending&DT=NA'
}

sub serealizeCurrency{
    my $self = shift;

    my $targetCurrecy = $self->targetCurrencies;
    foreach(@$targetCurrecy){ $_ = "'$_'";} #Quote all strings
    return join(',', @$targetCurrecy);
}

=head1 AUTHOR

Guillermo Martinez, C<< <guillermo.marcial at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-currency-exchange-imf at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Currency-Exchange-IMF>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Currency::Exchange::IMF


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Currency-Exchange-IMF>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Currency-Exchange-IMF>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Currency-Exchange-IMF>

=item * Search CPAN

L<https://metacpan.org/release/Currency-Exchange-IMF>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2020 by Guillermo Martinez.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of Currency::Exchange::IMF
