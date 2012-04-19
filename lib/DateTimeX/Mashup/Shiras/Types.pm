#! C:/Perl/bin/perl
package DateTimeX::Mashup::Shiras::Types;

use version 0.94; our $VERSION = qv('0.015_001');
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

This is a set of custom types for the L<DateTimeX::Mashup::Shiras> Moose role.

There are only Moose usable types in this package!  Read the code to understand 
the type range.

=head1 SUPPORT

L<DateTimeX-Mashup-Shiras/issues|https://github.com/jandrew/DateTimeX-Mashup-Shiras/issues>

=head1 TODO

=over

=item Support Timezone input and changes

=item ??

=back

=head1 AUTHOR

=over

=item Jed

=item jandrew@cpan.org

=back

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 DEPENDANCIES

=over

=item L<version>

=item L<MooseX::Types::Moose>

=item L<MooseX::Types>

=item L<DateTime>

=item L<DateTime::Format::Epoch>

=item L<DateTime::Format::Excel>

=item L<DateTime::Format::DateManip>

=back

=head1 SEE ALSO

=over

=item L<Date::Parse>

=item L<Date::Manip::Date>

=item L<DateTimeX::Format>

=back

=cut

#################### main pod documentation end #####################