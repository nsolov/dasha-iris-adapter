Class DashaDemo.Ens.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="DashaDemo.Ens.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="DBOperation" Category="" ClassName="DashaDemo.Ens.DBOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="DashaOperation" Category="" ClassName="DashaDemo.Ens.DashaOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="AuthHost">auth.dasha.ai</Setting>
    <Setting Target="Adapter" Name="ClientID"></Setting>
    <Setting Target="Adapter" Name="DashaAPI">api.us.dasha.ai</Setting>
    <Setting Target="Adapter" Name="SSLConfig"></Setting>
    <Setting Target="Host" Name="Group">med-in</Setting>
    <Setting Target="Host" Name="Task">us-demo-medical-incoming-us</Setting>
    <Setting Target="Adapter" Name="Credentials"></Setting>
    <Setting Target="Host" Name="CallBackURL"></Setting>
  </Item>
  <Item Name="NPSService" Category="" ClassName="DashaDemo.Ens.NPSService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="NPSResultsService" Category="" ClassName="DashaDemo.Ens.NPSResultsService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="AppointmentService" Category="" ClassName="DashaDemo.Ens.AppointmentService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
</Production>
}

}
