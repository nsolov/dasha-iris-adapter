Class DashaDemo.Ens.DBOperation Extends Ens.BusinessOperation
{

Method SaveConversation(pInput As DashaDemo.Ens.Msg.AppointmentRequest, Output pOutput As Ens.Response) As %Status
{
    try {
        $$$ThrowOnError(##class(DashaDemo.DB.Appointment).SaveConversation(pInput))
    } catch ex {
        return ex.AsStatus() 
    }
    return $$$OK
}

Method SaveSurveyResults(pInput As DashaDemo.Ens.Msg.SurveyResultsRequest, Output pOutput As Ens.Response) As %Status
{
    try {
        set sr = ##class(DashaDemo.DB.SurveyResults).ConvIDIndexOpen(pInput.DashaConversationID)
        if $isObject(sr) {
            $$$ThrowOnError(sr.UpdateResults(pInput))
        }
    } catch ex {
        do ex.Log()
        return ex.AsStatus() 
    }
    return $$$OK
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="DashaDemo.Ens.Msg.AppointmentRequest">
        <Method>SaveConversation</Method>
    </MapItem>
    <MapItem MessageType="DashaDemo.Ens.Msg.SurveyResultsRequest">
        <Method>SaveSurveyResults</Method>
    </MapItem>
</MapItems>
}

}
