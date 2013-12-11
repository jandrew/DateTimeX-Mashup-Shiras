#!perl
#######  Test File for DateTimeX::Mashup::Shiras  #######
use Test::Most;
use Test::Moose;
use MooseX::ClassCompositor;
use Test::MockTime qw(
    set_fixed_time
    restore_time
);
use YAML::Any;
use DateTime::Format::Flexible;
use Smart::Comments -ENV;
use lib '../lib', 'lib';
use DateTimeX::Mashup::Shiras 0.022;#Manage version tested


my  @datearray = qw(
        date_one
        date_two
        date_three
    );

my  @terminators = (
        '',
        '_wkend',
        '_wkstart',
    );

my  @attributes = qw(
        week_end
    );
push @attributes, @datearray;

my  @methods = qw(  
        new
        get_now
    );
for my $date ( @datearray ) {
    push @methods, 'has_' . $date, 'set_' . $date;
}
### <where> - finished the date array
for my $date ( @datearray, 'today' ) {
    for my $kristannaloken ( @terminators ) {
        my $extramethod = 'get_' . $date . $kristannaloken;
        push @methods, $extramethod;
    }
}
### <where> - finished the method array
my  ( $wait, $class, $firstinst, $secondinst );

$| = 1;

# easy questions
$class = MooseX::ClassCompositor->new({
    class_basename => 'Test',
})->class_for( 
    'DateTimeX::Mashup::Shiras',
);
map has_attribute_ok( $class, $_ ), @attributes;
### <where> - finished the attribute tests
map can_ok( $class, $_ ), @methods;

#Run the hard questions
lives_ok{ $firstinst   = $class->new() }      'Test that a new Class instance with a DateTimeX::Mashup Role starts quietly with no variables';


#Run the hard questions
lives_ok{ $firstinst   = $class->new() }      'Test that a new Class instance with a DateTimeX::Mashup Role starts quietly with no variables';
set_fixed_time( 1234567890 );# use Test::MockTime to resolve method compare processing times
is( $firstinst->get_today->ymd, 
    (DateTime::Format::Flexible->parse_datetime( 'today' ))->ymd( '-' ),
                                                        'Test that the base today is autoloaded and returns correctly');
is( $firstinst->get_now, 
    DateTime::Format::Flexible->parse_datetime( 'now' ),
                                                        'Test that asking for now works');
restore_time();# finish using Test::MockTime and restore system time
lives_ok{ $secondinst = $class->new( 
                            'date_one' => '8/26/00',
                        ) }                             'Test that another instance with a passed date starts';
is( $secondinst->get_date_one->format_cldr( "yyyy-MMMM-d" ),
    '2000-August-26',                                   'Test that get_date_one returns using a CLDR formatted date');
is( $secondinst->get_date_one_wkend->ymd( '' ), 
    '20000901',                                         'Test getting the date_one weekend');
is( $secondinst->get_date_one_wkstart->ymd( '' ), 
    '20000826',                                         'Test getting the date_one start of the week');
lives_ok{ $secondinst->set_date_three( '11-September-2001' ) }
                                                        'Test loading the third date';
is( $secondinst->get_date_three_wkstart->dmy( '' ), '08092001',
                                                        'Test the start of that week' );
throws_ok{ $secondinst->set_date_one( -0.1234 ) }
    qr/\QCould not use the number -|-0.1234|- as an Excel date or a Nix date\E/x,                                          
                                                        'Test negative decimal numbers fail';
is( $secondinst->set_date_one( -1299767400 ), '1928-10-24T09:30:00',
                                                        'Test that negative integers (and the Nix timestamp converter) do work');
is( $secondinst->set_date_one( 36764.54167 ), '2000-08-26T13:00:00',
                                                        'Test that general excel serialized dates work');
throws_ok{ $secondinst->set_date_one( [-1, 'excel'] ) }
    qr/\QAttempting to treat --1- as an Excel serialized date failed in the DateTime conversion\E/x,
														'Test the input |-1| (will fail when you force an Excel format on it)';
is( $secondinst->set_date_one( 0 ), '1970-01-01T00:00:00',
                                                        '0 evaluates as a Nix timestamp');
is( $secondinst->set_date_one( '2013-02-28 00:00:00' ),  '2013-02-28T00:00:00',
										'Test that DateTime::Format::Flexible can handle time strings without the T');# 00:00:00
done_testing();