// dump pi+ BSA from specified timeline HIPO file

import org.jlab.groot.data.TDirectory
import org.jlab.groot.data.GraphErrors

inFile = '/u/group/clas/www/clas12mon/html/hipo/rga/pass1/qa/rga_spring19/beam_spin_asymmetry.hipo'

def inTdir = new TDirectory()
inTdir.readFile(inFile)
def asymVsRun = inTdir.getObject('/timelines/helic_asym_pip_timeline')

def outFile = new File("bsa.dat")
def outFileW = outFile.newWriter(false)

asymVsRun.getDataSize(0).times{ i ->
  outFileW << [
    asymVsRun.getDataX(i),  // run number
    asymVsRun.getDataY(i),  // asymmetry
    asymVsRun.getDataEY(i), // asymmetry error
  ].join(' ') << '\n'
}

outFileW.close()
