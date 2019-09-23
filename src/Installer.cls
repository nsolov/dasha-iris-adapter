Include %occInclude

/// Dasha Installer
Class Dasha.Installer
{

XData DashaInstall [ XMLNamespace = INSTALLER ]
{
<Manifest>
    <Var Name="NAMESPACE" Value="Dasha"/>
    <Var Name="SSLCONFIG" Value="dasha"/>
    <Var Name="RESTAPP" Value = "/dasha"/>
    <Var Name="UIAPP" Value = "/"/>
    <Var Name="Production" Value="DashaDemo.Ens.Production" />
    
    <Namespace Name="${NAMESPACE}" Create="yes" Code="${NAMESPACE}" Data="${NAMESPACE}">
        <Configuration>
            <Resource Name="%DB_${NAMESPACE}" 
                Permission="RW"
                Description="use Dasha database"/>
            <Database Name="${NAMESPACE}"
                Create="yes"
                Dir="${INSTALLDIR}/mgr/${NAMESPACE}"
                Resource="%DB_${NAMESPACE}"
                PublicPermissions="RW"/>
        </Configuration>
         
        <Import File="${SRCDIR}/Dasha" Recurse="1" IgnoreErrors="1"/>
        <Import File="${SRCDIR}/DashaDemo" Recurse="1" IgnoreErrors="1"/>
        <CSPApplication
            Url="${RESTAPP}"
            Description="REST App for webhooks"
            name="${RESTAPP}"
            Directory="${SRCDIR}"
            AuthenticationMethods="64"
            AutoCompile="0"
            Recurse="1"
            Resource=""
            Grant="%All" />  

        <CSPApplication
            Url="${UIAPP}"
            Description="UI App"
            name="${UIAPP}"
            Directory="${SRCDIR}/web"
            AuthenticationMethods="64"
            AutoCompile="0"
            Recurse="1"
            Resource=""
            Grant="%All"  />    
             
         <Production Name="${Production}" AutoStart="1">
         </Production>                
    </Namespace>  
    <Namespace Name="${CURRENTNAMESPACE}">
        <Invoke Class="Dasha.Installer" Method="SetDispatchClass" CheckStatus="1">
            <Arg Value="${RESTAPP}"/>
            <Arg Value="DashaDemo.WEB.WebHooksREST"/>
        </Invoke>
        <Invoke Class="Dasha.Installer" Method="CreateClientSSLConfig" CheckStatus="1">
            <Arg Value="${SSLCONFIG}"/>
        </Invoke>
        <Invoke Class="Dasha.Installer" Method="StartProduction" CheckStatus="1">
            <Arg Value="${NAMESPACE}"/>
            <Arg Value="${Production}"/>
        </Invoke>
    </Namespace>  
</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
    return ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "DashaInstall")
}

ClassMethod SetDispatchClass(pApp As %String = "", pClass As %String = "") As %Status
{
    set $namespace = "%SYS"
    set sc = ##class(Security.Applications).Exists(pApp,.app)
    return:($$$ISERR(sc)) sc
    set app.DispatchClass = pClass
    return app.%Save()
}

ClassMethod CreateClientSSLConfig(clientname) As %Status
{
  set $namespace = "%SYS"
  if '##class(Security.SSLConfigs).Exists(clientname) {
      return ##class(Security.SSLConfigs).Create(clientname)
  }
  return $$$OK
}

ClassMethod StartProduction(ns As %String, production As %String)
{
    set $namespace = ns
    return ##class(Ens.Director).StartProduction(production)
}

/// for development purpose only!!!
ClassMethod ImportCLS(dir As %String) As %Status
{
    set $namespace = "dasha"
    do $system.OBJ.LoadDir(dir_"/Dasha", "ck",, 1)
    do $system.OBJ.LoadDir(dir_"/DashaDemo", "ck",, 1)
}

}
