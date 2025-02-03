import clasqa.QADB

def runnum
final EVNUM = 100000 // FIXME: assumption
def cook
if(args.length>=2) {
  cook   = args[0]
  runnum = args[1].toInteger()
} else {
  throw new Exception("arguments must be [cook] [runnum]")
}

QADB qa = new QADB(cook)
System.out.println(qa.correctHelicitySign(runnum, EVNUM))
