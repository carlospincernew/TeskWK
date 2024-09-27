object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 237
  Width = 347
  object WKConexao: TFDConnection
    Params.Strings = (
      'User_Name=root'
      'Database=dbtestwk'
      'Server=127.0.0.1'
      'Password=masterwk2024'
      'DriverID=MySQL')
    LoginPrompt = False
    Left = 56
    Top = 28
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    VendorLib = 'C:\Windows\SysWOW64\libmysql.dll'
    Left = 188
    Top = 32
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 142
    Top = 98
  end
  object qryExec: TFDQuery
    Connection = WKConexao
    Left = 240
    Top = 152
  end
end
