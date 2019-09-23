Class DashaDemo.WEB.WebSocket Extends %CSP.WebSocket
{

/// How long to wait for client when connection established
Parameter Timeout = 1800;

/// Buffer size in bytes
Parameter Buffer = 8192;

Method OnPreServer() As %Status
{
    set ..SharedConnection=1
    return $$$OK
}

Method OnPostServer() As %Status
{
    kill ^IRIS.Temp.Dasha.WebSockets(..WebSocketID)
    return $$$OK
}

/// If the call is successful the status (sc) will be returned as $$$OK, otherwise an error code of $$$CSPWebSocketTimeout 
/// indicates a timeout and $$$CSPWebSocketClosed indicates that the client has terminated the WebSocket.
/// Converts results into json
/// Closes connection if received incorrect json
Method Read(ByRef len As %Integer = 32656, ByRef sc As %Status, timeout As %Integer = 86400) As %String
{
    set jsonString = ##super(len, .sc, timeout)
    do:$$$ISERR(sc) ..EndServer()
    try {
        set jsonObject = {}.%FromJSON(jsonString)
    } catch ex {
        set jsonObject = $$$NULLOREF
        do ..EndServer()
    }
    return jsonObject
}

/// Write to the client.
/// If <var>data</var> is object - outputs JSON.
/// If <var>data</var> is string - wraps it as JSON { "Data" : data }.
Method Write(data As %String) As %Status
{
    if ( $isobject(data) && data.%IsA("%Library.DynamicObject") ) {
        if (0=data.%Size()) { 
            return $$$OK 
        } // skip empty object
        set data = data.%ToJSON()
    } else {
        set data = "{""Data"":"""_$Replace(data,"\'","'")_"""}"
    }
    set sc = ##super(data)
    quit sc
}

/// Main method. <br>
Method Server() As %Status
{
    try {
        set ^ws($zdt($Now())) = 1
        $$$ThrowOnError(..Write(..SessionId_" ::: "_..WebSocketID))
        $$$ThrowOnError(..Write(##class(DashaDemo.DB.Appointment).GetConversations()))
        $$$ThrowOnError(..Write(##class(DashaDemo.DB.Survey).GetSurveys()))
        set ^IRIS.Temp.Dasha.WebSockets(..WebSocketID) = 1 
        do ..ClientLoop()
    } catch ex {
        do ex.Log()
    }
    do ..EndServer()
    return $$$OK
}

Method ClientLoop()
{
    for  {
        set data=..Read(, .st, ..#Timeout)
        if ($$$ISERR(st)){
            if ($$$GETERRORCODE(st)=$$$CSPWebSocketTimeout) {
                quit
            }
            if ($$$GETERRORCODE(st)=$$$CSPWebSocketClosed){
                quit  
            }
        }

        if (data = "") { continue }
        if (data.action = "newNPS") {
            set ^newNPS = data.%ToJSON()
            do ..Write(..SendToProduction(data.phones)) 
        }
        if (data.action = "npsresults") {
            set ^npsresults = data.%ToJSON()
            do ..Write(##class(DashaDemo.DB.Survey).GetSurveyResults($tr(data.id,"#"))) 
        }
    }
}

Method SendToProduction(phones As %DynamicArray) As %DynamicObject
{
    try {
        set jo = {"action":"newNPS"}
        $$$ThrowOnError(##class(Ens.Director).CreateBusinessService("NPSService",.tService))
        set msg = ##class(Ens.StringContainer).%New(phones.%ToJSON())
        $$$ThrowOnError(tService.ProcessInput(msg,.output))
        do jo.%Set("ID",output.StringValue)
        do jo.%Set("success",1,"boolean")
        write jo.%ToJSON()
    } catch ex {
        do ex.Log()
        do jo.%Set("success",0,"boolean")
        return jo
    }
    return jo
}

ClassMethod SendToAll(jo As %DynamicAbstractObject) As %Status
{
    set wsid = ""
    for {
        set wsid = $Order(^IRIS.Temp.Dasha.WebSockets(wsid))
        quit:(wsid="")
        set websocket = ##class(DashaDemo.WEB.WebSocket).%New()
        $$$ThrowOnError(websocket.OpenServer(wsid))
        do websocket.Write(jo)
    }
}

}
