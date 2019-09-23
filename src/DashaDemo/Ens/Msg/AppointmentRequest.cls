Class DashaDemo.Ens.Msg.AppointmentRequest Extends Ens.Request
{

Property JSON As %String(MAXLEN = "");

Property FullName As %String(MAXLEN = 100);

Property ConvID As %String;

Property PhoneNumer As %String;

Property AppDate As %String;

Property AppTime As %String;

Property ServiceStatus As %String;

Property HasAppt As %Boolean;

Property CreatedTime As %String;

Property CompletedTime As %String;

/// Sends data to all clients using websocket
Method Send()
{
    set jo = {"action":"conv","conversations":[{"id":(..%Id()),"phone":(..PhoneNumer),"name":(..FullName), "hasappt":(..HasAppt), "apptime":(..AppTime),"appdate":(..AppDate),"ts":(..CompletedTime)}]}
    do ##class(DashaDemo.WEB.WebSocket).SendToAll(jo)
}

Storage Default
{
<Data name="ConversationRequestDefaultData">
<Subscript>"ConversationRequest"</Subscript>
<Value name="1">
<Value>JSON</Value>
</Value>
<Value name="2">
<Value>FullName</Value>
</Value>
<Value name="3">
<Value>ConvID</Value>
</Value>
<Value name="4">
<Value>PhoneNumer</Value>
</Value>
<Value name="5">
<Value>AppDate</Value>
</Value>
<Value name="6">
<Value>AppTime</Value>
</Value>
<Value name="7">
<Value>ServiceStatus</Value>
</Value>
<Value name="8">
<Value>HasAppt</Value>
</Value>
<Value name="9">
<Value>CreatedTime</Value>
</Value>
<Value name="10">
<Value>CompletedTime</Value>
</Value>
</Data>
<DefaultData>ConversationRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
