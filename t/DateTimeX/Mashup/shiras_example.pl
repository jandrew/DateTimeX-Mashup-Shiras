package MyPackage;
use Moose;
use MooseX::HasDefaults::RO;
use lib '../../../lib';
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
print $firstinst->set_date_one( 60 ) . "\n";