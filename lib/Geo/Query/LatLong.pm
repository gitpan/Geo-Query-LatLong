package Geo::Query::LatLong;

############################################################
# Geo::Query::LatLong
# Author: Reto Schaer
# Copyright (c) 2007
#
our $VERSION = '0.8005';
############################################################

use strict;

use LWP::UserAgent;
use HTTP::Request::Common;

# GLOBAL VARIABLES
my $package = __PACKAGE__;
my %Var = ();
my $contentType = "";
my $ua;
$| = 1;

#-----  FORWARD DECLARATIONS & PROTOTYPING
sub Debug($);

sub new {
	my $type = shift;
	my %params = @_;
	my $self = {};
	$self->{'debug'} = $params{'debug'};
	Debug "$package V$VERSION" if $self->{'debug'};
	$ua = LWP::UserAgent->new( agent => "Geo::Query::LatLong $VERSION" );
	bless $self, $type;
}

sub query {
	my $self = shift;
	my %args = @_;

	my %res_hash = ();
	   $res_hash{'rc'} = 0;

	$args{'country_code'} ||= 'SZ';
	$args{'city'        } ||= 'Zurich';
	$args{'exact'       } ||= 'on';

	if ($self->{'debug'}) { Debug "$_ = $args{$_}" foreach keys %args; }

	my $url = 'http://geo.pg' . 'ate.net/query/';

	my $r = HTTP::Request->new('GET', $url .
		"?city=$args{'city'}&country_code=$args{'country_code'}&exact=$args{'exact'}");
	my $resp = $ua->request($r);

	if ($resp->is_success) {
		my @lines = split /\n/, $resp->content();
		my $result = '';
		foreach (@lines) {
			my ($key, $val) = split /\t/;
			$res_hash{$key} = $val;
		}
	}

	\%res_hash;
}

sub Debug ($)  { print "[ $package ] $_[0]\n"; }

####  Used Warning / Error Codes  ##########################
#	Next free W Code: 1000
#	Next free E Code: 1000

1;

__END__

=head1 NAME

Geo::Query::LatLong - Perl module to query latitude and longitude from a city.

=head1 SYNOPSIS

  use Geo::Query::LatLong;

  $geo = Geo::Query::LatLong->new( debug => 0 );

=head1 DESCRIPTION

Query latitude and longitude from any city in any country.

=head2 Query example

  use Geo::Query::LatLong;

  $CITY = $ARGV[0] || 'Zurich';

  $res = $geo->query( city => $CITY, country_code => 'SZ' ); # FIPS 10 country code

  print "Latitude and longitude of $CITY: ",
		$res->{'lat'}, ' / ', $res->{'lng'}, "\n";

=head3 List all results

  foreach (keys %{$res}) {
	print "$_ = ", $res->{$_}, "\n";
  }

=head2 Another example

Switch exactness to "off" will increase the chance you get a result.

  $res = $geo->query( city => 'Unterwalden', country_code => 'SZ', exact => 'off' ); # exact default: on

  print "-- $_ = ", $res->{$_}, "\n" foreach keys %{$res};

=head3 Parameter country_code

  Country Codes according to FIPS 10: http://de.wikipedia.org/wiki/FIPS_10

=head3 Parameter city

  Use the english translations for the city names, e.g. Zurich for Zuerich, Munich for Muenchen.

=head2 Return values

The function query(...) always returns a hash reference. Hash key 'rc' is retured as 0 (Zero) on success and unequal 0 on a failure.
Additionally it is a good advice to read or display the 'msg' key on a failure to get a hint about the cause.

B<On case the city was not found:>

=item *

Hash key 'rc' returns a number unequal to zero.

=item *

Hash keys 'lat' / 'lng' are being returned as '99' / '99'.

=head2 EXPORT

None by default.

=head1 Further documentation and feedback

http://meta.pgate.net/perl-modules/

http://www.infocopter.com/perl/modules/

=head1 SEE ALSO

The Geo::Coder::* series.

=head1 AUTHOR

Reto Schaer, E<lt>retoh@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Reto Schaer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

http://www.infocopter.com/perl/licencing.html

=cut
