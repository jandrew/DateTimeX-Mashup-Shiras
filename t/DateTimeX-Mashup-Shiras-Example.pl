package MyPackage;

use Moose;
use lib '../lib';
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