use strict;
use warnings;
use Data::Dumper;


# I want to sum up the physical extents across all Physical Volumes within each Volume
# Group of a given system. So it should looke like:$PVs_in_VGs{$vg} = [@extents_in_vg]

my @PV = split(/\n/, `pvdisplay |grep "PV Name" |awk '{print \$3}'`);
my @VG = split(/\n/, `vgdisplay |grep "VG Name" |awk '{print \$3}'`);
my %PEs_in_VGs;

foreach my $vg (@VG) {
	my @list_of_pvs;
	my @extents_in_vg;
	foreach my $pv (@PV) {
		my $vg_for_pv = `pvdisplay $pv |grep "$vg" |awk '{print \$3}'`;
		chomp($vg_for_pv);
		if ( "$vg_for_pv" eq "$vg" ) 
		{
			my $extents_in_pv = `pvdisplay $pv |grep "Total PE" |awk '{print \$3}'`;
			chomp($extents_in_pv);
			push (@extents_in_vg, $extents_in_pv);			
		}
		$PEs_in_VGs{$vg} = [@extents_in_vg]
	}

}

$Data::Dumper::Sortkeys = 1; 
print Dumper %PEs_in_VGs;

1;
