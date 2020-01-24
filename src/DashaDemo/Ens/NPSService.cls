Class DashaDemo.Ens.NPSService Extends Ens.BusinessService
{

Method OnProcessInput(pRequest As Ens.StringContainer, pOutput As Ens.StringContainer) As %Status
{
    try {
	    set npsMsg = ##class(DashaDemo.Ens.Msg.NewNPSRequest).%New()
	    set phones = {}.%FromJSON(pRequest.StringValue)
        set jsonArray = []
        set iter = phones.%GetIterator()
        while iter.%GetNext(.key , .phone ) {
            set jo = {"name":(phone), "data":{"phone":(phone),"timezone":(-4)}}
            do jsonArray.%Push(jo)
        }
        set npsMsg.PhonesJSONString = jsonArray.%ToJSON()
        $$$ThrowOnError(npsMsg.%Save())
        $$$ThrowOnError(..SendRequestAsync("NPSBusinessProcess",npsMsg))
        set pOutput = ##class(Ens.StringContainer).%New(npsMsg.%Id())
    } catch ex {
        return ex.AsStatus()
    }
    return $$$OK
}

}
