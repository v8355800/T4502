unit DeviceDetect;

interface

uses
  Windows, Classes;

type
  PDetectedDevice = ^TDetectedDevice;
  TDetectedDevice = record
    friendlyName : string;
    hardwareID   : string;
    portStart    : Int64;
    portLength   : LongWord;
    irq          : Boolean;
    irqLevel     : LongWord;
    dma          : Boolean;
    dmaChannel   : LongWord;
  end;

  TDetectedDeviceList = class(TList)
  private
    function Get(Index: Integer): PDetectedDevice;
  public
    destructor Destroy; override;
    function Add(Value: PDetectedDevice): Integer;
    property Items[Index: Integer]: PDetectedDevice read Get; default;
  end;

function getDevicesWDM(DevList: TDetectedDeviceList; DeviceID: String; const Enumerator: PAnsiChar = nil): Boolean;//(var ports: array of TDetectedPort; guid1: TGUID; portPrefix: string): Boolean;

implementation

uses
  SysUtils;

  { TDetectedDeviceList }

  function TDetectedDeviceList.Add(Value: PDetectedDevice): Integer;
  begin
    Result := inherited Add(Value);
  end;

  destructor TDetectedDeviceList.Destroy;
  var
    i: Integer;
  begin
    for i := 0 to Count - 1 do
      FreeMem(Items[i]);
    inherited;
  end;

  function TDetectedDeviceList.Get(Index: Integer): PDetectedDevice;
  begin
    Result := PDetectedDevice(inherited Get(Index));
  end;

{$ALIGN 1}

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

{$ALIGN 8}

{$ALIGN 1}

const
  cfgmgr32 = 'cfgmgr32.dll';

const
  BASIC_LOG_CONF    = $00000000;
  FILTERED_LOG_CONF = $00000001;
  ALLOC_LOG_CONF    = $00000002;
  BOOT_LOG_CONF     = $00000003;
  FORCED_LOG_CONF   = $00000004;
  OVERRIDE_LOG_CONF = $00000005;
  NUM_LOG_CONF      = $00000006;
  LOG_CONF_BITS     = $00000007;

  CR_SUCCESS                  = $00000000;
  CR_DEFAULT                  = $00000001;
  CR_OUT_OF_MEMORY            = $00000002;
  CR_INVALID_POINTER          = $00000003;
  CR_INVALID_FLAG             = $00000004;
  CR_INVALID_DEVNODE          = $00000005;
  CR_INVALID_DEVINST          = CR_INVALID_DEVNODE;
  CR_INVALID_RES_DES          = $00000006;
  CR_INVALID_LOG_CONF         = $00000007;
  CR_INVALID_ARBITRATOR       = $00000008;
  CR_INVALID_NODELIST         = $00000009;
  CR_DEVNODE_HAS_REQS         = $0000000A;
  CR_DEVINST_HAS_REQS         = CR_DEVNODE_HAS_REQS;
  CR_INVALID_RESOURCEID       = $0000000B;
  CR_DLVXD_NOT_FOUND          = $0000000C;
  CR_NO_SUCH_DEVNODE          = $0000000D;
  CR_NO_SUCH_DEVINST          = CR_NO_SUCH_DEVNODE;
  CR_NO_MORE_LOG_CONF         = $0000000E;
  CR_NO_MORE_RES_DES          = $0000000F;
  CR_ALREADY_SUCH_DEVNODE     = $00000010;
  CR_ALREADY_SUCH_DEVINST     = CR_ALREADY_SUCH_DEVNODE;
  CR_INVALID_RANGE_LIST       = $00000011;
  CR_INVALID_RANGE            = $00000012;
  CR_FAILURE                  = $00000013;
  CR_NO_SUCH_LOGICAL_DEV      = $00000014;
  CR_CREATE_BLOCKED           = $00000015;
  CR_NOT_SYSTEM_VM            = $00000016;
  CR_REMOVE_VETOED            = $00000017;
  CR_APM_VETOED               = $00000018;
  CR_INVALID_LOAD_TYPE        = $00000019;
  CR_BUFFER_SMALL             = $0000001A;
  CR_NO_ARBITRATOR            = $0000001B;
  CR_NO_REGISTRY_HANDLE       = $0000001C;
  CR_REGISTRY_ERROR           = $0000001D;
  CR_INVALID_DEVICE_ID        = $0000001E;
  CR_INVALID_DATA             = $0000001F;
  CR_INVALID_API              = $00000020;
  CR_DEVLOADER_NOT_READY      = $00000021;
  CR_NEED_RESTART             = $00000022;
  CR_NO_MORE_HW_PROFILES      = $00000023;
  CR_DEVICE_NOT_THERE         = $00000024;
  CR_NO_SUCH_VALUE            = $00000025;
  CR_WRONG_TYPE               = $00000026;
  CR_INVALID_PRIORITY         = $00000027;
  CR_NOT_DISABLEABLE          = $00000028;
  CR_FREE_RESOURCES           = $00000029;
  CR_QUERY_VETOED             = $0000002A;
  CR_CANT_SHARE_IRQ           = $0000002B;
  CR_NO_DEPENDENT             = $0000002C;
  CR_SAME_RESOURCES           = $0000002D;
  CR_NO_SUCH_REGISTRY_KEY     = $0000002E;
  CR_INVALID_MACHINENAME      = $0000002F;
  CR_REMOTE_COMM_FAILURE      = $00000030;
  CR_MACHINE_UNAVAILABLE      = $00000031;
  CR_NO_CM_SERVICES           = $00000032;
  CR_ACCESS_DENIED            = $00000033;
  CR_CALL_NOT_IMPLEMENTED     = $00000034;
  CR_INVALID_PROPERTY         = $00000035;
  CR_DEVICE_INTERFACE_ACTIVE  = $00000036;
  CR_NO_SUCH_DEVICE_INTERFACE = $00000037;
  CR_INVALID_REFERENCE_STRING = $00000038;
  CR_INVALID_CONFLICT_LIST    = $00000039;
  CR_INVALID_INDEX            = $0000003A;
  CR_INVALID_STRUCTURE_SIZE   = $0000003B;
  NUM_CR_RESULTS              = $0000003C;

  ResType_All           = $00000000;
  ResType_None          = $00000000;
  ResType_Mem           = $00000001;
  ResType_IO            = $00000002;
  ResType_DMA           = $00000003;
  ResType_IRQ           = $00000004;
  ResType_DoNotUse      = $00000005;
  ResType_BusNumber     = $00000006;
  ResType_MAX           = $00000006;
  ResType_Ignored_Bit   = $00008000;
  ResType_ClassSpecific = $0000FFFF;
  ResType_Reserved      = $00008000;
  ResType_DevicePrivate = $00008001;
  ResType_PcCardConfig  = $00008002;
  ResType_MfCardConfig  = $00008003;

type
  DWORD_PTR = DWORD;
  LOG_CONF = DWORD_PTR;
  PLOG_CONF = ^LOG_CONF;
  DEVNODE = DWORD;
  PDEVNOD = ^DEVNODE;
  DEVINST = DWORD;
  PDEVINST = ^DEVINST;
  RETURN_TYPE = DWORD;
  CONFIGRET = RETURN_TYPE;
  RES_DES = DWORD_PTR;
  PRES_DES = ^RES_DES;
  RESOURCEID = ULONG;
  PRESOURCEID = ^RESOURCEID;
  DWORDLONG = Int64;
  ULONG32 = ULONG;
  IO_DES = record
    IOD_Count: DWORD;
    IOD_Type: DWORD;
    IOD_Alloc_Base: DWORDLONG;
    IOD_Alloc_End: DWORDLONG;
    IOD_DesFlags: DWORD;
  end;
  PIO_DES = ^IO_DES;
  IO_RANGE = record
   IOR_Align: DWORDLONG;
   IOR_nPorts: DWORD;
   IOR_Min: DWORDLONG;
   IOR_Max: DWORDLONG;
   IOR_RangeFlags: DWORD;
   IOR_Alias: DWORDLONG;
  end;
  PIO_RANGE = ^IO_RANGE;
  IO_RESOURCE = record
    IO_Header: IO_DES;
    IO_Data: array of IO_RANGE;
  end;
  PIO_RESOURCE = ^IO_RESOURCE;
  DMA_RANGE = record
    DR_Min: ULONG;
    DR_Max: ULONG;
    DR_Flags: ULONG;
  end;
  PDMA_RANGE = ^DMA_RANGE;
  DMA_DES = record
   DD_Count: DWORD;
   DD_Type: DWORD;
   DD_Flags: DWORD;
   DD_Alloc_Chan: ULONG;
  end;
  PDMA_DES = ^DMA_DES;
  DMA_RESOURCE = record
   DMA_Header: DMA_DES;
   DMA_Data: array of DMA_RANGE;
  end;
  PDMA_RESOURCE = ^DMA_RESOURCE;
  IRQ_RANGE = record
    IRQR_Min: ULONG;
    IRQR_Max: ULONG;
    IRQR_Flags: ULONG;
  end;
  PIRQ_RANGE = ^IRQ_RANGE;
  IRQ_DES_32 = record
   IRQD_Count: DWORD;    
   IRQD_Type: DWORD;
   IRQD_Flags: DWORD;
   IRQD_Alloc_Num: ULONG;
   IRQD_Affinity: ULONG32;
  end;
  PIRQ_DES_32 = ^IRQ_DES_32;
  IRQ_RESOURCE_32 = record
    IRQ_Header: IRQ_DES_32;
    IRQ_Data: array of IRQ_RANGE;
  end;
  PIRQ_RESOURCE_32 = ^IRQ_RESOURCE_32;

var
  hCfgmgr32: HINST;
  CM_Get_First_Log_Conf: function(
    plcLogConf: PLOG_CONF;
    dnDevInst: DEVINST;
    ulFlags: ULONG
  ): CONFIGRET; stdcall;
  CM_Free_Log_Conf_Handle: function(
    lcLogConf: LOG_CONF
    ): CONFIGRET; stdcall;
  CM_Get_Next_Res_Des: function(
    prdResDes: PRES_DES;
    rdResDes: RES_DES;
    ForResource: RESOURCEID;
    pResourceID: PRESOURCEID;
    ulFlags: ULONG
  ): CONFIGRET; stdcall;
  CM_Free_Res_Des_Handle: function(
    rdResDes: RES_DES
  ): CONFIGRET; stdcall;
  CM_Get_Res_Des_Data_Size: function(
    pulSize: PULONG;
    rdResDes: RES_DES;
    ulFlags: ULONG
  ): CONFIGRET; stdcall;
  CM_Get_Res_Des_Data: function(
    rdResDes: RES_DES;
    Buffer: Pointer;
    BufferLen: ULONG;
    ulFlags: ULONG
  ): CONFIGRET; stdcall;

{$ALIGN 8}

function extractResourceDesc(PDevice: PDetectedDevice;{var port: TDetectedPort; }resId: RESOURCEID; buffer: PChar; length: Integer): Boolean;
var
  ioResource: IO_RESOURCE;
  dmaResource: DMA_RESOURCE;
  irqResource: IRQ_RESOURCE_32;
  i, p, l: Integer;
begin
  Result := False;
  case resId of
    ResType_IO:
    begin
      p := 0;
      l := SizeOf(ioResource) - SizeOf(ioResource.IO_Data);
      if length >= p + l then
      begin
        Move((buffer + p)^, ioResource, l);
        Inc(p, l);
        SetLength(ioResource.IO_Data, ioResource.IO_Header.IOD_Count);
        for i := 0 to ioResource.IO_Header.IOD_Count - 1 do
        begin
          l := SizeOf(ioResource.IO_Data[i]);
          if length >= p + l then
          begin
            Move((buffer + p)^, ioResource.IO_Data[i], l);
            Inc(p, l);
          end;
        end;
        if PDevice.portLength = 0 then
        begin
          PDevice.portStart := ioResource.IO_Header.IOD_Alloc_Base;
          PDevice.portLength := ioResource.IO_Header.IOD_Alloc_End - ioResource.IO_Header.IOD_Alloc_Base + 1;
        end;
        Result := True;
      end;
    end;
    ResType_DMA:
    begin
      p := 0;
      l := SizeOf(dmaResource) - SizeOf(dmaResource.DMA_Data);
      if length >= p + l then
      begin
        Move((buffer + p)^, dmaResource, l);
        Inc(p, l);
        SetLength(dmaResource.DMA_Data, dmaResource.DMA_Header.DD_Count);
        for i := 0 to dmaResource.DMA_Header.DD_Count - 1 do
        begin
          l := SizeOf(dmaResource.DMA_Data[i]);
          if length >= p + l then
          begin
            Move((buffer + p)^, dmaResource.DMA_Data[i], l);
            Inc(p, l);
          end;
        end;
        if not(PDevice.dma) then
        begin
          PDevice.dma := True;
          PDevice.dmaChannel := dmaResource.DMA_Header.DD_Alloc_Chan;
        end;
        Result := True;
      end;
    end;
    ResType_IRQ:
    begin
      p := 0;
      l := SizeOf(irqResource) - SizeOf(irqResource.IRQ_Data);
      if length >= p + l then
      begin
        Move((buffer + p)^, irqResource, l);
        Inc(p, l);
        SetLength(irqResource.IRQ_Data, irqResource.IRQ_Header.IRQD_Count);
        for i := 0 to irqResource.IRQ_Header.IRQD_Count - 1 do
        begin
          l := SizeOf(irqResource.IRQ_Data[i]);
          if length >= p + l then
          begin
            Move((buffer + p)^, irqResource.IRQ_Data[i], l);
            Inc(p, l);
          end;
        end;
        if not(PDevice.irq) then
        begin
          PDevice.irq := True;
          PDevice.irqLevel := irqResource.IRQ_Header.IRQD_Alloc_Num;
        end;
        Result := True;
      end;
    end;
  end;
end;

procedure getPortResourcesWDMConfigManager(PDevice: PDetectedDevice; devInst1: DEVINST);
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
                  extractResourceDesc(PDevice, resId, resDescBuffer, size);
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

function getDevicesWDM(DevList: TDetectedDeviceList; DeviceID: String; const Enumerator: PAnsiChar = nil): Boolean;
var
  i, n: Integer;
  devInfoList: HDEVINFO;
  devInfoData: SP_DEVINFO_DATA;
  buffer: array[0..255] of Char;
  instanceId, friendlyName, hardwareID, portName: string;
//  key: HKEY;
//  type1, size: DWORD;
  PDevice: PDetectedDevice;
begin
  Result := False;
  if (DevList <> nil)
     and
     (@SetupDiClassGuidsFromNameA <> nil)
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
    DevList.Clear;

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
          begin
            Result := True;

            GetMem(PDevice, SizeOf(TDetectedDevice));
            PDevice.friendlyName := friendlyName;
            PDevice.hardwareID := hardwareID;
            getPortResourcesWDMConfigManager(PDevice, {ports[n],} devInfoData.DevInst);
            DevList.Add(PDevice);

//            write('->');
          end;
//          Writeln('  ',friendlyname, #9, hardwareID);
          // retrieve port name from registry, for example: LPT1, LPT2, COM1, COM2
//          key :=
//            SetupDiOpenDevRegKey(
//              devInfoList,
//              @devInfoData,
//              DICS_FLAG_GLOBAL,
//              0,
//              DIREG_DEV,
//              KEY_READ
//            );
//          if key <> INVALID_HANDLE_VALUE then
//          begin
//            size := 255;
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
//                getPortResourcesWDMConfigManager({ports[n],} devInfoData.DevInst);
//              end;
//            end;
//          end;
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
  @SetupDiClassGuidsFromNameA        := nil;
  @SetupDiGetClassDevsA              := nil;
  @SetupDiDestroyDeviceInfoList      := nil;
  @SetupDiEnumDeviceInfo             := nil;
  @SetupDiEnumDeviceInterfaces       := nil;
  @SetupDiGetDeviceInterfaceDetailA  := nil;
  @SetupDiGetDeviceInstanceIdA       := nil;
  @SetupDiGetDeviceRegistryPropertyA := nil;
  @SetupDiOpenClassRegKeyExA         := nil;
  @SetupDiOpenDevRegKey              := nil;
  @CM_Get_First_Log_Conf             := nil;
  @CM_Free_Log_Conf_Handle           := nil;
  @CM_Get_Next_Res_Des               := nil;
  @CM_Free_Res_Des_Handle            := nil;
  @CM_Get_Res_Des_Data_Size          := nil;
  @CM_Get_Res_Des_Data := nil;
//  hKernel32 := LoadLibrary('kernel32.dll');
//  if hKernel32 <> 0 then
//    @toolhelp32ReadProcessMemory := GetProcAddress(hKernel32, 'Toolhelp32ReadProcessMemory');
  hSetupapi := LoadLibrary('setupapi.dll');
  if hSetupapi <> 0 then
  begin
    @SetupDiClassGuidsFromNameA        := GetProcAddress(hSetupapi, 'SetupDiClassGuidsFromNameA');
    @SetupDiGetClassDevsA              := GetProcAddress(hSetupapi, 'SetupDiGetClassDevsA');
    @SetupDiDestroyDeviceInfoList      := GetProcAddress(hSetupapi, 'SetupDiDestroyDeviceInfoList');
    @SetupDiEnumDeviceInfo             := GetProcAddress(hSetupapi, 'SetupDiEnumDeviceInfo');
    @SetupDiEnumDeviceInterfaces       := GetProcAddress(hSetupapi, 'SetupDiEnumDeviceInterfaces');
    @SetupDiGetDeviceInterfaceDetailA  := GetProcAddress(hSetupapi, 'SetupDiGetDeviceInterfaceDetailA');
    @SetupDiGetDeviceInstanceIdA       := GetProcAddress(hSetupapi, 'SetupDiGetDeviceInstanceIdA');
    @SetupDiGetDeviceRegistryPropertyA := GetProcAddress(hSetupapi, 'SetupDiGetDeviceRegistryPropertyA');
    @SetupDiOpenClassRegKeyExA         := GetProcAddress(hSetupapi, 'SetupDiOpenClassRegKeyExA');
    @SetupDiOpenDevRegKey              := GetProcAddress(hSetupapi, 'SetupDiOpenDevRegKey');
  end;
  hCfgmgr32 := LoadLibrary('cfgmgr32.dll');
  if hCfgmgr32 <> 0 then
  begin
    @CM_Get_First_Log_Conf    := GetProcAddress(hCfgmgr32, 'CM_Get_First_Log_Conf');
    @CM_Free_Log_Conf_Handle  := GetProcAddress(hCfgmgr32, 'CM_Free_Log_Conf_Handle');
    @CM_Get_Next_Res_Des      := GetProcAddress(hCfgmgr32, 'CM_Get_Next_Res_Des');
    @CM_Free_Res_Des_Handle   := GetProcAddress(hCfgmgr32, 'CM_Free_Res_Des_Handle');
    @CM_Get_Res_Des_Data_Size := GetProcAddress(hCfgmgr32, 'CM_Get_Res_Des_Data_Size');
    @CM_Get_Res_Des_Data      := GetProcAddress(hCfgmgr32, 'CM_Get_Res_Des_Data');
  end;

finalization
  FreeLibrary(hCfgmgr32);
  FreeLibrary(hSetupapi);
//  FreeLibrary(hKernel32);

end.
