// dump QADB data for a specified run; this is for QADB validation and testing,
// but may still be useful as an example; see dumpQADB.cpp for a more
// user-friendly example
// - this program does not require a HIPO file or clas12root; it only loops
//   through the QADB itself, performing lookup by bin number

// imports
import clasqa.QADB // access QADB

int maxbit = 5; // max defect bit number

// print separator
def sep = { s,n -> n.times{print s}; println ""; }

// print error
def err = { s -> System.err << "ERROR: $s\n" }


// parse arguments
String runlist
String cook
if(args.length>=2) {
  runlist = args[0]
  cook    = args[1]
} else {
  throw new Exception("invalid arguments")
}

// instantiate QADB
QADB qa = new QADB(cook)

// loop over runs
runlistFile = new File(runlist)
if(!(runlistFile.exists())) {
  throw new Exception("runlist does not exist")
}
runlistFile.eachLine { runnumStr ->
  def runnum = runnumStr.toInteger()

  // loop through bins
  int evnum
  def defname
  int chargeInt
  for(int binnum=0; binnum<=qa.getMaxBinnum(runnum); binnum++) {
    // skip non-existent bin numbers (required since old QADBs' bin numbers are multiples of 5)
    if(!qa.hasBinnum(runnum, binnum)) { continue }
    sep("=",50)

    //err("test error print")

    // query by bin number
    qa.queryByBinnum(runnum,binnum)
    evnum = qa.getEvnumMin() // evnum needed for QA cut methods

    // check run and bin number accessors: make sure that they
    // are equal to what we asked for
    println "- run,bin,evnum"
    println qa.getRunnum() + " " + runnum
    if(qa.getRunnum() != runnum) err("QADB::getRunnum != runnum");
    println qa.getBinnum() + " " + binnum
    if(qa.getBinnum() != binnum) err("QADB::GetBinnum != binnum");

    // check event number: report an error if evnum min>=max
    println qa.getEvnumMin() + " " + qa.getEvnumMax()
    if(qa.getEvnumMin() >= qa.getEvnumMax()) {
      if(binnum != 0 && binnum != qa.getMaxBinnum(runnum)) { // don't bother, if not first or last bin
        err("GetEvnumMin() >= GetEvnumMax()")
      }
    }

    // print charge (convert to pC and truncate, for easier comparison)
    // println "- charge"
    // println ((int)(1000*qa.getCharge())) // FIXME: too many warnings
    qa.accumulateCharge();

    // print comment
    println "comment: \"" + qa.getComment() + "\""


    // print overall defect info
    println "- defect"
    println qa.getDefect()
    for(int sec=1; sec<=6; sec++) 
      print " " + qa.getDefect(sec); println ""

    // print defect bit info
    for(int bit=0; bit<=maxbit; bit++) {
      // translate bit number to name; check if QADB::Bit returns correct bit
      switch(bit) {
        case 0: defname="TotalOutlier"; break;
        case 1: defname="TerminalOutlier"; break;
        case 2: defname="MarginalOutlier"; break;
        case 3: defname="SectorLoss"; break;
        case 4: defname="LowLiveTime"; break;
        case 5: defname="Misc"; break;
      };
      if(qa.Bit(defname) != bit) err("QADB::Bit problem");
      println qa.Bit(defname) + " $bit $defname"
      // print defect info
      println (qa.hasDefect(defname)?1:0)
      for(int sec=1; sec<=6; sec++) 
        print " " + (qa.hasDefect(defname,sec)?1:0); println ""
      // print bit masking
      qa.checkForDefect(defname);
      println qa.getMask() + " " + (qa.pass(runnum,evnum)?1:0)
      qa.checkForDefect(defname,false);
    };

    // print QA cuts (see above for custom cut check with mask)
    // println "- cuts"
    // println (qa.golden(runnum,evnum)?1:0) // disabled, because of verbose deprecation warnings
    // println (qa.OkForAsymmetry(runnum,evnum)?1:0)
  }
  sep("=",50);

  // print accumulated charge
  println "- charge, max binnum"
  println ((int)(1000*qa.getAccumulatedCharge()))

  // print max bin number
  println qa.getMaxBinnum(runnum)

  // reset charge acummulator for the next run
  qa.resetAccumulatedCharge()

  sep("=",50);

}
