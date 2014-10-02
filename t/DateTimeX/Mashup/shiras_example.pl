package MyPackage;
use Moose;
use lib '../../../lib';
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