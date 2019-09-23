Class DashaDemo.Ens.Msg.SurveyResultsRequest Extends Ens.Request
{

Property DashaConversationID As %String;

Property ServiceStatus As %String;

Property ClientStatus As %String;

Property TaskStatus As %String;

Property CSIQ1 As %Integer;

Property CSIQ1Comment As %String(MAXLEN = 10000);

Property CSIQ2 As %Integer;

Property CSIQ2Comment As %String(MAXLEN = 10000);

Property NPSQ1 As %Integer;

Property NPSQ1Comment As %String(MAXLEN = 10000);

Property JSON As %String(MAXLEN = "");

Storage Default
{
<Data name="SurveyRequestDefaultData">
<Subscript>"SurveyRequest"</Subscript>
<Value name="1">
<Value>DashaConversationID</Value>
</Value>
<Value name="2">
<Value>ClientStatus</Value>
</Value>
<Value name="3">
<Value>TaskStatus</Value>
</Value>
<Value name="4">
<Value>CSIQ1</Value>
</Value>
<Value name="5">
<Value>CSIQ1Comment</Value>
</Value>
<Value name="6">
<Value>CSIQ2</Value>
</Value>
<Value name="7">
<Value>CSIQ2Comment</Value>
</Value>
<Value name="8">
<Value>NPSQ1</Value>
</Value>
<Value name="9">
<Value>NPSQ1Comment</Value>
</Value>
<Value name="10">
<Value>JSON</Value>
</Value>
<Value name="11">
<Value>ServiceStatus</Value>
</Value>
</Data>
<DefaultData>SurveyRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
