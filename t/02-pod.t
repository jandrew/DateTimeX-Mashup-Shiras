#! C:/Perl/bin/perl
### Test that the pod files run
use Test::More;
eval "use Test::Pod 1.48";
if( $@ ){
	plan skip_all => "Test::Pod 1.48 required for testing POD";
}else{
	plan tests => 3;
}
pod_file_ok( '..\lib\DateTimeX\Mashup\Shiras\Types.pm', "Types file has good POD" );
pod_file_ok( '..\lib\DateTimeX\Mashup\Shiras.pm', "Shiras file has good POD" );
pod_file_ok( '..\README.pod', "The README file has good POD" );
explain "...Test Done";
done_testing();