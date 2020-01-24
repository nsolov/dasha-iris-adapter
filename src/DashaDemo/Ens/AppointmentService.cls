Class DashaDemo.Ens.AppointmentService Extends Ens.BusinessService
{

Method OnProcessInput(pRequest As Ens.StringContainer, pOutput As Ens.StringContainer) As %Status
{
    try {
	    set appointment = ##class(DashaDemo.Ens.Msg.AppointmentRequest).%New()
	    set appointment.JSON = pRequest.StringValue 
	    set json = {}.%FromJSON(pRequest.StringValue)
	    set appointment.ConvID = json.id
        set appointment.CreatedTime = json.createdTime
        set iter = json.results.%GetIterator()
        // finding the latest result
        set latestResultTime = 0
        set latestResult = "" 
	    while iter.%GetNext(.key , .result ) {
        	set time = ##class(%Library.PosixTime).XSDToLogical(result.completedTime)
            if (time>latestResultTime) {
                set latestResultTime = time
                set latestResult = result
            }
        }  
        if (latestResult'="") {
            set appointment.HasAppt = latestResult.result.hasAppt
            set appointment.ServiceStatus = latestResult.result.serviceStatus
            set appointment.PhoneNumer = latestResult.result.phoneNumber
            set appointment.AppDate = latestResult.result.date
            set appointment.AppTime = latestResult.result.time
            set appointment.FullName = latestResult.result.fullname
            set appointment.CompletedTime = latestResult.completedTime
            $$$ThrowOnError(..SendRequestAsync("DBOperation",appointment))
        }
    } catch ex {
        do ex.Log()
        return ex.AsStatus()
    }
    return $$$OK
}

}
