unit PCI1751_Detect;

interface

uses
  Windows;

function getPortsWDM(DeviceID: String; const Enumerator: PAnsiChar = nil): Boolean;//(var ports: array of TDetectedPort; guid1: TGUID; portPrefix: string): Boolean;


implementation

uses
  SysUtils;

const
  setupapi = 'setupapi.dll';

const
  DIGCF_DEFAULT         = $00000001;  // only valid with DIGCF_DEVICEINTERFACE
  DIGCF_PRESENT         = $00000002;
  DIGCF_ALLCLASSES      = $00000004;
  DIGCF_PROFILE         = $00000008;
  DIGCF_DEVICEINTERFACE = $00000010;

type
  GUID = TGUID;
  ULONG_PTR = PULONG;
  HDEVINFO = THandle;
  PVOID = Pointer;

  SP_DEVINFO_DATA = record
      cbSize: DWORD;
      ClassGuid: GUID;
      DevInst: DWORD;    // DEVINST handle
      Reserved: ULONG_PTR;
  end;
  PSP_DEVINFO_DATA = ^SP_DEVINFO_DATA;

  SP_DEVICE_INTERFACE_DATA = record
    cbSize: DWORD;
    InterfaceClassGuid: GUID;
    Flags: DWORD;
    Reserved: ULONG_PTR;
  end;
  PSP_DEVICE_INTERFACE_DATA = ^SP_DEVICE_INTERFACE_DATA;

const
  SPINT_ACTIVE  = $00000001;
  SPINT_DEFAULT = $00000002;
  SPINT_REMOVED = $00000004;

type
  SP_DEVICE_INTERFACE_DETAIL_DATA_A = record
    cbSize: DWORD;
    //DevicePath: array of CHAR;
  end;
  PSP_DEVICE_INTERFACE_DETAIL_DATA_A = ^SP_DEVICE_INTERFACE_DETAIL_DATA_A;

const
  SPDRP_DEVICEDESC                  = $00000000;
  SPDRP_HARDWAREID                  = $00000001;
  SPDRP_COMPATIBLEIDS               = $00000002;
  SPDRP_UNUSED0                     = $00000003;
  SPDRP_SERVICE                     = $00000004;
  SPDRP_UNUSED1                     = $00000005;
  SPDRP_UNUSED2                     = $00000006;
  SPDRP_CLASS                       = $00000007;
  SPDRP_CLASSGUID                   = $00000008;
  SPDRP_DRIVER                      = $00000009;
  SPDRP_CONFIGFLAGS                 = $0000000A;
  SPDRP_MFG                         = $0000000B;
  SPDRP_FRIENDLYNAME                = $0000000C;
  SPDRP_LOCATION_INFORMATION        = $0000000D;
  SPDRP_PHYSICAL_DEVICE_OBJECT_NAME = $0000000E;
  SPDRP_CAPABILITIES                = $0000000F;
  SPDRP_UI_NUMBER                   = $00000010;
  SPDRP_UPPERFILTERS                = $00000011;
  SPDRP_LOWERFILTERS                = $00000012;
  SPDRP_BUSTYPEGUID                 = $00000013;
  SPDRP_LEGACYBUSTYPE               = $00000014;
  SPDRP_BUSNUMBER                   = $00000015;
  SPDRP_ENUMERATOR_NAME             = $00000016;
  SPDRP_SECURITY                    = $00000017;
  SPDRP_SECURITY_SDS                = $00000018;
  SPDRP_DEVTYPE                     = $00000019;
  SPDRP_EXCLUSIVE                   = $0000001A;
  SPDRP_CHARACTERISTICS             = $0000001B;
  SPDRP_ADDRESS                     = $0000001C;
  SPDRP_UI_NUMBER_DESC_FORMAT       = $0000001D;
  SPDRP_DEVICE_POWER_DATA           = $0000001E;
  SPDRP_REMOVAL_POLICY              = $0000001F;
  SPDRP_REMOVAL_POLICY_HW_DEFAULT   = $00000020;
  SPDRP_REMOVAL_POLICY_OVERRIDE     = $00000021;
  SPDRP_INSTALL_STATE               = $00000022;
  SPDRP_LOCATION_PATHS              = $00000023;
  SPDRP_MAXIMUM_PROPERTY            = $00000024;

  DICS_ENABLE     = $00000001;
  DICS_DISABLE    = $00000002;
  DICS_PROPCHANGE = $00000003;
  DICS_START      = $00000004;
  DICS_STOP       = $00000005;

  DICS_FLAG_GLOBAL         = $00000001;
  DICS_FLAG_CONFIGSPECIFIC = $00000002;
  DICS_FLAG_CONFIGGENERAL  = $00000004;

  DIREG_DEV  = $00000001;
  DIREG_DRV  = $00000002;
  DIREG_BOTH = $00000004;

  DIOCR_INSTALLER = $00000001;
  DIOCR_INTERFACE = $00000002;

var
  hSetupapi: HINST;
  SetupDiClassGuidsFromNameA: function(
    ClassName: LPCTSTR;
    ClassGuidList: PGUID;
    ClassGuidListSize: DWORD;
    RequiredSize: PDWORD
  ): LongBool; stdcall;
  SetupDiGetClassDevsA: function(
    ClassGuid: PGUID;
    Enumerator: LPCSTR;
    hwndParent: HWND;
    Flags: DWORD
  ): HDEVINFO; stdcall;
  SetupDiDestroyDeviceInfoList: function(
    DeviceInfoSet: HDEVINFO
  ): LongBool; stdcall;
  SetupDiEnumDeviceInfo: function(
    DeviceInfoSet: HDEVINFO;
    MemberIndex: DWORD;
    DeviceInfoData: PSP_DEVINFO_DATA
  ): LongBool; stdcall;
  SetupDiEnumDeviceInterfaces: function(
    DeviceInfoSet: HDEVINFO;
    DeviceInfoData: PSP_DEVINFO_DATA;
    InterfaceClassGuid: PGUID;
    MemberIndex: DWORD;
    DeviceInterfaceData: PSP_DEVICE_INTERFACE_DATA
  ): LongBool; stdcall;
  SetupDiGetDeviceInterfaceDetailA: function(
    DeviceInfoSet: HDEVINFO;
    DeviceInterfaceData: PSP_DEVICE_INTERFACE_DATA;
    DeviceInterfaceDetailData: PSP_DEVICE_INTERFACE_DETAIL_DATA_A;
    DeviceInterfaceDetailDataSize: DWORD;
    RequiredSize: PDWORD;
    DeviceInfoData: PSP_DEVINFO_DATA
  ): LongBool; stdcall;
  SetupDiGetDeviceInstanceIdA: function(
    DeviceInfoSet: HDEVINFO;
    DeviceInfoData: PSP_DEVINFO_DATA;
    DeviceInstanceId: LPSTR;
    DeviceInstanceIdSize: DWORD;
    RequiredSize: PDWORD
  ): LongBool; stdcall;
  SetupDiGetDeviceRegistryPropertyA: function(
    DeviceInfoSet: HDEVINFO;
    DeviceInfoData: PSP_DEVINFO_DATA;
    Property1: DWORD;
    PropertyRegDataType: PDWORD;
    PropertyBuffer: PBYTE;
    PropertyBufferSize: DWORD;
    RequiredSize: PDWORD
  ): LongBool; stdcall;
  SetupDiOpenClassRegKeyExA: function(
    ClassGuid: PGUID;
    samDesired: REGSAM;
    Flags: DWORD;
    MachineName: LPCTSTR;
    Reserved: PVOID
  ): HKEY; stdcall;
  SetupDiOpenDevRegKey: function(
    DeviceInfoSet: HDEVINFO;
    DeviceInfoData: PSP_DEVINFO_DATA;
    Scope: DWORD;
    HwProfile: DWORD;
    KeyType: DWORD;
    samDesired: REGSAM
  ): HKEY; stdcall;


procedure getPortResourcesWDMConfigManager({var port: TDetectedPort; }devInst1: DEVINST);
var
  logConf: LOG_CONF;
  resDesc, resDescPrev: RES_DES;
  resId: RESOURCEID;
  size, resDescBufferSize: ULONG;
  resDescBuffer: PChar;
begin
  if (@CM_Get_First_Log_Conf <> nil)
     and
     (@CM_Free_Log_Conf_Handle <> nil)
     and
     (@CM_Get_Next_Res_Des <> nil)
     and
     (@CM_Free_Res_Des_Handle <> nil)
     and
     (@CM_Get_Res_Des_Data_Size <> nil)
     and
     (@CM_Get_Res_Des_Data <> nil) then
  begin
    if CM_Get_First_Log_Conf(@logConf, devInst1, ALLOC_LOG_CONF) = CR_SUCCESS then
    begin
      resDescPrev := INVALID_HANDLE_VALUE;
      if CM_Get_Next_Res_Des(@resDesc, logConf, ResType_All, @resId, 0) = CR_SUCCESS then
      begin
        resDescBufferSize := 100;
        GetMem(resDescBuffer, resDescBufferSize);
        try
          repeat
            if resDescPrev <> INVALID_HANDLE_VALUE then
              CM_Free_Res_Des_Handle(resDescPrev);
            if CM_Get_Res_Des_Data_Size(@size, resDesc, 0) = CR_SUCCESS then
            begin
              if size > 0 then
              begin
                if size > resDescBufferSize then
                begin
                  ReallocMem(resDescBuffer, size);
                  resDescBufferSize := size;
                end;
                if CM_Get_Res_Des_Data(resDesc, resDescBuffer, size, 0) = CR_SUCCESS then
                  extractResourceDesc(port, resId, resDescBuffer, size);
              end;
            end;
            resDescPrev := resDesc;
          until CM_Get_Next_Res_Des(@resDesc, resDesc, ResType_All, @resId, 0) <> CR_SUCCESS;
          if resDescPrev <> INVALID_HANDLE_VALUE then
            CM_Free_Res_Des_Handle(resDescPrev);
        finally
          FreeMem(resDescBuffer);
        end;
      end;
      CM_Free_Log_Conf_Handle(logConf);
    end
  end;
end;

function getPortsWDM(DeviceID: String; const Enumerator: PAnsiChar = nil): Boolean;
var
  i, n: Integer;
  devInfoList: HDEVINFO;
  devInfoData: SP_DEVINFO_DATA;
  buffer: array[0..255] of Char;
  instanceId, friendlyName, hardwareID, portName: string;
  key: HKEY;
  type1, size: DWORD;
begin
  Result := False;
  if (@SetupDiClassGuidsFromNameA <> nil)
     and
     (@SetupDiGetClassDevsA <> nil)
     and
     (@SetupDiDestroyDeviceInfoList <> nil)
     and
     (@SetupDiEnumDeviceInfo <> nil)
     and
     (@SetupDiEnumDeviceInterfaces <> nil)
     and
     (@SetupDiGetDeviceInterfaceDetailA <> nil)
     and
     (@SetupDiGetDeviceInstanceIdA <> nil)
     and
     (@SetupDiGetDeviceRegistryPropertyA <> nil)
     and
     (@SetupDiOpenClassRegKeyExA <> nil)
     and
     (@SetupDiOpenDevRegKey <> nil) then
  begin
    devInfoList :=
      SetupDiGetClassDevsA(
        nil,{@guid1,}
        Enumerator,
        0,
        DIGCF_PRESENT or DIGCF_ALLCLASSES
      );
    if devInfoList <> INVALID_HANDLE_VALUE then
    begin
      devInfoData.cbSize := sizeof(SP_DEVINFO_DATA);
      i := 0;
      while SetupDiEnumDeviceInfo(devInfoList, i, @devInfoData) do
      begin
        if SetupDiGetDeviceInstanceIdA(devInfoList, @devInfoData, @buffer, sizeof(buffer), nil) then
        begin
          instanceId := buffer;
          if SetupDiGetDeviceRegistryPropertyA(devInfoList, @devInfoData, SPDRP_FRIENDLYNAME, nil, @buffer, sizeof(buffer), nil) then
            friendlyName := buffer
          else if SetupDiGetDeviceRegistryPropertyA(devInfoList, @devInfoData, SPDRP_DEVICEDESC, nil, @buffer, sizeof(buffer), nil) then
            friendlyName := buffer
          else
            friendlyName := '';

          if SetupDiGetDeviceRegistryPropertyA(devInfoList, @devInfoData, SPDRP_HARDWAREID, nil, @buffer, sizeof(buffer), nil) then
            hardwareID := buffer;

          if Pos(UpperCase(DeviceID), hardwareID) > 0 then
            write('->');
          Writeln('  ',friendlyname, #9, hardwareID);
          // retrieve port name from registry, for example: LPT1, LPT2, COM1, COM2
          key :=
            SetupDiOpenDevRegKey(
              devInfoList,
              @devInfoData,
              DICS_FLAG_GLOBAL,
              0,
              DIREG_DEV,
              KEY_READ
            );
          if key <> INVALID_HANDLE_VALUE then
          begin
            size := 255;
//            if RegQueryValueEx(key, 'PortName', nil, @type1, @buffer, @size) = ERROR_SUCCESS then
//            begin
//              buffer[size] := #0;
//              portName := buffer;
//              RegCloseKey(key);
//            end;
//            if (Copy(portName, 1, Length(portPrefix)) = portPrefix) then
//            begin
//              n := StrToIntDef(Copy(portName, Length(portPrefix) + 1, Length(portName)), 0) - 1;
//              if (n >= 0) and (n < Length(ports)) then
//              begin
//                Result := True;
//                if ports[n].friendlyName = '' then
//                  if friendlyName <> '' then
//                    ports[n].friendlyName := friendlyName
//                  else
//                    friendlyName := portName;
//                // retrieve port hardware address
                getPortResourcesWDMConfigManager(ports[n], devInfoData.DevInst);
//              end;
//            end;
          end;
        end;
        Inc(i);
      end;
      SetupDiDestroyDeviceInfoList(devInfoList);
    end;
  end;
end;  


initialization
  // dynamically load all optional libraries
//  @toolhelp32ReadProcessMemory := nil;
  @SetupDiClassGuidsFromNameA := nil;
  @SetupDiGetClassDevsA := nil;
  @SetupDiDestroyDeviceInfoList := nil;
  @SetupDiEnumDeviceInfo := nil;
  @SetupDiEnumDeviceInterfaces := nil;
  @SetupDiGetDeviceInterfaceDetailA := nil;
  @SetupDiGetDeviceInstanceIdA := nil;
  @SetupDiGetDeviceRegistryPropertyA := nil;
  @SetupDiOpenClassRegKeyExA := nil;
  @SetupDiOpenDevRegKey := nil;
//  @CM_Get_First_Log_Conf := nil;
//  @CM_Free_Log_Conf_Handle := nil;
//  @CM_Get_Next_Res_Des := nil;
//  @CM_Free_Res_Des_Handle := nil;
//  @CM_Get_Res_Des_Data_Size := nil;
//  @CM_Get_Res_Des_Data := nil;
//  hKernel32 := LoadLibrary('kernel32.dll');
//  if hKernel32 <> 0 then
//    @toolhelp32ReadProcessMemory := GetProcAddress(hKernel32, 'Toolhelp32ReadProcessMemory');
  hSetupapi := LoadLibrary('setupapi.dll');
  if hSetupapi <> 0 then
  begin
    @SetupDiClassGuidsFromNameA := GetProcAddress(hSetupapi, 'SetupDiClassGuidsFromNameA');
    @SetupDiGetClassDevsA := GetProcAddress(hSetupapi, 'SetupDiGetClassDevsA');
    @SetupDiDestroyDeviceInfoList := GetProcAddress(hSetupapi, 'SetupDiDestroyDeviceInfoList');
    @SetupDiEnumDeviceInfo := GetProcAddress(hSetupapi, 'SetupDiEnumDeviceInfo');
    @SetupDiEnumDeviceInterfaces := GetProcAddress(hSetupapi, 'SetupDiEnumDeviceInterfaces');
    @SetupDiGetDeviceInterfaceDetailA := GetProcAddress(hSetupapi, 'SetupDiGetDeviceInterfaceDetailA');
    @SetupDiGetDeviceInstanceIdA := GetProcAddress(hSetupapi, 'SetupDiGetDeviceInstanceIdA');
    @SetupDiGetDeviceRegistryPropertyA := GetProcAddress(hSetupapi, 'SetupDiGetDeviceRegistryPropertyA');
    @SetupDiOpenClassRegKeyExA := GetProcAddress(hSetupapi, 'SetupDiOpenClassRegKeyExA'); 
    @SetupDiOpenDevRegKey := GetProcAddress(hSetupapi, 'SetupDiOpenDevRegKey');
  end;
//  hCfgmgr32 := LoadLibrary('cfgmgr32.dll');
//  if hCfgmgr32 <> 0 then
//  begin
//    @CM_Get_First_Log_Conf := GetProcAddress(hCfgmgr32, 'CM_Get_First_Log_Conf');
//    @CM_Free_Log_Conf_Handle := GetProcAddress(hCfgmgr32, 'CM_Free_Log_Conf_Handle');
//    @CM_Get_Next_Res_Des := GetProcAddress(hCfgmgr32, 'CM_Get_Next_Res_Des');
//    @CM_Free_Res_Des_Handle := GetProcAddress(hCfgmgr32, 'CM_Free_Res_Des_Handle');
//    @CM_Get_Res_Des_Data_Size := GetProcAddress(hCfgmgr32, 'CM_Get_Res_Des_Data_Size');
//    @CM_Get_Res_Des_Data := GetProcAddress(hCfgmgr32, 'CM_Get_Res_Des_Data');
//  end;
finalization
//  FreeLibrary(hCfgmgr32);
  FreeLibrary(hSetupapi);
//  FreeLibrary(hKernel32);

end.
