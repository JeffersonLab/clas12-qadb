// for charge cross check
// - prints charge for a selection of runs, applying specified QA criteria

#include <iostream>
#include <bitset>

// QADB header and namespace
#include "QADB.h"
using namespace QA;

using namespace std;

// MAIN
int main(int argc, char ** argv) {

  // instantiate QADB
  QADB * qa = new QADB("latest");
  // alternatively, specify run range to restrict QADB (may be more efficient)
  //QADB * qa = new QADB("latest",5000,5500);
  int evnum;
  string defname;
  int chargeInt;


  // specify run number list
  vector<int> runnumList;
  runnumList.push_back(5682);
  runnumList.push_back(5683);
  runnumList.push_back(5695);
  runnumList.push_back(5751);
  runnumList.push_back(5827);

  

  // specify QA criteria
  qa->CheckForDefect("SectorLoss");
  qa->CheckForDefect("MarginalOutlier");


  // loop over runs
  for(int runnum : runnumList) {

    // loop over files
    for(int filenum=0; filenum<=qa->GetMaxBinnum(runnum); filenum++) {

      // skip non-existent bin numbers (required since old QADBs' bin numbers are multiples of 5)
      if(!qa->HasBinnum(runnum, filenum)) continue;

      // query by file number
      qa->QueryByBinnum(runnum,filenum);
      evnum = qa->GetEvnumMin(); // evnum needed for QA cut methods

      // accumulate charge, if QA criteria are satisfied
      if( 
        qa->Pass(runnum,evnum) &&
        !( runnum==5827 && (filenum==10 || filenum==45 || filenum==50) )
      ) {
        qa->AccumulateCharge();
      };

    }; // end file loop

    // print this run's charge, and reset
    cout << runnum << " " << qa->GetAccumulatedCharge() << endl;
    qa->ResetAccumulatedCharge();

  }; // end run loop
  

  return 0;
}

