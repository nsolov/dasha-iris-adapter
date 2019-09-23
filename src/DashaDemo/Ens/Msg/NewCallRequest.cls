Class DashaDemo.Ens.Msg.NewCallRequest Extends Ens.Request
{

Property PhonesJSONString As %String(MAXLEN = "");

Storage Default
{
<Data name="NewCallRequestDefaultData">
<Subscript>"NewCallRequest"</Subscript>
<Value name="1">
<Value>PhonesJSONString</Value>
</Value>
</Data>
<DefaultData>NewCallRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
