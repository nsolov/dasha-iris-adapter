/// Business Operation to create and manage calls
Class DashaDemo.Ens.DashaOperation Extends Ens.BusinessOperation [ Language = objectscript ]
{

Parameter ADAPTER = "Dasha.OutboundAdapter";

Property Adapter As Dasha.OutboundAdapter;

Parameter INVOCATION = "Queue";

Property Task As %String;

Property Group As %String;

Property CallBackURL As %String;

Method NewCall(pRequest As DashaDemo.Ens.Msg.NewCallRequest, Output pResponse As Ens.Response) As %Status
{
	try {
		$$$TRACE(pRequest.PhonesJSONString)
		set ids = ..Adapter.StartNPSSurvey(..Task, ..Group, ..CallBackURL, [].%FromJSON(pRequest.PhonesJSONString))
		$$$TRACE(ids.%ToJSON())

		// save to DB!
		set survey = ##class(DashaDemo.DB.Survey).%New(pRequest.%Id())
		set iter = ids.%GetIterator()
		while iter.%GetNext(.key , .obj ) {
			set surveyResult = ##class(DashaDemo.DB.SurveyResults).%New(survey, obj)
			do surveyResult.%Save()
		}
		do survey.Send() // send to all client using websocket
	} catch ex {
		return ex.AsStatus()	
	}
	return $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="DashaDemo.Ens.Msg.NewCallRequest"> 
		<Method>NewCall</Method>
	</MapItem>
</MapItems>
}

Parameter SETTINGS = "CallBackURL:Dasha,Task:Dasha,Group:Dasha,ReplyCodeActions,RetryInterval,AlertRetryGracePeriod:Alerting,FailureTimeout,QueueCountAlert:Alerting,QueueWaitAlert:Alerting,SendSuperSession";

}
