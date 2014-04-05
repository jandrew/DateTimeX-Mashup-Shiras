#! C:/Perl/bin/perl
### Test that the module(s) load!(s)
use	Test::More;
use	lib '../lib', 'lib';
BEGIN{ use_ok( version ) };
BEGIN{ use_ok( Moose::Role ) };
BEGIN{ use_ok( DateTime::TimeZone, 1.64 ) };
BEGIN{ use_ok( DateTime::Format::Epoch, 0.013 ) };
BEGIN{ use_ok( DateTime::Format::Excel ) };
BEGIN{ use_ok( DateTime::Format::Flexible ) };
BEGIN{ use_ok( MooseX::Types ) };
BEGIN{ use_ok( MooseX::Types::Moose ) };
BEGIN{ use_ok( Test::Moose ) };
BEGIN{ use_ok( MooseX::ClassCompositor ) };
BEGIN{ use_ok( Test::MockTime ) };
BEGIN{ use_ok( YAML::Any ) };
BEGIN{ use_ok( Smart::Comments ) };
BEGIN{ use_ok( DateTimeX::Mashup::Shiras, 0.026 ) };
BEGIN{ use_ok( DateTimeX::Mashup::Shiras::Types, 0.026 ) };
done_testing();