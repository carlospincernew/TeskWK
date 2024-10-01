object FrmPedido: TFrmPedido
  Left = 0
  Top = 0
  Caption = 'Pedido'
  ClientHeight = 528
  ClientWidth = 649
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PnlAddProduto: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 108
    Width = 643
    Height = 96
    Margins.Top = 0
    Align = alTop
    BevelInner = bvLowered
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object Label2: TLabel
      Left = 12
      Top = 6
      Width = 88
      Height = 13
      Caption = 'Informe o Produto'
    end
    object Label3: TLabel
      Left = 12
      Top = 51
      Width = 56
      Height = 13
      Caption = 'Quantidade'
    end
    object Label4: TLabel
      Left = 79
      Top = 51
      Width = 53
      Height = 13
      Caption = 'R$ Unit'#225'rio'
    end
    object Label5: TLabel
      Left = 175
      Top = 51
      Width = 40
      Height = 13
      Caption = 'R$ Total'
    end
    object edtCodProduto: TEdit
      Left = 12
      Top = 25
      Width = 61
      Height = 21
      TabOrder = 0
      OnChange = OnChange
      OnExit = OnLocateObj
    end
    object edtDescricao: TEdit
      Left = 79
      Top = 25
      Width = 550
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 5
    end
    object btnAdicionar: TButton
      Left = 271
      Top = 63
      Width = 86
      Height = 23
      Cursor = crHandPoint
      Caption = 'ADICIONAR'
      TabOrder = 3
      OnClick = btnAdicionarClick
    end
    object edtUnitario: TMaskEdit
      Left = 79
      Top = 65
      Width = 89
      Height = 21
      Alignment = taRightJustify
      TabOrder = 2
      Text = '0,00'
      OnChange = OnChangeDecimal
      OnExit = edtUnitarioExit
    end
    object edtTotal: TMaskEdit
      Left = 175
      Top = 65
      Width = 90
      Height = 21
      TabStop = False
      Alignment = taRightJustify
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 4
      Text = '0,00'
    end
    object edtQtd: TEdit
      Left = 12
      Top = 65
      Width = 61
      Height = 21
      Alignment = taRightJustify
      TabOrder = 1
      Text = '1'
      OnChange = OnChangeDecimal
      OnExit = edtUnitarioExit
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 484
    Width = 649
    Height = 44
    Align = alBottom
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object lbTotalPedido: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 279
      Height = 36
      Align = alLeft
      AutoSize = False
      Caption = ' Total Pedido: 0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 15
      ExplicitTop = 10
      ExplicitHeight = 23
    end
    object btnCancelarPedido: TButton
      Left = 411
      Top = 5
      Width = 110
      Height = 33
      Cursor = crHandPoint
      Caption = 'CANCELAR PEDIDO'
      TabOrder = 0
      OnClick = btnCancelarPedidoClick
    end
    object BtnGravarPedido: TButton
      Left = 527
      Top = 5
      Width = 110
      Height = 33
      Cursor = crHandPoint
      Caption = 'GRAVAR PEDIDO'
      Enabled = False
      TabOrder = 1
      OnClick = BtnGravarPedidoClick
    end
    object btnNovoPedido: TButton
      Left = 295
      Top = 5
      Width = 110
      Height = 33
      Cursor = crHandPoint
      Caption = 'NOVO PEDIDO'
      TabOrder = 2
      OnClick = btnNovoPedidoClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 207
    Width = 649
    Height = 277
    Align = alClient
    Caption = 'Panel2'
    Color = clWhite
    ParentBackground = False
    TabOrder = 3
    object GridPedProd: TStringGrid
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 641
      Height = 269
      Align = alClient
      Color = clWhite
      ColCount = 1
      DefaultColWidth = 70
      DefaultRowHeight = 18
      DrawingStyle = gdsGradient
      FixedColor = clSilver
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
      TabOrder = 0
      OnKeyDown = GridPedProdKeyDown
      OnSelectCell = GridPedProdSelectCell
    end
  end
  object PnlPedido: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 643
    Height = 102
    Align = alTop
    BevelInner = bvLowered
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object Bevel1: TBevel
      Left = 408
      Top = 7
      Width = 221
      Height = 56
      Shape = bsFrame
    end
    object Label1: TLabel
      Left = 12
      Top = 54
      Width = 87
      Height = 13
      Caption = 'Informe o Cliente:'
    end
    object Label6: TLabel
      Left = 422
      Top = 13
      Width = 47
      Height = 13
      Caption = 'N'#186' Pedido'
    end
    object Label7: TLabel
      Left = 12
      Top = 13
      Width = 47
      Height = 13
      Caption = 'N'#186' Pedido'
    end
    object Label8: TLabel
      Left = 157
      Top = 13
      Width = 64
      Height = 13
      Caption = 'Data Emiss'#227'o'
    end
    object edtNomeCliente: TEdit
      Left = 79
      Top = 71
      Width = 550
      Height = 21
      TabStop = False
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 4
    end
    object edtCodCliente: TEdit
      Tag = 1
      Left = 12
      Top = 71
      Width = 61
      Height = 21
      TabOrder = 1
      OnChange = OnChange
      OnExit = OnLocateObj
    end
    object BtnBuscarPedido: TButton
      Left = 538
      Top = 29
      Width = 83
      Height = 23
      Cursor = crHandPoint
      Caption = 'Consulta'
      TabOrder = 3
      TabStop = False
      OnClick = BtnBuscarPedidoClick
    end
    object edtNumeroPedido: TEdit
      Left = 416
      Top = 30
      Width = 109
      Height = 21
      TabStop = False
      TabOrder = 2
      OnChange = OnChange
    end
    object edtCodigoPedido: TEdit
      Left = 12
      Top = 30
      Width = 139
      Height = 21
      TabStop = False
      Color = clInfoBk
      ReadOnly = True
      TabOrder = 5
    end
    object edtDataPedido: TDateTimePicker
      Left = 157
      Top = 30
      Width = 186
      Height = 21
      Date = 45561.000000000000000000
      Time = 0.108124988422787300
      TabOrder = 0
    end
  end
end
