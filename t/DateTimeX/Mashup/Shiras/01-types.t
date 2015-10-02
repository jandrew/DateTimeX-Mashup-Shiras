#########1 Test File for DateTimeX::Mashup::Shiras::Types  6#########7#########8#########9
#!perl
BEGIN{
	$ENV{PERL_TYPE_TINY_XS} = 0;
	#~ $ENV{ Smart_Comments } = '### #### #####';
}
if( $ENV{ Smart_Comments } ){
	use Smart::Comments -ENV;
	### Smart-Comments turned on for MooseX-ShortCut-BuildInstance-Types test...
}
$| = 1;
use	Test::Most tests => 39;
use	DateTime;
use Data::Dumper;
use Capture::Tiny qw( capture_stderr );
use Types::Standard -types;
use	lib 
		'../../../../lib',;
use DateTimeX::Mashup::Shiras::Types v0.30 qw(
		WeekDay
		DateTimeDate
		
		WeekDayFromStr
		DateTimeDateFromHashRef
		DateTimeDateFromArrayRef
		DateTimeDateFromNum
		DateTimeDateFromStr
	);
my  ( 
			$position, $counter, $capture, $type_test,
	);
my			$date_time = DateTime->new( day => 11, year => 2002, month => 9 );
my 			$row = 0;
my			$question_ref =[
				1, 2, 3, 4, 5, 6, 7, 'Monday', 'Tue', 'Wed', 'Th', 8, 0, -1, 1.5,
				
				$date_time, { day => 11, year => 2002, month => 9 }, '8/26/00',
				'11-September-2001', -1299767400, 36764.54167, 0, 60, '2013-02-28 00:00:00',
				'7/4/76', '4/7/76', '5-30-11 0:00', '4-7-76 0:00', '4/7/76', '7/4/76',
				-0.1234, [-1, 'excel'],
			];
my			$answer_ref = [
				1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4,
				qr/\-8\- cannot be coerced to a weekday/,
				qr/\-0\- cannot be coerced to a weekday/,
				qr/\-\-1\- cannot be coerced to a weekday/,
				qr/Value "1.5" did not pass type constraint "Int"/,
				'2002-09-11T00:00:00', '2002-09-11T00:00:00', '2000-08-26T00:00:00',
				'2001-09-11T00:00:00', '1928-10-24T09:30:00', '2000-08-26T13:00:00',
				'1970-01-01T00:00:00', '1970-01-01T00:01:00', '2013-02-28T00:00:00',
				'1976-07-04T00:00:00', '1976-04-07T00:00:00', '2011-05-30T00:00:00',
				'1976-07-04T00:00:00', '1976-07-04T00:00:00', '1976-04-07T00:00:00',
				qr/\QCould not use the number -|-0.1234|- as an Excel date or a Nix date\E/x,
				qr/\QAttempting to treat --1- as an Excel serialized date failed in the DateTime conversion\E/x,
				qr/\QAttempting to treat --1- as an Excel serialized date failed in the DateTime conversion\E/x,
			];
### Types Tests ...
			$type_test = WeekDay->plus_coercions( WeekDayFromStr );
			map{
is			$type_test->assert_coerce( $question_ref->[$_] ), $answer_ref->[$_],
							"Check that a good WeekDay passes: $question_ref->[$_]";
			} ( 0..10 );
			map{
dies_ok{	$type_test->assert_coerce( $question_ref->[$_] ) }
							"Check that a bad WeekDay fails: $question_ref->[$_]";
like		$@, $answer_ref->[$_],
							"... and check for the correct error message";
			} ( 11..14 );
			$type_test =	DateTimeDate->plus_coercions(
								DateTimeDateFromHashRef,
								DateTimeDateFromArrayRef,
								DateTimeDateFromNum,
								DateTimeDateFromStr,
							);
			map{
is			$type_test->assert_coerce( $question_ref->[$_] ), $answer_ref->[$_],
							"Check that a good DateTimeDate passes:" . Dumper( $question_ref->[$_] );
			} ( 15..26 );
ok			$DateTimeX::Mashup::Shiras::Types::european_first = 1,
							"Set euro style text date parsing as a priority";
			map{
is			$type_test->assert_coerce( $question_ref->[$_] ), $answer_ref->[$_],
							"Check that a good DateTimeDate passes:" . Dumper( $question_ref->[$_] );
			} ( 27..29 );
			map{
dies_ok{	$type_test->assert_coerce( $question_ref->[$_] ) }
							"Check that a bad DateTimeDate fails: " . Dumper( $question_ref->[$_] );
#~ explain		$@;
like		$@, $answer_ref->[$_],
							"... and check for the correct error message";
			} ( 30..31 );
explain 								"...Test Done";
done_testing();