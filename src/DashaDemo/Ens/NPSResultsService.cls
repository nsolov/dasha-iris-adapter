Class DashaDemo.Ens.NPSResultsService Extends Ens.BusinessService
{

Method OnProcessInput(pRequest As Ens.StringContainer, pOutput As Ens.StringContainer) As %Status
{
    try {
	    set nps = ##class(DashaDemo.Ens.Msg.SurveyResultsResponse).%New()
	    set nps.JSON = pRequest.StringValue
	    set json = {}.%FromJSON(pRequest.StringValue)
	    set nps.DashaConversationID = json.id
	    if $data(^conversations(json.id)) {
	        set token = ^conversations(json.id)
	    } else {
	        $$$ThrowStatus($$$ERROR(5001,"no token for conversation, ID = "_json.id))
	    }
        set iter = json.results.%GetIterator()
        set latestResultTime = 0
        set latestResult = ""
	    while iter.%GetNext(.key , .result ) {
            set time = ##class(%Library.PosixTime).XSDToLogical(result.completedTime)
            if ((time>latestResultTime) || (latestResult = "")) {
                set latestResultTime = time
                set latestResult = result                
            }
        }   
        if (latestResult'="") {
            set nps.ClientStatus = latestResult.result.clientStatus
            set nps.TaskStatus = latestResult.taskStatus
            set nps.CSIQ1 = latestResult.result.csiQ1
            if (latestResult.result.csiQ1="unknown") {set nps.CSIQ1 = -1}
            set nps.CSIQ1Comment = latestResult.result."csiQ1_comment"
            set nps.CSIQ2 = latestResult.result.csiQ2
            if (latestResult.result.csiQ2="unknown") {set nps.CSIQ2 = -1}
            set nps.CSIQ2Comment = latestResult.result."csiQ2_comment"  
            set nps.NPSQ1 = latestResult.result.npsQ1
            if (latestResult.result.npsQ1="unknown") {set nps.NPSQ1 = -1}
            set nps.NPSQ1Comment = latestResult.result."npsQ1_comment"
            set nps.ServiceStatus = latestResult.serviceStatus
        	$$$ThrowOnError(..SendDeferredResponse(token,nps))
        } 
    } catch ex {
        return ex.AsStatus()
    }
    return $$$OK
}

}
