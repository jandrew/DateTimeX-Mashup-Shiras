package DateTimeX::Mashup::Shiras::Types;
use version 0.94; our $VERSION = qv("v0.22.4");

use 5.010;
use DateTime;
use DateTime::Format::Epoch 0.013;
use DateTime::Format::Excel;
use DateTime::Format::Flexible;
use MooseX::Types -declare => [ qw(
        weekday
        datetimedate
    ) ];
        
        #~ MyDateTime
use MooseX::Types::Moose qw(
        Object
        HashRef
        ArrayRef
        Str
        Num
        Int
    );

#########1 Dispatch Tables and Module Variables   5#########6#########7#########8#########9

### Module variables here
my  $epochdt = DateTime->new( 
        year => 1970, 
        month => 1, 
        day => 1 
    );
my  $epochformtr = DateTime::Format::Epoch->new(
        epoch               => $epochdt,
        unit                => 'seconds',
        type                => 'int',
        skip_leap_seconds   => 1,
        start_at            => 0,
        local_epoch         => undef,
    );
my  $weekdays = {
        'Monday'        => 1,
        'Tuesday'       => 2,
        'Wednessday'    => 3,
        'Thursday'      => 4,
        'Friday'        => 5,
        'Saturday'      => 6,
        'Sunday'        => 7,
    };
my	$local_time_zone = DateTime::TimeZone->new( name => 'local' );

#########1 Subtypes           3#########4#########5#########6#########7#########8#########9

subtype weekday, as Int,
    where{ $_ >= 1 and $_ <= 7 },
    message{ 
        ( $_ ) ? 
            "-$_- cannot be coerced to a weekday" : 
            'No value passed to the weekday type test' 
    };

coerce weekday, from Str,
    via{
        for my $day ( keys %$weekdays ) {
            if ( $day =~ /^$_/i ) {
                return $weekdays->{$day};
            }
        }
    };

subtype datetimedate, as Object,
	where{ $_->isa( 'DateTime' ) },
    message{ $_ };

coerce datetimedate, from Num|ArrayRef|Str,
    via {
        my ( $arg, $type ) = ( ref $_ eq 'ARRAY' ) ? ( @$_ ) : ( $_, undef ) ;#Provides a way to force epoch vs excel
		$type //=
			( $arg =~ /^(\d{7,11}|60|0|-\d+)$/  )		? 'epoch'	:#choose epoch style
			( $arg =~ /^(\d{0,6}(.\d*)?|\d{7,}.\d+)$/ )	? 'excel'	:#choose excel style
			( $arg =~ /^-\d*.\d+$/ )					? 'bad_num' :#Negative decimals not allowed
			'string' ;#default to Date::Manip
		if( $type eq 'bad_num' ){
			return "Could not use the number -|$arg|- as an Excel date or a Nix date";
		}
			
        my ( $dt, $return );
		$return =
			( $type eq 'epoch' ) ?
				( ( eval{ $dt = $epochformtr->parse_datetime( $arg ) } ) ?
					$dt : "Attempting to treat -$arg- as a Nix epoch failed in the DateTime conversion" ) :
			( $type eq 'excel' ) ? 
				( ( eval{ $dt = DateTime::Format::Excel->parse_datetime( $arg ) } ) ?
					$dt : "Attempting to treat -$arg- as an Excel serialized date failed in the DateTime conversion\n" ) :
				undef;
		if( !$return ){
			#~ my 	$dm = ParseDate( $arg );
				$dt = DateTime::Format::Flexible->parse_datetime( $arg, time_zone => $local_time_zone, );
				#~ $dt->set_time_zone( DateTime::TimeZone->new( name => 'America/Chicago' ) );
			$return = ( $dt ) ? $dt :
				"Failed to build a date time from DateTime::Format::DateManip (or any other method) for string -$arg-\n";
		}
		return $return;
    };

coerce datetimedate, from HashRef,
    via{ 
        my $dt;
        my %input = %$_;
        return(
            ( eval{ $dt = DateTime->new(%input) } ) ?
                $dt : "Failed to create a DateTime object from the HashRef\n" . Dump( $_ )
        );
    };

#########1 Phinish            3#########4#########5#########6#########7#########8#########9

1;

#########1 main pod docs      3#########4#########5#########6#########7#########8#########9
__END__

=head1 NAME

DateTimeX::Mashup::Shiras::Types - Types for DateTimeX::Mashup::Shiras

=head1 SYNOPSIS
    
    #!perl
    package MyPackage;

    use Moose;
    use DateTimeX::Mashup::Shiras::Types qw(
        weekday
    );
    
    has 'attribute_1' => (
            is  => 'ro',
            isa => weekday,
        );

=head1 DESCRIPTION

L<Shiras|http://en.wikipedia.org/wiki/Moose#Subspecies> - A small subspecies of 
Moose found in the western United States (of America).

This is the custom type class that ships with the L<DateTimeX::Mashup::Shiras
|https://metacpan.org/module/DateTimeX::Mashup::Shiras> package.  Wherever 
possible coersion failures are passed back to the type so type errors will be 
explained.

There are only subtypes in this package!  B<WARNING> These types should be 
considered in a beta state.  Future type fixing will be done with a set of tests in 
the test suit of this package.  (currently none are implemented)

See L<MooseX::Types|https://metacpan.org/module/MooseX::Types> for general re-use 
of this module.

=head1 Types

=head2 weekday

=over

B<Definition: >integers ( 1 .. 7 )

B<Coercions: >from a string.  The type will try to qr//i match the passed string 
to an english name of the week.

=back

=head2 datetimedate

=over

B<Definition: >a DateTime instance

B<Coercions: >

=over

B<from a number> This will check the number for 0, 60 (microsoft issues), 
negative integers, and positive integers with more than 7 digits and read them 
as epoch (Nixy) dates with the start at January 1st, 1970 using.  
L<DateTime::Format::Epoch|https://metacpan.org/module/DateTime::Format::Epoch>
It will turn any positive integer or decimial with less than 7 leading digits 
into an excel date using L<DateTime::Format::Excel
|https://metacpan.org/module/DateTime::Format::Excel>.  All positive decimals 
with 7 or more digits will also be treated as excel dates.  Negative decimals 
will fail.

B<from a string> This will use 
L<DateTime::Format::Flexible|https://metacpan.org/module/DateTime::Format::Flexible> 
to try and coerce the string into a DateTime object.

B<from an array ref> This will use the second element of the array ref to try 
to match 'epoch', 'excel', or 'string'.  If that match works the first element 
is evaluated as described above otherwise it is evaluated as a string.

=back

=back

=head1 GLOBAL VARIABLES

=over

B<$ENV{Smart_Comments}>

The module uses L<Smart::Comments|https://metacpan.org/module/Smart::Comments> if the '-ENV' 
option is set.  The 'use' is encapsulated in an if block triggered by an environmental 
variable to comfort non-believers.  Setting the variable $ENV{Smart_Comments} in a BEGIN 
block will load and turn on smart comment reporting.  There are three levels of 'Smartness' 
available in this module '###',  '####', and '#####'.

=back

=head1 SUPPORT

L<github DateTimeX-Mashup-Shiras/issues|https://github.com/jandrew/DateTimeX-Mashup-Shiras/issues>

=head1 TODO

=over

B<1.> Support Timezone input and changes

B<2.> Support custom epoch input and changes

B<3.> Add L<Log::Shiras|https://github.com/jandrew/Log-Shiras> debugging in exchange for
L<Smart::Comments|https://metacpan.org/module/Smart::Comments>

=over

* Get Log::Shiras CPAN ready first!

=back

=back

=head1 AUTHOR

=over

Jed

jandrew@cpan.org

=back

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

This software is copyrighted (c) 2013 by Jed Lund.

=head1 DEPENDANCIES

=over

L<version|https://metacpan.org/module/version>

L<MooseX::Types|https://metacpan.org/module/MooseX::Types>

L<MooseX::Types::Moose|https://metacpan.org/module/MooseX::Types::Moose>

L<DateTime|https://metacpan.org/module/DateTime>

L<DateTime::Format::Epoch|https://metacpan.org/module/DateTime::Format::Epoch>

L<DateTime::Format::Excel|https://metacpan.org/module/DateTime::Format::Excel>

L<DateTime::Format::Flexible|https://metacpan.org/module/DateTime::Format::Flexible>

=back

=head1 SEE ALSO

=over

L<Time::Piece|https://metacpan.org/module/Time::Piece>

L<MooseX::Types::Perl|https://metacpan.org/module/MooseX::Types::Perl>

L<Date::Parse|https://metacpan.org/module/Date::Parse>

L<Date::Manip::Date|https://metacpan.org/module/Date::Manip::Date>

L<DateTimeX::Format|https://metacpan.org/module/DateTimeX::Format>

=back

=cut

#########1 Main POD ends      3#########4#########5#########6#########7#########8#########9