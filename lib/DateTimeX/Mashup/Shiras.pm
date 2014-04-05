package DateTimeX::Mashup::Shiras;
use version 0.94; our $VERSION = qv("v0.26.2");

use Moose::Role;
use 5.010;
if( $ENV{ Smart_Comments } ){
	use Smart::Comments -ENV;
	### <where> - Smart-Comments turned on for DateTimeX-Mashup-Shiras v0.26
}
use MooseX::Types::Moose qw(
        Bool
        Str
        ArrayRef
    );
use lib '../../../lib', '../../lib';
use DateTimeX::Mashup::Shiras::Types 0.026 qw(
        weekday
        datetimedate
    );

#########1 Dispatch Tables and Module Variables   5#########6#########7#########8#########9

my  @datearray = qw(
        date_one
        date_two
        date_three
        date_four
    );

#########1 Public Attributes  3#########4#########5#########6#########7#########8#########9

has 'week_end' =>(
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
        isa         => datetimedate,
        coerce      => 1,
        predicate   => $predicate,
        reader      => $reader,
        writer      => $writer,
        trigger     => sub{ $_[3] = $dateattribute; _load_day( @_ ); },
    );
}

#########1 Public Methods     3#########4#########5#########6#########7#########8#########9

sub get_now{### for real time checking - get_today is when the module started
    my ( $self ) = @_;
    #### <where> - Reached get_now ...
    return to_datetimedate( 'now' );### beautiful MooseX::Types majic!
}

#########1 Private Attributes 3#########4#########5#########6#########7#########8#########9

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

#########1 Private Methods    3#########4#########5#########6#########7#########8#########9

sub _load_day{
    my ( $self, $newvalue, $oldvalue, $basedate ) = @_;
    #### <where> - Reached _load_day with: $newvalue
    my  $weekday    = $newvalue->day_of_week;
    my ( $daysfromweekstart, $daystoweekend ) = $self->_find_weekend( $weekday );
    #### <where> - to weekend: $daystoweekend
    #### <where> - to weekstart: $daysfromweekstart
    my	$dtweekstart = $newvalue->clone;
		$dtweekstart->subtract( days => $daysfromweekstart );
	my	$dtweekend = $newvalue->clone;
		$dtweekend->add( days => $daystoweekend );
	my  $wkstartsetter  = '_set_' . $basedate . '_wkstart';
    $self->$wkstartsetter( $dtweekstart );
    my  $wkendsetter    = '_set_' . $basedate . '_wkend';
    $self->$wkendsetter( $dtweekend );
    #### <where> - week start day: $dtweekstart
    #### <where> - week end day: $dtweekend
	return $newvalue;
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

#########1 Phinish Strong     3#########4#########5#########6#########7#########8#########9

no Moose::Role;

1;
# The preceding line will help the module return a true value

#########1 Main POD starts    3#########4#########5#########6#########7#########8#########9

__END__

=head1 NAME

DateTimeX::Mashup::Shiras - A Moose role with four date attributes

=head1 SYNOPSIS
    
	package MyPackage;
	use Moose;
	use MooseX::HasDefaults::RO;
	with 'DateTimeX::Mashup::Shiras';
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
    
	#######################################
	#     Output of SYNOPSIS
	# 01:2000-August-26
	# 02:20000901
	# 03:20000826
	# 04:2001-09-11T00:00:00
	# 05:08092001
	# 06:1928-10-26T09:30:00
	# 07:2000-08-26T13:00:00
	# 09:1970-01-01T00:00:00
	#######################################
    
=head1 DESCRIPTION

L<Shiras|http://en.wikipedia.org/wiki/Moose#Subspecies> - A small subspecies of 
Moose found in the western United States.

This is a Moose Role (L<Moose::Manual::Roles>) that 
has four flexible date attributes and some additional date functionality.  This 
role can add some date attributes to your class with built in date handling.  It 
also provides the traditional today, now, and weekend date calculation for a given 
day.

The flexibility of input for the dates comes from three different DateTime::Format 
packages using type coersion.  The three modules are; L<DateTime::Format::Flexible
|https://metacpan.org/module/DateTime::Format::Flexible>, 
L<DateTime::Format::Epoch|https://metacpan.org/module/DateTime::Format::Epoch>, 
and L<DateTime::Format::Excel|https://metacpan.org/module/DateTime::Format::Excel>.  
The choice between them is managed by L<DateTimeX::Mashup::Shiras::Types
|https://metacpan.org/module/DateTimeX::Mashup::Shiras::Types> as a type coersion.  
This means that all input strings are parsed by ::Format::Flexible.  All numbers 
are parsed either by ::Format::Excel or ::Format::Epoch.  See the type package 
for the details and corner cases.  Since all the succesful date 'getters' 
return DateTime objects, all the L<DateTime|https://metacpan.org/module/DateTime> 
methods can be applied directly.  ex. $inst->get_today_wkend->ymd( "/" ). 

=head2 Attributes

Attributes listed here can be passed to -E<gt>new as listed below.

=head3 (date_one|date_two|date_three|date_four)

=over

B<Definition:> these are date attributes set to the type 'datetimedate'.  
See the L<Type|https://metacpan.org/module/DateTimeX::Mashup::Shiras::Types> 
Class for more details.

B<Default> empty

B<Range> Currently input of Time Zones is L<not supported|/TODO>.

=back

=head3 week_end

=over

B<Definition:> This holds the definition of the last day of the week

B<Default> 'Friday'

B<Range> This will accept either day names, day abbreviations 
(no periods), or day integers (1 = Monday, 7 = Sunday )

=back

=head2 Methods

Methods are used to manipulate both the public and private attributes of this role.  
All attributes are set as 'ro' so other than ->new(  ) these methods are the only way 
to change or clear attributes.  See L<Moose::Manual::Roles
|https://metacpan.org/module/Moose::Manual::Roles> for generic implementation 
instructions.

=head3 set_(date_one|date_two|date_three|date_four)( $date )

=over

B<Definition:> This is the way to change (or set) the various dates.  

B<Accepts:> Any $date data that can be coerced by L<supported ::Format
|/DESCRIPTION> modules.

B<Returns:> the equivalent DateTime object

=back

=head3 get_(date_one|date_two|date_three|date_four|today|)->format_command( 'format' )

=over

B<Definition:> This is how you can call various dates and format their 
output.  example $self->get_date_two->ymd( "-" ).  For this example 
the date_two attribute had been previously set.  B<Note:> 'today' and 'now' 
are special attribute cases and do not need to be defined to be retrieved.

B<Returns:> a DateTime object

=back

=head3 get_$attribute_name_(wkend|wkstart)

=over

B<Definition:> This is a way to call the equivalent start and end of the 
week definded by the given 'week_end' attribute value.  All dates listed above 
including 'today' except 'now' can be substitued for $attributename.

B<Returns:> a DateTime object

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

* Get Log::Shiras CPAN ready first

=back

=back

=head1 AUTHOR

=over

=item Jed Lund

=item jandrew@cpan.org

=back

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

This software is copyrighted (c) 2013 by Jed Lund.

=head1 DEPENDENCIES

=over

L<version|https://metacpan.org/module/version>

L<Moose::Role|https://metacpan.org/module/Moose::Role>

L<MooseX::Types::Moose|https://metacpan.org/module/MooseX::Types::Moose>

L<DateTimeX::Mashup::Shiras::Types|https://metacpan.org/module/DateTimeX::Mashup::Shiras::Types>

=over

B<includes depenencies>

=over

L<DateTime|https://metacpan.org/module/DateTime>

L<DateTime::Format::Epoch|https://metacpan.org/module/DateTime::Format::Epoch>

L<DateTime::Format::Excel|https://metacpan.org/module/DateTime::Format::Excel>

L<DateTime::Format::Flexible|https://metacpan.org/module/DateTime::Format::Flexible>

=back

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

#########1 Main POD ends      3#########4#########5#########6#########7#########8#########9