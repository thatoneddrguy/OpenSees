set np [getNP]
set pid [getPID]
set count 0

source model.tcl
source analysis.tcl
source recorder.tcl

set tStart [clock seconds]

set recordsFile [open motionList r]

foreach line [split [read $recordsFile] \n] {
    if {[expr $count % $np] == $pid} {

	doModel

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
}

set tFinish [clock seconds]
barrier
puts "Duration Process $pid [expr $tFinish - $tStart]"
