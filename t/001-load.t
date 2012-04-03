#! C:/Perl/bin/perl
### Test that the module loads
use Test::Most;

use lib '../lib', 'lib';

my  @modules = (
        'DateTimeX::Mashup::Shiras v0.07',
        'DateTimeX::Mashup::Shiras::Types v0.15',
    );

map{ use_ok( $_ ) } @modules;
done_testing;



