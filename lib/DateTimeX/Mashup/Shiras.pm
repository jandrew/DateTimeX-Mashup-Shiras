package DateTimeX::Mashup::Shiras;

use Moose::Role;
use MooseX::StrictConstructor;
use version; our $VERSION = qv('0.07_01');
use Smart::Comments -ENV;
### Smart-Comments turned on for DateTimeX::Mashup::Shiras
use MooseX::Types::Moose qw(
        Bool
        Str
        ArrayRef
    );
use lib '../../../lib', '../../ib';
use DateTimeX::Mashup::Shiras::Types v0.15 qw(
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
    ### Reached get_now
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
    ### Reached _load_day with: $newvalue
    my  $weekday    = $newvalue->day_of_week;
    my ( $daysfromweekstart, $daystoweekend ) = $self->_find_weekend( $weekday );
    ### $daystoweekend
    ### $daysfromweekstart
    my  $dtweekstart    = $newvalue->clone->subtract( days => $daysfromweekstart );
    my  $dtweekend      = $newvalue->clone->add( days => $daystoweekend );
    my  $wkstartsetter  = '_set_' . $basedate . '_wkstart';
    $self->$wkstartsetter( $dtweekstart );
    my  $wkendsetter    = '_set_' . $basedate . '_wkend';
    $self->$wkendsetter( $dtweekend );
    ### $dtweekstart
    ### $dtweekend
}

sub _find_weekend{
    my ( $self, $weekday ) = @_;
    my  $weekend    = $self->_get_weekend;
    ### Reached _find_weekend
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
    ### $daysfromweekstart
    ### $daystoweekend
    return ( $daysfromweekstart, $daystoweekend );
}

#################### Phinish with a Phlourish ##########################

no Moose::Role;

1;
# The preceding line will help the module return a true value

#################### main pod documentation begin ###################

__END__

=head1 NAME

DateTimeX::Mashup::Shiras - a mashup allowing multiple date formats

=head1 SYNOPSIS
    
    package MyPackage;
    
    use Moose;
    with 'DateTimeX::Mashup::Shiras' => { -VERSION =>  0.07 };

    no Moose;
    __PACKAGE__->meta->make_immutable;

    #! C:/Perl/bin/perl
    use Modern::Perl;
    
    my  $firstinst = MyPackage->new( 
                                'date_one' => '8/26/00',
        );
    say $firstinst->get_date_one->format_cldr( "yyyy-MMMM-d" );
    say $firstinst->get_date_one_wkend->ymd( '' );
    say $firstinst->get_date_one_wkstart->ymd( '' );
    say $firstinst->set_date_three( '11-September-2001' );
    say $firstinst->get_date_three_wkstart->dmy( '' );
    say $firstinst->set_date_one( -1299767400 );
    say $firstinst->set_date_one( 36764.54167 );
    say $firstinst->set_date_one( 0 );
    say $firstinst->set_date_one( [0, 'epoch'] );
    
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

This is a Moose Role that provides combined functionality from three different 
L<DateTime::Format> packages. The three modules are; 
L<DateTime::Format::DateManip>, L<DateTime::Format::Epoch>, and 
L<DateTime::Format::Excel>.  It then uses the Moose type coersion system to choose 
the correct way to format the date.  This means that all input strings are 
parsed by ::DateManip.  All numbers are parsed either by ::Format::Excel or 
::Format::Epoch.  Since the numbers of each overlap, the general rule is all 
positive numbers under 7 positions left of the decimal are given to ::Excel and 
negative integers and integers of 7 or greater positions are given to ::Epoch.  
Numbers outside of this range fail the type constraints.  I<See the 'Attribute' 
section below for a way to force the numerical values to be parsed by the 
non-preffered formatter in the overlap.> Currently the Epoch is fixed at midnight 
1-January-1970.  Since all the date 'getters' return DateTime objects, all the 
L<DateTime> formats can be applied directly.  ex. $inst->get_today_wkend->ymd( "/" ).  

I learned the magic for the input coersion from 
L<The Moose is Flying (part 2)|http://www.stonehenge.com/merlyn/LinuxMag/col95.html> 
by Merlyn / Randal L. Schwartz++.  Any goodness found here should be attributed there, 
while I accept the responsibility for any errors.

=head2 Attributes

Attributes listed here can be passed to ->new as listed below.

=head3 (date_one|date_two|date_three)

=over

=item B<Definition:> these are date attributes that can be accept data that can be 
formatted via any of the supported DateTime::Format modules.  All positive real numbers 
with 6 or fewer positions left of the decimal will be treated as Excel dates.  All 
integers over 7 digits will be treated as epoch seconds from 1-January-1970.  Negative 
decimals will fail!  To force an integer with less than 7 digits into an epoch 
format send the value as an array ref with the number in the first position and 
'epoch' in the second position.  ex. [ 60, 'epoch' ]  To force a number into 
excel formatting do the same with 'excel' in the second position. 

=item B<Default> empty

=item B<Range> See L<DateTime::Format::Excel>, L<DateTime::Format::Epoch>, and 
L<DateTime::Format::DateManip> for specific input range issues.  The results will 
all be coerced to a L<DateTime> instance.  Currently input of Time Zones is L<not 
supported|/TODO>.

=back

=head3 week_end

=over

=item B<Definition:> This holds the definition of the last day of the week.

=item B<Default> 'Friday'

=item B<Range> This will accept either day names, day abbreviations 
(no periods), or day integers (1 = Monday, 7 = Sunday )

=back

=head2 Methods

Methods are used to manipulate both the public and private attributes of this role.  
All attributes are set as 'ro' so other than ->new(  ) these methods are the only way 
to change, read, or clear attributes.  See L<Moose::Manual::Roles> for 
generic implementation instructions for Moose Roles.

=head3 set_(date_one|date_two|date_three)( $date )

=over

=item B<Definition:> This is another way to set (or change) the various dates if 
additional input is required after the initial declaration of ->new( 'attribute' 
=> 'value', ) command.  

=item B<Accepts:> Any $date data that can be coerced by supported ::Format modules 
I<See the attribute definitions for the details of sending dates.>

=item B<Returns:> a DateTime object

=back

=head3 get_(date_one|date_two|date_three|today)( 'DateTime->formatcommand' )

=over

=item B<Definition:> This is how you can call various dates and format their 
output.  example $self->get_date_two( 'ymd( "-" )' ). B<Note:> 'today' and 'now' 
are special attribute cases and do not need to be defined to be retrieved.

=item B<Accepts:> In this returns a L<DateTime> object which will stringify 
to scalar data by default.  However, if you want to format the output then call the 
'->get_$attribute_name' method with the additional DateTime formatting tagged on the end.  
ex. ->get_today->format_cldr( "yyyy-MMMM-d" ).

=item B<Returns:> a DateTime object.  If the object is passed DateTime formatting 
then that formatting will be applied.

=back

=head3 get_$attribute_name_(wkend|wkstart)

=over

=item B<Definition:> This is a way to call the equivalent start and end of the 
week definded by the given 'week_end' attribute value.  All dates listed above 
including 'today' can be substitued for $attributename. I<'now' does not allow a 
weekend method.>

=item B<Accepts:> In this returns a L<DateTime> object which will stringify 
to scalar data by default.  However, if you want to format the output then call the 
'->get_$attribute_name' method with the additional DateTime formatting tagged on the end.  
ex. ->get_today->format_cldr( "yyyy-MMMM-d" ).

=item B<Returns:> a DateTime object.  If the object is passed DateTime formatting 
then that formatting will be applied.

=back

=head1 BUGS

L<DateTimeX-Mashup-Shiras/issues|https://github.com/jandrew/DateTimeX-Mashup-Shiras/issues>

=head1 TODO

=over

=item Support Timezone input and changes

=item ??

=back

=head1 SUPPORT

=over

=item jandrew@cpan.org

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

=item L<Moose::Role>

=item L<MooseX::StrictConstructor>

=item L<version>

=item L<MooseX::Types::Moose>

=item L<MooseX::Types>

=item L<Smart::Comments>

=item L<DateTimeX::Mashup::Shiras::Types> - in this CPAN package

=item L<DateTime>

=item L<DateTime::Format::Epoch>

=item L<DateTime::Format::Excel>

=item L<DateTime::Format::DateManip>

=back

=head1 SEE ALSO

=over

=item L<DateTimeX::Format>

=back

=cut

#################### main pod documentation end #####################