#ifndef QADB_H_
#define QADB_H_

#include "rapidjson/document.h"
#include "rapidjson/filereadstream.h"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <map>
#include <vector>
#include <set>
#include <algorithm>

namespace QA {

  int const MISC_BIT       = 5;  // FIXME: should be obtained from `defect_definitions.json`
  int const BSAWRONG_BIT   = 10;
  int const BSAUNKNOWN_BIT = 11;

  class QADB {
    private:

      void DeprecationGuidance() {
        std::cerr << R"(| INSTEAD: use the general methods
|   - use `QADB::CheckForDefect` to choose which defects you want
|     to filter out, then use `QADB::Pass` on each event
|   - for runs with the `Misc` defect bit (bit 5) assigned:
|     - use `QADB::GetComment` to check the QADB comment, which
|       explains why this bit was assigned for the run
|     - use `QADB::AllowMiscBit` to ignore the `Misc` bit for certain
|       runs that you want to allow in your analysis (`OkForAsymmetry`
|       internally does this for a specific list of RG-A runs)
)";
      }

      void WarningBanner(bool first) {
        if(first)
          std::cerr << "\nWARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING\n|\n";
        else
          std::cerr << "|\nWARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING\n\n";
      }

    public:

      //.................
      // constructor
      //`````````````````
      //arguments:
      // - cook: which cook (pass) to use:
      //   - 'latest': just use the latest available one
      //   - 'pass1': use pass 1
      //   - 'pass2': use pass 2
      // - runnumMin and runnumMax: if both are negative (default), then the
      //   entire QADB will be read; you can restrict to a specific range of
      //   runs to limit QADB, which may be more effecient
      // - verbose: if true, print (a lot) more information
      inline QADB(std::string const& cook, int runnumMin_=-1, int runnumMax=-1, bool verbose_=false);

      inline QADB(int runnumMin_=-1, int runnumMax=-1, bool verbose_=false) {
        std::cerr << R"(| ERROR: the QADB constructor now requires you to specify the cook as the first argument
|   - use "latest" to use the latest available cook's QADB
|     - see the QADB documentation for the list of available QADBs,
|       https://github.com/JeffersonLab/clas12-qadb/blob/main/README.md
|     - the latest cook may not yet have a QADB
|   - use "pass1" to restrict to Pass 1 cooks
|     - older data may have less QA defect bits, or other issues
|   - use "pass2" to restrict to Pass 2 data, etc.
)";
        throw std::runtime_error("please specify the cook");
      }

      //...............................
      // golden QA cut
      //```````````````````````````````
      // returns false if the event is in a file with *any* defect
      inline bool Golden(int runnum_, int evnum_) {
        if(!dep_warned_Golden) {
          dep_warned_Golden = true;
          WarningBanner(true);
          std::cerr << R"(| WARNING: `QADB::Golden` is DEPRECATED
|   - you may still use this method, but since many more defect bits have been
|     defined, and "Golden" means "no defect bits set", you may find that
|     requiring your data to be "Golden" is too strict for your analysis
|     - NOTE: QADBs for Run Groups A, B, K, and M for Pass1 data only use
|       defect bits 0 to 9, whereas newer QADBs define many more bits
|   - in some cases, none of the data are "Golden"
)";
          DeprecationGuidance();
          WarningBanner(false);
        }
        bool foundHere = this->Query(runnum_,evnum_);
        return foundHere && defect==0;
      };


      //.....................................
      // QA for spin asymmetry analysis
      //`````````````````````````````````````
      // if true, this event is good for a spin asymmetry analysis
      inline bool OkForAsymmetry(int runnum_, int evnum_);


      //...............................
      // user-defined custom QA cuts
      //```````````````````````````````
      // first set which defect bits you want to filter out; by default
      // none are set; the variable `mask` will be applied as a mask
      // on the defect bits
      inline void SetMaskBit(const char * defectName, bool state=true);
      inline void CheckForDefect(const char * defectName, bool state=true); // alias
      // access the custom mask, if you want to double-check it
      inline int GetMask() { return mask; };
      // then call this method to check your custom QA cut for a given
      // run number and event number
      inline bool Pass(int runnum_, int evnum_);

      // ignore certain runs for the `Misc` bit assignment
      inline void AllowMiscBit(int runnum_) {
        allowMiscBitList.insert(runnum_);
      }


      //.................
      // accessors
      //`````````````````
      // --- access this file's info
      inline int GetRunnum() { return found ? runnum : -1; };
      inline int GetFilenum() { return found ? filenum : -1; };
      inline int GetBinnum() { return GetFilenum(); }; // alias for `GetFilenum`
      inline std::string GetComment() { return found ? comment : ""; };
      inline int GetEvnumMin() { return found ? evnumMin : -1; };
      inline int GetEvnumMax() { return found ? evnumMax : -1; };
      inline double GetCharge() { return found ? charge : -1; };
      // --- access QA info
      // check if the file has a particular defect
      // - if sector==0, checks the OR of all the sectors
      // - if an error is thrown, return true so file will be flagged
      inline bool HasDefect(const char * defectName, int sector=0) {
        return this->HasDefectBit(Bit(defectName),sector);
      };
      // - alternatively, check for defect by bit number
      inline bool HasDefectBit(int defect_, int sector=0) {
        return (this->GetDefect(sector) >> defect_) & 0x1;
      };
      // get this file's defect bitmask;
      // - if sector==0, gets OR of all sectors' bitmasks
      inline int GetDefect(int sector=0);
      // translate defect name to defect bit
      inline int Bit(const char * defectName);
      // --- access the full tree
      inline rapidjson::Document * GetQaTree() { return &qaTree; };
      inline rapidjson::Document * GetChargeTree() { return &chargeTree; };


      //.................................................................
      // query qaTree to get QA info for this run number and event number
      // - a lookup is only performed if necessary: if the run number changes
      //   or if the event number goes outside of the range of the file which
      //   most recently queried
      // - this method is called automatically when evaluating QA cuts
      //`````````````````````````````````````````````````````````````````
      inline bool Query(int runnum_, int evnum_);
      // if you know the DST file number, you can call QueryByFilenum to perform
      // lookups via the file number, rather than via the event number
      // - you can subsequently call any QA cut method, such as `Golden()`;
      //   although QA cut methods require an event number, no additional lookup
      //   query will be performed since it already has been done in QueryByFilenum
      inline bool QueryByFilenum(int runnum_, int filenum_);
      // get maximum file number for a given run (useful for QADB validation)
      inline int GetMaxFilenum(int runnum_);
      // aliases
      inline bool QueryByBinnum(int runnum_, int binnum_);
      inline int GetMaxBinnum(int runnum_);

      // check if this bin number exists
      inline bool HasBinnum(int runnum_, int binnum_) {
        sprintf(runnumStr,"%d",runnum_);
        if(qaTree.HasMember(runnumStr)) {
          sprintf(filenumStr,"%d",binnum_);
          return qaTree[runnumStr].GetObject().HasMember(filenumStr);
        }
        return false;
      }


      //.................................
      // Faraday Cup charge
      //`````````````````````````````````
      // -- accumulator
      // call this method after evaluating QA cuts (or at least after calling Query())
      // to add the current file's charge to the total charge;
      // - charge is accumulated per DST file, since the QA filters per DST file
      // - a DST file's charge is only accounted for if we have not counted it before
      inline void AccumulateCharge();
      // -- accessor
      // returns total accumlated charge that passed your QA cuts; call this
      // method after your event loop
      inline double GetAccumulatedCharge() {
        return chargeTotal;
      }
      // reset accumulated charge, if you ever need to
      inline void ResetAccumulatedCharge() { chargeTotal = 0; };


      //.................................
      // Helicity Sign Correction
      //`````````````````````````````````
      // use this method to get the correct helicity sign:
      // - this method returns -1 if the QA bin has the `BSAWrong` defect,
      //   which indicates the helicity sign in the data is incorrect
      // - therefore:
      //   'true helicity' = 'helicity from data' * CorrectHelicitySign(run_number, event_number)
      // - zero is returned, if the event is not found in the QADB or if the pion BSA
      //   sign is not distinguishable from zero
      // - the return value is constant for a run, but is still assigned per QA bin, for
      //   full generality
      // - the return value may NOT be constant for all runs in a data set; for example,
      //   deviations from the normal value happen when a single run is cooked with the
      //   wrong HWP position
      inline int CorrectHelicitySign(int runnum_, int evnum_);


    private:

      int runnumMin, runnumMax;
      bool verbose = false;
      std::vector<std::string> qaJsonList;
      std::vector<std::string> chargeJsonList;

      rapidjson::Document qaTree;
      rapidjson::Document chargeTree;
      char readBuffer[65536];
      inline void chainTrees(std::vector<std::string> jsonList, rapidjson::Document & outTree);

      char runnumStr[32];
      char filenumStr[32];
      int runnum,filenum,evnumMin,evnumMax,evnumMinTmp,evnumMaxTmp;
      int defect;
      int sectorDefect[6];
      char sectorStr[8];
      std::string comment;
      double charge, chargeMin, chargeMax, chargeTotal;
      bool chargeCounted;
      std::vector<std::pair<int,int>> chargeCountedFiles;

      std::map<std::string,int> defectNameMap;
      int nbits;

      bool found;
      int asymMask;
      int mask;

      std::set<int> allowForOkForAsymmetry;
      std::set<int> allowMiscBitList;

      bool dep_warned_Golden;
      bool dep_warned_OkForAsymmetry;
  };



  //...............
  // constructor
  //```````````````
  QADB::QADB(std::string const& cook, int runnumMin_, int runnumMax_, bool verbose_) {

    runnumMin = runnumMin_;
    runnumMax = runnumMax_;
    verbose = verbose_;

    // get QADB directory
    if(verbose) std::cout << "\n[+] find json files" << std::endl;
    std::string dbDirN = getenv("QADB") ? getenv("QADB") : "";
    if(dbDirN.compare("")==0) {
      throw std::runtime_error("QADB environment variable not set");
    };
    dbDirN += "/qadb";
    std::set<std::string> cooks_avail{"latest", "pass1", "pass2"};
    if(cooks_avail.find(cook) != cooks_avail.end())
      dbDirN += std::string("/") + cook;
    else
      throw std::runtime_error("cook '" + cook + "' is not available in the QADB");
    if(verbose) std::cout << "QADB at " << dbDirN << std::endl;

    // get list of json files
    DIR * dbDir = opendir(dbDirN.c_str());
    struct dirent * dbDirent;
    while((dbDirent=readdir(dbDir))) {
      std::string qaDirN = std::string(dbDirent->d_name);
      if(qaDirN.at(0)=='.') continue;
      qaJsonList.push_back(dbDirN+"/"+qaDirN+"/qaTree.json");
      chargeJsonList.push_back(dbDirN+"/"+qaDirN+"/chargeTree.json");
    };
    closedir(dbDir);
    if(verbose) {
      std::cout << "qaTree files:" << std::endl;
      for(std::string str : qaJsonList) std::cout << " - " << str << std::endl;
      std::cout << "chargeTree files:" << std::endl;
      for(std::string str : chargeJsonList) std::cout << " - " << str << std::endl;
    };

    // read json files and concatenate, including only runs within specified
    // range [runnumMin,runnumMax]
    if(verbose) std::cout << "\n[+] read specified runs from json files" << std::endl;
    qaTree.SetObject();
    chargeTree.SetObject();
    this->chainTrees(qaJsonList,qaTree);
    this->chainTrees(chargeJsonList,chargeTree);
    if(verbose) {
      std::cout << "full list of runs read from QADB:" << std::endl;
      for(auto it=qaTree.MemberBegin(); it!=qaTree.MemberEnd(); ++it)
        std::cout << (it->name).GetString() << std::endl;
      std::cout << "-----\n";
    };


    // define bits (order and names must match those in ../../src/clasqa/Tools.groovy)
    nbits=0;
    defectNameMap.insert(std::pair<std::string,int>("TotalOutlier",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("TerminalOutlier",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("MarginalOutlier",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("SectorLoss",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("LowLiveTime",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("Misc",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("TotalOutlierFT",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("TerminalOutlierFT",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("MarginalOutlierFT",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("LossFT",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("BSAWrong",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("BSAUnknown",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("TSAWrong",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("TSAUnknown",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("DSAWrong",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("DSAUnknown",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("ChargeHigh",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("ChargeNegative",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("ChargeUnknown",nbits++));
    defectNameMap.insert(std::pair<std::string,int>("PossiblyNoBeam",nbits++));


    // defect mask used for asymmetry analysis
    asymMask = 0;
    asymMask += 0x1 << Bit("TotalOutlier");
    asymMask += 0x1 << Bit("TerminalOutlier");
    asymMask += 0x1 << Bit("MarginalOutlier");
    asymMask += 0x1 << Bit("SectorLoss");

    // list of runs allowed by OkForAsymmetry, even though they have Misc defect
    allowForOkForAsymmetry.insert(5046);
    allowForOkForAsymmetry.insert(5047);
    allowForOkForAsymmetry.insert(5051);
    allowForOkForAsymmetry.insert(5128);
    allowForOkForAsymmetry.insert(5129);
    allowForOkForAsymmetry.insert(5130);
    allowForOkForAsymmetry.insert(5158);
    allowForOkForAsymmetry.insert(5159);
    allowForOkForAsymmetry.insert(5160);
    allowForOkForAsymmetry.insert(5163);
    allowForOkForAsymmetry.insert(5165);
    allowForOkForAsymmetry.insert(5166);
    allowForOkForAsymmetry.insert(5167);
    allowForOkForAsymmetry.insert(5168);
    allowForOkForAsymmetry.insert(5169);
    allowForOkForAsymmetry.insert(5180);
    allowForOkForAsymmetry.insert(5181);
    allowForOkForAsymmetry.insert(5182);
    allowForOkForAsymmetry.insert(5183);
    allowForOkForAsymmetry.insert(5400);
    allowForOkForAsymmetry.insert(5448);
    allowForOkForAsymmetry.insert(5495);
    allowForOkForAsymmetry.insert(5496);
    allowForOkForAsymmetry.insert(5505);
    allowForOkForAsymmetry.insert(5567);
    allowForOkForAsymmetry.insert(5610);
    allowForOkForAsymmetry.insert(5617);
    allowForOkForAsymmetry.insert(5621);
    allowForOkForAsymmetry.insert(5623);



    // initialize local vars
    runnum = -1;
    filenum = -1;
    evnumMin = -1;
    evnumMax = -1;
    found = false;
    mask = 0;
    charge = 0;
    chargeTotal = 0;
    chargeCounted = false;
    dep_warned_Golden = false;
    dep_warned_OkForAsymmetry = false;
  };


  //....................................................................
  // concatenate trees from JSON files in jsonList to tree outTree
  //````````````````````````````````````````````````````````````````````
  // - includes only runs within specified range [runnumMin,runnumMax]
  void QADB::chainTrees(std::vector<std::string> jsonList, rapidjson::Document & outTree) {

    // loop through list of json files
    for(std::string jsonFileN : jsonList) {

      // open json file stream
      if(verbose) std::cout << "read json stream " << jsonFileN << std::endl;
      FILE * jsonFile = fopen(jsonFileN.c_str(),"r");
      rapidjson::FileReadStream jsonStream(jsonFile,readBuffer,sizeof(readBuffer));
      
      // parse stream to tmpTree
      rapidjson::Document tmpTree(rapidjson::kObjectType);
      if(tmpTree.ParseStream(jsonStream).HasParseError()) {
        std::cerr << "ERROR: QADB could not parse " << jsonFileN << std::endl;
        return;
      };

      // append to tmpTree to outTree
      for(auto it=tmpTree.MemberBegin(); it!=tmpTree.MemberEnd(); ++it) {
        runnum = atoi((it->name).GetString());
        if( ( runnumMin<0 && runnumMax<0) ||
            ( runnum>=runnumMin && runnum<=runnumMax)
        ) {
          if(verbose) std::cout << "- add run " << runnum << std::endl;
          rapidjson::Value objKey, objVal;
          objKey.CopyFrom(it->name,outTree.GetAllocator());
          objVal.CopyFrom(it->value,outTree.GetAllocator());
          outTree.AddMember(objKey,objVal,outTree.GetAllocator());
        };
      };

      // close json file
      fclose(jsonFile);
    };

    // reset runnum
    runnum = -1;
  };


  //...................................
  // QA for spin asymmetry analysis
  //```````````````````````````````````
  bool QADB::OkForAsymmetry(int runnum_, int evnum_) {

    // deprecation notice
    if(!dep_warned_OkForAsymmetry) {
      dep_warned_OkForAsymmetry = true;
      WarningBanner(true);
      std::cerr << R"(| WARNING: `QADB::OkForAsymmetry` is DEPRECATED
|   - you may still use this method, but `OkForAsymmetry` does
|     not include NEW defect bits that have been recently defined
)";
      DeprecationGuidance();
      std::cerr << R"(| EXAMPLE:
|   - see '$QADB/srcC/tests/testOkForAsymmetry.cpp' for a
|     preferred, equivalent implementation; from there, you may
|     customize your QA criteria and use the new defect bits
)";
      WarningBanner(false);
    }

    // perform lookup
    bool foundHere = this->Query(runnum_,evnum_);
    if(!foundHere) return false;

    // check for bits which will always cause the file to be rejected 
    // (asymMask is defined in the constructor)
    if( defect & asymMask ) return false;

    // special cases for `Misc` bit
    if(this->HasDefect("Misc")) {

      // check if this is a run on the list of runs with a large fraction of
      // events with undefined helicity; if so, accept this run, since none of
      // these files are marked with `Misc` for any other reasons
      if(allowForOkForAsymmetry.find(runnum_) != allowForOkForAsymmetry.end())
        return true;

      // check if this run had an FADC failure; there is no indication spin
      // asymmetries are impacted by this issue
      else if(runnum_>=6736 && runnum_<=6757) return true;

      // otherwise, this file fails the QA
      else return false;
    };

    // otherwise, this file passes the QA
    return true;
  };


  //...............................
  // user-defined custom QA cuts
  //```````````````````````````````
  void QADB::SetMaskBit(const char * defectName, bool state) {
    int defectBit = this->Bit(defectName);
    if(defectBit<0 || defectBit>=nbits)
      std::cerr << "ERROR: QADB::SetMaskBit called for unknown bit" << std::endl;
    else {
      mask &= ~(0x1 << defectBit);
      if(state) mask |= (0x1 << defectBit);
    };
  };
  void QADB::CheckForDefect(const char * defectName, bool state) {
    SetMaskBit(defectName, state);
  }
  bool QADB::Pass(int runnum_, int evnum_) {
    bool foundHere = this->Query(runnum_,evnum_);
    if(!foundHere)
      return false;
    auto use_mask = mask;
    if(this->HasDefectBit(MISC_BIT)) {
      if(allowMiscBitList.find(runnum_) != allowMiscBitList.end())
        use_mask &= ~(0x1 << MISC_BIT); // set `use_mask`'s Misc bit to 0
    }
    return !(defect & use_mask);
  }




  //.................
  // accessors
  //`````````````````
  int QADB::GetDefect(int sector) {
    if(!found) return -1;
    if(sector==0) return defect;
    else if(sector>=1 && sector<=6) return sectorDefect[sector-1];
    else {
      std::cerr << "ERROR: bad sector number for QADB::GetDefect" << std::endl;
      return -1;
    };
  };
  int QADB::Bit(const char * defectName) {
    int defectBit;
    try { defectBit = defectNameMap.at(std::string(defectName)); }
    catch(const std::out_of_range & e) {
      std::cerr << "ERROR: QADB::Bit() unknown defectName" << std::endl;
      return -1;
    };
    return defectBit;
  };
    



  //.....................................................................
  // query qaTree to get QA info for this run number and event number
  // - a lookup is only performed if necessary: if the run number changes
  //   or if the event number goes outside of the range of the file which
  //   most recently queried
  //`````````````````````````````````````````````````````````````````````
  bool QADB::Query(int runnum_, int evnum_) {

    // if the run number changed, or if the event number is outside the range
    // of the previously queried file, perform a new lookup
    if( runnum_ != runnum ||
        ( runnum_ == runnum && (evnum_ < evnumMin || evnum_ > evnumMax ))
    ) {
      // reset vars
      runnum = runnum_;
      filenum = -1;
      evnumMin = -1;
      evnumMax = -1;
      charge = -1;
      found = false;

      // search for file which contains this event
      sprintf(runnumStr,"%d",runnum);
      if(qaTree.HasMember(runnumStr)) {
        auto runTree = qaTree[runnumStr].GetObject();

        for(auto it=runTree.MemberBegin(); it!=runTree.MemberEnd(); ++it) {
          auto fileTree = (it->value).GetObject();
          evnumMinTmp = fileTree["evnumMin"].GetInt();
          evnumMaxTmp = fileTree["evnumMax"].GetInt();
          if( evnum_ >= evnumMinTmp && evnum_ <= evnumMaxTmp ) {
            this->QueryByFilenum(runnum_,atoi((it->name).GetString()));
            break;
          };
        };
      };

      // print a warning if a file was not found for this event
      // - this warning is suppressed for 'tag1' events
      if(!found && runnum_!=0) {
        std::cerr << "WARNING: QADB::Query could not find runnum=" <<
          runnum_ << " evnum=" << evnum_ << std::endl;
      };
    };

    // result of query
    return found;
  };

  // ------ query by file number
  bool QADB::QueryByFilenum(int runnum_, int filenum_) {

    // if the run number or file number changed, perform new lookup
    if( runnum_ != runnum || filenum_ != filenum) {
      
      // reset vars
      runnum = runnum_;
      filenum = filenum_;
      evnumMin = -1;
      evnumMax = -1;
      charge = -1;
      found = false;

      sprintf(runnumStr,"%d",runnum);
      if(qaTree.HasMember(runnumStr)) {
        auto runTree = qaTree[runnumStr].GetObject();
        sprintf(filenumStr,"%d",filenum);
        if(runTree.HasMember(filenumStr)) {
          auto fileTree = runTree[filenumStr].GetObject();
          evnumMin = fileTree["evnumMin"].GetInt();
          evnumMax = fileTree["evnumMax"].GetInt();
          comment = fileTree["comment"].GetString();
          defect = fileTree["defect"].GetInt();
          auto sectorTree = fileTree["sectorDefects"].GetObject();
          for(int s=0; s<6; s++) {
            sprintf(sectorStr,"%d",s+1);
            const rapidjson::Value& defList = sectorTree[sectorStr];
            sectorDefect[s] = 0;
            for(rapidjson::SizeType i=0; i<defList.Size(); i++) {
              sectorDefect[s] += 0x1 << defList[i].GetInt();
            };
          };
          chargeMin = chargeTree[runnumStr][filenumStr]["fcChargeMin"].GetDouble();
          chargeMax = chargeTree[runnumStr][filenumStr]["fcChargeMax"].GetDouble();
          charge = chargeMax - chargeMin;
          chargeCounted = false;
          found = true;
        };
      };

      // print a warning if a file was not found for this event
      // - this warning is suppressed for 'tag1' events
      if(!found && runnum!=0) {
        std::cerr << "WARNING: QADB::QueryByFilenum could not find runnum=" <<
          runnum_ << " filenum=" << filenum_ << std::endl;
      };
    };

    // result of query
    return found;
  };
  bool QADB::QueryByBinnum(int runnum_, int binnum_) {
    return QueryByFilenum(runnum_, binnum_);
  }

  // ----- return maximum filenum for a given runnum
  int QADB::GetMaxFilenum(int runnum_) {
    int maxFilenum = 0;
    sprintf(runnumStr,"%d",runnum_);
    auto runTree = qaTree[runnumStr].GetObject();
    for(auto it=runTree.MemberBegin(); it!=runTree.MemberEnd(); ++it)
      maxFilenum = std::max(atoi((it->name).GetString()), maxFilenum);
    return maxFilenum;
  };
  int QADB::GetMaxBinnum(int runnum_) {
    return GetMaxFilenum(runnum_);
  }




  //.................................
  // Faraday Cup charge accumulator
  //`````````````````````````````````
  void QADB::AccumulateCharge() {
    if(!chargeCounted) {
      if(
        find(
          chargeCountedFiles.begin(),
          chargeCountedFiles.end(),
          std::pair<int,int>(runnum,filenum)
        ) == chargeCountedFiles.end()
      ) {
        chargeTotal += charge;
        chargeCountedFiles.push_back(std::pair<int,int>(runnum,filenum));
      };
      chargeCounted = true;
    };
  };

  //.................................
  // Helicity Sign Correction
  //`````````````````````````````````
  int QADB::CorrectHelicitySign(int runnum_, int evnum_) {
    bool foundHere = this->Query(runnum_,evnum_);
    if(!foundHere)
      return 0;
    if(this->HasDefectBit(BSAUNKNOWN_BIT))
      return 0;
    return this->HasDefectBit(BSAWRONG_BIT) ? -1 : 1;
  }

};


#endif
