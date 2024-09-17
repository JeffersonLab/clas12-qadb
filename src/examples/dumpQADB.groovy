// dump QADB data for a specified run; this demonstrates access to the various
// data stored in QADB
// - this program does not require a HIPO file or clas12root; it only loops
//   through the QADB itself, performing lookup by bin number
// - you can specify a run number as an argument

// imports
import clasqa.QADB // access QADB

// print separator
def sep = { s,n -> n.times{print s}; println ""; }


// specify run number
int runnum = 5160
if(args.length>=1) runnum = args[0].toInteger()
println "dump QADB for RUN NUMBER $runnum"


// instantiate QADB
QADB qa = new QADB()
// alternatively, specify run range to restrict QADB (may be more efficient)
//QADB qa = new QADB(5000,5500);


// loop through QA bins
int evnum
for(int binnum=0; binnum<=qa.getMaxBinnum(runnum); binnum++) {
  // skip non-existent bin numbers (required since old QADBs' bin numbers are multiples of 5)
  if(!qa.hasBinnum(runnum, binnum)) { continue }
  sep("=",50)
  println "BIN NUMBER $binnum"

  // perform the lookup, by binnum
  if(qa.queryByBinnum(runnum,binnum)) {

    // we need an event number within this QA bin, to pass to QA criteria
    // checking methods, such as Golden; no additional Query will be called
    evnum = qa.getEvnumMin();

    // print whether this bin passes some QA cuts
    if(qa.golden(runnum,evnum)) {
      println "- GOLDEN BIN!"
    } else {
      println "- not golden: bin has defects"
      print (qa.OkForAsymmetry(runnum,evnum) ? "- OK" : "- NOT OK")
      println " for asymmetry analysis"
    }

    // print event number range
    sep("-",40)
    println "- event number range = " +
      qa.getEvnumMin() + " to " + qa.getEvnumMax()

    // print charge (max accumulated charge minus min accumulated charge)
    printf("- charge (max-min) = %.3f nC\n",qa.getCharge())

    // print defect bits (OR over all sectors)
    sep("-",40)
    println "- defect = " + qa.getDefect() + 
      " = " + qa.util.printBinary(qa.getDefect(),16)
    if(qa.hasDefect("TotalOutlier"))    println "   - TotalOutlier defect"
    if(qa.hasDefect("TerminalOutlier")) println "   - TerminalOutlier defect"
    if(qa.hasDefect("MarginalOutlier")) println "   - MarginalOutlier defect"
    if(qa.hasDefect("SectorLoss"))      println "   - SectorLoss defect"
    if(qa.hasDefect("LowLiveTime"))     println "   - LowLiveTime defect"
    if(qa.hasDefect("Misc"))            println "   - Misc defect"
    if(qa.hasDefect("TotalOutlierFT"))    println "   - TotalOutlierFT defect"
    if(qa.hasDefect("TerminalOutlierFT")) println "   - TerminalOutlierFT defect"
    if(qa.hasDefect("MarginalOutlierFT")) println "   - MarginalOutlierFT defect"
    if(qa.hasDefect("LossFT"))            println "   - LossFT defect"

    // print defect bits for each sector
    sep(".",40)
    (1..6).each{ s ->
      println "  sector $s defect = " +
        qa.getDefect(s) +
        " = " + qa.util.printBinary(qa.getDefect(s),16)
    }

    // if there is a sector loss, print which sectors
    (1..6).each{ s ->
      if(qa.hasDefect("SectorLoss",s)) println "    -> sector $s loss"
    }

    // print comment
    sep(".",40)
    println "comment = \"" + qa.getComment() + "\""
  }
}
sep("=",50)
