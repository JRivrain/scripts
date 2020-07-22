use strict;
use warnings;
use Data::Dumper;


# for each PV, I want the number of physical extents in each PV that are part of the VG..
# This will allow me to sum up all physical extents of the VG, across all PVs.
# So let's create a hash like that contains an array of sizes for each PV, in each VG.

my @PV = split(/\n/, `pvdisplay |grep "PV Name" |awk '{print \$3}'`);
my @VG = split(/\n/, `vgdisplay |grep "VG Name" |awk '{print \$3}'`);
my %PVs_in_VGs;

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
		$PVs_in_VGs{$vg} = [@extents_in_vg]
	}

}

$Data::Dumper::Sortkeys = 1; 
print Dumper %PVs_in_VGs;

1;
