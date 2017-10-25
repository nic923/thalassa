#!/usr/bin/python2
"""
BATCH TOLERANCE SCRIPT FOR THALASSA
Launches batch propagations in which the tolerance parameter in input.txt
is progressively varied in the interval [tolmin,tolmax], with logarithmic
spacing. The output of each propagation is saved to a separate directory.
The script also compiles a statistics file for the batch propagations.
"""

import sys
import os
import subprocess
import numpy as np

def generateTolVec(tolMax,tolMin,ntol):
  # Generates the tolerance vector, logarithmically spaced from 'tolmax' to
  # tolmin.
  tolVec = np.logspace(tolMax,tolMin,num=ntol)
  return tolVec

def modifyInput(inpPath,lineN,tol,outPath):
  # Modifies the line 'lineN' (counted from zero) in the input file to assign
  # the specified tolerance 'tol'.
  # TODO: Use regex to find the lines to modify.
  
  # Read contents of input file
  inpFile = open(inpPath,'rU')
  lines   = inpFile.readlines()
  inpFile.close
  
  # Change tolerance
  lines[lineN[0]] = lines[lineN[0]][:11] + '%.15E\n' % (tol)
  lines[lineN[1]] = lines[lineN[1]][:5]  + outPath + '/\n'
  
  # Write contents to input file
  inpFile = open(inpPath,'w')
  inpFile.writelines(lines)
  inpFile.close


def readStats(statPath):
  # Read integration statistics from Thalassa's output file.
  
  statFile = open(statPath,'rU')
  stats = np.loadtxt(statPath)
  statFile.close()
  return stats

def main():
  args = sys.argv[1:]
  
  if not args:
    print 'Usage: ./batch_tol.py MASTER_DIRECTORY'
    sys.exit(1)

  tolVec  = generateTolVec(-5.,-10.,6)
  masterPath = os.path.abspath(args[0])
  
  # Initializations
  rep_time = 3
  calls = np.zeros(rep_time)
  steps = np.zeros(rep_time)
  cpuT  = np.zeros(rep_time)

  # Open summary file and write header
  summFile = open(os.path.join(masterPath,'summary.csv'),'w')
  summFile.write('# THALASSA - BATCH PROPAGATION SUMMARY\n')
  summFile.write('# Legend:\n# Tolerance,Calls,Steps,Average CPU Time [s]\n# ' + 80*'=' + '\n')
  for tol in tolVec:
    subDir = '%.2g' % np.log10(tol)
    outPath = os.path.join(masterPath,'tol' + subDir)
    modifyInput('./in/input.txt',[31,43],tol,outPath)

    for i in range(0,rep_time):
      # LAUNCH PROPAGATION (this could be parallelised somehow)
      subprocess.call('./thalassa.x')

      # Save statistics (esp. CPU time) for this run and unpack them
      stats = readStats(os.path.join(outPath,'stats.dat'))
      calls[i] = stats[0]; steps[i] = stats[1]; cpuT[i] = stats[2]
    
    cpuTAvg = np.average(cpuT)

    # Write results to summary file
    summLine = ('%.6g,' + 2*'%i,' + '%.6g') % (tol,calls[-1],steps[-1],cpuTAvg) + '\n'
    summFile.write(summLine)

  summFile.close()


if __name__ == '__main__':
  main()