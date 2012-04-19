#! C:/Perl/bin/perl
### Test that the module(s) load!(s)
use Test::More;
use lib '../lib', 'lib';
use DateTimeX::Mashup::Shiras v0.007;
use DateTimeX::Mashup::Shiras::Types v0.015;
pass( "Test loading the modules in the package" );
done_testing();