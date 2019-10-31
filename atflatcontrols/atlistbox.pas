{
Copyright (C) Alexey Torgashin, uvviewsoft.com
License: MPL 2.0 or LGPL
}

unit ATListbox;

{$ifdef FPC}
  {$mode delphi}
{$endif}

interface

uses
  Classes, SysUtils, Graphics, Controls, Forms,
  {$ifdef FPC}
  LMessages,
  {$else}
  Messages, Windows,
  {$endif}
  ATScrollBar,
  ATFlatThemes,
  ATCanvasPrimitives;

type
  TATListboxDrawItemEvent = procedure(Sender: TObject; C: TCanvas; AIndex: integer; const ARect: TRect) of object;

type
  TATIntArray = array of integer;

type
  TATListboxShowX = (
    albsxNone,
    albsxAllItems,
    albsxHotItem
    );

type
  { TATListboxItemProp }

  TATListboxItemProp = class
  public
    Tag: Int64;
    Modified: boolean;
    DataText: string;
    constructor Create(const ATag: Int64; AModified: boolean; const ADataText: string);
  end;

type
  { TATListbox }

  TATListbox = class(TCustomControl)
  private
    FTheme: PATFlatTheme;
    FThemedScrollbar: boolean;
    FThemedFont: boolean;
    FScrollbar: TATScrollbar;
    FScrollbarHorz: TATScrollbar;
    FOwnerDrawn: boolean;
    FVirtualMode: boolean;
    FVirtualItemCount: integer;
    FItemIndex: integer;
    FItemHeightPercents: integer;
    FItemHeight: integer;
    FItemHeightIsFixed: boolean;
    FItemTop: integer;
    FBitmap: Graphics.TBitmap;
    FCanGetFocus: boolean;
    FList: TStringList;
    FHotTrack: boolean;
    FHotTrackIndex: integer;
    FIndentLeft: integer;
    FIndentTop: integer;
    FIndentForX: integer;
    FColumnSep: char;
    FColumnSizes: TATIntArray;
    FColumnWidths: TATIntArray;
    FShowHorzScrollbar: boolean;
    FShowX: TATListboxShowX;
    FMaxWidth: integer;
    FOnDrawItem: TATListboxDrawItemEvent;
    FOnClickX: TNotifyEvent;
    FOnChangeSel: TNotifyEvent;
    FOnScroll: TNotifyEvent;
    procedure DoDefaultDrawItem(C: TCanvas; AIndex: integer; R: TRect);
    procedure DoPaintTo(C: TCanvas; r: TRect);
    procedure DoPaintX(C: TCanvas; const R: TRect; ACircle: boolean);
    function GetMaxWidth(C: TCanvas): integer;
    function GetOnDrawScrollbar: TATScrollbarDrawEvent;
    function ItemBottom: integer;
    procedure ScrollbarChange(Sender: TObject);
    procedure ScrollbarHorzChange(Sender: TObject);
    procedure SetCanBeFocused(AValue: boolean);
    procedure SetItemHeightPercents(AValue: integer);
    procedure SetOnDrawScrollbar(AValue: TATScrollbarDrawEvent);
    procedure SetVirtualItemCount(AValue: integer);
    procedure SetItemIndex(AValue: integer);
    procedure SetItemTop(AValue: integer);
    procedure SetItemHeight(AValue: integer);
    procedure SetThemedScrollbar(AValue: boolean);
    procedure UpdateColumnWidths;
    {$ifdef FPC}
    procedure UpdateFromScrollbarMsg(const Msg: TLMScroll);
    {$else}
    procedure UpdateFromScrollbarMsg(const Msg: TWMVScroll);
    procedure CMMouseEnter(var msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
    {$endif}
    procedure UpdateScrollbar;
    function GetVisibleItems: integer;
    function GetItemHeightDefault: integer;
    function GetColumnWidth(AIndex: integer): integer;
    procedure DoKeyDown(var Key: Word; Shift: TShiftState);
    procedure InvalidateNoSB;
    function CurrentFontName: string;
    function CurrentFontSize: integer;
  protected
    procedure Paint; override;
    procedure Click; override;
    {$ifdef FPC}
    procedure LMVScroll(var Msg: TLMVScroll); message LM_VSCROLL;
    procedure MouseLeave; override;
    {$else}
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    {$endif}
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure ChangedSelection; virtual;
    procedure Scrolled; virtual;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Items: TStringList read FList;
    property ItemIndex: integer read FItemIndex write SetItemIndex;
    property ItemTop: integer read FItemTop write SetItemTop;
    property ItemHeight: integer read FItemHeight write SetItemHeight;
    property ItemHeightDefault: integer read GetItemHeightDefault;
    function ItemCount: integer;
    function IsIndexValid(AValue: integer): boolean;
    property HotTrackIndex: integer read FHotTrackIndex;
    property VirtualItemCount: integer read FVirtualItemCount write SetVirtualItemCount;
    property VisibleItems: integer read GetVisibleItems;
    function GetItemIndexAt(Pnt: TPoint): integer;
    property Theme: PATFlatTheme read FTheme write FTheme;
    property ThemedScrollbar: boolean read FThemedScrollbar write SetThemedScrollbar;
    property ThemedFont: boolean read FThemedFont write FThemedFont;
    property Scrollbar: TATScrollbar read FScrollbar;
    property ScrollbarHorz: TATScrollbar read FScrollbarHorz;
    property ColumnSeparator: char read FColumnSep write FColumnSep;
    property ColumnSizes: TATIntArray read FColumnSizes write FColumnSizes;
    property ColumnWidth[AIndex: integer]: integer read GetColumnWidth;
    {$ifdef FPC}
    function CanFocus: boolean; override;
    function CanSetFocus: boolean; override;
    {$endif}
    function ClientHeight: integer;
    function ClientWidth: integer;
    procedure Invalidate; override;
    procedure UpdateItemHeight;
  published
    property Align;
    property Anchors;
    {$ifdef FPC}
    property BorderStyle;
    property BorderSpacing;
    {$endif}
    property CanGetFocus: boolean read FCanGetFocus write SetCanBeFocused default false;
    property DoubleBuffered stored false;
    property Enabled;
    property HotTrack: boolean read FHotTrack write FHotTrack default false;
    property IndentLeft: integer read FIndentLeft write FIndentLeft default 4;
    property IndentTop: integer read FIndentTop write FIndentTop default 2;
    property ItemHeightPercents: integer read FItemHeightPercents write SetItemHeightPercents default 100;
    property OwnerDrawn: boolean read FOwnerDrawn write FOwnerDrawn default false;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property ShowXMark: TATListboxShowX read FShowX write FShowX default albsxNone;
    property ShowHorzScrollbar: boolean read FShowHorzScrollbar write FShowHorzScrollbar default true;
    property VirtualMode: boolean read FVirtualMode write FVirtualMode default true;
    property Visible;
    property OnClick;
    property OnClickXMark: TNotifyEvent read FOnClickX write FOnClickX;
    property OnDblClick;
    property OnContextPopup;
    property OnChangedSel: TNotifyEvent read FOnChangeSel write FOnChangeSel;
    property OnDrawItem: TATListboxDrawItemEvent read FOnDrawItem write FOnDrawItem;
    property OnDrawScrollbar: TATScrollbarDrawEvent read GetOnDrawScrollbar write SetOnDrawScrollbar;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
    property OnKeyPress;
    property OnKeyDown;
    property OnKeyUp;
    property OnResize;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
  end;


implementation

uses
  {$ifdef FPC}
  Types,
  InterfaceBase,
  LCLType, LCLIntf,
  {$endif}
  Math;

function SGetItem(var S: string; const ch: Char): string;
var
  i: integer;
begin
  i:= Pos(ch, S);
  if i=0 then
  begin
    Result:= S;
    S:= '';
  end
  else
  begin
    Result:= Copy(S, 1, i-1);
    Delete(S, 1, i);
  end;
end;

function IsDoubleBufferedNeeded: boolean;
begin
  Result := true;
  {$ifdef FPC}
  Result:= WidgetSet.GetLCLCapability(lcCanDrawOutsideOnPaint) = LCL_CAPABILITY_YES;
  {$endif}
end;

{ TATListboxItemProp }

constructor TATListboxItemProp.Create(const ATag: Int64; AModified: boolean;
  const ADataText: string);
begin
  Tag:= ATag;
  Modified:= AModified;
  DataText:= ADataText;
end;

{ TATListbox }

function TATListbox.GetVisibleItems: integer;
begin
  Result:= ClientHeight div FItemHeight;
end;

function TATListbox.IsIndexValid(AValue: integer): boolean;
begin
  Result:= (AValue>=0) and (AValue<ItemCount);
end;

function TATListbox.GetItemHeightDefault: integer;
begin
  Result:= FTheme^.DoScaleFont(CurrentFontSize) * 18 div 10 + 2;
  Result:= Result * Screen.PixelsPerInch div 96;
end;

procedure TATListbox.UpdateItemHeight;
begin
  if not FItemHeightIsFixed then
    FItemHeight:= GetItemHeightDefault * FItemHeightPercents div 100;
end;

procedure TATListbox.ChangedSelection;
begin
  if Assigned(FOnChangeSel) then
    FOnChangeSel(Self);
end;

procedure TATListbox.Scrolled;
begin
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

procedure TATListbox.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
begin
  //must select item under mouse cursor
  ItemIndex:= GetItemIndexAt(MousePos);

  inherited;
end;

function TATListbox.GetMaxWidth(C: TCanvas): integer;
var
  S: string;
  i: integer;
begin
  if FVirtualMode then
    exit(ClientWidth);
  Result:= 0;
  for i:= 0 to ItemCount-1 do
  begin
    S:= Items[i];
    Result:= Max(Result, C.TextWidth(S));
  end;
  Inc(Result, FIndentLeft+2);
end;

procedure TATListbox.UpdateScrollbar;
var
  si: TScrollInfo;
begin
  if ThemedScrollbar then
  begin
    FScrollbar.Min:= 0;
    FScrollbar.Max:= ItemCount;
    FScrollbar.PageSize:= VisibleItems;
    FScrollbar.Position:= ItemTop;
    FScrollbar.Update;

    FScrollbarHorz.Visible:= FShowHorzScrollbar;
    if FShowHorzScrollbar then
    begin
      FScrollbarHorz.Min:= 0;
      FScrollbarHorz.Max:= FMaxWidth;
      FScrollbarHorz.PageSize:= ClientWidth;
      FScrollbarHorz.Update;
    end;
  end;

  FillChar(si{%H-}, SizeOf(si), 0);
  si.cbSize:= SizeOf(si);
  si.fMask:= SIF_ALL;
  si.nMin:= 0;

  if ThemedScrollbar then
  begin
    si.nMax:= 1;
    si.nPage:= 2;
    si.nPos:= 0;
  end
  else
  begin
    si.nMax:= ItemCount;
    si.nPage:= GetVisibleItems;
    si.nPos:= FItemTop;
  end;

  SetScrollInfo(Handle, SB_VERT, si, True);
end;

function TATListbox.ItemCount: integer;
begin
  if FVirtualMode then
    Result:= FVirtualItemCount
  else
    Result:= Items.Count;
end;


procedure TATListbox.DoPaintTo(C: TCanvas; r: TRect);
var
  Index: integer;
  bPaintX, bCircle: boolean;
  RectX: TRect;
begin
  C.Font.Name:= CurrentFontName;
  C.Font.Size:= FTheme^.DoScaleFont(CurrentFontSize);

  FMaxWidth:= GetMaxWidth(C);

  C.Brush.Color:= ColorToRGB(FTheme^.ColorBgListbox);
  C.FillRect(r);

  FIndentForX:= 0;
  if FShowX<>albsxNone then
    Inc(FIndentForX, FTheme^.DoScale(FTheme^.XMarkWidth));

  for Index:= FItemTop to ItemCount-1 do
  begin
    r.Top:= (Index-FItemTop)*FItemHeight;
    r.Bottom:= r.Top+FItemHeight;
    r.Left:= 0;
    r.Right:= ClientWidth;
    if r.Top>=ClientHeight then Break;

    if FOwnerDrawn then
    begin
      if Assigned(FOnDrawItem) then
        FOnDrawItem(Self, C, Index, r);
    end
    else
    begin
      DoDefaultDrawItem(C, Index, r);
    end;

    bCircle:=
      (Index>=0) and (Index<FList.Count) and
      (FList.Objects[Index] is TATListboxItemProp) and
      TATListboxItemProp(FList.Objects[Index]).Modified;

    case FShowX of
      albsxNone:
        bPaintX:= false;
      albsxAllItems:
        bPaintX:= true;
      albsxHotItem:
        bPaintX:= bCircle or (FHotTrack and (Index=FHotTrackIndex));
    end;

    if bPaintX then
    begin
      RectX:= Rect(r.Left, r.Top, r.Left+FIndentForX, r.Bottom);
      DoPaintX(C, RectX, bCircle and (Index<>FHotTrackIndex));
    end;
  end;
end;

procedure TATListbox.DoPaintX(C: TCanvas; const R: TRect; ACircle: boolean);
var
  P: TPoint;
  NColor: TColor;
begin
  NColor:= FTheme^.ColorArrows;
  if FHotTrack then
  begin
    P:= ScreenToClient(Mouse.CursorPos);
    if PtInRect(R, P) then
      NColor:= FTheme^.ColorArrowsOver;
  end;

  if ACircle then
    CanvasPaintCircleMark(C, R, NColor,
      FTheme^.DoScale(FTheme^.XMarkOffsetLeft),
      FTheme^.DoScale(FTheme^.XMarkOffsetRight)
    )
  else
    CanvasPaintXMark(C, R, NColor,
      FTheme^.DoScale(FTheme^.XMarkOffsetLeft),
      FTheme^.DoScale(FTheme^.XMarkOffsetRight),
      FTheme^.DoScale(FTheme^.XMarkLineWidth)
      );
end;

function TATListbox.GetOnDrawScrollbar: TATScrollbarDrawEvent;
begin
  Result:= FScrollbar.OnOwnerDraw;
end;

function TATListbox.GetColumnWidth(AIndex: integer): integer;
begin
  if (AIndex>=0) and (AIndex<Length(FColumnSizes)) then
    Result:= FColumnWidths[AIndex]
  else
    Result:= 0;
end;

procedure TATListbox.UpdateColumnWidths;
var
  NTotalWidth, NAutoSized, NSize, NFixedSize, i: integer;
begin
  NTotalWidth:= ClientWidth;
  NAutoSized:= 0;
  NFixedSize:= 0;

  SetLength(FColumnWidths, Length(FColumnSizes));

  //set width of fixed columns
  for i:= 0 to Length(FColumnSizes)-1 do
  begin
    NSize:= FColumnSizes[i];

    //auto-sized?
    if NSize=0 then
      Inc(NAutoSized)
    else
    //in percents?
    if NSize<0 then
      NSize:= NTotalWidth * -NSize div 100;

    Inc(NFixedSize, NSize);
    FColumnWidths[i]:= NSize;
  end;

  //set width of auto-sized columns
  for i:= 0 to Length(FColumnSizes)-1 do
  begin
    if FColumnSizes[i]=0 then
      FColumnWidths[i]:= Max(0, NTotalWidth-NFixedSize) div NAutoSized;
  end;
end;

procedure TATListbox.DoDefaultDrawItem(C: TCanvas; AIndex: integer; R: TRect);
var
  S, SItem: string;
  NIndentLeft,
  NColOffset, NColWidth, NAllWidth, i: integer;
begin
  if AIndex=FItemIndex then
  begin
    C.Brush.Color:= ColorToRGB(FTheme^.ColorBgListboxSel);
    C.Font.Color:= ColorToRGB(FTheme^.ColorFontListboxSel);
  end
  else
  if FHotTrack and (AIndex=FHotTrackIndex) then
  begin
    C.Brush.Color:= ColorToRGB(FTheme^.ColorBgListboxHottrack);
    C.Font.Color:= ColorToRGB(FTheme^.ColorFontListbox);
  end
  else
  begin
    C.Brush.Color:= ColorToRGB(FTheme^.ColorBgListbox);
    C.Font.Color:= ColorToRGB(FTheme^.ColorFontListbox);
  end;
  C.FillRect(R);

  if (AIndex>=0) and (AIndex<FList.Count) then
    S:= FList[AIndex]
  else
    S:= '('+IntToStr(AIndex)+')';

  NIndentLeft:= FIndentLeft+FIndentForX;

  if Length(FColumnSizes)=0 then
  begin
    C.TextOut(
      R.Left+NIndentLeft - FScrollbarHorz.Position,
      R.Top+FIndentTop,
      S);
  end
  else
  begin
    NAllWidth:= ClientWidth;
    NColOffset:= R.Left+FIndentLeft - FScrollbarHorz.Position;
    C.Pen.Color:= Theme^.ColorSeparators;

    for i:= 0 to Length(FColumnSizes)-1 do
    begin
      NColWidth:= FColumnWidths[i];
      SItem:= SGetItem(S, FColumnSep);

      C.FillRect(
        Rect(NColOffset,
        R.Top,
        NAllWidth,
        R.Bottom)
        );
      C.TextOut(
        NColOffset+1+IfThen(i=0, NIndentLeft),
        R.Top+FIndentTop,
        SItem
        );

      Inc(NColOffset, NColWidth);
      {$ifdef FPC}
      C.Line(NColOffset-1, R.Top, NColOffset-1, R.Bottom);
      {$else}
      C.MoveTo (NColOffset-1, R.Top);
      C.LineTo (NColOffset-1, R.Bottom);
      {$endif}
    end;
  end;
end;

procedure TATListbox.Paint;
var
  R: TRect;
begin

  inherited;
  UpdateScrollbar;
  UpdateItemHeight;
  UpdateColumnWidths;

  R:= ClientRect;
  if DoubleBuffered then
  begin
    DoPaintTo(FBitmap.Canvas, R);
    Canvas.CopyRect(R, FBitmap.Canvas, R);
  end
  else
    DoPaintTo(Canvas, R);
end;

procedure TATListbox.Click;
var
  Pnt: TPoint;
begin
  if FCanGetFocus then
    {$ifdef FPC}
    LCLIntf.SetFocus(Handle);
    {$else}
    SetFocus;
    {$endif}

  Pnt:= ScreenToClient(Mouse.CursorPos);

  if FShowX<>albsxNone then
    if Pnt.X<=FIndentForX then
      if Assigned(FOnClickX) then
      begin
        FOnClickX(Self);
        exit;
      end;

  inherited; //OnClick must be after ItemIndex set
end;

function TATListbox.GetItemIndexAt(Pnt: TPoint): integer;
begin
  Result:= -1;
  if ItemCount=0 then exit;

  if (Pnt.X>=0) and (Pnt.X<ClientWidth) then
  begin
    Result:= Pnt.Y div FItemHeight + FItemTop;
    if Result>=ItemCount then
      Result:= -1;
  end;
end;

function TATListbox.ItemBottom: integer;
begin
  Result:= Min(ItemCount-1, FItemTop+GetVisibleItems-1);
end;

procedure TATListbox.ScrollbarChange(Sender: TObject);
begin
  ItemTop:= FScrollbar.Position;
end;

procedure TATListbox.ScrollbarHorzChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TATListbox.SetCanBeFocused(AValue: boolean);
begin
  if FCanGetFocus=AValue then Exit;
  FCanGetFocus:= AValue;
  {$ifdef FPC}
  if AValue then
    ControlStyle:= ControlStyle-[csNoFocus]
  else
    ControlStyle:= ControlStyle+[csNoFocus];
  {$endif}
end;

procedure TATListbox.SetItemHeightPercents(AValue: integer);
begin
  if FItemHeightPercents=AValue then Exit;
  FItemHeightPercents:= AValue;
  FItemHeightIsFixed:= false;
end;

procedure TATListbox.SetOnDrawScrollbar(AValue: TATScrollbarDrawEvent);
begin
  FScrollbar.OnOwnerDraw:= AValue;
end;

procedure TATListbox.SetVirtualItemCount(AValue: integer);
begin
  if FVirtualItemCount=AValue then Exit;
  if AValue<0 then Exit;
  FVirtualItemCount:= AValue;
  Scrolled;
  Invalidate;
end;

procedure TATListbox.SetItemIndex(AValue: integer);
begin
  if FItemIndex=AValue then Exit;
  if not IsIndexValid(AValue) then Exit;
  FItemIndex:= AValue;

  UpdateItemHeight; //needed, ItemHeight may be not calculated yet

  //scroll if needed
  if FItemIndex=0 then
    FItemTop:= 0
  else
  if FItemIndex<FItemTop then
    FItemTop:= FItemIndex
  else
  if FItemIndex>ItemBottom then
    FItemTop:= Max(0, FItemIndex-GetVisibleItems+1);

  ChangedSelection;
  Invalidate;
end;

procedure TATListbox.SetItemTop(AValue: integer);
begin
  if FItemTop=AValue then Exit;
  if not IsIndexValid(AValue) then Exit;
  FItemTop:= Max(0, AValue);
  Scrolled;
  Invalidate;
end;

procedure TATListbox.SetItemHeight(AValue: integer);
begin
  if AValue=FItemHeight then exit;
  FItemHeight:= AValue;
  FItemHeightIsFixed:= true;
end;

procedure TATListbox.SetThemedScrollbar(AValue: boolean);
begin
  if FThemedScrollbar=AValue then Exit;
  FThemedScrollbar:= AValue;

  FScrollbar.Visible:= AValue;
  Invalidate;
end;


constructor TATListbox.Create(AOwner: TComponent);
begin
  inherited;

  ControlStyle:= ControlStyle+[csOpaque] {$ifdef FPC}-[csTripleClicks]{$endif};
  DoubleBuffered:= IsDoubleBufferedNeeded;
  Width:= 180;
  Height:= 150;
  Font.Size:= 9;

  CanGetFocus:= false;
  FList:= TStringList.Create;
  FVirtualItemCount:= 0;
  FItemIndex:= 0;
  FItemHeightPercents:= 100;
  FItemHeight:= 17;
  FItemTop:= 0;
  FIndentLeft:= 4;
  FIndentTop:= 2;
  FOwnerDrawn:= false;
  FVirtualMode:= true;
  FHotTrack:= false;
  FColumnSep:= #9;
  SetLength(FColumnSizes, 0);
  SetLength(FColumnWidths, 0);
  FShowX:= albsxNone;
  FShowHorzScrollbar:= true;

  FBitmap:= Graphics.TBitmap.Create;
  FBitmap.SetSize(1600, 1200);

  FTheme:= @ATFlatTheme;
  FThemedScrollbar:= true;
  FThemedFont:= true;

  FScrollbar:= TATScrollbar.Create(Self);
  FScrollbar.Parent:= Self;
  FScrollbar.Kind:= sbVertical;
  FScrollbar.Align:= alRight;
  FScrollbar.OnChange:= ScrollbarChange;

  FScrollbarHorz:= TATScrollbar.Create(Self);
  FScrollbarHorz.Parent:= Self;
  FScrollbarHorz.Kind:= sbHorizontal;
  FScrollbarHorz.Align:= alBottom;
  FScrollbarHorz.IndentCorner:= 100;
  FScrollbarHorz.OnChange:= ScrollbarHorzChange;
end;

destructor TATListbox.Destroy;
begin
  FreeAndNil(FList);
  FreeAndNil(FBitmap);
  inherited;
end;

{$ifdef FPC}
procedure TATListbox.UpdateFromScrollbarMsg(const Msg: TLMScroll);
var
  NMax: integer;
begin
  NMax:= Max(0, ItemCount-GetVisibleItems);

  case Msg.ScrollCode of
    SB_TOP:        FItemTop:= 0;
    SB_BOTTOM:     FItemTop:= Max(0, ItemCount-GetVisibleItems);

    SB_LINEUP:     FItemTop:= Max(0, FItemTop-1);
    SB_LINEDOWN:   FItemTop:= Min(NMax, FItemTop+1);

    SB_PAGEUP:     FItemTop:= Max(0, FItemTop-GetVisibleItems);
    SB_PAGEDOWN:   FItemTop:= Min(NMax, FItemTop+GetVisibleItems);

    SB_THUMBPOSITION,
    SB_THUMBTRACK: FItemTop:= Max(0, Msg.Pos);
  end;
end;
{$endif}

{$ifndef FPC}
procedure TATListbox.UpdateFromScrollbarMsg(const Msg: TWMVScroll);
var
  NMax: integer;
begin
  NMax:= Max(0, ItemCount-GetVisibleItems);

  case Msg.ScrollCode of
    SB_TOP:        FItemTop:= 0;
    SB_BOTTOM:     FItemTop:= Max(0, ItemCount-GetVisibleItems);

    SB_LINEUP:     FItemTop:= Max(0, FItemTop-1);
    SB_LINEDOWN:   FItemTop:= Min(NMax, FItemTop+1);

    SB_PAGEUP:     FItemTop:= Max(0, FItemTop-GetVisibleItems);
    SB_PAGEDOWN:   FItemTop:= Min(NMax, FItemTop+GetVisibleItems);

    SB_THUMBPOSITION,
    SB_THUMBTRACK: FItemTop:= Max(0, Msg.Pos);
  end;
end;

procedure TATListbox.CMMouseEnter(var msg: TMessage);
begin
  inherited;
  InvalidateNoSB;
end;

procedure TATListbox.CMMouseLeave(var msg: TMessage);
begin
  inherited;
  InvalidateNoSB;
end;

procedure TATListbox.WMEraseBkgnd(var Message: TMessage);
begin
  Message.Result:= 1;
  if Assigned(FScrollbar) then
  if not MouseInClient then
    FScrollbar.Refresh;
end;
{$endif}

{$ifdef FPC}
procedure TATListbox.LMVScroll(var Msg: TLMVScroll);
begin
  UpdateFromScrollbarMsg(Msg);
  Invalidate;
end;
{$endif}

{$ifndef FPC}
procedure TATListbox.WMVScroll(var Msg: TWMVScroll);
begin
  UpdateFromScrollbarMsg(Msg);
  Invalidate;
end;

procedure TATListbox.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
 inherited;
 Message.Result:= Message.Result or DLGC_WANTARROWS;
end;

procedure TATListbox.WMKeyDown(var Message: TWMKeyDown);
var
  ShiftState: TShiftState;
begin

 { Check the ShiftState, like delphi does while processing WMKeyDown }
 ShiftState := KeyDataToShiftState(Message.KeyData);
 DoKeyDown(Message.CharCode,ShiftState);

 inherited;

end;

{$endif}

{$ifdef FPC}
function TATListbox.CanFocus: boolean;
begin
  Result:= FCanGetFocus;
end;
{$endif}

{$ifdef FPC}
function TATListbox.CanSetFocus: boolean;
begin
  Result:= FCanGetFocus;
end;
{$endif}

function TATListbox.ClientHeight: integer;
begin
  Result:= inherited ClientHeight;
  if ThemedScrollbar and FScrollbarHorz.Visible then
    Dec(Result, FScrollbarHorz.Height);
end;

function TATListbox.ClientWidth: integer;
begin
  Result:= inherited ClientWidth;
  if ThemedScrollbar and FScrollbar.Visible then
    Dec(Result, FScrollbar.Width);
end;

procedure TATListbox.InvalidateNoSB;
var
  R: TRect;
begin
  if Assigned(FScrollbar) and FScrollbar.Visible then
  begin
    // https://github.com/Alexey-T/ATFlatControls/issues/32
    R:= Rect(0, 0, ClientWidth, ClientHeight);
    InvalidateRect(Handle, {$ifdef fpc}@{$endif}R, false);
  end
  else
    Invalidate;
end;

function TATListbox.CurrentFontName: string;
begin
  if FThemedFont then
    Result:= FTheme^.FontName
  else
    Result:= Font.Name;
end;

function TATListbox.CurrentFontSize: integer;
begin
  if FThemedFont then
    Result:= FTheme^.FontSize
  else
    Result:= Font.Size;
end;


procedure TATListbox.Invalidate;
begin
  if Assigned(FScrollbar) then
    FScrollbar.Update;

  inherited Invalidate;
end;

function TATListbox.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  if not ThemedScrollbar then
  begin
    Result:= inherited;
    exit
  end;

  Result:= true;
  if WheelDelta>0 then
    ItemTop:= Max(0, ItemTop-Mouse.WheelScrollLines)
  else
    ItemTop:= Max(0, Min(ItemCount-VisibleItems, ItemTop+Mouse.WheelScrollLines));
end;

procedure TATListbox.DoKeyDown(var Key: Word; Shift: TShiftState);
begin
  if (key=vk_up) then
  begin
    ItemIndex:= ItemIndex-1;
    key:= 0;
    Exit
  end;
  if (key=vk_down) then
  begin
    ItemIndex:= ItemIndex+1;
    key:= 0;
    Exit
  end;

  if (key=vk_prior) then
  begin
    ItemIndex:= Max(0, ItemIndex-(VisibleItems-1));
    key:= 0;
    Exit
  end;
  if (key=vk_next) then
  begin
    ItemIndex:= Min(ItemCount-1, ItemIndex+(VisibleItems-1));
    key:= 0;
    Exit
  end;

  if (key=vk_home) then
  begin
    ItemIndex:= 0;
    key:= 0;
    Exit
  end;
  if (key=vk_end) then
  begin
    ItemIndex:= ItemCount-1;
    key:= 0;
    Exit
  end;

  if (key=vk_return) then
  begin
    DblClick;
    key:= 0;
    Exit
  end;
end;

procedure TATListbox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  DoKeyDown(Key,Shift);
end;

procedure TATListbox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewIndex: integer;
begin
  inherited;

  if FHotTrack then
  begin
    NewIndex:= GetItemIndexAt(Point(X, Y));
    if (FHotTrackIndex<>NewIndex) or (FShowX<>albsxNone) then
    begin
      FHotTrackIndex:= NewIndex;
      InvalidateNoSB;
    end;
  end
  else
    FHotTrackIndex:= -1;
end;

procedure TATListbox.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  ItemIndex:= GetItemIndexAt(Point(X, Y));
  inherited;
end;

{$ifdef fpc}
procedure TATListbox.MouseLeave;
begin
  inherited;
  if FHotTrack then
  begin
    FHotTrackIndex:= -1;
    Invalidate;
  end;
end;
{$endif}

initialization

end.

