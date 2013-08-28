#!perl
package DateTimeX::Mashup::Shiras;

use Moose::Role;
use version; our $VERSION = qv('0.014.002');
if( $ENV{ Smart_Comments } ){
	use Smart::Comments -ENV;
	### <where> - Smart-Comments turned on for DateTimeX-Mashup-Shiras v0.014
}
use MooseX::Types::Moose qw(
        Bool
        Str
        ArrayRef
    );
use lib '../../../lib', '../../lib';
use DateTimeX::Mashup::Shiras::Types 0.016 qw(
        weekday
        datetimedate
    );
my  @datearray = qw(
        date_one
        date_two
        date_three
    );

##############  Public Attributes  #####################################

has 'week_end' =>(
        is      => 'ro',
        isa     => weekday,
        coerce  => 1,
        default => 'Fri',# Use Friday as the end of the week, (Saturday would start the next week)
        reader  => '_get_weekend',
);

# set up public attributes for the @datearray
for my $dateattribute ( @datearray ) {
    my $predicate   = 'has_' . $dateattribute;
    my $reader      = 'get_' . $dateattribute;
    my $writer      = 'set_' . $dateattribute;
    has $dateattribute =>( 
        is          => 'ro',
        isa         => datetimedate,
        coerce      => 1,
        predicate   => $predicate,
        reader      => $reader,
        writer      => $writer,
        trigger     => sub{ $_[3] = $dateattribute; _load_day( @_ ); },
    );
}

###############  Public Methods  #######################################

sub get_now{### for real time checking - get_today is when the module started
    my ( $self ) = @_;
    #### <where> - Reached get_now ...
    return to_datetimedate( 'now' );### beautiful MooseX::Types majic!
}

###############  Private Attributes  ###################################

# set up a private attribute with a public getter for 'today'
has '_today' => (
        is          => 'ro',
        isa         => datetimedate,
        required    => 1,
        lazy        => 1,
        coerce      => 1,
        default     => 'today',
        reader      => 'get_today',
        writer      => '_set_today',
    );

# set up private attributes for the @datearray weekbounds
for my $terminator ( '_wkstart', '_wkend' ) {
    for my $datename ( @datearray, 'today' ) {
        my  $attributename   = $datename . $terminator;
        my  $reader     = 'get_' . $attributename;
        my  $writer     = '_set_' . $attributename;
        has '_' . $attributename =>( #
                is => 'ro',
                isa         => datetimedate,
                reader      => $reader,
                writer      => $writer,
            );
    }
}

###############  Private Methods / Modifiers  ##########################

sub _load_day{
    my ( $self, $newvalue, $oldvalue, $basedate ) = @_;
    #### <where> - Reached _load_day with: $newvalue
    my  $weekday    = $newvalue->day_of_week;
    my ( $daysfromweekstart, $daystoweekend ) = $self->_find_weekend( $weekday );
    #### <where> - to weekend: $daystoweekend
    #### <where> - to weekstart: $daysfromweekstart
    my  $dtweekstart    = $newvalue->clone->subtract( days => $daysfromweekstart );
    my  $dtweekend      = $newvalue->clone->add( days => $daystoweekend );
    my  $wkstartsetter  = '_set_' . $basedate . '_wkstart';
    $self->$wkstartsetter( $dtweekstart );
    my  $wkendsetter    = '_set_' . $basedate . '_wkend';
    $self->$wkendsetter( $dtweekend );
    #### <where> - week start day: $dtweekstart
    #### <where> - week end day: $dtweekend
}

sub _find_weekend{
    my ( $self, $weekday ) = @_;
    my  $weekend    = $self->_get_weekend;
    #### <where> - Reached _find_weekend
    my  $daystoweekend =
            ( $weekday == $weekend ) ? 
                0 :
            ( $weekday > $weekend ) ?
                ( 7 - $weekday + $weekend ):
                ( $weekend - $weekday ) ;
    my  $weekstart =
            ( $weekend == 7 ) ?
                1 : $weekend + 1;
    my  $daysfromweekstart =
            ( $weekday == $weekstart ) ? 
                0 :
            ( $weekday < $weekstart ) ?
                ( 7 - $weekstart + $weekday ):
                ( $weekday - $weekstart ) ;
    #### <where> - to week ene: $daysfromweekstart
    #### <where> - to week start: $daystoweekend
    return ( $daysfromweekstart, $daystoweekend );
}

#################### Phinish with a Phlourish ##########################

no Moose::Role;

1;
# The preceding line will help the module return a true value

#################### main pod documentation begin ###################

__END__

=head1 NAME

DateTimeX::Mashup::Shiras - a mashup for consuming multiple date formats

=head1 SYNOPSIS
    
	package MyPackage;
	use Moose;
	with 'DateTimeX::Mashup::Shiras' => { -VERSION =>  0.014 };
	no Moose;
	__PACKAGE__->meta->make_immutable;

	#!perl
	my  $firstinst = MyPackage->new( 
			'date_one' => '8/26/00',
		);
	print $firstinst->get_date_one->format_cldr( "yyyy-MMMM-d" ) . "\n";
	print $firstinst->get_date_one_wkend->ymd( '' ) . "\n";
	print $firstinst->get_date_one_wkstart->ymd( '' ) . "\n";
	print $firstinst->set_date_three( '11-September-2001' ) . "\n";
	print $firstinst->get_date_three_wkstart->dmy( '' ) . "\n";
	print $firstinst->set_date_one( -1299767400 ) . "\n";
	print $firstinst->set_date_one( 36764.54167 ) . "\n";
	print $firstinst->set_date_one( 0 ) . "\n";
	print $firstinst->set_date_one( [0, 'epoch'] ) . "\n";
    
	#######################################
	#     Output of SYNOPSIS
	# 01:2000-August-26
	# 02:20000901
	# 03:20000826
	# 04:2001-09-14T00:00:00
	# 05:08092001
	# 06:1928-10-26T09:30:00
	# 07:2000-09-01T13:00:00
	# 08:1900-01-05T00:00:00
	# 09:1970-01-02T00:00:00
	#######################################
    
=head1 DESCRIPTION

L<Shiras|http://en.wikipedia.org/wiki/Moose#Subspecies> - A small subspecies of 
Moose found in the western United States.

This is a Moose L<Role|https://metacpan.org/module/Moose::Manual::Roles> 
that provides combined functionality from three different DateTime::Format packages. 
The three modules are; L<DateTime::Format::DateManip
|https://metacpan.org/module/DateTime::Format::DateManip>, 
L<DateTime::Format::Epoch|https://metacpan.org/module/DateTime::Format::Epoch>, 
and L<DateTime::Format::Excel|https://metacpan.org/module/DateTime::Format::Excel>.  
It then uses the Moose type coersion system to choose the correct way to format the 
date.  This means that all input strings are parsed by ::Format::DateManip.  All 
numbers are parsed either by ::Format::Excel or ::Format::Epoch.  Since the numbers 
of each overlap, the rule is all positive numbers under 7 positions left of the decimal 
are given to ::Excel and negative integers and integers of 7 or greater positions 
are given to ::Epoch.  Numbers outside of this range fail the type constraints.  
I<See the L<Attribute|/Attribute> section below for a way to force the numerical 
values to be parsed by the non-preffered formatter in the overlap.> Currently the 
Epoch is fixed at midnight 1-January-1970.  Since all the succesful date 'getters' 
return DateTime objects, all the L<DateTime|https://metacpan.org/module/DateTime> 
methods can be applied directly.  ex. $inst->get_today_wkend->ymd( "/" ).  

I learned the magic for the input coersion from 
L<The Moose is Flying (part 2)|http://www.stonehenge.com/merlyn/LinuxMag/col95.html> 
by Merlyn / Randal L. Schwartz++.  Any goodness found here should be attributed there, 
while I accept the responsibility for any errors.

=head2 Attributes

Attributes listed here can be passed to -E<gt>new as listed below.

=head3 (date_one|date_two|date_three)

=over

B<Definition:> these are date attributes that can be accept data that can be 
formatted via any of the supported DateTime::Format modules.  All positive real numbers 
with 6 or fewer positions left of the decimal will be treated as Excel dates.  All 
integers over 7 digits will be treated as epoch seconds from 1-January-1970.  Negative 
decimals will fail!  To force an integer with less than 7 digits into an epoch 
format send the value as an array ref with the number in the first position and 
'epoch' in the second position.  ex. [ 60, 'epoch' ]  To force a number into 
excel formatting do the same with 'excel' in the second position. 

B<Default> empty

B<Range> See L<DateTime::Format::Excel|https://metacpan.org/module/DateTime::Format::Excel>, 
L<DateTime::Format::Epoch|https://metacpan.org/module/DateTime::Format::Epoch>, and 
L<DateTime::Format::DateManip|https://metacpan.org/module/DateTime::Format::DateManip> 
for specific input range issues.  The results will all be coerced to a L<DateTime
|https://metacpan.org/module/DateTime> instance.  Currently input of Time Zones is 
L<not supported|/TODO>.

=back

=head3 week_end

=over

B<Definition:> This holds the definition of the last day of the week.

B<Default> 'Friday'

B<Range> This will accept either day names, day abbreviations 
(no periods), or day integers (1 = Monday, 7 = Sunday )

=back

=head2 Methods

Methods are used to manipulate both the public and private attributes of this role.  
All attributes are set as 'ro' so other than ->new(  ) these methods are the only way 
to change, read, or clear attributes.  See L<Moose::Manual::Roles
|https://metacpan.org/module/Moose::Manual::Roles> for generic implementation 
instructions.

=head3 set_(date_one|date_two|date_three)( $date )

=over

B<Definition:> This is another way to set (or change) the various dates if 
additional input is required after the initial declaration of ->new( 'attribute' 
=> 'value', ) command.  

B<Accepts:> Any $date data that can be coerced by L<supported ::Format
|/B<Range> See DateTime::Format::Excel> 
modules.

B<Returns:> a DateTime object

=back

=head3 get_(date_one|date_two|date_three|today)( 'DateTime->formatcommand' )

=over

B<Definition:> This is how you can call various dates and format their 
output.  example $self->get_date_two( 'ymd( "-" )' ).  For this example 
the date_two attribute had been previously set.  B<Note:> 'today' and 'now' 
are special attribute cases and do not need to be defined to be retrieved.

B<Accepts:> This returns a L<DateTime|https://metacpan.org/module/DateTime> 
object which will stringify to scalar data by default.  However, if you want to 
format the output then call the '->get_$attribute_name' method with the additional 
DateTime formatting tagged on the end.  ex. ->get_today->format_cldr( "yyyy-MMMM-d" ).

B<Returns:> a DateTime object.  If the object is passed DateTime methods
then the format determined by that method will be applied.

=back

=head3 get_$attribute_name_(wkend|wkstart)

=over

B<Definition:> This is a way to call the equivalent start and end of the 
week definded by the given 'week_end' attribute value.  All dates listed above 
including 'today' can be substitued for $attributename. I<'now' does not provide a 
weekend extrapolation.>

B<Accepts:> This returns a L<DateTime|https://metacpan.org/module/DateTime> 
object which will stringify to scalar data by default.  However, if you want to 
format the output then call the '->get_$attribute_name' method with the additional 
DateTime formatting tagged on the end.  ex. ->get_today->format_cldr( "yyyy-MMMM-d" ).

B<Returns:> a DateTime object.  If the object is passed DateTime formatting 
then that formatting will be applied.

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

=head1 DEPENDENCIES

=over

L<version|https://metacpan.org/module/version>

L<Moose::Role|https://metacpan.org/module/Moose::Role>

L<MooseX::Types|https://metacpan.org/module/MooseX::Types>

L<MooseX::Types::Moose|https://metacpan.org/module/MooseX::Types::Moose>

L<DateTimeX::Mashup::Shiras|https://metacpan.org/module/DateTimeX::Mashup::Shiras>

B<includes depenencies>

=over

L<DateTime|https://metacpan.org/module/DateTime>

L<DateTime::Format::Epoch|https://metacpan.org/module/DateTime::Format::Epoch>

L<DateTime::Format::Excel|https://metacpan.org/module/DateTime::Format::Excel>

L<DateTime::Format::DateManip|https://metacpan.org/module/DateTime::Format::DateManip>

=back

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