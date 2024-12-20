// dump QADB data for a specified run; this is for QADB validation and testing,
// but may still be useful as an example; see dumpQADB.cpp for a more
// user-friendly example
// - this program does not require a HIPO file or clas12root; it only loops
//   through the QADB itself, performing lookup by file number
// - you can specify a run number as an argument

// imports
import clasqa.QADB // access QADB

int maxbit = 5; // max defect bit number

// print separator
def sep = { s,n -> n.times{print s}; println ""; }

// print error
def err = { s -> System.err << "ERROR: $s\n" }


// specify run number
int runnum = 5160
String cook = "latest"
if(args.length>=1) runnum = args[0].toInteger()
if(args.length>=2) cook = args[1]
println "test QADB for RUN NUMBER $runnum COOK $cook"


// instantiate QADB
QADB qa = new QADB(cook)
// alternatively, specify run range to restrict QADB (may be more efficient)
//QADB qa = new QADB(cook,5000,5500);


// loop through files
int evnum
def defname
int chargeInt
for(int filenum=0; filenum<=qa.getMaxBinnum(runnum); filenum++) {
  // skip non-existent bin numbers (required since old QADBs' bin numbers are multiples of 5)
  if(!qa.hasBinnum(runnum, filenum)) { continue }
  sep("=",50)

  //err("test error print")

  // query by file number
  qa.queryByBinnum(runnum,filenum)
  evnum = qa.getEvnumMin() // evnum needed for QA cut methods

  // check run and file number accessors: make sure that they
  // are equal to what we asked for
  println "- run,file,evnum"
  println qa.getRunnum() + " " + runnum
  if(qa.getRunnum() != runnum) err("QADB::getRunnum != runnum");
  println qa.getBinnum() + " " + filenum
  if(qa.getBinnum() != filenum) err("QADB::GetBinnum != filenum");

  // check event number: report an error if evnum min>=max
  println qa.getEvnumMin() + " " + qa.getEvnumMax()
  if(qa.getEvnumMin() >= qa.getEvnumMax())
    err("GetEvnumMin() >= GetEvnumMax()");

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
println "- charge, max filenum"
println ((int)(1000*qa.getAccumulatedCharge()))

// print max file number
println qa.getMaxBinnum(runnum)

sep("=",50);
