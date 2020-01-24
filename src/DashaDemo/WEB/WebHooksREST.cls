Class DashaDemo.WEB.WebHooksREST Extends DashaDemo.WEB.AbstractREST
{

XData UrlMap
{
<Routes>
    <Route Url="/" Method="GET" Call="Hello" />
    <Route Url="/appointment" Method="POST" Call="SaveConversation" />
    <Route Url="/nps" Method="POST" Call="SaveNPSResult" />
    <Route Url="/admin/deleteData" Method="GET" Call="DeleteData" />

    </Routes>
}

ClassMethod Hello() As %Status
{
    write "It works from IRIS!"
    return $$$OK
}

ClassMethod SaveNPSResult() As %Status
{
    try {
        set request = %request.Content
        if ('$IsObject(request)) {
            $$$ThrowStatus($$$ERROR(5001,"empty request body"))
        }
        $$$ThrowOnError(##class(Ens.Director).CreateBusinessService("NPSResultsService",.tService))
        set msg = ##class(Ens.StringContainer).%New(request.%ToJSON())
        $$$ThrowOnError(tService.ProcessInput(msg))

        set jo = {}
        do jo.%Set("success",1,"boolean")
        write jo.%ToJSON()

    } catch ex {
        do ex.Log()
        return ex.AsStatus()
    }
    return $$$OK
}

ClassMethod DeleteData() As %Status
{
    set n = ##class(DashaDemo.DB.Appointment).Clear()
    write n_" appointments removed; "
    set n = ##class(DashaDemo.DB.Survey).Clear()
    write n_" NPS surveys removed."

    return $$$OK
}

ClassMethod SaveConversation() As %Status
{
    try {
        set request = %request.Content
        if ('$IsObject(request)) {
            $$$ThrowStatus($$$ERROR(5001,"empty request body"))
        }
        $$$ThrowOnError(##class(Ens.Director).CreateBusinessService("AppointmentService",.tService))
        set msg = ##class(Ens.StringContainer).%New(request.%ToJSON())
        $$$ThrowOnError(tService.ProcessInput(msg))
        set jo = {}
        do jo.%Set("success",1,"boolean")
        write jo.%ToJSON()
    } catch ex {
        do ex.Log()
        return ex.AsStatus()
    }
    return $$$OK
}

}
