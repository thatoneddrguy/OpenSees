set np [getNP]
set pid [getPID]
set count 0

source model.tcl
source analysis.tcl
source recorder.tcl

set tStart [clock seconds]

if {$pid == 0} {

    #
    # Coordinator
    #

    set recordsFile [open motionList r]
    set lines [split [read $recordsFile] \n]
    set numLines [llength $lines]
    foreach line $lines {
	recv -pid ANY pidWorker
	send -pid $pidWorker $line
    }
    
    for {set i 1} {$i < $np} {incr i 1} {
	send -pid $i "DONE"
    }

} else {

    #
    # Worker
    #
    
    set done NOT_DONE;
    while {$done != "DONE"} {
	send -pid 0 $pid
	recv -pid 0 line
	set record [lindex $line 0]

	if {$record == "DONE"} {
	    break;
	}
	
	set npts   [lindex $line 1]
	set dt     [lindex $line 2]
	
	doModel;
	
	doGravityAnalysis;
	
	loadConst  -time 0.0

	set accelSeries "Path -filePath $record -dt $dt -factor 386.4"
	pattern UniformExcitation  2   1  -accel $accelSeries
	
	doRecorders $record $npts $dt
	set ok [doDynamicAnalysis $npts $dt]
	wipe
    }
}
 
set tFinish [clock seconds]
barrier
puts "Duration Process $pid [expr $tFinish - $tStart]"