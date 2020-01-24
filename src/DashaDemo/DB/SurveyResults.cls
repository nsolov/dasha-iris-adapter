Class DashaDemo.DB.SurveyResults Extends %Persistent
{

Property Survey As DashaDemo.DB.Survey;

Property DashaConversationID As %String [ Required ];

Index ConvIDIndex On DashaConversationID [ Unique ];

Property Name As %String;

/// Phone Number
Property Phone As %String;

Property Timezone As %String;

Property ClientStatus As %String;

Property TaskStatus As %String;

Property ServiceStatus As %String;

Property CSIQ1 As %Integer;

Property CSIQ1Comment As %String(MAXLEN = 10000);

Property CSIQ2 As %Integer;

Property CSIQ2Comment As %String(MAXLEN = 10000);

Property NPSQ1 As %Integer;

Property NPSQ1Comment As %String(MAXLEN = 10000);

Method %OnNew(survey As DashaDemo.DB.Survey, convID, obj) As %Status
{
    set ..Survey = survey
    set ..DashaConversationID = convID
    set ..Name = obj.name
    set ..Phone = obj.phone
    set ..Timezone = obj.timezone
    return $$$OK
}

Method UpdateResults(obj As %DynamicObject) As %Status
{
    set ..ClientStatus = obj.ClientStatus
    set ..TaskStatus = obj.TaskStatus
    set ..CSIQ1 = obj.CSIQ1
    set ..CSIQ1Comment = obj.CSIQ1Comment
    set ..CSIQ2 = obj.CSIQ2
    set ..CSIQ2Comment = obj.CSIQ2Comment
    set ..NPSQ1 = obj.NPSQ1
    set ..NPSQ1Comment = obj.NPSQ1Comment
    set ..ServiceStatus = obj.ServiceStatus
    set sc = ..%Save()
    return:('sc) sc
    // send to all clients using websocket
    do ##class(DashaDemo.WEB.WebSocket).SendToAll(##class(DashaDemo.DB.Survey).GetSurveyResults(..Survey.SurveyMessageID))
    return $$$OK
}

Storage Default
{
<Data name="SurveyResultsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Survey</Value>
</Value>
<Value name="3">
<Value>DashaConversationID</Value>
</Value>
<Value name="4">
<Value>Phone</Value>
</Value>
<Value name="5">
<Value>ResultJSON</Value>
</Value>
<Value name="6">
<Value>Timezone</Value>
</Value>
<Value name="7">
<Value>ClientStatus</Value>
</Value>
<Value name="8">
<Value>TaskStatus</Value>
</Value>
<Value name="9">
<Value>CSIQ1</Value>
</Value>
<Value name="10">
<Value>CSIQ1Comment</Value>
</Value>
<Value name="11">
<Value>CSIQ2</Value>
</Value>
<Value name="12">
<Value>CSIQ2Comment</Value>
</Value>
<Value name="13">
<Value>NPSQ1</Value>
</Value>
<Value name="14">
<Value>NPSQ1Comment</Value>
</Value>
<Value name="15">
<Value>Name</Value>
</Value>
<Value name="16">
<Value>ServiceStatus</Value>
</Value>
</Data>
<DataLocation>^DashaDemo.DB.SurveyResultsD</DataLocation>
<DefaultData>SurveyResultsDefaultData</DefaultData>
<IdLocation>^DashaDemo.DB.SurveyResultsD</IdLocation>
<IndexLocation>^DashaDemo.DB.SurveyResultsI</IndexLocation>
<StreamLocation>^DashaDemo.DB.SurveyResultsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
