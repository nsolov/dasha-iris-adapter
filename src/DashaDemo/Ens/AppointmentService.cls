Class DashaDemo.Ens.AppointmentService Extends Ens.BusinessService
{

Method OnProcessInput(pRequest As Ens.StringContainer, pOutput As Ens.StringContainer) As %Status
{
    try {
	    set appointment = ##class(DashaDemo.Ens.Msg.AppointmentRequest).%New()
	    set appointment.JSON = pRequest.StringValue
	    
	    $$$TRACE(pRequest.StringValue)

	    set json = {}.%FromJSON(pRequest.StringValue)
	    set appointment.ConvID = json.Id
        set appointment.CreatedTime = json.CreatedTime
        $$$TRACE("id:"_json.Id)
	    set iter = json.Results.%GetIterator()
        // finding the latest result
        set latestResultTime = 0
        set latestResult = "" 
	    while iter.%GetNext(.key , .result ) {
        	set time = ##class(%Library.PosixTime).XSDToLogical(result.CompletedTime)
            if (time>latestResultTime) {
                set latestResultTime = time
                set latestResult = result
            }
        }  
        $$$TRACE(time_" "_latestResultTime_" "_latestResult)

        if (latestResult'="") {
            set appointment.HasAppt = latestResult.result.hasAppt
            set appointment.ServiceStatus = latestResult.result.serviceStatus
            set appointment.PhoneNumer = latestResult.result.phoneNumber
            set appointment.AppDate = latestResult.result.date
            set appointment.AppTime = latestResult.result.time
            set appointment.FullName = latestResult.result.fullname
            set appointment.CompletedTime = latestResult.CompletedTime
            $$$ThrowOnError(..SendRequestAsync("DBOperation",appointment))
        }
    } catch ex {
        do ex.Log()
        return ex.AsStatus()
    }
    return $$$OK
}

}
