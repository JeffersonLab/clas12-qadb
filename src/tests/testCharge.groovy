// for charge cross check
// - prints charge for a selection of runs, applying specified QA criteria

// imports
import clasqa.QADB // access QADB


// instantiate QADB
QADB qa = new QADB("latest")
// alternatively, specify run range to restrict QADB (may be more efficient)
//QADB qa = new QADB("latest",5000,5500);
int evnum
def defname
int chargeInt


// specify run number list
def runnumList = [
  5682,
  5683,
  5695,
  5751,
  5827
]


// specify QA criteria
qa.checkForDefect("SectorLoss")
qa.checkForDefect("MarginalOutlier")


// loop over runs
runnumList.each{ runnum ->

  // loop over files
  for(int filenum=0; filenum<=qa.getMaxBinnum(runnum); filenum++) {

    // skip non-existent bin numbers (required since old QADBs' bin numbers are multiples of 5)
    if(!qa.hasBinnum(runnum, filenum)) { continue }

    // query by file number
    qa.queryByBinnum(runnum,filenum)
    evnum = qa.getEvnumMin() // evnum needed for QA cut methods

    // accumulate charge, if QA criteria are satisfied
    if( 
      qa.pass(runnum,evnum) &&
      !( runnum==5827 && (filenum==10 || filenum==45 || filenum==50) )
    ) {
      qa.accumulateCharge()
    }

  } // end file loop

  // print this run's charge, and reset
  println "$runnum " + qa.getAccumulatedCharge()
  qa.resetAccumulatedCharge()

} // end run loop
