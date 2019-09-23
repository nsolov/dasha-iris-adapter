Class DashaDemo.DB.Survey Extends %Persistent
{

/// Internal IRIS ID, based on ID of original Message in the Interoperability Production
Property SurveyMessageID As %Integer [ Required ];

Index SurveyMessageIDIndex On SurveyMessageID [ Unique ];

Property TS As %PosixTime;

Method %OnNew(msgID As %Integer) As %Status
{
    set ..SurveyMessageID = msgID
    set ..TS = ##class(%Library.PosixTime).CurrentTimeStamp()
    return $$$OK
}

Method Send()
{
    set jo = {"action":"NPSlist","surveys":[{"id":(..SurveyMessageID),"ts":(##class(%Library.PosixTime).LogicalToOdbc(..TS)),"status":" "}]}
    do ##class(DashaDemo.WEB.WebSocket).SendToAll(jo)
}

/// fetches top 100 surveys ordered by Timestamp
Query AllSurveys() As %SQLQuery [ SqlProc ]
{
    SELECT '['||List(xx)||']' Surveys FROM
    (SELECT TOP 100 JSON_OBJECT('id':SurveyMessageID,'ts':%ODBCOUT(TS),'status':' ') as xx
        FROM DashaDemo_DB.Survey
        ORDER BY TS ASC)
}

/// fetch survey results
Query SurveyResults(id) As %SQLQuery [ SqlProc ]
{
    SELECT '['||List(xx)||']' Results FROM
    (SELECT TOP 1000 JSON_OBJECT('convid':DashaConversationID, 'CSIQ1':CSIQ1, 'CSIQ1Comment':CSIQ1Comment, 'CSIQ2':CSIQ2, 'CSIQ2Comment':CSIQ2Comment, 'NPSQ1':NPSQ1, 'NPSQ1Comment':NPSQ1Comment, 'phone':Phone, 'taskStatus':TaskStatus, 'clientStatus':ClientStatus, 'serviceStatus':ServiceStatus) as xx
        FROM DashaDemo_DB.SurveyResults
        WHERE Survey->SurveyMessageID = :id
        ORDER BY ID DESC)
}

ClassMethod GetSurveys() As %Library.DynamicObject
{
    try {
        set stmt = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(stmt.%PrepareClassQuery("DashaDemo.DB.Survey","AllSurveys"))
            
        set sqlResult = stmt.%Execute()
        if (sqlResult.%SQLCODE<0) { throw ##class(%Exception.SQL).CreateFromSQLCODE(sqlResult.%SQLCODE,sqlResult.%Message) }
        set surveysArray = []
        if (sqlResult.%Next()) { 
            if (sqlResult.%Get("Surveys")'="") {
                set surveysArray = [].%FromJSON(sqlResult.%Get("Surveys"))
            } 
        }
    } catch ex {
        do ex.Log()
        return {}
    }
    return { "action":"NPSlist", "surveys":(surveysArray) }
}

ClassMethod GetSurveyResults(id As %Integer) As %Library.DynamicObject
{
    try {
        set stmt = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(stmt.%PrepareClassQuery("DashaDemo.DB.Survey","SurveyResults"))
            
        set sqlResult = stmt.%Execute(id)
        if (sqlResult.%SQLCODE<0) { throw ##class(%Exception.SQL).CreateFromSQLCODE(sqlResult.%SQLCODE,sqlResult.%Message) }
        set surveysArray = []
        if (sqlResult.%Next()) { 
            if (sqlResult.%Get("Results")'="") {
                set surveysArray = [].%FromJSON(sqlResult.%Get("Results"))
            } 
        }
    } catch ex {
        do ex.Log()
        return {}
    }
    return { "action":"npsresults", "id":(id), "results":(surveysArray) }
}

ClassMethod Clear() As %Status
{
    &sql(DELETE FROM DashaDemo_DB.SurveyResults)
    &sql(DELETE FROM DashaDemo_DB.Survey)
    return %ROWCOUNT
}

Storage Default
{
<Data name="SurveyDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SurveyMessageID</Value>
</Value>
<Value name="3">
<Value>TS</Value>
</Value>
</Data>
<DataLocation>^DashaDemo.DB.SurveyD</DataLocation>
<DefaultData>SurveyDefaultData</DefaultData>
<IdLocation>^DashaDemo.DB.SurveyD</IdLocation>
<IndexLocation>^DashaDemo.DB.SurveyI</IndexLocation>
<StreamLocation>^DashaDemo.DB.SurveyS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
