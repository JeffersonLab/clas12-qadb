package clasqa

import groovy.json.JsonOutput

class Tools {

  /////////////////
  // defect bits //
  /////////////////

  // define defect bits here, with syntax "[bitName]: description"
  // - bitName will be used as an enumerator; colon must follow
  // - description will be printed if desired; do not use colons in description
  def bitDefinitions = [
    "TotalOutlier: outlier N/F, but not terminal, marginal, or sector loss, for FD electron",
    "TerminalOutlier: outlier N/F of first or last file of run, not marginal, for FD electron",
    "MarginalOutlier: marginal outlier N/F, within one standard deviation of cut line, for FD electron",
    "SectorLoss: N/F diminished within a FD sector for several consecutive files",
    "LowLiveTime: live time < 0.9",
    "Misc: miscellaneous defect, documented as comment",
    "TotalOutlierFT: outlier N/F, but not terminal, marginal, or `LossFT`, FT electron",
    "TerminalOutlierFT: outlier N/F of first or last file of run, not marginal, FT electron",
    "MarginalOutlierFT: marginal outlier N/F, within one standard deviation of cut line, FT electron",
    "LossFT: N/F diminished within FT for several consecutive files",
    "BSAWrong: Beam Spin Asymmetry is the wrong sign",
    "BSAUnknown: Beam Spin Asymmetry is unknown, likely because of low statistics",
    "TSAWrong: Target Spin Asymmetry is the wrong sign",
    "TSAUnknown: Target Spin Asymmetry is unknown, likely because of low statistics",
    "DSAWrong: Double Spin Asymmetry is the wrong sign",
    "DSAUnknown: Double Spin Asymmetry is unknown, likely because of low statistics",
    "ChargeHigh: FC Charge is abnormally high",
    "ChargeNegative: FC Charge is negative",
    "ChargeUnknown: FC Charge is unknown; the first and last time bins always have this defect",
    "PossiblyNoBeam: Both N and F are low, indicating the beam was possibly off",
  ]

  // list of bit names and descriptions
  def bitNames = bitDefinitions.collect{ it.tokenize(':')[0] }
  def bitDescripts = bitDefinitions.collect{ it.tokenize(':')[1].substring(1) }

  // map of bitName to bit number
  def bit = { bitName ->
    def bitNum = bitNames.findIndexOf{ it==bitName }
    if(bitNum>=0 && bitNum<bitNames.size()) return bitNum
    else {
      System.err << "ERROR bad bit name $bitName\n"
      return 31
    }
  }

  // convert a positive integer into a string binary number
  def printBinary = { num,length ->
    def str = ""
    for(int i=0; i<length; i++) str += (num>>i)&1 ? "1":"0"
    return "0b"+str.reverse()
  }

  ////////////////
  // JSON FILES //
  ////////////////

  // access subtree at path
  def jAccess ( tree,path ) {
    if(path.size()<1) tree
    else if(path.size()==1) jAccess(tree[path[0]],[])
    else jAccess(tree[path[0]],path[1..-1])
  }

  // pretty printer
  def pPrint = { str -> JsonOutput.prettyPrint(JsonOutput.toJson(str)) }

}
