# Define a procedure which generates a rectangular reinforced concrete section
# with one layer of steel evenly distributed around the perimeter and a confined core.
# 
#                       y
#                       |
#                       |
#                       |    
#             ---------------------
#             |\                 /|
#             | \---------------/ |
#             | |               | |
#             | |               | |
#  z ---------| |               | |  h
#             | |               | |
#             | |               | |
#             | /---------------\ |
#             |/                 \|
#             ---------------------
#                       b
#
# Formal arguments
#    id - tag for the section that is generated by this procedure
#    h - overall height of the section (see above)
#    b - overall width of the section (see above)
#    cover - thickness of the cover patches
#    coreID - material tag for the core patch
#    coverID - material tag for the cover patches
#    steelID - material tag for the reinforcing steel
#    numBars - number of reinforcing bars on any given side of the section
#    barArea - cross-sectional area of each reinforcing bar
#    nfCoreY - number of fibers in the core patch in the y direction
#    nfCoreZ - number of fibers in the core patch in the z direction
#    nfCoverY - number of fibers in the cover patches with long sides in the y direction
#    nfCoverZ - number of fibers in the cover patches with long sides in the z direction
#
# Notes
#    The thickness of cover concrete is constant on all sides of the core.
#    The number of bars is the same on any given side of the section.
#    The reinforcing bars are all the same size.
#    The number of fibers in the short direction of the cover patches is set to 1.
# 
proc RCsection {id h b cover coreID coverID steelID numBars barArea nfCoreY nfCoreZ nfCoverY nfCoverZ} {

   # The distance from the section z-axis to the edge of the cover concrete
   # in the positive y direction
   set coverY [expr $h/2.0]

   # The distance from the section y-axis to the edge of the cover concrete
   # in the positive z direction
   set coverZ [expr $b/2.0]

   # The negative values of the two above
   set ncoverY [expr -$coverY]
   set ncoverZ [expr -$coverZ]

   # Determine the corresponding values from the respective axes to the
   # edge of the core concrete
   set coreY [expr $coverY-$cover]
   set coreZ [expr $coverZ-$cover]
   set ncoreY [expr -$coreY]
   set ncoreZ [expr -$coreZ]

   # Define the fiber section
   section fiberSec $id -GJ 1000 {

	# Define the core patch
	patch quadr $coreID $nfCoreZ $nfCoreY $ncoreY $coreZ $ncoreY $ncoreZ $coreY $ncoreZ $coreY $coreZ
      
	# Define the four cover patches
	patch quadr $coverID 1 $nfCoverY $ncoverY $coverZ $ncoreY $coreZ $coreY $coreZ $coverY $coverZ
	patch quadr $coverID 1 $nfCoverY $ncoreY $ncoreZ $ncoverY $ncoverZ $coverY $ncoverZ $coreY $ncoreZ
	patch quadr $coverID $nfCoverZ 1 $ncoverY $coverZ $ncoverY $ncoverZ $ncoreY $ncoreZ $ncoreY $coreZ
	patch quadr $coverID $nfCoverZ 1 $coreY $coreZ $coreY $ncoreZ $coverY $ncoverZ $coverY $coverZ

	# Define the steel along constant values of y (in the z direction)
	layer straight $steelID $numBars $barArea $ncoreY $coreZ $ncoreY $ncoreZ
	layer straight $steelID $numBars $barArea $coreY $coreZ $coreY $ncoreZ

	# Determine the spacing for the remaining bars in the y direction
	set spacingY [expr ($coreY-$ncoreY)/($numBars-1)]

	# Avoid double counting bars
	set numBars [expr $numBars-2]

	# Define remaining steel in the y direction
	layer straight $steelID $numBars $barArea [expr $coreY-$spacingY] $coreZ [expr $ncoreY+$spacingY] $coreZ
	layer straight $steelID $numBars $barArea [expr $coreY-$spacingY] $ncoreZ [expr $ncoreY+$spacingY] $ncoreZ
   }

}
