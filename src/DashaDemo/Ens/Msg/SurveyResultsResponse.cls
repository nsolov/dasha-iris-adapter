Class DashaDemo.Ens.Msg.SurveyResultsResponse Extends Ens.Response
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
<Data name="SurveyResultsResponseDefaultData">
<Subscript>"SurveyResultsResponse"</Subscript>
<Value name="1">
<Value>DashaConversationID</Value>
</Value>
<Value name="2">
<Value>ServiceStatus</Value>
</Value>
<Value name="3">
<Value>ClientStatus</Value>
</Value>
<Value name="4">
<Value>TaskStatus</Value>
</Value>
<Value name="5">
<Value>CSIQ1</Value>
</Value>
<Value name="6">
<Value>CSIQ1Comment</Value>
</Value>
<Value name="7">
<Value>CSIQ2</Value>
</Value>
<Value name="8">
<Value>CSIQ2Comment</Value>
</Value>
<Value name="9">
<Value>NPSQ1</Value>
</Value>
<Value name="10">
<Value>NPSQ1Comment</Value>
</Value>
<Value name="11">
<Value>JSON</Value>
</Value>
</Data>
<DefaultData>SurveyResultsResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}