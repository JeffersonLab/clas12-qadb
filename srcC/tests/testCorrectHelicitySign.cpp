#include <iostream>
#include <bitset>
#include <memory>

#include "QADB.h"

int main(int argc, char ** argv) {

  int runnum;
  int const EVNUM = 100000; // FIXME: assumption
  std::string cook;
  if(argc>2) {
    cook   = std::string(argv[1]);
    runnum = std::stoi(argv[2]);
  }
  else throw std::runtime_error("arguments must be [cook] [runnum]");

  auto qa = std::make_unique<QA::QADB>(cook);
  std::cout << qa->CorrectHelicitySign(runnum, EVNUM) << std::endl;
  return 0;
}
