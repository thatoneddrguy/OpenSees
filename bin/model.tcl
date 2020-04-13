source RCsection.tcl

proc doModel {} {

    set widthX   240.0
    set widthY   240.0
    set height   144.0
    set P [expr 0.4*$height*$height]
    set p $P

    model BasicBuilder -ndm 3 -ndf 6

    # Set parameters for model geometry
    set h $height;  #144.0;       # Story height
    set by $widthX; #240.0;      # Bay width in Y-direction
    set bx $widthX; #240.0;      # Bay width in X-direction

    # Create nodes
    node  1  [expr -$bx/2] [expr  $by/2]           0
    node  2  [expr  $bx/2] [expr  $by/2]           0
    node  3  [expr  $bx/2] [expr -$by/2]           0 
    node  4  [expr -$bx/2] [expr -$by/2]           0 
    
    node  5  [expr -$bx/2] [expr  $by/2]          $h 
    node  6  [expr  $bx/2] [expr  $by/2]          $h 
    node  7  [expr  $bx/2] [expr -$by/2]          $h 
    node  8  [expr -$bx/2] [expr -$by/2]          $h 
    
    node 10  [expr -$bx/2] [expr  $by/2] [expr 2*$h]
    node 11  [expr  $bx/2] [expr  $by/2] [expr 2*$h] 
    node 12  [expr  $bx/2] [expr -$by/2] [expr 2*$h] 
    node 13  [expr -$bx/2] [expr -$by/2] [expr 2*$h] 
    
    node 15  [expr -$bx/2] [expr  $by/2] [expr 3*$h] 
    node 16  [expr  $bx/2] [expr  $by/2] [expr 3*$h] 
    node 17  [expr  $bx/2] [expr -$by/2] [expr 3*$h] 
    node 18  [expr -$bx/2] [expr -$by/2] [expr 3*$h]
    
    # Master nodes for rigid diaphragm
    #    tag X Y          Z 
    node  9  0 0         $h 
    node 14  0 0 [expr 2*$h]
    node 19  0 0 [expr 3*$h]
    
    # Set base constraints
    #   tag DX DY DZ RX RY RZ
    fix  1   1  1  1  1  1  1
    fix  2   1  1  1  1  1  1
    fix  3   1  1  1  1  1  1
    fix  4   1  1  1  1  1  1
    
    # Define rigid diaphragm multi-point constraints
    #               normalDir  master     slaves
    rigidDiaphragm     3          9     5  6  7  8
    rigidDiaphragm     3         14    10 11 12 13
    rigidDiaphragm     3         19    15 16 17 18

    set g 386.4;            # Gravitational constant
    set m [expr (4*$P)/$g]
    
    # Rotary inertia of floor about master node
    set i [expr $m*($bx*$bx+$by*$by)/12.0]
    
    # Set mass at the master nodes
    #    tag MX MY MZ RX RY RZ
    mass  9  $m $m  0  0  0 $i
    mass 14  $m $m  0  0  0 $i
    mass 19  $m $m  0  0  0 $i
    
    
    # Constraints for rigid diaphragm master nodes
    #   tag DX DY DZ RX RY RZ
    fix  9   0  0  1  1  1  0
    fix 14   0  0  1  1  1  0
    fix 19   0  0  1  1  1  0
    
    
    uniaxialMaterial Concrete01  1  -5.0 -0.005  -3.5  -0.02
    
    # Cover concrete (unconfined)
    set fc 4.0
    uniaxialMaterial Concrete01  2   -$fc -0.002   0.0 -0.006
    
    # STEEL
    # Reinforcing steel
    #                        tag fy   E     b
    uniaxialMaterial Steel01  3  60 30000 0.02
    
    # Column width
    set h 18.0
    
    # Call the procedure to generate the column section
    #          id  h  b cover core cover steel nBars barArea nfCoreY nfCoreZ nfCoverY nfCoverZ
    RCsection   1 $h $h   2.5    1     2     3     3    0.79       8       8       10       10
    
    # Concrete elastic stiffness
    set E [expr 57000.0*sqrt($fc*1000)/1000];
    
    # Column torsional stiffness
    set GJ 1.0e10;

    # Linear elastic torsion for the column
    uniaxialMaterial Elastic 10 $GJ
    
    # Attach torsion to the RC column section
    #                 tag uniTag uniCode       secTag
    section Aggregator 2    10      T    -section 1
    set colSec 2

    # Define column elements
    # ----------------------

    #set PDelta "ON"
    set PDelta "OFF"

    # Geometric transformation for columns
    if {$PDelta == "ON"} {
	#                           tag  vecxz
	geomTransf LinearWithPDelta  1   1 0 0
    } else {
	geomTransf Linear  1   1 0 0
    }
    
    # Number of column integration points (sections)
    set np 4

    # Create the nonlinear column elements
    #                           tag ndI ndJ nPts   secID  transf
    element nonlinearBeamColumn  1   1   5   $np  $colSec    1
    element nonlinearBeamColumn  2   2   6   $np  $colSec    1
    element nonlinearBeamColumn  3   3   7   $np  $colSec    1
    element nonlinearBeamColumn  4   4   8   $np  $colSec    1
    
    element nonlinearBeamColumn  5   5  10   $np  $colSec    1
    element nonlinearBeamColumn  6   6  11   $np  $colSec    1
    element nonlinearBeamColumn  7   7  12   $np  $colSec    1
    element nonlinearBeamColumn  8   8  13   $np  $colSec    1

    element nonlinearBeamColumn  9  10  15   $np  $colSec    1
    element nonlinearBeamColumn 10  11  16   $np  $colSec    1
    element nonlinearBeamColumn 11  12  17   $np  $colSec    1
    element nonlinearBeamColumn 12  13  18   $np  $colSec    1
    
    # Define beam elements
    # --------------------
    
    # Define material properties for elastic beams
    # Using beam depth of 24 and width of 18
    # --------------------------------------------
    set Abeam [expr 18*24];
    # "Cracked" second moments of area
    set Ibeamzz [expr 0.5*1.0/12*18*pow(24,3)];
    set Ibeamyy [expr 0.5*1.0/12*24*pow(18,3)];
    
    # Define elastic section for beams
    #               tag  E    A      Iz       Iy     G   J
    section Elastic  3  $E $Abeam $Ibeamzz $Ibeamyy $GJ 1.0
    set beamSec 3
    
    # Geometric transformation for beams
    #                tag  vecxz
    geomTransf Linear 2   1 1 0
    
    # Number of beam integration points (sections)
    set np 3
    
    # Create the beam elements
    #                           tag ndI ndJ nPts    secID   transf
    element nonlinearBeamColumn  13  5   6   $np  $beamSec     2
    element nonlinearBeamColumn  14  6   7   $np  $beamSec     2
    element nonlinearBeamColumn  15  7   8   $np  $beamSec     2
    element nonlinearBeamColumn  16  8   5   $np  $beamSec     2
    
    element nonlinearBeamColumn  17 10  11   $np  $beamSec     2
    element nonlinearBeamColumn  18 11  12   $np  $beamSec     2
    element nonlinearBeamColumn  19 12  13   $np  $beamSec     2
    element nonlinearBeamColumn  20 13  10   $np  $beamSec     2
    
    element nonlinearBeamColumn  21 15  16   $np  $beamSec     2
    element nonlinearBeamColumn  22 16  17   $np  $beamSec     2
    element nonlinearBeamColumn  23 17  18   $np  $beamSec     2
    element nonlinearBeamColumn  24 18  15   $np  $beamSec     2

    pattern Plain 1 Constant {
	foreach node {5 6 7 8  10 11 12 13  15 16 17 18} {
	    load $node 0.0 0.0 -$p 0.0 0.0 0.0
	}
    }	

}