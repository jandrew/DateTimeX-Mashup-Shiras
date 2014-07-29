package DateTimeX::Mashup::Shiras::Types;
use version 0.94; our $VERSION = qv("v0.30.2");
use strict;
use warnings;
use 5.010;
use DateTime;
use DateTime::Format::Epoch 0.013;
use DateTimeX::Format::Excel v0.12;
use DateTime::Format::Flexible;
use Type::Utils 0.046 -all;
use Type::Library
	-base,
	-declare => qw(
		WeekDay
		DateTimeDate
		
		WeekDayFromStr
		DateTimeDateFromHashRef
		DateTimeDateFromArrayRef
		DateTimeDateFromNum
		DateTimeDateFromStr
	);
use Types::Standard qw(
        InstanceOf
        HashRef
        ArrayRef
        Str
        Num
		is_Num
        Int
    );
my $try_xs =
		exists($ENV{PERL_TYPE_TINY_XS}) ? !!$ENV{PERL_TYPE_TINY_XS} :
		exists($ENV{PERL_ONLY})         ?  !$ENV{PERL_ONLY} :
		1;
if( $try_xs and exists $INC{'Type/Tiny/XS.pm'} ){
	eval "use Type::Tiny::XS 0.010";
	if( $@ ){
		die "You have loaded Type::Tiny::XS but versions prior to 0.010 will cause this module to fail";
	}
}

#########1 Dispatch Tables and Module Variables   5#########6#########7#########8#########9

our	$epochdt = DateTime->new( 
        year => 1970, 
        month => 1, 
        day => 1 
    );

our	$excel_type = 'win_excel';

my  $epochformtr = DateTime::Format::Epoch->new(
        epoch               => $epochdt,
        unit                => 'seconds',
        type                => 'int',
        skip_leap_seconds   => 1,
        start_at            => 0,
        local_epoch         => undef,
    );
my	$excelformter = 
my  $weekdays = {
        'Monday'        => 1,
        'Tuesday'       => 2,
        'Wednessday'    => 3,
        'Thursday'      => 4,
        'Friday'        => 5,
        'Saturday'      => 6,
        'Sunday'        => 7,
    };
#~ my	$local_time_zone = DateTime::TimeZone->new( name => 'local' );

#########1 Subtypes           3#########4#########5#########6#########7#########8#########9

declare WeekDay, as Int,
    where{ $_ >= 1 and $_ <= 7 },
    message{ 
        ( defined $_ ) ? 
            "-$_- cannot be coerced to a weekday" : 
            'No value passed to the weekday type test' 
    };

declare_coercion WeekDayFromStr,
	to_type WeekDay,
	from Str,
    via{
		my $str = $_;
		return $str if is_Num( $str );
        for my $day ( keys %$weekdays ) {
            if ( $day =~ /^$str/i ) {
                return $weekdays->{$day};
            }
        }
		return "can't match -$str- to day list";
    };

declare DateTimeDate, as InstanceOf[ 'DateTime' ],
	message{ $_ };

declare_coercion DateTimeDateFromHashRef,
	to_type DateTimeDate,
	from HashRef,
    via{ 
        my $dt;
        my %input = %$_;
        return(
            ( eval{ $dt = DateTime->new(%input) } ) ?
                $dt : "Failed to create a DateTime object from the HashRef\n" . Dump( $_ )
        );
    };

declare_coercion DateTimeDateFromArrayRef,
	to_type DateTimeDate,
	from ArrayRef,
    via{ 
        my $dt;
        my ( $arg, $type, $time_zone ) = @$_;
		$type = _deduce_epoch_type( $arg, $type );
		return _convert_list_to_date_time( $arg, $type, $time_zone );
    };

declare_coercion DateTimeDateFromNum,
	to_type DateTimeDate,
	from Num,
    via{ 
        my $dt;
        my $arg		= $_;
		my $type	= _deduce_epoch_type( $arg );
		return	"Could not use the number -|$arg|- as an Excel date or a Nix date" if ! $type or $type eq 'bad_num';
		return _convert_list_to_date_time( $arg, $type,);
    };

declare_coercion DateTimeDateFromStr,
	to_type DateTimeDate,
	from Str,
    via{ 
        my $str		= $_;
		my $dt		= DateTime::Format::Flexible->parse_datetime( $str );
		my $return	= ( $dt ) ? $dt :
				"Failed to build a date time from DateTime::Format::Flexible (or any other method) for string -$str-\n";
		return $return;
    };

#########1 Private Methods    3#########4#########5#########6#########7#########8#########9

sub _deduce_epoch_type{
	my ( $num, $type ) = @_;
	$type //=
		( $num =~ /^(\d{7,11}|60|0|-\d+)$/  )		? 'epoch'	:#choose epoch style
		( $num =~ /^(\d{0,6}(.\d*)?|\d{7,}.\d+)$/ )	? 'excel'	:#choose excel style
		( $num =~ /^-\d*.\d+$/ )					? 'bad_num' :#Negative decimals not allowed
		'bad_num';
	$type = ( $type eq 'excel' ) ? $excel_type : $type;
	return $type;
}

sub _convert_list_to_date_time{
	my ( $arg, $type, $time_zone ) = @_;
	my ( $formatter, $parser_args );
	if( $type eq 'epoch' ){
		$formatter = DateTime::Format::Epoch->new( 
			epoch          => $epochdt,
			unit           => 'seconds',
			type           => 'int',    # or 'float', 'bigint'
			skip_leap_seconds => 1,
			start_at       => 0,
			local_epoch    => undef,
		);
	}elsif( $type =~ /_excel$/ ){
		$formatter = DateTimeX::Format::Excel->new(
			system_type => $type
		);
	}else{
		return "Unknown type -$type- passed to date conversion";
	}
	my	$dt = $formatter->parse_datetime( $arg );
	if( DateTimeDate->check( $dt ) ){
		$dt->set_time_zone( $time_zone ) if $time_zone;
		return $dt;
	}else{
		my	$return =
			( $type eq 'epoch' ) ?
				"Attempting to treat -$arg- as a Nix epoch failed in the DateTime conversion" :
			( $type =~ /_excel$/ ) ?
				"Attempting to treat -$arg- as an Excel serialized date failed in the DateTime conversion" :
				"Failed to build a date time from DateTime::Format::DateManip (or any other method) for string -$arg-" ;
		return $return;
	}
}
	

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
        WeekDay
		WeekDayFromStr
    );
    
    has 'attribute_1' => (
            is  => 'ro',
            isa => WeekDay->plus_coercions( WeekDayFromStr ),
        );

=head1 DESCRIPTION

L<Shiras|http://en.wikipedia.org/wiki/Moose#Subspecies> - A small subspecies of 
Moose found in the western United States (of America).

This is the custom type class that ships with the L<DateTimeX::Mashup::Shiras> 
package.  Wherever possible coersion failures are passed back to the type so 
type errors will be explained.  The types are implemented using L<Type::Tiny>.

=head2 L<Caveat utilitor|http://en.wiktionary.org/wiki/Appendix:List_of_Latin_phrases_(A%E2%80%93E)#C>

All type tests included with this package are considered to be the fixed definition of 
the types.  Any definition not included in the testing is considered flexible.

This module uses L<Type::Tiny> which can, in the background, use L<Type::Tiny::XS>.  
While in general this is a good thing you will need to make sure that 
Type::Tiny::XS is version 0.010 or newer since the older ones didn't support the 
'Optional' method.

=head2 Types

There are no included coercions with these types.  Any coercion usage should be 
with -E<gt>plus_coercions from the L<list|/Coercions> below.

=head3 WeekDay

=over

B<Definition: >integers ( 1 .. 7 )

B<Coercions: >from a string.  The type will try to qr//i match the passed string 
to an english name of the week.

=back

=head3 DateTimeDate

=over

B<Definition: >a L<DateTime> instance

=back

=head2 Coercions

These are named coercions available for export by this module.  For the 
coercions to work with the Type they must be added to the type via 
-E<gt>plus_coercions.  To test the type and coercions together use the 
-E<gt>coerce or -E<gt>assert_coerce functions.

=head3 WeekDayFromStr

=over

B<Definition: >Takes a string that matches the full or any portion of 
the initial letters in an english weekday name and converts it to an integer 
(1..7) where 1 = Monday.  The match is case independant (qr/$_/i).

=back

=head3 DateTimeDateFromHashRef

=over

B<Definition: >This will take a HashRef and attempt to treat is as %$args for 
the function Datetime->new( %$args )

=back

=head3 DateTimeDateFromArrayRef

=over

B<Definition: > this will take an ArrayRef and use up to the first three positions 
in the array as; [ $arg, $type, $time_zone ].  This is only used for passing numbers 
coded as excel or unix epochs to be converted to DateTime objects.  The elements are 
used as follows.

=over

B<$arg:> this is expected to be a number that falls either in the L<Unix|DateTime::Format::Epoch> 
range or in the L<Microsoft Excel|DateTimeX::Format::Excel> range.

B<$type:> this is a way to force the interpretation of the number.  The four 
possibilites are; excel, win_excel, apple_excel, or epoch.  If epoch is called then 
the number is interpreted by L<DateTime::Format::Epoch> and the global variable 
L</$DateTimeX::Mashup::Shiras::Types::epochdt> will be used.  A $type eq 'excel' 
setting will convert to the global variable L</$DateTimeX::Mashup::Shiras::Types::excel_type>.  
Then the value will be passed to L<DateTimeX::Format::Excel> as the 'system_type' 
for interpretation by that program.

B<$time_zone:> if a value is entered then after $arg is converted to a DateTime object 
the instance will have $dt-E<gt>set_time_zone( $time_zone ) called on it.

=back

=back

=head3 DateTimeDateFromNum

=over

B<Definition: > This will check the number for 0 or 60 (microsoft issues), 
negative integers, and positive integers with more than 7 digits and read them 
as epoch (Nixy) dates. It will turn any positive integer or decimial with 
less than 7 leading digits into an excel date using L<DateTime::Format::Excel>.  
All positive decimals with 7 or more digits will also be treated as excel dates.  
Negative decimals will fail.This will take a number and guess what type it is.  
The data is then handled the same as L<an ArrayRef|/DateTimeDateFromArrayRef>. 

=back

=head3 DateTimeDateFromStr

=over

B<Definition: > This should be the final fall back check and it attempts to 
turn any String into a DateTime object with L<DateTime::Format::Flexible>.

=back

=head1 GLOBAL VARIABLES

=head2 $ENV{Smart_Comments}

The module uses L<Smart::Comments> if the '-ENV' option is set.  The 'use' is 
encapsulated in an if block triggered by an environmental variable to comfort 
non-believers.  Setting the variable $ENV{Smart_Comments} in a BEGIN block will 
load and turn on smart comment reporting.  There are three levels of 'Smartness' 
available in this module '###',  '####', and '#####'.

=head2 $DateTimeX::Mashup::Shiras::Types::epochdt

This variable holds a L<DateTime> object set to; year => 1970, month => 1, 
day => 1. To be used by L<DateTime::Format::Epoch> as the Epoch start.  If you 
wish to change the epoch start change this variable.  All changes are permanent 
until the next change.

=head2 $DateTimeX::Mashup::Shiras::Types::excel_type

This variable holds the default excel type for L<DateTimeX::Format::Excel>.  
The default is 'win_excel'.

=head1 SUPPORT

L<github DateTimeX-Mashup-Shiras/issues|https://github.com/jandrew/DateTimeX-Mashup-Shiras/issues>

=head1 TODO

=over

B<1.> Add L<Log::Shiras|https://github.com/jandrew/Log-Shiras> debugging in exchange for
L<Smart::Comments>

=over

* Get Log::Shiras CPAN ready first! (Some horrible deep recursion happens so far)

=back

=back

=head1 AUTHOR

=over

Jed Lund

jandrew@cpan.org

=back

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

This software is copyrighted (c) 2013, 2014 by Jed Lund.

=head1 DEPENDANCIES

=over

B<5.010> - (L<perl>)

L<version>

L<Type::Tiny>

L<DateTime>

L<DateTime::Format::Epoch> - 0.013

L<DateTimeX::Format::Excel>

L<DateTime::Format::Flexible>

=back

=head1 SEE ALSO

=over

L<Time::Piece>

L<DateTime::Format::Excel>

L<MooseX::Types>

L<Date::Parse>

L<Date::Manip::Date>

L<DateTimeX::Format>

=back

=cut

#########1 Main POD ends      3#########4#########5#########6#########7#########8#########9