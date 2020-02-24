# Convert an OpenSees(Tcl) script to OpenSeesPy
#  Author: Michael H. Scott, michael.scott@oregonstate.edu
#  Date: June 2018
#
# Usage in a Python script
#   exec(open('toOpenSeesPy.py').read())
#   ...
#   outfile = open('model.py','w')
#   toOpenSeesPy('model.tcl',outfile)
#   toOpenSeesPy('anotherScript.tcl',outfile)
#   ...
#   outfile.close()
#
# - Assumes the OpenSees(.tcl) file defines the model line by line
#   without any loops, conditionals, variables, expressions, etc.
#   This is the format generated when you export a model from
#   OpenSees Navigator and perhaps from other front-ends to OpenSees.
#
# - The calling Python script should open and close the file stream for
#   for writing the converted .py file.  This allows you to call the
#   converter on multiple Tcl files in sequence, as shown above. 
#
# - If your OpenSees(.tcl) file uses any loops, conditionals, variables,
#   expressions, etc., you might be better off to port your OpenSees
#   model from Tcl to Python manually, or you can look in to Tkinter.
#
# - You may have some luck making your own "middleware" to convert your
#   OpenSees(.tcl) script to a model defined line by line by inserting
#   output statements in your loops and other constructs.  Even though
#   this won't get you to 100% conversion and you'll still have some
#   conversions to make here and there, it'll get you pretty far.
#
#   set output [open lineByLine.tcl w]
#   ...
#   for {set i 1} {$i <= $N} {incr i} {
#     element truss $i ...
#     puts $output "element truss $i ..."
#   }
#   ...
#   close $output
#
#   Then, in your Python script, call toOpenSeesPy with lineByLine.tcl as
#   the input file.
#
# - If you see any improvements to make to this toOpenSeesPy function,
#   please submit a pull request at OpenSees/OpenSees on github


# Helper function to deterine if a variable is a floating point value or not
#
def isfloat(value):  # should probably combine this with exprFlag check
    try:
        float(value)
        return True
    except ValueError:
        return False

# Helper function to process specific parts of conversion
#
def convertLine(line, type='standard'):
    # if(type == 'comment'):  # for in-line comments; comments spanning an entire line already handled
        # line = line
    if(type == 'expr'):
        line = line
    elif(type == 'set'):
        line = line
    else:  # standard command
        line = line
    return line

# Function that does the conversion
#
def toOpenSeesPy():
    filename = input("Enter filename (no extension): ")
    outfile = open(filename + '.py', 'w')
    infile = open(filename + '.tcl', 'r')
    outfile.write('from openseespy.opensees import *\n')
    outfile.write('import math\n')  # for exponents
    
    for line in infile:
<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
        #if ";" in line:
        line = line.replace(";", "")

        exprFlag = False
        if "expr" in line:
            line = line.replace("[expr", "")
            line = line.replace("]", "")
            exprFlag = True
<<<<<<< Updated upstream

        #if "$" in line:  # '$' denotes variables in TCL
        line = line.replace("$", "")
=======
>>>>>>> Stashed changes
        
        # if "#" in line:
            # line = convertLine(line, 'comment')

        setFlag = False
        quotesFlag = False
        if "set" in line:
            line = line.replace("set", "")
            setFlag = True
            if "\"" in line:  # don't add single quotes if double quotes already found
                quotesFlag = True

<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
>>>>>>> Stashed changes
        info = line.split()
        N = len(info)

        # Ignore a close brace
        if N > 0 and info[0][0] == '}':
            continue
	# Echo a comment line
        # if N < 2 or info[0][0] == '#':
        if N < 2 or info[0][0] == '#':  # might want to consider using an 'in' check to process comments, but this works for now...
            if 'wipe' in line:
                line = line.replace("wipe", "wipe()")
            elif 'initialize' in line:
                line = line.replace("initialize", "initialize()")
            outfile.write(line)        
            continue
	  
	# Needs to be a special case for now due to beam integration
        if info[1] == 'forceBeamColumn' or info[1] == 'dispBeamColumn':
            secTag = info[6]
            eleTag = info[2]
            Np = info[5]
            Np = 3
            outfile.write('beamIntegration(\'Legendre\',%s,%s,%s)\n' % (eleTag,secTag,Np))
            outfile.write('element(\'%s\',%s,%s,%s,%s,%s)\n' % (info[1],eleTag,info[3],info[4],info[7],eleTag))
            continue

	# Change print to printModel
        if info[0] == 'print':
            info[0] = 'printModel'

        # For everything else, have to do the first one before loop because of the commas
        if setFlag == True:
            info[0] = info[0] + " = "
            if isfloat(info[1]) or exprFlag == True or quotesFlag == True:  # no quotes around expressions or existing double quotes
                outfile.write('%s%s' % (info[0],info[1]))
            else:
                outfile.write('%s\'%s\'' % (info[0],info[1]))
        else:
<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
            outfile.write('%s(\'%s\'' % (info[0],info[1]))
        # Now loop through the rest with preceding commas
=======
>>>>>>> Stashed changes
            if isfloat(info[1]) or exprFlag == True:     
                outfile.write('%s(%s' % (info[0],info[1]))     
            else:
                outfile.write('%s(\'%s\'' % (info[0],info[1]))
            
<<<<<<< Updated upstream
		  
	# Now loop through the rest with preceding commas
=======
	# Now loop through the rest with preceding commas
>>>>>>> Stashed changes
>>>>>>> Stashed changes
        writeClose = True
        commentFlag = False
        for i in range (2,N):
<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
=======
            varFlag = False
>>>>>>> Stashed changes
            if info[i] == "#":
                if setFlag == False:
                    info[i] = ") " + info[i]
                else:
                    info[i] = " " + info[i]
                commentFlag = True
<<<<<<< Updated upstream
=======
            if "$" in info[i]:
                varFlag = True
                info[i] = info[i].replace("$", "")
>>>>>>> Stashed changes
>>>>>>> Stashed changes
            if info[i] == '{':
                writeClose = True
                break
            if info[i] == '}':
                writeClose = False                
                break
            if commentFlag == True or setFlag == True:
                outfile.write(info[i] + " ")
            else:
<<<<<<< Updated upstream
                if isfloat(info[i]) or exprFlag == True:
                    outfile.write(',%s' % info[i])
                else:
                    outfile.write(',\'%s\'' % info[i])
=======
<<<<<<< Updated upstream
                outfile.write(',\'%s\'' % info[i])
=======
                if isfloat(info[i]) or exprFlag == True or varFlag == True:
                    outfile.write(',%s' % info[i])
                else:
                    outfile.write(',\'%s\'' % info[i])
>>>>>>> Stashed changes
>>>>>>> Stashed changes
        if writeClose:
            if commentFlag == False and setFlag == False:
                outfile.write(')\n')
            else:
                outfile.write('\n')
    infile.close()
    outfile.close()


if __name__ == '__main__':
  toOpenSeesPy()
