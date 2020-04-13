set pid [getPID]
set np [getNP]
puts "Hello World Process: $pid"
if {$np != 2} {
    puts "ONLY WORKS FOR 2 PROCESSORS"
    exit
}

model BasicBuilder -ndm 2 -ndf 2

uniaxialMaterial Elastic 1 3000

if {$pid == 0} {
    node 1   0.0  0.0
    node 4  72.0 96.0

    fix 1 1 1 

    element truss 1 1 4 10.0 1

    pattern Plain 1 "Linear" {
	load 4 100 -50
    }

} else { 
    node 2 144.0  0.0
    node 3 168.0  0.0
    node 4  72.0 96.0

    fix 2 1 1
    fix 3 1 1

    element truss 2 2 4 5.0 1
    element truss 3 3 4 5.0 1
}

# ------------------------------
# Create the recorders
# ------------------------------

recorder Node -file node4.out.$pid -time -node 4 -dof 1 2 disp

# ------------------------------
# Start of analysis generation
# ------------------------------

# Create the system of equation, a SPD using a band storage scheme
system Mumps
numberer ParallelPlain
constraints Plain
integrator LoadControl 0.1
test NormDispIncr 1.0e-12 3 
algorithm Newton
analysis Static 

analyze 10

print node 4
