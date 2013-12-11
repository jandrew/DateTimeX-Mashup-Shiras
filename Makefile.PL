
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A Moose role with three date attributes\r",
  "AUTHOR" => "Jed Lund <jandrew\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "DateTimeX-Mashup-Shiras",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "DateTimeX::Mashup::Shiras",
  "PREREQ_PM" => {
    "DateTime" => 0,
    "DateTime::Format::Epoch" => "0.013",
    "DateTime::Format::Excel" => 0,
    "DateTime::Format::Flexible" => 0,
    "Moose::Role" => 0,
    "MooseX::Types" => 0,
    "MooseX::Types::Moose" => 0,
    "Smart::Comments" => 0,
    "lib" => 0,
    "version" => "0.94"
  },
  "TEST_REQUIRES" => {
    "Moose" => 0,
    "MooseX::ClassCompositor" => 0,
    "Test::MockTime" => 0,
    "Test::Moose" => 0,
    "Test::More" => 0,
    "Test::Most" => 0,
    "YAML::Any" => 0
  },
  "VERSION" => "v0.22.2",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "DateTime" => 0,
  "DateTime::Format::Epoch" => "0.013",
  "DateTime::Format::Excel" => 0,
  "DateTime::Format::Flexible" => 0,
  "Moose" => 0,
  "Moose::Role" => 0,
  "MooseX::ClassCompositor" => 0,
  "MooseX::Types" => 0,
  "MooseX::Types::Moose" => 0,
  "Smart::Comments" => 0,
  "Test::MockTime" => 0,
  "Test::Moose" => 0,
  "Test::More" => 0,
  "Test::Most" => 0,
  "YAML::Any" => 0,
  "lib" => 0,
  "version" => "0.94"
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



