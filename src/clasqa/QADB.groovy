package clasqa

import groovy.json.JsonSlurper
import groovy.json.JsonOutput
import groovy.json.JsonParserType
import clasqa.Tools

class QADB {

  final MISC_BIT       = 5 // FIXME: should be obtained from `defect_definitions.json`
  final BSAWRONG_BIT   = 10
  final BSAUNKNOWN_BIT = 11

  //..............
  // constructor
  //``````````````
  // arguments:
  // - cook: which cook (pass) to use:
  //   - 'latest': just use the latest available one
  //   - 'pass1': use pass 1
  //   - 'pass2': use pass 2
  // - runnumMin and runnumMax: if both are negative (default), then the
  //   entire QADB will be read; you can restrict to a specific range of
  //   runs to limit QADB, which may be more effecient
  // - verbose: if true, print (a lot) more information
  public QADB(String cook, int runnumMin=-1, runnumMax=-1, boolean verbose_=false) {

    // setup
    verbose = verbose_
    util = new Tools()
    nbits = util.bitDefinitions.size()
    dbDirN = System.getenv('QADB')
    if(dbDirN==null) {
      throw new Exception("env var QADB not set; source environ.sh")
    }
    dbDirN += '/qadb'
    if(cook in ["latest", "pass1", "pass2"]) {
      dbDirN += "/${cook}"
    } else {
      throw new Exception("cook '${cook}' is not available in the QADB")
    }
    if(verbose) println("QADB dir = ${dbDirN}")

    // concatenate trees
    qaTree = [:]
    chargeTree = [:]
    slurper = new JsonSlurper().setType(JsonParserType.INDEX_OVERLAY)
    def dbDir = new File(dbDirN)
    def dbFilter = ~/.*Tree.json$/
    def slurpAction = { tree,branch ->
      def rnum = branch.key.toInteger()
      if( ( runnumMin<0 && runnumMax<0 ) || 
          ( rnum>=runnumMin && rnum<=runnumMax)) {
        if(verbose) println "run $rnum"
        tree << branch
      }
    }
    dbDir.traverse( 
      type:groovy.io.FileType.FILES,
      maxDepth:1,
      nameFilter:dbFilter)
    { dbFile ->
      if(dbFile.name.contains("qaTree.json")) {
        if(verbose) println "read qaTree: " + dbFile
        slurper.parse(dbFile).each{ obj -> slurpAction(qaTree,obj) }
      } else if(dbFile.name.contains("chargeTree.json")) {
        if(verbose) println "read chargeTree: " + dbFile
        slurper.parse(dbFile).each{ obj -> slurpAction(chargeTree,obj) }
      }
    }

    // defect mask used for asymmetry analysis
    asymMask = 0
    asymMask += 0x1 << Bit('TotalOutlier')
    asymMask += 0x1 << Bit('TerminalOutlier')
    asymMask += 0x1 << Bit('MarginalOutlier')
    asymMask += 0x1 << Bit('SectorLoss')

    // list of runs allowed by OkForAsymmetry, even though they have Misc defect
    allowForOkForAsymmetry = [
      5046,
      5047,
      5051,
      5128,
      5129,
      5130,
      5158,
      5159,
      5160,
      5163,
      5165,
      5166,
      5167,
      5168,
      5169,
      5180,
      5181,
      5182,
      5183,
      5400,
      5448,
      5495,
      5496,
      5505,
      5567,
      5610,
      5617,
      5621,
      5623,
    ]

    // initialize local vars
    runnum = -1
    filenum = -1
    evnumMin = -1
    evnumMax = -1
    found = false
    mask = 0
    charge = 0
    chargeTotal = 0
    chargeCounted = false
    chargeCountedFiles = []
    dep_warned_Golden = false
    dep_warned_OkForAsymmetry = false
    allowMiscBitList = []
  }

  public QADB(int runnumMin=-1, runnumMax=-1, boolean verbose_=false) {
    System.err.print('''| ERROR: the QADB constructor now requires you to specify the cook as the first argument
|   - use "latest" to use the latest available cook's QADB
|     - see the QADB documentation for the list of available QADBs,
|       https://github.com/JeffersonLab/clas12-qadb/blob/main/README.md
|     - the latest cook may not yet have a QADB
|   - use "pass1" to restrict to Pass 1 cooks
|     - older data may have less QA defect bits, or other issues
|   - use "pass2" to restrict to Pass 2 data, etc.
''')
    throw new Exception("please specify the cook");
  }

  //...............................
  // deprecation warnings
  //```````````````````````````````
  private void deprecationGuidance() {
    System.err.print('''| INSTEAD: use the general methods
|   - use `QADB::checkForDefect` to choose which defects you want
|     to filter out, then use `QADB::pass` on each event
|   - for runs with the `Misc` defect bit (bit 5) assigned:
|     - use `QADB::getComment` to check the QADB comment, which
|       explains why this bit was assigned for the run
|     - use `QADB::allowMiscBit` to ignore the `Misc` bit for certain
|       runs that you want to allow in your analysis (`OkForAsymmetry`
|       internally does this for a specific list of RG-A runs)
''')
  }

  private void warningBanner(boolean first) {
    if(first) {
      System.err.print("\nWARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING\n|\n")
    } else {
      System.err.print("|\nWARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING\n\n")
    }
  }


  //...............................
  // golden QA cut
  //```````````````````````````````
  // returns false if the event is in a file with *any* defect
  public boolean golden(int runnum_, int evnum_) {
    if(!dep_warned_Golden) {
      dep_warned_Golden = true
      warningBanner(true)
      System.err.print('''| WARNING: `QADB::golden` is DEPRECATED
|   - you may still use this method, but since many more defect bits have been
|     defined, and "Golden" means "no defect bits set", you may find that
|     requiring your data to be "Golden" is too strict for your analysis
|     - NOTE: QADBs for Run Groups A, B, K, and M for Pass1 data only use
|       defect bits 0 to 9, whereas newer QADBs define many more bits
|   - in some cases, none of the data are "Golden"
''')
      deprecationGuidance()
      warningBanner(false)
    }
    def foundHere = query(runnum_,evnum_)
    return foundHere && defect==0
  }


  //.....................................
  // QA for spin asymmetry analysis
  //`````````````````````````````````````
  // if true, this event is good for a spin asymmetry analysis
  public boolean OkForAsymmetry(int runnum_, int evnum_) {

    if(!dep_warned_OkForAsymmetry) {
      dep_warned_OkForAsymmetry = true
      warningBanner(true)
      System.err.print('''| WARNING: `QADB::OkForAsymmetry` is DEPRECATED
|   - you may still use this method, but `OkForAsymmetry` does
|     not include NEW defect bits that have been recently defined
''')
      deprecationGuidance()
      System.err.print('''| EXAMPLE:
|   - see '$QADB/src/tests/testOkForAsymmetry.groovy' for a
|     preferred, equivalent implementation; from there, you may
|     customize your QA criteria and use the new defect bits
''')
      warningBanner(false)
    }


    // perform lookup
    def foundHere = query(runnum_,evnum_)
    if(!foundHere) return false;

    // check for bits which will always cause the file to be rejected 
    // (asymMask is defined in the constructor)
    if( defect & asymMask ) return false

    // special cases for `Misc` bit
    if(hasDefect('Misc')) {

      // check if this is a run on the list of runs with a large fraction of
      // events with undefined helicity; if so, accept this run, since none of
      // these files are marked with `Misc` for any other reasons
      if( runnum_ in allowForOkForAsymmetry ) return true

      // check if this run had an FADC failure; there is no indication spin
      // asymmetries are impacted by this issue
      else if( runnum_ in 6736..6757 ) return true

      // otherwise, this file fails the QA
      else return false

    }

    // otherwise, this file passes the QA
    return true
  }

  
  //...............................
  // user-defined custom QA cuts
  //```````````````````````````````
  // first set which defect bits you want to filter out; by default
  // none are set; the variable `mask` will be applied as a mask
  // on the defect bits
  public void setMaskBit(String bitStr, boolean state=true) { 
    def defectBit = Bit(bitStr)
    if(defectBit<0 || defectBit>=nbits)
      System.err << "ERROR: QADB::setMaskBit called for unknown defectBit\n"
    else  {
      mask &= ~(0x1 << defectBit)
      if(state) mask |= (0x1 << defectBit)
    }
  }
  public void checkForDefect(String bitStr, boolean state=true) { // alias
    setMaskBit(bitStr, state)
  }
  // access the custom mask, if you want to double-check it
  public int getMask() { return mask }
  // then call this method to check your custom QA cut for a given
  // run number and event number
  public boolean pass(int runnum_, int evnum_) {
    def foundHere = query(runnum_,evnum_)
    if(!foundHere) {
      return false
    }
    def use_mask = mask
    if(hasDefectBit(MISC_BIT)) {
      if(runnum_ in allowMiscBitList) {
        use_mask &= ~(0x1 << MISC_BIT) // set `use_mask`'s Misc bit to 0
      }
    }
    return foundHere && !(defect & use_mask)
  }

  // ignore certain runs for the `Misc` bit assignment
  public void allowMiscBit(int runnum_) {
    allowMiscBitList.add(runnum_)
  }


  //..............
  // accessors
  //``````````````
  // --- access this file's info
  public int getRunnum() { return found ? runnum.toInteger() : -1 }
  public int getFilenum() { return found ? filenum.toInteger() : -1 }
  public int getBinnum() { return getFilenum() }
  public String getComment() { return found ? comment : "" }
  public int getEvnumMin() { return found ? evnumMin : -1 }
  public int getEvnumMax() { return found ? evnumMax : -1 }
  public double getCharge() { return found ? charge : -1 }
  // --- access QA info
  // check if the file has a particular defect
  // - if sector==0, checks the OR of all the sectors
  // - if an error is thrown, return true so file will be flagged
  public boolean hasDefect(String name_, int sector=0) {
    return hasDefectBit(Bit(name_),sector)
  }
  // - alternatively, check for defect by bit number
  public boolean hasDefectBit(int defect_, int sector=0) {
    return (getDefect(sector) >> defect_) & 0x1
  }
  // get defect bitmask; if sector==0, gets OR of all sectors' bitmasks
  public int getDefect(int sector=0) {
    if(!found) return -1
    if(sector==0) return defect
    else if(sector>=1 && sector<=6) return sectorDefect["$sector"]
    else {
      System.err << "ERROR: bad sector number in QADB::getDefect\n"
      return -1;
    }
  }
  // translate defect name to defect bit
  public int Bit(String name_) { return util.bit(name_) }
  // --- access the full tree
  public def getQaTree() { return qaTree }
  public def getChargeTree() { return chargeTree }


  //....................................................................
  // query qaTree to get QA info for this run number and event number
  // - a lookup is only performed if necessary: if the run number changes
  //   or if the event number goes outside of the range of the file which
  //   most recently queried
  // - this method is called automatically when evaluating QA cuts
  //````````````````````````````````````````````````````````````````````
  public boolean query(int runnum_, int evnum_) {

    // perform lookup, only if needed
    if( runnum_ != runnum ||
        ( runnum_ == runnum && (evnum_ < evnumMin || evnum_ > evnumMax ))
    ) {
      // reset vars
      runnum = runnum_
      filenum = -1
      evnumMin = -1
      evnumMax = -1
      charge = -1
      found = false

      // search for file which contains this event
      if(verbose) println "query qaTree..."
      qaFile = qaTree["$runnum"].find{
        if(verbose) println " search file "+it.key+" for event $evnum_"
        evnum_ >= it.value['evnumMin'] && evnum_ <= it.value['evnumMax']
      }

      // if file found, set variables
      if(qaFile!=null) {
        queryByFilenum(runnum_,qaFile.key.toInteger())
      }

      // print a warning if a file was not found for this event
      // - this warning is suppressed for 'tag1' events
      if(!found && runnum_!=0) {
        System.err << "WARNING: QADB::query could not find " <<
        "runnum=$runnum_ evnum=$evnum_\n"
      }
    }

    // result of query
    return found
  }

  //........................................
  // if you know the DST file number, you can call QueryByFilenum to perform
  // lookups via the file number, rather than via the event number
  // - you can subsequently call any QA cut method, such as `Golden()`;
  //   although QA cut methods require an event number, no additional lookup
  //   query will be performed since it already has been done in QueryByFilenum
  //````````````````````````````````````````
  public boolean queryByFilenum(int runnum_, int filenum_) {

    // if the run number or file number changed, perform new lookup
    if( runnum_ != runnum || filenum_ != filenum) {
      
      // reset vars
      runnum = runnum_
      filenum = filenum_
      evnumMin = -1
      evnumMax = -1
      charge = -1
      found = false

      if(qaTree["$runnum"]!=null) {
        if(qaTree["$runnum"]["$filenum"]!=null) {
          qaFileTree = qaTree["$runnum"]["$filenum"]
          evnumMin = qaFileTree['evnumMin']
          evnumMax = qaFileTree['evnumMax']
          comment = qaFileTree['comment']
          defect = qaFileTree['defect']
          sectorDefect = [:]
          qaFileTree['sectorDefects'].each{ sec,defs ->
            sectorDefect[sec] = 0
            defs.each{ 
              sectorDefect[sec] += 0x1 << it
            }
          }
          chargeMin = chargeTree["$runnum"]["$filenum"]["fcChargeMin"]
          chargeMax = chargeTree["$runnum"]["$filenum"]["fcChargeMax"]
          charge = chargeMax - chargeMin
          chargeCounted = false
          found = true
        }
      }

      // print a warning if a file was not found for this event
      // - this warning is suppressed for 'tag1' events
      if(!found && runnum_!=0) {
        System.err << "WARNING: QADB::queryByFilenum could not find " <<
          "runnum=$runnum_ filenum=$filenum_\n"
      }
    }

    // result of query
    return found
  }
  // aliases
  public boolean queryByBinnum(int runnum_, int binnum_) {
    return queryByFilenum(runnum_, binnum_)
  }

  // check if this bin number exists
  public boolean hasBinnum(int runnum_, int binnum_) {
    if(qaTree["$runnum_"] != null) {
      return qaTree["$runnum_"]["$binnum_"] != null
    }
    return false
  }


  // get maximum file number for a given run (useful for QADB validation)
  public int getMaxFilenum(int runnum_) {
    int maxFilenum=0
    qaTree["$runnum_"].each{ 
      maxFilenum = it.key.toInteger() > maxFilenum ? 
                   it.key.toInteger() : maxFilenum
    }
    return maxFilenum
  }
  public int getMaxBinnum(int runnum_) { // alias
    return getMaxFilenum(runnum_)
  }




  //.................................
  // Faraday Cup charge accumulator
  //`````````````````````````````````
  // -- accumulator
  // call this method after evaluating QA cuts (or at least after calling query())
  // to add the current file's charge to the total charge;
  // - charge is accumulated per DST file, since the QA filters per DST file
  // - a DST file's charge is only accounted for if we have not counted it before
  public void accumulateCharge() {
    if(!chargeCounted) {
      if(!( [runnum,filenum] in chargeCountedFiles )) {
        chargeTotal += charge
        chargeCountedFiles << [runnum,filenum]
      }
      chargeCounted = true
    }
  }
  // -- accessor
  // call this method at the end of your event loop
  public double getAccumulatedCharge() {
    return chargeTotal
  }
  // reset accumulated charge, if you ever need to
  public void resetAccumulatedCharge() { chargeTotal = 0 }


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
  public int correctHelicitySign(int runnum_, int evnum_) {
    def foundHere = query(runnum_,evnum_)
    if(!foundHere) {
      return 0
    }
    if(hasDefectBit(BSAUNKNOWN_BIT)) {
      return 0
    }
    return hasDefectBit(BSAWRONG_BIT) ? -1 : 1
  }


  //===============================================================

  public Tools util

  private def qaTree
  private def chargeTree
  private def qaFile
  private def qaFileTree

  private boolean verbose
  private def dbDirN
  private def slurper

  private def runnum,filenum,evnumMin,evnumMax,evnumMinTmp,evnumMaxTmp
  private double charge,chargeMin,chargeMax,chargeTotal
  private boolean chargeCounted
  private def chargeCountedFiles
  private int defect
  private def sectorDefect
  private String comment
  private boolean found
  private int nbits
  private def mask
  private def asymMask
  private def allowForOkForAsymmetry
  private def allowMiscBitList

  private boolean dep_warned_Golden
  private boolean dep_warned_OkForAsymmetry
}
