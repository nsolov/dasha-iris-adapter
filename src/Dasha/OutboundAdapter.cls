Class Dasha.OutboundAdapter Extends (Ens.OutboundAdapter, Dasha.Client)
{

Property Credentials As %String;

Property NPSQueueID As %String;

/// List of properties can be set as settings in the configuration file
/// format is a comma separated list of property names
Parameter SETTINGS = "SSLConfig:Dasha Connection:sslConfigSelector,AuthHost:Dasha Connection,DashaAPI:Dasha Connection,ClientID:Dasha Connection,Credentials:Dasha Connection:credentialsSelector";

Method OnInit() As %Status
{
	do ##class(Ens.Config.Credentials).GetCredentialsObj(.cred, "Dasha.OutboundAdapter", "Ens.Config.Credentials", ..Credentials)
	return:(cred="") $$$ERROR($$$GeneralError, "Unable to create Dasha Client object - setup the credentials") 
	set sc = ..SetClientProps(..AuthHost, ..DashaAPI, ..ClientID, ..SSLConfig, cred.Username, cred.Password)
    return:($$$ISERR(sc)) $$$ERROR($$$GeneralError, "Unable to create Dasha Client object") 
    return $$$OK
}

}
