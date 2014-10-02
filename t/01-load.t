#! C:/Perl/bin/perl
### Test that the module(s) load!(s)
use	Test::More tests => 13;
use	lib '../lib', 'lib';
BEGIN{ use_ok( version ) };
BEGIN{ use_ok( MooseX::Role::Parameterized ) };
BEGIN{ use_ok( DateTime::Format::Epoch, 0.013 ) };
BEGIN{ use_ok( DateTimeX::Format::Excel, v0.12 ) };
BEGIN{ use_ok( DateTime::Format::Flexible ) };
BEGIN{ $ENV{PERL_TYPE_TINY_XS} = 0; };
BEGIN{ use_ok( Type::Tiny, 0.046 ) };
BEGIN{ use_ok( Test::Moose ) };
BEGIN{ use_ok( MooseX::ShortCut::BuildInstance, 1.026 ) };
BEGIN{ use_ok( Test::MockTime ) };
BEGIN{ use_ok( YAML::Any ) };
BEGIN{ use_ok( Smart::Comments ) };
use lib '../lib';
BEGIN{ use_ok( DateTimeX::Mashup::Shiras, 0.031 ) };
BEGIN{ use_ok( DateTimeX::Mashup::Shiras::Types, 0.031 ) };
done_testing();