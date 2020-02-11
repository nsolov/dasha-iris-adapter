Include Ensemble

/// Object script class to work with Dasha.ai API.
/// 
/// This class implements not all methods from 
/// Dasha.ai API documentation https://demo.us.dasha.ai/swagger/index.html
/// 
/// How to use:
/// 1) Create Dasha.Client object
/// 2) Call SetClientProps() method
/// 3) Use Dasha.Client methods
/// 
Class Dasha.Client Extends %RegisteredObject
{

Property AuthHost As %String [ Private ];

Property DashaAPI As %String [ Private ];

Property Login As %String [ Private ];

Property Password As %String [ Private ];

Property ClientID As %String [ Private ];

Property SSLConfig As %String [ Private ];

Property Timeout As %Integer [ InitialExpression = 5 ];

Property Token As %String;

Property TokenExpirationTime As %PosixTime;

Method SetClientProps(authHost As %String = "", dashaAPI As %String = "", clientID As %String = "", SSLConfig As %String = "", login As %String = "", password As %String = "") As %Status
{
	try {
	    if ( (authHost="") || (dashaAPI="") || (clientID="") || (SSLConfig="") || (login="") || (password="")) {
	        $$$ThrowStatus($$$ERROR(5001, "All arguments are required: authHost, dashaAPI, clientID, SSLConfig, login, password"))
	    }
	    set ..AuthHost = authHost
	    set ..DashaAPI = dashaAPI
	    set ..ClientID = clientID
	    set ..Login = login
	    set ..Password = password
	    set ..SSLConfig = SSLConfig
	    $$$ThrowOnError(..GetToken())
	} catch ex {
		do ex.Log()
		return ex.AsStatus()	
	}
	return $$$OK
}

/// Authorise and getToken
Method GetToken() As %Status
{
    #dim httprequest as %Net.HttpRequest
    #dim response as %Net.HttpResponse
    set ..Token = ""
    set ..TokenExpirationTime = ""
    try {
        set time = ##class(%Library.PosixTime).CurrentTimeStamp()
        set httprequest = ##class(%Net.HttpRequest).%New()
        set httprequest.SSLConfiguration = ..SSLConfig
        set httprequest.Https = 1
        set httprequest.Timeout = ..Timeout
        do httprequest.SetHeader("Content-Type","application/x-www-form-urlencoded")
        do httprequest.InsertFormData("client_id",..ClientID)
        do httprequest.InsertFormData("grant_type","password")
        do httprequest.InsertFormData("username",..Login)
        do httprequest.InsertFormData("password",..Password)
        set httprequest.Server = ..AuthHost
        
        do httprequest.Post("/connect/token")
        if (httprequest.HttpResponse="") { 
            $$$ThrowStatus($$$ERROR(5001, "Error connecting "_..AuthHost)) 
        }
        set response = httprequest.HttpResponse
        
        set js = {}.%FromJSON(response.Data)
        
        set ..Token = js."access_token"
        set ..TokenExpirationTime = time + (1000000*js."expires_in"/2)
    } catch ex {
	    
        return ex.AsStatus()
    }
    return $$$OK
}

/// Create conversation queue
Method CreateConversationQueue(individualReportUrl As %String, maxParallelConversation As %Integer = 0) As %String
{
	#dim httprequest as %Net.HttpRequest
    #dim response as %Net.HttpResponse
    try {
        set jsonParams = {"individualReportUrl": (individualReportUrl), "maxParallelConversation": (maxParallelConversation)}
        if (..TokenExpirationTime < ##class(%Library.PosixTime).CurrentTimeStamp()) {
            $$$ThrowOnError(..GetToken())
        }
        set httprequest = ..GetHTTPRequestObject()
        do httprequest.EntityBody.Write(jsonParams.%ToJSON())
        set path = "/api/v1/queues"
        
        do httprequest.Post(path)
        set response = httprequest.HttpResponse
        
        set key = ""
        set str = ""
        for {
            set key = $Order(httprequest.HttpResponse.Headers(key))
            quit:(key="")
            set str = str_key_":"_httprequest.HttpResponse.Headers(key)_$$$NL
        }
        if (response.StatusCode<200) || (response.StatusCode>=300)  {
            $$$ThrowStatus($$$ERROR($$$GeneralError,"error while executing POST request to resource "_path_". Status: "_response.StatusCode_". Data: "_response.Data.Read(1000)))
        }
        return response.Data.Read(1000)
    } catch ex {
        throw ex
        return ""
    }
}

/// Gets a running state of the queue
Method GetQueueState(Output state As %String, queueID As %String = "") As %Status
{
    try {
        if (..TokenExpirationTime < ##class(%Library.PosixTime).CurrentTimeStamp()) {
            $$$ThrowOnError(..GetToken())
        }
        set httprequest = ..GetHTTPRequestObject()
        set path = "/api/v1/queues/"_queueID_"/state"
        do httprequest.Get(path)
        set response = httprequest.HttpResponse
        if (response.StatusCode<200) || (response.StatusCode>=300) {
            $$$ThrowStatus($$$ERROR($$$GeneralError,"Error while executing GET request to resource "_path_". Status: "_response.StatusCode_", Data: "_response.Data.Read(1000)))
        }
        set state = $translate(response.Data.Read(1000),"""")
    } catch ex {
        return ex.AsStatus()
    }
    return $$$OK
}

/// helper method
Method GetHTTPRequestObject() As %Net.HttpRequest [ Private ]
{
    set httprequest = ##class(%Net.HttpRequest).%New()
    set httprequest.SSLConfiguration = ..SSLConfig
    set httprequest.Https = 1
    do httprequest.SetHeader("Content-Type","application/json")
    do httprequest.SetHeader("Authorization","Bearer "_..Token)
    set httprequest.Server = ..DashaAPI
    return httprequest
}

/// Get groups for task
Method GetGroups(Output groups As %DynamicArray, taskId As %String) As %Status
{
    try {
        if (..TokenExpirationTime < ##class(%Library.PosixTime).CurrentTimeStamp()) {
            $$$ThrowOnError(..GetToken())
        }
        set httprequest = ..GetHTTPRequestObject()
        set path = "/api/v1/conversations/tasks/"_taskId_"/groups"
        do httprequest.Get(path)
        set response = httprequest.HttpResponse
        if (response.StatusCode<200) || (response.StatusCode>=300) {
            $$$ThrowStatus($$$ERROR($$$GeneralError,"Error while executing GET request to resource "_path_". Status: "_response.StatusCode_", Data: "_response.Data.Read(1000)))
        }
        set groups = [].%FromJSON(response.Data)
    } catch ex {
        return ex.AsStatus()
    }
    return $$$OK
}

/// Gets a running state of the schedule 
Method GetScheduleState(Output state As %String, taskId As %String, groupId As %String) As %Status
{
    try {
        if (..TokenExpirationTime < ##class(%Library.PosixTime).CurrentTimeStamp()) {
            $$$ThrowOnError(..GetToken())
        }
        set httprequest = ..GetHTTPRequestObject()
        set path = "/api/v1/schedules/task/"_taskId_"/group/"_groupId_"/state"
        do httprequest.Get(path)
        set response = httprequest.HttpResponse
        if (response.StatusCode<200) || (response.StatusCode>=300) {
            $$$ThrowStatus($$$ERROR($$$GeneralError,"Error while executing GET request to resource "_path_". Status: "_response.StatusCode_", Data: "_response.Data.Read(1000)))
        }
        set state =  $translate(response.Data.Read(),"""")
    } catch ex {
        return ex.AsStatus()
    }
    return $$$OK
}

/// Gets information about a schedule
Method GetSchedule(Output schedule As %DynamicObject, taskId As %String, groupId As %String) As %Status
{
    try {
        if (..TokenExpirationTime < ##class(%Library.PosixTime).CurrentTimeStamp()) {
            $$$ThrowOnError(..GetToken())
        }
        set httprequest = ..GetHTTPRequestObject()
        set path = "/api/v1/schedules/task/"_taskId_"/group/"_groupId
        do httprequest.Get(path)
        set response = httprequest.HttpResponse
        if (response.StatusCode<200) || (response.StatusCode>=300) {
            $$$ThrowStatus($$$ERROR($$$GeneralError,"Error while executing GET request to resource "_path_". Status: "_response.StatusCode_", Data: "_response.Data.Read(1000)))
        }
        set schedule = {}.%FromJSON(response.Data)
    } catch ex {
        return ex.AsStatus()
    }
    return $$$OK
}

/// Add or update schedule
Method PutSchedule(schedule As %DynamicObject, taskId As %String, groupId As %String) As %Status
{
    try {
        if (..TokenExpirationTime < ##class(%Library.PosixTime).CurrentTimeStamp()) {
            $$$ThrowOnError(..GetToken())
        }
        set httprequest = ..GetHTTPRequestObject()
        do httprequest.EntityBody.Write(schedule.%ToJSON())
        
        set path = "/api/v1/schedules/task/"_taskId_"/group/"_groupId
        do httprequest.Put(path)
        set response = httprequest.HttpResponse
        if (response.StatusCode<200) || (response.StatusCode>=300) {
            $$$ThrowStatus($$$ERROR($$$GeneralError,"Error while executing PUT request to resource "_path_". Status: "_response.StatusCode_", Data: "_response.Data.Read(1000)))
        }
        return response.Data.Read(1000)
    } catch ex {
        throw ex
        return ""
    }
}

/// Creates New conversation
/// Using conversationIDs returns array of ID
Method NewConversation(Output conversationIDs As %DynamicObject, task As %String, group As %String, data As %DynamicArray) As %Status
{
	#dim httprequest as %Net.HttpRequest
    #dim response as %Net.HttpResponse
    try {
        set conversationIDs = {} 
        if ('$isObject(data)) { set data = {} }
        
        if (..TokenExpirationTime < ##class(%Library.PosixTime).CurrentTimeStamp()) {
            $$$ThrowOnError(..GetToken())
        }
        set httprequest = ..GetHTTPRequestObject()

        do httprequest.EntityBody.Write(data.%ToJSON())

        set path = "/api/v1/conversations/tasks/"_task_"/groups/"_group_"?strategy=ForceAdd" 
        do httprequest.Post(path)
        set response = httprequest.HttpResponse
        if (response.StatusCode<200) || (response.StatusCode>=300) {
            return $$$ERROR($$$GeneralError,"error while executing POST request to resource "_path_".  Status: "_response.StatusCode_", Data: "_response.Data.Read(1000))
        }
        set jsResult = [].%FromJSON(response.Data)
        set iter = jsResult.%GetIterator()
        while iter.%GetNext(.key , .res ) {
            set convData = {"name":(res.name), "phone":(res.data.phone), "timezone":(res.data.timezone)}
            do conversationIDs.%Set(res.id,convData)
        }
    } catch ex {
	    set conversationIDs = {}
	    do ex.Log()
        return ex.AsStatus()
    }
    return $$$OK
}

/// Add conversations to queue
Method AddConversationsToQueue(id As %String) As %Status
{
    try {
        if (..TokenExpirationTime < ##class(%Library.PosixTime).CurrentTimeStamp()) {
            $$$ThrowOnError(..GetToken())
        }
        set httprequest = ..GetHTTPRequestObject()

        set path = "/api/v1/processing/conversations/"_id_"/add"
        do httprequest.Post(path)
        set response = httprequest.HttpResponse
        if (response.StatusCode<200) || (response.StatusCode>=300) {
            return $$$ERROR($$$GeneralError,"error while executing post request to resource "_path_". "_response.Data.Read(1000))
        }
        return $$$OK
    } catch ex {
        do ex.Log()
        return ex.AsStatus()
    }
}

}
