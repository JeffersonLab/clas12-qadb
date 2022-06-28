// print list of files, and whether they are Golden, OkForAsymmetry, etc.

import clasqa.QADB
QADB qa = new QADB()

// open output file writer
def outFileObj = new File(System.getenv('QADB')+"/text/summary.txt")
def outFile = outFileObj.newWriter(false)

// print header
outFile << "#Run File Golden OkForAsymmetry\n"

// run loop (sorted)
qa.getQaTree().sort{ a,b -> a.key.toInteger() <=> b.key.toInteger() }.each{ runnumStr,runQA ->
  runnum = runnumStr.toInteger()
  println(runnum)

  // file loop (sorted)
  runQA.sort{ c,d -> c.key.toInteger() <=> d.key.toInteger() }.each{ filenumStr, fileQA ->
    filenum = filenumStr.toInteger()

    // query
    qa.queryByFilenum(runnum,filenum)
    evnum = qa.getEvnumMin() // evnum needed for QA cut methods

    // print
    outFile << [
      qa.getRunnum(),
      qa.getFilenum(),
      qa.golden(runnum,evnum)?1:0,
      qa.OkForAsymmetry(runnum,evnum)?1:0,
    ].join(' ') + "\n"

  }
  System.gc() // garbage collect after each run, to keep mem usage low
}

outFile.close()
