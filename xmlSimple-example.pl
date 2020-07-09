use strict;
use warnings;
use XML::Simple;
#use Data::Dumper; # Only for debug, to understand data structure
# $Data::Dumper::Sortkeys = 1;
# print Dumper $profile;

my $profile = XMLin('./clone-autoinst.xml');

print "name of lv: $profile->{partitioning}->{drive}[0]->{partitions}->{partition}[0]->{lv_name}\n";

foreach my $part (@{$profile->{partitioning}->{drive}[0]->{partitions}->{partition}}) {
	my $count = 0;
	print "$part->{lv_name} will be mounted on $part->{mount} and will have a size of $part->{size}\n";
	$count++;
}

1;
