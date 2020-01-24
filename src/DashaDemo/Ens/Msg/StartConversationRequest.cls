Class DashaDemo.Ens.Msg.StartConversationRequest Extends Ens.Request
{

Property ConversationId as %String [Required ];

Storage Default
{
<Data name="StartConversationRequestDefaultData">
<Subscript>"StartConversationRequest"</Subscript>
<Value name="1">
<Value>ConversationId</Value>
</Value>
</Data>
<DefaultData>StartConversationRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}