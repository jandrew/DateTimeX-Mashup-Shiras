#! C:/Perl/bin/perl
### Test that the pod files run
use Test::More;
eval "use Test::Pod 1.48";
if( $@ ){
	plan skip_all => "Test::Pod 1.48 required for testing POD";
}else{
	plan tests => 3;
}
my	$up		= '../';
for my $next ( <*> ){
	if( ($next eq 't') and -d $next ){
		### <where> - found the t directory - must be using prove ...
		$up	= '';
		last;
	}
}
pod_file_ok( $up . 'lib/DateTimeX/Mashup/Shiras/Types.pm', "Types file has good POD" );
pod_file_ok( $up . 'lib/DateTimeX/Mashup/Shiras.pm', "Shiras file has good POD" );
pod_file_ok( $up . 'README.pod', "The README file has good POD" );
explain "...Test Done";
done_testing();