Class DashaDemo.Ens.Msg.NewNPSRequest Extends Ens.Request
{

Property PhonesJSONString As %String(MAXLEN = "");

Storage Default
{
<Data name="NewNPSRequestDefaultData">
<Subscript>"NewNPSRequest"</Subscript>
<Value name="1">
<Value>PhonesJSONString</Value>
</Value>
</Data>
<DefaultData>NewNPSRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}