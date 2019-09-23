Class DashaDemo.DB.Appointment Extends %Persistent
{

/// Dasha conversation ID
Property ConvID As %String [ Required ];

Index ConvIDIndex On ConvID [ Unique ];

Property PhoneNumer As %String;

Property FullName As %String;

/// Appointment Date
Property AppDate As %String;

/// Appointment Time
Property AppTime As %String;

Property ServiceStatus As %String;

Property HasAppt As %Boolean;

Property CreatedTime As %String;

Property CompletedTime As %String;

/// JSON
Property JSON As %String(MAXLEN = "");

ClassMethod SaveConversation(data As DashaDemo.Ens.Msg.AppointmentRequest) As %Status
{
    try {
        set c = ##class(DashaDemo.DB.Appointment).%New()
        set c.ConvID = data.ConvID
        set c.PhoneNumer = data.PhoneNumer
        set c.FullName = data.FullName
        set c.AppDate = data.AppDate
        set c.AppTime = data.AppTime
        set c.ServiceStatus = data.ServiceStatus
        set c.HasAppt = data.HasAppt
        set c.CreatedTime = data.CreatedTime
        set c.CompletedTime = data.CompletedTime
        set c.JSON = data.JSON
        $$$ThrowOnError(c.%Save())
        do data.Send() // send data to all clients using websocket
        return $$$OK
    } catch ex {
        return ex.AsStatus()
    }
}

/// fetches top 100 conversations ordered by insert timestamp
Query AllConversations() As %SQLQuery [ SqlProc ]
{
    SELECT '['||List(xx)||']' Conversations FROM
    (SELECT TOP 100 JSON_OBJECT('id':ID,'name':FullName,'phone':PhoneNumer, 'hasappt':HasAppt, 'apptime':AppTime,'appdate':AppDate,'ts':CompletedTime) xx
        FROM DashaDemo_DB.Appointment
        ORDER BY CompletedTime ASC)
}

ClassMethod Clear() As %Integer
{
    &sql(DELETE FROM DashaDemo_DB.Appointment)
    return %ROWCOUNT
}

ClassMethod GetConversations() As %Library.DynamicObject
{
    try {
        set stmt = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(stmt.%PrepareClassQuery("DashaDemo.DB.Appointment","AllConversations"))
        set sqlResult = stmt.%Execute()
        if (sqlResult.%SQLCODE<0) { throw ##class(%Exception.SQL).CreateFromSQLCODE(sqlResult.%SQLCODE,sqlResult.%Message) }
        set convArray = []
        if (sqlResult.%Next()) { 
            if (sqlResult.%Get("Conversations")'="") {
                set convArray = [].%FromJSON(sqlResult.%Get("Conversations"))
            } 
        }
    } catch ex {
        do ex.Log()
        return {}
    }
    return { "action":"conv", "conversations":(convArray) }
}

Storage Default
{
<Data name="AppointmentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ConvID</Value>
</Value>
<Value name="3">
<Value>PhoneNumer</Value>
</Value>
<Value name="4">
<Value>FullName</Value>
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
<Value name="11">
<Value>JSON</Value>
</Value>
</Data>
<DataLocation>^DashaDemo.DB.AppointmentD</DataLocation>
<DefaultData>AppointmentDefaultData</DefaultData>
<IdLocation>^DashaDemo.DB.AppointmentD</IdLocation>
<IndexLocation>^DashaDemo.DB.AppointmentI</IndexLocation>
<StreamLocation>^DashaDemo.DB.AppointmentS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
