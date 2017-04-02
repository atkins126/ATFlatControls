{
Copyright (C) Alexey Torgashin, uvviewsoft.com
License: MPL 2.0 or LGPL
}

unit ATButtons;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls,
  Types, Math, Dialogs;

type
  TATButtonTheme = record
    FontName: string;
    FontSize: integer;
    FontStyles: TFontStyles;
    ColorFont,
    ColorFontDisabled,
    ColorBgPassive,
    ColorBgOver,
    ColorBgChecked,
    ColorBgDisabled,
    ColorArrows,
    ColorBorderPassive,
    ColorBorderOver,
    ColorBorderFocused: TColor;
    MouseoverBorderWidth: integer;
    PressedBorderWidth: integer;
    PressedCaptionShiftY: integer;
    PressedCaptionShiftX: integer;
  end;

var
  ATButtonTheme: TATButtonTheme;

type
  TATButtonKind = (
    abuTextOnly,
    abuIconOnly,
    abuTextIconHorz,
    abuTextIconVert,
    abuTextArrow,
    abuArrowOnly,
    abuSeparatorHorz,
    abuSeparatorVert,
    abuCross
    );

const
  cATButtonKindValues: array[TATButtonKind] of string = (
    'text',
    'icon',
    'text_icon_h',
    'text_icon_v',
    'text_arr',
    'arr',
    'sep_h',
    'sep_v',
    'x'
    );

type
  { TATButton }

  TATButton = class(TCustomControl)
  private
    FPressed,
    FOver,
    FChecked,
    FCheckable,
    FFocusable: boolean;
    FCaption: TCaption;
    FDataString: string;
    FPicture: TPicture;
    FOnClick: TNotifyEvent;
    FImages: TImageList;
    FImageIndex: integer;
    FFlat: boolean;
    FKind: TATButtonKind;
    procedure DoClick;
    function GetIconHeight: integer;
    function GetIconWidth: integer;
    function IsPressed: boolean;
    procedure PaintIcon(AX, AY: integer);
    procedure PaintArrow(AX, AY: integer);
    procedure SetCaption(const AValue: TCaption);
    procedure SetChecked(AValue: boolean);
    procedure SetFlat(AValue: boolean);
    procedure SetFocusable(AValue: boolean);
    procedure SetKind(AValue: TATButtonKind);
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    procedure MouseEnter; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyPress(var Key: char); override;
    procedure DoEnter; override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DataString: string read FDataString write FDataString;
    function GetTextSize(const S: string): TSize;
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property TabStop;
    property TabOrder;
    property Enabled;
    property Visible;
    property ShowHint;
    property ParentShowHint;
    property PopupMenu;
    property Caption: TCaption read FCaption write SetCaption;
    property Checked: boolean read FChecked write SetChecked default false;
    property Checkable: boolean read FCheckable write FCheckable default false;
    property Images: TImageList read FImages write FImages;
    property ImageIndex: integer read FImageIndex write FImageIndex default -1;
    property Focusable: boolean read FFocusable write SetFocusable default true;
    property Flat: boolean read FFlat write SetFlat default false;
    property Kind: TATButtonKind read FKind write SetKind default abuTextOnly;
    property Picture: TPicture read FPicture write FPicture;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick;
    property OnResize;
    property OnContextPopup;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
  end;

var
  cATButtonArrowSize: integer = 6;
  cATButtonIndent: integer = 3;
  cATButtonIndentArrow: integer = 5;

implementation

{ TATButton }

procedure TATButton.SetChecked(AValue: boolean);
begin
  if FChecked=AValue then Exit;
  FChecked:= AValue;
  Invalidate;
end;

procedure TATButton.SetFlat(AValue: boolean);
begin
  if FFlat=AValue then Exit;
  FFlat:= AValue;
  Invalidate;
  if FFlat then
    Focusable:= false;
end;

procedure TATButton.SetFocusable(AValue: boolean);
begin
  if FFocusable=AValue then Exit;
  FFocusable:= AValue;
  TabStop:= AValue;
end;

procedure TATButton.SetKind(AValue: TATButtonKind);
begin
  if FKind=AValue then Exit;
  FKind:= AValue;
  Invalidate;
end;

procedure TATButton.SetCaption(const AValue: TCaption);
begin
  if FCaption=AValue then Exit;
  FCaption:= AValue;
  Invalidate;
end;

function TATButton.IsPressed: boolean;
begin
  Result:= FPressed and FOver;
end;

procedure TATButton.Paint;
var
  r: TRect;
  pnt1, pnt2: TPoint;
  size, dx, dy, i: integer;
begin
  inherited;

  if not FFlat or FChecked or
    (FOver and not (FKind in [abuSeparatorHorz, abuSeparatorVert])) then
  begin
    //----draw bg
    r:= ClientRect;
    Canvas.Brush.Color:=
      IfThen(not Enabled, ATButtonTheme.ColorBgDisabled,
       IfThen(FChecked, ATButtonTheme.ColorBgChecked,
        IfThen(FOver, ATButtonTheme.ColorBgOver, ATButtonTheme.ColorBgPassive)));
    Canvas.FillRect(r);

    //----draw border
    Canvas.Brush.Style:= bsClear;

    Canvas.Pen.Color:=
      IfThen(FOver, ATButtonTheme.ColorBorderOver,
        IfThen(Focused, ATButtonTheme.ColorBorderFocused, ATButtonTheme.ColorBorderPassive));
    Canvas.Rectangle(r);

    size:= 1;
    if IsPressed then size:= ATButtonTheme.PressedBorderWidth else
    if FOver then size:= ATButtonTheme.MouseoverBorderWidth;

    for i:= 1 to size-1 do
    begin
      InflateRect(r, -1, -1);
      Canvas.Rectangle(r);
    end;

    Canvas.Brush.Style:= bsSolid;
  end;

  Canvas.Font.Name:= ATButtonTheme.FontName;
  Canvas.Font.Color:= IfThen(Enabled, ATButtonTheme.ColorFont, ATButtonTheme.ColorFontDisabled);
  Canvas.Font.Size:= ATButtonTheme.FontSize;
  Canvas.Font.Style:= ATButtonTheme.FontStyles;
  Canvas.Brush.Style:= bsClear;

  case FKind of
    abuIconOnly:
      begin
        pnt1.x:= (ClientWidth-GetIconWidth) div 2+
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftX);
        pnt1.y:= (ClientHeight-GetIconHeight) div 2 +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftY);
        PaintIcon(pnt1.x, pnt1.y);
      end;

    abuTextOnly:
      begin
        pnt1.x:= (ClientWidth-GetTextSize(Caption).cx) div 2 +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftX);
        pnt1.y:= (ClientHeight-GetTextSize(Caption).cy) div 2 +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftY);
        Canvas.TextOut(pnt1.x, pnt1.y, FCaption);
      end;

    abuTextIconHorz:
      begin
        pnt1.x:= cATButtonIndent +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftX);
        pnt1.y:= (ClientHeight-GetIconHeight) div 2 +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftY);
        PaintIcon(pnt1.x, pnt1.y);

        Inc(pnt1.x, GetIconWidth+cATButtonIndentArrow);
        pnt1.y:= (ClientHeight-GetTextSize(Caption).cy) div 2 +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftY);
        Canvas.TextOut(pnt1.x, pnt1.y, FCaption);
      end;

    abuTextIconVert:
      begin
        pnt1.x:= (ClientWidth-GetIconWidth) div 2+
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftX);
        pnt1.y:= cATButtonIndent +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftY);
        PaintIcon(pnt1.x, pnt1.y);

        Inc(pnt1.y, GetIconHeight+cATButtonIndentArrow);
        pnt1.x:= (ClientWidth-GetTextSize(Caption).cx) div 2 +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftX);
        Canvas.TextOut(pnt1.x, pnt1.y, FCaption);
      end;

    abuTextArrow:
      begin
        pnt1.x:= (ClientWidth-GetTextSize(Caption).cx) div 2 +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftX);
        pnt1.y:= (ClientHeight-GetTextSize(Caption).cy) div 2 +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftY);
        Canvas.TextOut(pnt1.x, pnt1.y, FCaption);

        pnt1.x:= ClientWidth-cATButtonArrowSize*2+
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftX);
        pnt1.y:= (ClientHeight-cATButtonArrowSize div 2) div 2 +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftY);
        PaintArrow(pnt1.x, pnt1.y);
      end;

    abuArrowOnly:
      begin
        pnt1.x:= (ClientWidth-cATButtonArrowSize) div 2+
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftX);
        pnt1.y:= (ClientHeight-cATButtonArrowSize div 2) div 2 +
          IfThen(IsPressed, ATButtonTheme.PressedCaptionShiftY);
        PaintArrow(pnt1.x, pnt1.y);
      end;

    abuSeparatorVert:
      begin
        dy:= 2;
        pnt1:= Point(dy, Height div 2);
        pnt2:= Point(Width-dy, Height div 2);
        Canvas.Pen.Color:= ATButtonTheme.ColorArrows;
        Canvas.Line(pnt1, pnt2);
      end;

    abuSeparatorHorz:
      begin
        dy:= 2;
        pnt1:= Point(Width div 2, dy);
        pnt2:= Point(Width div 2, Height-dy);
        Canvas.Pen.Color:= ATButtonTheme.ColorArrows;
        Canvas.Line(pnt1, pnt2);
      end;

    abuCross:
      begin
        dx:= (Width-cATButtonArrowSize) div 2 - 1;
        dy:= (Height-cATButtonArrowSize) div 2 - 1;
        Canvas.Pen.Color:= ATButtonTheme.ColorArrows;
        Canvas.Line(dx, dy, dx+cATButtonArrowSize+1, dy+cATButtonArrowSize+1);
        Canvas.Line(dx+cATButtonArrowSize, dy, dx-1, dy+cATButtonArrowSize+1);
      end;
  end;

  //debug
  {
  Canvas.Font.Size:= 6;
  Canvas.Font.Color:= clNavy;
  Canvas.Brush.Style:= bsClear;
  Canvas.TextOut(0, 0, cATButtonKindValues[Kind]);
  }
end;

procedure TATButton.PaintIcon(AX, AY: integer);
begin
  if Assigned(FImages) and (FImageIndex>=0) and (FImageIndex<FImages.Count) then
    FImages.Draw(Canvas, AX, AY, FImageIndex)
  else
  if Assigned(FPicture) then
    Canvas.Draw(AX, AY, FPicture.Graphic);
end;

procedure TATButton.PaintArrow(AX, AY: integer);
var
  p1, p2, p3: TPoint;
begin
  p1:= Point(AX, AY);
  p2:= Point(AX + cATButtonArrowSize, AY);
  p3:= Point(AX + cATButtonArrowSize div 2, AY + cATButtonArrowSize div 2);
  Canvas.Brush.Style:= bsSolid;
  Canvas.Pen.Color:= ATButtonTheme.ColorArrows;
  Canvas.Brush.Color:= ATButtonTheme.ColorArrows;
  Canvas.Polygon([p1, p2, p3]);
end;

function TATButton.GetIconWidth: integer;
begin
  if Assigned(FImages) then
    Result:= FImages.Width
  else
  if Assigned(FPicture) then
    Result:= FPicture.Width
  else
    Result:= 0;
end;

function TATButton.GetIconHeight: integer;
begin
  if Assigned(FImages) then
    Result:= FImages.Height
  else
  if Assigned(FPicture) then
    Result:= FPicture.Height
  else
    Result:= 0;
end;

procedure TATButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  bOver: boolean;
begin
  inherited;

  bOver:= PtInRect(ClientRect, Point(X, Y));
  if bOver<>FOver then
  begin
    FOver:= bOver;
    Invalidate;
  end;
end;

procedure TATButton.MouseLeave;
begin
  inherited;
  FOver:= false;
  Invalidate;
end;

procedure TATButton.MouseEnter;
begin
  inherited;
  FOver:= true;
  Invalidate;
end;

procedure TATButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if Shift=[ssLeft] then
  begin
    FPressed:= true;
    if FFocusable then
      SetFocus;
  end;

  Invalidate;
end;

procedure TATButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if IsPressed then
    DoClick;

  FPressed:= false;
  Invalidate;
end;

procedure TATButton.DoClick;
begin
  if FCheckable then
    FChecked:= not FChecked;
  Invalidate;
  if Assigned(FOnClick) then
    FOnClick(Self);
end;


procedure TATButton.KeyPress(var Key: char);
begin
  inherited;
  if (Key=' ') then
    DoClick;
end;

procedure TATButton.DoEnter;
begin
  inherited;
  Invalidate;
end;

procedure TATButton.DoExit;
begin
  inherited;
  Invalidate;
end;

constructor TATButton.Create(AOwner: TComponent);
begin
  inherited;

  ControlStyle:= ControlStyle
    +[csOpaque]
    -[csDoubleClicks, csTripleClicks];

  TabStop:= true;
  Width:= 100;
  Height:= 25;

  FCaption:= 'Button';
  FPicture:= TPicture.Create;
  FPressed:= false;
  FOver:= false;
  FChecked:= false;
  FCheckable:= false;
  FFocusable:= true;
  FFlat:= false;
  FOnClick:= nil;
  FImages:= nil;
  FImageIndex:= -1;
  FKind:= abuTextOnly;
end;

destructor TATButton.Destroy;
begin
  FPicture.Free;

  inherited;
end;

function TATButton.GetTextSize(const S: string): TSize;
begin
  Result.cx:= 0;
  Result.cy:= 0;
  if S='' then exit;
  Canvas.Font.Name:= ATButtonTheme.FontName;
  Canvas.Font.Size:= ATButtonTheme.FontSize;
  Canvas.Font.Style:= ATButtonTheme.FontStyles;
  Result:= Canvas.TextExtent(S);
end;


initialization

  with ATButtonTheme do
  begin
    FontName:= 'default';
    FontSize:= 10;
    FontStyles:= [];
    ColorFont:= $303030;
    ColorFontDisabled:= $808088;
    ColorBgPassive:= $e0e0e0;
    ColorBgOver:= $e0e0e0;
    ColorBgChecked:= $b0b0b0;
    ColorBgDisabled:= $c0c0d0;
    ColorArrows:= clGray;
    ColorBorderPassive:= $a0a0a0;
    ColorBorderOver:= $d0d0d0;
    ColorBorderFocused:= clNavy;
    MouseoverBorderWidth:= 1;
    PressedBorderWidth:= 3;
    PressedCaptionShiftX:= 0;
    PressedCaptionShiftY:= 1;
  end;

end.

