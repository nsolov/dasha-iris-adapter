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

XData MessageMap
{
<MapItems>
    <MapItem MessageType="DashaDemo.Ens.Msg.AppointmentRequest">
        <Method>SaveConversation</Method>
    </MapItem>
</MapItems>
}

}
