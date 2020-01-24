Class DashaDemo.Ens.NPSBusinessProcess Extends Ens.BusinessProcess
{

//Property DashaOperation as %String [ Required ];

//Parameter SETTINGS = "DashaOperation:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Parameter NPSStartCOMPLETIONKEY = "*start*";
Parameter ConversationCOMPLETIONKEY = "*conv*";

Method OnRequest(pRequest As DashaDemo.Ens.Msg.NewNPSRequest, Output pResponse As Ens.StringContainer) As %Status
{
    #dim msg As DashaDemo.Ens.Msg.NewNPSRequest = pRequest.%ConstructClone(1)
    quit ..SendRequestAsync("DashaOperation", msg, $$$YES, ..#NPSStartCOMPLETIONKEY)
}

Method OnResponse(request As DashaDemo.Ens.Msg.NewNPSRequest, ByRef response As Ens.StringContainer, callrequest As Ens.Request, callresponse As Ens.Response, pCompletionKey As %String) As %Status
{
    set sc = $$$OK
	if (pCompletionKey=..#NPSStartCOMPLETIONKEY) {
	    set jo = {}.%FromJSON(callresponse.StringValue)
	    quit:(jo.%Size()=0) $$$OK
	    // add to DB
	    set sc = ..SaveSurvey(request, jo)
	    quit:($$$ISERR(sc)) sc
	    // foreach conversation - start conversation
	    set iter = jo.%GetIterator()
	    set sc = $$$OK
	    while iter.%GetNext(.id , .obj ) {
	        $$$TRACE("convID = "_id)
	        set startConvMgs = ##class(DashaDemo.Ens.Msg.StartConversationRequest).%New()
	        set startConvMgs.ConversationId = id
	        set sc2 = ..SendRequestAsync("DashaOperation", startConvMgs, $$$YES, ..#ConversationCOMPLETIONKEY) 
	        set sc = $$$ADDSC(sc,sc2)
	    }
	}
	if (pCompletionKey=..#ConversationCOMPLETIONKEY) {
	    set sr = ##class(DashaDemo.DB.SurveyResults).ConvIDIndexOpen(callresponse.DashaConversationID)
        if $isObject(sr) {
            set sc = sr.UpdateResults(callresponse)
        }
	}
	return sc
}

Method SaveSurvey(pRequest As DashaDemo.Ens.Msg.NewNPSRequest, data As %DynamicObject) As %Status
{
	set survey = ##class(DashaDemo.DB.Survey).%New(pRequest.%Id())
    set iter = data.%GetIterator()
    while iter.%GetNext(.id , .obj ) {
        set surveyResult = ##class(DashaDemo.DB.SurveyResults).%New(survey, id, obj)
        do surveyResult.%Save()
    }	
    return survey.%Save() 
}

Storage Default
{
<Data name="NPSBusinessProcessDefaultData">
<Subscript>"NPSBusinessProcess"</Subscript>
<Value name="1">
<Value>DashaOperation</Value>
</Value>
</Data>
<DefaultData>NPSBusinessProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}