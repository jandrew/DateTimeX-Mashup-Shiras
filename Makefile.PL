
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "a mashup for consuming multiple date formats\r",
  "AUTHOR" => "Jed Lund <jandrew\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Moose" => 0,
    "MooseX::ClassCompositor" => 0,
    "Test::MockTime" => 0,
    "Test::Moose" => 0,
    "Test::More" => 0,
    "Test::Most" => 0,
    "YAML::Any" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "DateTimeX-Mashup-Shiras",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "DateTimeX::Mashup::Shiras",
  "PREREQ_PM" => {
    "DateTime" => 0,
    "DateTime::Format::DateManip" => 0,
    "DateTime::Format::Epoch" => "0.013",
    "DateTime::Format::Excel" => 0,
    "Moose::Role" => 0,
    "MooseX::Types" => 0,
    "MooseX::Types::Moose" => 0,
    "Smart::Comments" => 0,
    "version" => "0.94"
  },
  "VERSION" => "0.014.002",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



