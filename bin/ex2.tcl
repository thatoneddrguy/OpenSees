set pid [getPID]; 	# get process ID
set np [getNP]; 	# get no. of processes

if {$pid == 0 } {
    puts "\nRandom:"
    for {set i 1 } {$i < $np} {incr i 1} {
	recv -pid ANY msg
	puts "$msg"
    }
} else {
    send -pid 0 "Hello from $pid"
}

barrier

if {$pid == 0 } {
    puts "Ordered:"
    for {set i 1 } {$i < $np} {incr i 1} {
	recv -pid $i msg
	puts "$msg"
    }
} else {
    send -pid 0 "Hello from $pid"
}

