/// Business Operation to create and manage calls
Class DashaDemo.Ens.DashaOperation Extends Ens.BusinessOperation [ Language = objectscript ]
{

Parameter ADAPTER = "Dasha.OutboundAdapter";

Property Adapter As Dasha.OutboundAdapter;

Parameter INVOCATION = "Queue";

Property Task As %String;

Property Group As %String;

/// Creates conversations in Dasha service and Response an array of conversation ID
Method StartNPSSurvey(pRequest As DashaDemo.Ens.Msg.NewNPSRequest, Output pResponse As Ens.StringContainer) As %Status
{
	try {
	    $$$TRACE(pRequest.PhonesJSONString)
	    $$$ThrowOnError(..Adapter.NewConversation(.conversationIDs,..Task,..Group,[].%FromJSON(pRequest.PhonesJSONString)))
	    $$$TRACE(conversationIDs.%ToJSON())
	    set pResponse = ##class(Ens.StringContainer).%New(conversationIDs.%ToJSON()) 
	} catch ex {
	    do ex.Log()
	    return ex.AsStatus()
	}
	return $$$OK
}

Method StartConversation(pRequest As DashaDemo.Ens.Msg.StartConversationRequest, Output pResponse As Ens.StringContainer) As %Status
{
    $$$TRACE("ConversationId:"_pRequest.ConversationId)
    do ..DeferResponse(.token)
    set ^conversations(pRequest.ConversationId) = token
	$$$ThrowOnError(..Adapter.AddConversationsToQueue(pRequest.ConversationId))
	return $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="DashaDemo.Ens.Msg.StartConversationRequest"> 
        <Method>StartConversation</Method>
    </MapItem>
    <MapItem MessageType="DashaDemo.Ens.Msg.NewNPSRequest"> 
        <Method>StartNPSSurvey</Method>
    </MapItem>
</MapItems>
}

Parameter SETTINGS = "Task:Dasha,Group:Dasha,ReplyCodeActions,RetryInterval,AlertRetryGracePeriod:Alerting,FailureTimeout,QueueCountAlert:Alerting,QueueWaitAlert:Alerting,SendSuperSession";

}
