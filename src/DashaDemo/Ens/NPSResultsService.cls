Class DashaDemo.Ens.NPSResultsService Extends Ens.BusinessService
{

Method OnProcessInput(pRequest As Ens.StringContainer, pOutput As Ens.StringContainer) As %Status
{
    try {
	    set nps = ##class(DashaDemo.Ens.Msg.SurveyResultsRequest).%New()
	    set nps.JSON = pRequest.StringValue
	    
	    $$$TRACE(pRequest.StringValue)

	    set json = {}.%FromJSON(pRequest.StringValue)

	    set nps.DashaConversationID = json.Id
	    
        set iter = json.Results.%GetIterator()
        set latestResultTime = 0
        set latestResult = ""
	    while iter.%GetNext(.key , .result ) {
            set time = ##class(%Library.PosixTime).XSDToLogical(result.CompletedTime)
            if ((time>latestResultTime) || (latestResult = "")) {
                set latestResultTime = time
                set latestResult = result                
            }
        }   
        $$$TRACE("time: "_latestResultTime)    
        $$$TRACE("res: "_latestResult)   
        if (latestResult'="") {
            set nps.ClientStatus = latestResult.result.clientStatus
            set nps.TaskStatus = latestResult.TaskStatus
            set nps.CSIQ1 = latestResult.result.csiQ1
            set nps.CSIQ1Comment = latestResult.result."csiQ1_comment"
            set nps.CSIQ2 = latestResult.result.csiQ2
            set nps.CSIQ2Comment = latestResult.result."csiQ2_comment"  
            set nps.NPSQ1 = latestResult.result.npsQ1
            set nps.NPSQ1Comment = latestResult.result."npsQ1_comment"
            set nps.ServiceStatus = latestResult.ServiceStatus

        	$$$ThrowOnError(..SendRequestAsync("DBOperation",nps))
        } 
    } catch ex {
        return ex.AsStatus()
    }
    return $$$OK
}

}
