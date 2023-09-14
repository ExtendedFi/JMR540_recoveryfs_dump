<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:cwmp="urn:dslforum-org:cwmp-1-0">
<SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
<cwmp:SetParameterAttributes>
<ParameterList SOAP-ENC:arrayType="cwmp:SetParameterAttributesStruct[3]">
<SetParameterAttributesStruct>
<Name>Device.DeviceInfo.HardwareVersion</Name>
<NotificationChange>1</NotificationChange>
<Notification>1</Notification>
<AccessListChange>0</AccessListChange>
<AccessList SOAP-ENC:arrayType="xsd:string[0]"></AccessList></SetParameterAttributesStruct>
<SetParameterAttributesStruct>
<Name>Device.ManagementServer.ParameterKey</Name>
<NotificationChange>1</NotificationChange>
<Notification>1</Notification>
<AccessListChange>0</AccessListChange>
<AccessList SOAP-ENC:arrayType="xsd:string[0]"></AccessList></SetParameterAttributesStruct>
<SetParameterAttributesStruct>
<Name>Device.ManagementServer.ConnectionRequestURL</Name>
<NotificationChange>1</NotificationChange>
<Notification>2</Notification>
<AccessListChange>0</AccessListChange>
<AccessList SOAP-ENC:arrayType="xsd:string[0]"></AccessList></SetParameterAttributesStruct>
</ParameterList></cwmp:SetParameterAttributes></SOAP-ENV:Body></SOAP-ENV:Envelope>
