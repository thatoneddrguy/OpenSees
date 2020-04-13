
proc doGravityAnalysis { } {
    system BandGEN
    constraints Plain
    numberer RCM
    test NormDispIncr 1.0e-12  10 3
    algorithm Newton
    integrator LoadControl 0.1
    analysis Static

    return [analyze 10]
}

proc doDynamicAnalysis {nPts dt} {

    set tFinal [expr $nPts * $dt]
    set tCurrent [getTime]
    set ok 0


    # Perform the transient analysis
    while {$ok == 0 && $tCurrent < $tFinal} {

	set ok [analyze 1 $dt]
	
	# if the analysis fails try initial tangent iteration
	if {$ok != 0} {
	    puts "regular newton failed .. lets try an initail stiffness for this step"
	    test NormDispIncr 1.0e-12  100 0
	    algorithm ModifiedNewton -initial
	    set ok [analyze 1 $dt]
	    if {$ok == 0} {puts "that worked .. back to regular newton"}
	    test NormDispIncr 1.0e-12  10 
	    algorithm Newton
	}
    
	set tCurrent [getTime]
    }
    return $ok
}


