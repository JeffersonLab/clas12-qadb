// demonstrates how to select events from golden files only, which 
// are files that have no defect
// - you must specify a hipo file as an argument

// imports
import org.jlab.io.hipo.HipoDataSource // to read HIPO files
import clasqa.QADB // access QADB


// instantiate HIPO file reader for specified HIPO file
def inHipoFile
if(args.length>=1) inHipoFile = args[0]
else { System.err << "ERROR: specify hipo file\n"; return; }
def reader = new HipoDataSource()
reader.open(inHipoFile)


// instantiate QADB
QADB qa = new QADB("latest")
// alternatively, specify run range to restrict QADB (may be more efficient)
//QADB qa = new QADB("latest",5000,5500);


// define variables
def event
def runnum,evnum
def evCount = 0
def evCountOK = 0


// event loop
println "begin event loop..."
while(reader.hasEvent()) {
  if(evCount%10000==0) println "$evCount events analyzed"

  // truncate event loop (for quick testing)
  if(evCount>1e5) { println "event loop truncated!"; break; }

  event = reader.getNextEvent()

  // get run and event numbers
  runnum = event.getBank("RUN::config").getInt('run',0)
  evnum = event.getBank("RUN::config").getInt('event',0)

  // QA cuts
  if(qa.golden(runnum,evnum)) {
    evCountOK++

    /* continue your analysis here */

  }

  // do not increment evCount for events with runnum==0, which fail QA
  if(runnum>0) evCount++
}

// print fraction of events which pass QA cuts
println "\nrun = $runnum"
println "number of events analyzed = $evCount"
println "number of events in golden DSTs = $evCountOK  (" +
  100.0 * evCountOK/evCount + "%)"
