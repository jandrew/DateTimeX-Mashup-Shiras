#! C:/Perl/bin/perl
### Test that the module(s) load!(s)
use Test::More;
use lib '../lib', 'lib';
use DateTimeX::Mashup::Shiras v0.014;
use DateTimeX::Mashup::Shiras::Types v0.016;
pass( "Test loading the modules in the package" );
done_testing();