set np [getNP]
set pid [getPID]
set count 0

source model.tcl
source analysis.tcl
source recorder.tcl

set tStart [clock seconds]

set recordsFile [open motionList r]

set factor 0.5
set lines [split [read $recordsFile] \n]
set numLines [llength $lines]

if {$pid == 0} {
    set fileShared [open sharedFile w]
#    puts $fileShared [expr $numLines * $factor]
    puts $fileShared "NOT_REACHED"
    close $fileShared
}

set finishID -1;

foreach line $lines {
    if {[expr $count % $np] == $pid || $finishID == $pid} {
	
	puts "$pid $count $finishID"

	doModel;
	
	doGravityAnalysis;
	
	loadConst  -time 0.0
	set record [lindex $line 0]
	set npts   [lindex $line 1]
	set dt     [lindex $line 2]
	set accelSeries "Path -filePath $record -dt $dt -factor 386.4"
	pattern UniformExcitation  2   1  -accel $accelSeries
	
	doRecorders $record $npts $dt
	set ok [doDynamicAnalysis $npts $dt]
	wipe
    }
    incr count 1

    if {$count > [expr $numLines * $factor] && $finishID == -1} {
	set fileShared [open sharedFile RDWR]
	set data [split [read $fileShared] \n]
	if {[lindex $data 0] == "NOT_REACHED"} {
	    seek $fileShared 0
	    puts $fileShared "REACHED BY $pid"
	    close $fileShared
	    set finishID $pid
	} else {
	    close $fileShared
	    break;
	}
    }
}

set tFinish [clock seconds]
barrier
puts "Duration Process $pid [expr $tFinish - $tStart]"