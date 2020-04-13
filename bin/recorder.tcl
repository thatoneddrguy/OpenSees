
proc doRecorders {motion npts dt} {
    recorder EnvelopeNode -file Node$motion.$npts.$dt -node 3 -dof 1 disp
}