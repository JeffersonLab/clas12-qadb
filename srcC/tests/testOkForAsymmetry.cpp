// test equivelance of `OkForAsymmetry` and the preferred user method

#include <iostream>
#include <cassert>
#include "../include/QADB.h"

bool const debug = false;

// MAIN
int main(int argc, char ** argv) {

  // specify run numbers to test
  std::set<int> test_runnums = {
    // RGA Fa18 inbending
    5032, 5036, 5038, 5039, 5040, 5041, 5043, 5045,
    5046, 5047, 5051, 5052, 5053, 5116, 5117, 5119,
    5120, 5124, 5125, 5126, 5127, 5128, 5129, 5130,
    5137, 5138, 5139, 5153, 5158, 5159, 5160, 5162,
    5163, 5164, 5165, 5166, 5167, 5168, 5169, 5180,
    5181, 5182, 5183, 5189, 5190, 5191, 5193, 5194,
    5195, 5196, 5197, 5198, 5199, 5200, 5201, 5202,
    5203, 5204, 5205, 5206, 5208, 5211, 5212, 5215,
    5216, 5219, 5220, 5221, 5222, 5223, 5225, 5229,
    5230, 5231, 5232, 5233, 5234, 5235, 5237, 5238,
    5239, 5247, 5248, 5249, 5250, 5252, 5253, 5257,
    5258, 5259, 5261, 5262, 5300, 5301, 5302, 5303,
    5304, 5305, 5306, 5307, 5310, 5311, 5315, 5316,
    5317, 5318, 5319, 5320, 5323, 5324, 5325, 5333,
    5334, 5335, 5336, 5339, 5340, 5341, 5342, 5343,
    5344, 5345, 5346, 5347, 5349, 5351, 5354, 5355,
    5356, 5357, 5358, 5359, 5360, 5361, 5362, 5366,
    5367, 5368, 5369, 5370, 5371, 5372, 5373, 5374,
    5375, 5376, 5377, 5378, 5379, 5380, 5381, 5382,
    5383, 5386, 5390, 5391, 5392, 5393, 5394, 5398,
    5399, 5400, 5401, 5402, 5403, 5404, 5406, 5407,
    5414, 5415, 5416, 5417, 5418, 5419
  };

  // instantiate two QADBs
  std::cout << "Loading QADBs..." << std::endl;
  QA::QADB * qa = new QA::QADB();             // will use the preferred method
  QA::QADB * qa_deprecated = new QA::QADB();  // will use `OkForAsymmetry`, which is deprecated
  std::cout << "...done" << std::endl;

  //////////////////////////////////////////////////////////////////////////////////
  // the preferred method requires the user to choose the bits, an runs for which
  // the `Misc` defect bit should be ignored
  // - these choices match the criteria of `OkForAsymmetry`
  // - in the event loop, call `qa->Pass(runnum,evnum)`
  qa->CheckForDefect("TotalOutlier");
  qa->CheckForDefect("TerminalOutlier");
  qa->CheckForDefect("MarginalOutlier");
  qa->CheckForDefect("SectorLoss");
  qa->CheckForDefect("Misc");
  for(int run : { // list of runs with `Misc` defect that are allowed
      5046, 5047, 5051, 5128, 5129, 5130, 5158, 5159,
      5160, 5163, 5165, 5166, 5167, 5168, 5169, 5180,
      5181, 5182, 5183, 5400, 5448, 5495, 5496, 5505,
      5567, 5610, 5617, 5621, 5623})
    qa->AllowMiscBit(run);
  //////////////////////////////////////////////////////////////////////////////////

  // loop over test runs
  for(auto const& runnum : test_runnums) {
    std::cout << "test run " << runnum << std::endl;

    // loop over QA bins for this run
    auto max_bin_num = qa->GetMaxBinnum(runnum);
    if(debug) std::cout << "debug: this run has max bin number = " << max_bin_num << std::endl;
    for(int binnum = 0; binnum <= max_bin_num; binnum++) {

      // skip non-existent bin numbers (required since old QADBs' bin numbers are multiples of 5)
      if(!qa->HasBinnum(runnum, binnum)) continue;
      if(debug) std::cout << "debug: test binnum " << binnum << std::endl;

      // we need an event number to query the QADBs
      qa->QueryByBinnum(runnum, binnum);
      auto evnum = (qa->GetEvnumMin() + qa->GetEvnumMax()) / 2;

      // test equivelance of `OkForAsymmetry` and the preferred user method (`Pass`)
      auto pass_qa_preferred  = qa->Pass(runnum, evnum);
      auto pass_qa_deprecated = qa_deprecated->OkForAsymmetry(runnum, evnum);
      if(debug) std::cout << "debug: " << pass_qa_preferred << " =?= " << pass_qa_deprecated << std::endl;
      assert(( pass_qa_preferred == pass_qa_deprecated ));
    }

    std::cout << "=> test passed." << std::endl;
  }

  std::cout << "all test passed." << std::endl;
  return 0;
}

