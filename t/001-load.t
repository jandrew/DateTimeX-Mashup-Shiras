#! C:/Perl/bin/perl
### Test that the module(s) load!(s)
use Test::More;
use lib '../lib', 'lib';
use DateTimeX::Mashup::Shiras 0.020;
use DateTimeX::Mashup::Shiras::Types 0.020;
pass( "Test loading the modules in the package" );
done_testing();