#!perl
package DateTimeX::Mashup::Shiras::Types;

use version 0.94; our $VERSION = qv('0.016.002');
use DateTime;
use DateTime::Format::Epoch 0.013;
use DateTime::Format::Excel;
use DateTime::Format::DateManip;
use MooseX::Types -declare => [ qw(
        weekday
        datetimedate
        
        MyDateTime
    ) ];
use MooseX::Types::Moose qw(
        Object
        HashRef
        ArrayRef
        Str
        Num
        Int
    );

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

###############  Subtypes  #############################################

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

subtype MyDateTime, as Object,
    where{ $_->isa( 'DateTime' ) },
    message{ $_ };

coerce MyDateTime, from HashRef,
    via{ 
        my $dt;
        my %input = %$_;
        return(
            ( eval{ $dt = DateTime->new(%input) } ) ?
                $dt : "Failed to create a DateTime object from the HashRef\n" . Dump( $_ )
        );
    };

subtype datetimedate, as MyDateTime,
    message{ $_ };

coerce datetimedate, from Num|ArrayRef,
    via {
        my ( $arg, $type ) = ( ref $_ eq 'ARRAY' ) ? ( @$_ ) : ( $_, undef ) ;#Provides a way to force epoch vs excel
        my  $dt;
        return
            (   ( $type and $type eq 'epoch' ) or #force epoch 1-Jan-1970 calculation
                ( $arg =~ /^(\d{7,11}|60|-\d*)$/ ) ) ?#Concedes 1-Jan-1970 to 12-Jan-1970 to excel
                ( ( eval{ $dt = $epochformtr->parse_datetime( $arg ) } ) ?
                    $dt : "Attempting to treat -$arg- as a Nix epoch failed in the DateTime conversion" ) :
                (   ( $type and $type eq 'excel' ) or  #force excel calculation
                    ( $arg =~ /^\d{0,6}(.\d*)?$/ )      ) ?#Concedes > 27-Nov-4637 to Unix (Excel doesn't recognize dates earlier than Jan 1 1900)
                    ( ( eval{ $dt = DateTime::Format::Excel->parse_datetime( $arg ) } ) ?
                        $dt : "Attempting to treat -$arg- as an Excel serialized date failed in the DateTime conversion\n" ) :
                    "Could not use the number -|$arg|- as an Excel date or a Nix date";
    };

coerce datetimedate, from Str,
    via {
        my $dt;
        my $input = $_;
        return(
            ( eval { $dt = DateTime::Format::DateManip->parse_datetime( $input ) } ) ?
                $dt : "Failed to build a date time from DateManip with string -$input-\n"
        );
    };

###############  Private Type methods  #################################



#################### Phinish with a Phlourish ##########################

1;
# The preceding line will help the module return a true value

#################### main pod documentation begin ###################

__END__

=head1 NAME

DateTimeX::Mashup::Shiras::Types - Types for DateTimeX::Mashup::Shiras

=head1 SYNOPSIS
    
    #! C:/Perl/bin/perl
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
possible errors to coersions are passed back to the type so coersion failure 
will be explained.

There are only subtypes in this package!  B<WARNING> These types should be 
considered in a beta state.  Future type fixing will be done with a set of tests in 
the test suit of this package.  (currently none are implemented)

See L<MooseX::Types|https://metacpan.org/module/MooseX::Types> for general re-use 
of this module.

=head1 Types

=head2 weekday

=over

B<Definition: >integers ( 1 .. 7 )

B<Coercions: >from a string.  The type will try to qr//i match the passed string to an 
english name of the week.

=back

=head2 datetimedate

=over

B<Definition: >a DateTime instance

B<Coercions: >

=over

B<from a number> This will check the number range and attempt to turn any positive number 
with less than 7 digits left of the decimal into a DateTime object using 
L<DateTime::Format::Excel|https://metacpan.org/module/DateTime::Format::Excel> 
it will attempt to turn any integer with more than 6 digits into a DateTime object using 
L<DateTime::Format::Epoch|https://metacpan.org/module/DateTime::Format::Epoch>

B<from an array ref> This will use the second element of the array ref to try and match to 
either 'epoch' or 'excel'.  If that match works the first element is sent to the 
number coercion already described but it forces excel or 1-Jan-1970 epoch coersion 
based on the match.  If the second element is undef or doesn't match then the number 
test is still performed on the first element.

B<from a string> This will use 
L<DateTime::Format::DateManip|https://metacpan.org/module/DateTime::Format::DateManip> 
to try and coerce the string into a DateTime object.

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

L<DateTimeX-Mashup-Shiras/issues|https://github.com/jandrew/DateTimeX-Mashup-Shiras/issues>

=head1 TODO

=over

B<1.> Support Timezone input and changes

B<2.> Support custom epoch input and changes

B<3.> Add L<Log::Shiras|https://metacpan.org/module/Log::Shiras> debugging in exchange for
L<Smart::Comments|https://metacpan.org/module/Smart::Comments>

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

=head1 DEPENDANCIES

=over

L<version|https://metacpan.org/module/version>

L<MooseX::Types|https://metacpan.org/module/MooseX::Types>

L<MooseX::Types::Moose|https://metacpan.org/module/MooseX::Types::Moose>

L<DateTime|https://metacpan.org/module/DateTime>

L<DateTime::Format::Epoch|https://metacpan.org/module/DateTime::Format::Epoch>

L<DateTime::Format::Excel|https://metacpan.org/module/DateTime::Format::Excel>

L<DateTime::Format::DateManip|https://metacpan.org/module/DateTime::Format::DateManip>

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

#################### main pod documentation end #####################