package DateTimeX::Mashup::Shiras;
use version 0.77; our $VERSION = qv("v0.34.2");

if( $ENV{ Smart_Comments } ){
	use Smart::Comments -ENV;
	### <where> - Smart-Comments turned on for DateTimeX-Mashup-Shiras: $VERSION
}

use 5.010;
use MooseX::Role::Parameterized;
use Types::Standard qw(
        Bool
        Str
        ArrayRef
    );
use lib '../../../lib', '../../lib';
use DateTimeX::Mashup::Shiras::Types v0.30 qw(
        WeekDay
		DateTimeDate
		
		WeekDayFromStr
		DateTimeDateFromHashRef
		DateTimeDateFromArrayRef
		DateTimeDateFromNum
		DateTimeDateFromStr
    );

my  @datearray = qw(
        date_one
        date_two
        date_three
        date_four
    );
my	@attribute_list;

#########1 Import and set up the attributes to be built     6#########7#########8#########9
 
parameter date_attributes =>(
		isa      	=> ArrayRef,
		predicate	=> '_has_date_attributes',
	);

role{
	( my $input, ) = @_;
	##### <where> - Loaded ref: $input
	if( $input->_has_date_attributes ){
		@attribute_list = @{$input->date_attributes};
		### <where> - Ref has a date attribute list: @attribute_list
	}else{
		@attribute_list = @datearray;
		### <where> - Using the default attribute list: @attribute_list
	}

	# build public attributes from the list
	for my $dateattribute ( @attribute_list ) {
		my $predicate   = 'has_' . $dateattribute;
		my $reader      = 'get_' . $dateattribute;
		my $writer      = 'set_' . $dateattribute;
		has $dateattribute =>(
			isa         => DateTimeDate->plus_coercions(
								DateTimeDateFromHashRef,
								DateTimeDateFromArrayRef,
								DateTimeDateFromNum,
								DateTimeDateFromStr,
							),
			coerce      => 1,
			predicate   => $predicate,
			reader      => $reader,
			writer      => $writer,
			trigger     => sub{ $_[3] = $dateattribute; _load_day( @_ ); },
		);
	}
	
	# build private attributes from the list
	for my $terminator ( '_wkstart', '_wkend' ) {
		for my $datename ( @attribute_list, 'today' ) {
			my  $attributename   = $datename . $terminator;
			my  $reader     = 'get_' . $attributename;
			my  $writer     = '_set_' . $attributename;
			has '_' . $attributename =>( #
					is 			=> 'ro',
					isa         => DateTimeDate->plus_coercions(
										DateTimeDateFromHashRef,
										DateTimeDateFromArrayRef,
										DateTimeDateFromNum,
										DateTimeDateFromStr,
									),
					reader      => $reader,
					writer      => $writer,
				);
		}
	}
};

#########1 Other Public Attributes      4#########5#########6#########7#########8#########9

has 'week_end' =>(
        isa     => WeekDay->plus_coercions( WeekDayFromStr ),
        coerce  => 1,
        default => 'Fri',# Use Friday as the end of the week, (Saturday would start the next week)
        reader  => '_get_weekend',
);

#########1 Public Methods     3#########4#########5#########6#########7#########8#########9

sub get_now{### for real time checking - get_today is when the module started
    #~ my ( $self ) = @_;
    #### <where> - Reached get_now ...
    return DateTimeDateFromStr->( 'now' );
}

#########1 Private Attributes 3#########4#########5#########6#########7#########8#########9

# set up a private attribute with a public getter for 'today'
has '_today' => (
        is          => 'ro',
        isa         => DateTimeDate->plus_coercions( DateTimeDateFromStr ),
        required    => 1,
        lazy        => 1,
        coerce      => 1,
        default     => 'today',
        reader      => 'get_today',
        writer      => '_set_today',
    );

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
    #### <where> - to week end: $daysfromweekstart
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

DateTimeX::Mashup::Shiras - A Moose role with date attributes

=begin html

<a href="https://www.perl.org">
	<img src="https://img.shields.io/badge/perl-5.10+-brightgreen.svg" alt="perl version">
</a>

<a href="https://travis-ci.org/jandrew/DateTimeX-Mashup-Shiras">
	<img alt="Build Status" src="https://travis-ci.org/jandrew/DateTimeX-Mashup-Shiras.png?branch=master" alt='Travis Build'/>
</a>

<a href='https://coveralls.io/r/jandrew/DateTimeX-Mashup-Shiras?branch=master'>
	<img src='https://coveralls.io/repos/jandrew/DateTimeX-Mashup-Shiras/badge.svg?branch=master' alt='Coverage Status' />
</a>

<a>
	<img src="https://img.shields.io/badge/this version-0.32.10-brightgreen.svg" alt="this version">
</a>

<a href="https://metacpan.org/pod/DateTimeX::Mashup::Shiras">
	<img src="https://badge.fury.io/pl/DateTimeX-Mashup-Shiras.svg?label=cpan version" alt="CPAN version" height="20">
</a>

<a href='http://cpants.cpanauthors.org/dist/DateTimeX-Mashup-Shiras'>
	<img src='http://cpants.cpanauthors.org/dist/DateTimeX-Mashup-Shiras.png' alt='kwalitee' height="20"/>
</a>

=end html

=head1 SYNOPSIS
    
	package MyPackage;
	use Moose;
	with 	'DateTimeX::Mashup::Shiras' =>{
				date_attributes =>[ qw(
					start_date end_date
				) ],
			};
	no Moose;
	__PACKAGE__->meta->make_immutable;

	#!env perl
	my  $firstinst = MyPackage->new( 
			'start_date' => '8/26/00',
		);
	print $firstinst->get_start_date->format_cldr( "yyyy-MMMM-d" ) . "\n";
	print $firstinst->get_start_date_wkend->ymd( '' ) . "\n";
	print $firstinst->get_start_date_wkstart->ymd( '' ) . "\n";
	print $firstinst->set_end_date( '11-September-2001' ) . "\n";
	print $firstinst->get_end_date_wkstart->dmy( '' ) . "\n";
	print $firstinst->set_start_date( -1299767400 ) . "\n";
	print $firstinst->set_start_date( 36764.54167 ) . "\n";
	print $firstinst->set_start_date( 0 ) . "\n";
	print $firstinst->set_start_date( 60 ) . "\n";
    
	#######################################
	#     Output of SYNOPSIS
	# 01:2000-August-26
	# 02:20000901
	# 03:20000826
	# 04:2001-09-11T00:00:00
	# 05:08092001
	# 06:1928-10-24T09:30:00
	# 07:2000-08-26T13:00:00
	# 09:1970-01-01T00:00:00
	# 09:1970-01-01T00:01:00
	#######################################
    
=head1 DESCRIPTION

L<Shiras|http://en.wikipedia.org/wiki/Moose#Subspecies> - A small subspecies of 
Moose found in the western United States.

This is a Moose Role (L<Moose::Manual::Roles>) that can add date based attributes 
with some built in date converions to your Moose class.  It also provides the 
traditional today, now, and weekend date calculation for the executed day.

The date conversion functionality comes from three different DateTime::Format 
packages using L<Type::Tiny> coersion.  The three modules are; 
L<DateTime::Format::Flexible>, L<DateTime::Format::Epoch>, and L<DateTimeX::Format::Excel>.  
The choice between them is managed by L<DateTimeX::Mashup::Shiras::Types> as a type 
coersion.  As a general rule all input strings are parsed by ::Format::Flexible.  All 
numbers are parsed either by ::Format::Excel or by ::Format::Epoch.  See the type 
package for the details and corner cases.  Since all the succesful date 'getters' 
return DateTime objects, all the L<DateTime> methods can be applied directly.  
ex. $inst-E<gt>get_today_wkend-E<gt>ymd( "/" ). 

=head2 Parameters

This is a L<MooseX::Role::Parameterized> role. The following parameters are passed as 
keys to a hash_ref when calling B<with 'DateTimeX::Mashup::Shiras' =E<gt>{ %args }>. 

=head3 date_attributes 

=over

B<Definition:> This is any array ref of the requested date attributes for the target 
class consuming this role.  To review the behavior of each named attribute review the 
documentation for L<$named_attribute|/$named_attribute> below.

B<Default> if this key is not called the role will set up the following four attributes; 
[ qw( date_one date_two date_three date_four )] (Yes the count four is arbitrary)

B<Range> any string that can be treated as an attribute name.

=back

=head2 Attributes

Data passed to new when creating an instance of the consuming class.  For modification of 
these attributes see the listed L</Methods> of the instance.

=head3 $named_attribute

=over

B<Definition:> these are date attributes set to the type 'DateTimeDate'.  
See the L<Type|DateTimeX::Mashup::Shiras::Types> Class for more details.

B<Default> empty

B<Range> epoch numbers, DateTime definition HashRefs, Date Epoch ArrayRefs, and 
human readable strings

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
to change or clear attributes.  See L<Moose::Manual::Roles> for generic implementation 
instructions.

=head3 set_${named_attribute}( $date )

=over

B<Definition:> This is the way to change (or set) the various dates.  

B<Accepts:> Any $date data that can be coerced by L<supported ::Format
|/DESCRIPTION> modules.

B<Returns:> the equivalent DateTime object

=back

=head3 get_(${named_attribute}|today|now)->format_command( 'format' )

=over

B<Definition:> This is how you can call various dates and format their 
output.  example $self->get_today->ymd( "-" ).  B<Note:> 'today' and 'now' 
are special attribute cases and do not need to be defined to be retrieved.

B<Returns:> a DateTime object

=back

=head3 get_(${named_attribute}|today)_(wkend|wkstart)

=over

B<Definition:> This is a way to call the equivalent start and end of the 
week definded by the given 'week_end' attribute value.  'now' is not included 
in this list.

B<Returns:> a DateTime object

=back

=head1 GLOBAL VARIABLES

=head2 $ENV{Smart_Comments}

The module uses L<Smart::Comments> if the '-ENV' option is set.  The 'use' is 
encapsulated in an if block triggered by an environmental variable to comfort 
non-believers.  Setting the variable $ENV{Smart_Comments} in a BEGIN block will 
load and turn on smart comment reporting.  There are three levels of 'Smartness' 
available in this module '###',  '####', and '#####'.

=head1 BUILD / INSTALL from Source
	
B<1.> Download a compressed file with this package code from your favorite source

=over

L<Meta::CPAN|https://metacpan.org/pod/DateTimeX::Mashup::Shiras>

L<github|https://github.com/jandrew/DateTimeX-Mashup-Shiras>

L<CPAN|http://search.cpan.org/~jandrew/DateTimeX-Mashup-Shiras/>

=back
	
B<3.> Extract the code from the compressed file.

=over

If you are using tar on a .tar.gz file this should work:

	tar -zxvf DateTimeX-Mashup-Shiras-v0.xx.tar.gz
	
=back

B<4.> Change (cd) into the extracted directory

B<5.> Run the following

=over

(for Windows find what version of make was used to compile your perl)

	perl  -V:make
	
(then for Windows substitute the correct make function (s/make/dmake/g)? below)
	
=back

	>perl Makefile.PL

	>make

	>make test

	>make install # As sudo/root

	>make clean

=head1 SUPPORT

L<github DateTimeX-Mashup-Shiras/issues|https://github.com/jandrew/DateTimeX-Mashup-Shiras/issues>

=head1 TODO

=over

B<1.> Add L<Log::Shiras|https://github.com/jandrew/Log-Shiras> debugging in exchange for
L<Smart::Comments>

=back

=head1 AUTHOR

=over

Jed Lund

jandrew@cpan.org

=back

=head1 CONTRIBUTORS

This is the (likely incomplete) list of people who have helped
make this distribution what it is, either via code contributions, 
patches, bug reports, help with troubleshooting, etc. A huge
'thank you' to all of them.

=over

L<Toby Inkster|https://github.com/tobyink>

=back

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

This software is copyrighted (c) 2013, 2015 by Jed Lund.

=head1 DEPENDENCIES

=over

B<5.010> - (L<perl>)

L<version>

L<MooseX::Role::Parameterized>

L<Type::Tiny>

L<DateTimeX::Mashup::Shiras::Types>

L<DateTime|https://metacpan.org/module/DateTime>

L<DateTime::Format::Epoch|https://metacpan.org/module/DateTime::Format::Epoch>

L<DateTime::Format::Excel|https://metacpan.org/module/DateTime::Format::Excel>

L<DateTime::Format::Flexible|https://metacpan.org/module/DateTime::Format::Flexible>

=back

=head1 SEE ALSO

=over

L<Time::Piece>

L<MooseX::Types::Perl>

L<Date::Parse>

L<Date::Manip::Date>

L<DateTimeX::Format>

=back

=cut

#########1 Main POD ends      3#########4#########5#########6#########7#########8#########9