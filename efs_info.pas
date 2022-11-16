{ <This unit is a part of Enemies from Space> }
unit efs_info;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls, StdCtrls;

type

  { THighScoreEdit }

  THighScoreEdit = class(TCustomControl)
  private
    FTextStyle        : TTextStyle;
    BlinkiTimer       : TTimer;
    FBlinkiFontColor  : TColor;
    FEdit             : TEdit;
    procedure SetEdit(AValue: TEdit);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure   Paint; override;
    procedure OnBlinkiTimer(Sender:TObject);
    property Edit : TEdit read FEdit write SetEdit;
  end;



type

  { THighScoreDisplay }

  THighScoreDisplay = class(TCustomControl)
  private
    FTextStyle        : TTextStyle;
    BlinkiTimer       : TTimer;
    FBlinkiFontColor  : TColor;
    FDisplayText      : string;
  public
    ScoreList: TStringList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure   Paint; override;
    procedure OnBlinkiTimer(Sender:TObject);
  end;

type

  { TDisplay }

  TDisplay = class(TCustomControl)
  private
    FDisplayText: string;
    FTextStyle : TTextStyle;
    procedure SetDisplayText(AValue: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure   Paint; override;
    property DisplayText : string read FDisplayText write SetDisplayText;
  end;

type
  { TInfo }

  TInfo = class(TCustomControl)
  private
    FBlinki: boolean;
    FBlinkiText: string;
    FText      : string;
    FTextStyle : TTextStyle;
    BlinkiTimer: TTimer;
    FBlinkiFontColor : TColor;
    procedure SetBlinki(AValue: boolean);
    procedure setBlinkiText(AValue: string);
    procedure setText(AValue: string);
    procedure OnBlinkiTimer(Sender:TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure   Paint; override;
    property Text : string read FText write setText;
    property BlinkiText : string read FBlinkiText write setBlinkiText;
    property Blinki: boolean read FBlinki write SetBlinki;

  end;
implementation

{xxxxxxxxxxxxxxxxxxxxxxxxxx THighScoreEdit xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

procedure THighScoreEdit.SetEdit(AValue: TEdit);
begin
  if FEdit=AValue then Exit;
  FEdit:=AValue;
end;

constructor THighScoreEdit.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
  width  := 300;
  height := 150;
  Cursor := crDefault;

  FEdit             := TEdit.Create(self);
  FEdit.SetSubComponent(true);
  FEdit.Parent      := self;
  FEdit.SetBounds(55,80,200,30);

  FTextStyle.Clipping  := true;
  FTextStyle.Wordbreak := true;
  FTextStyle.SingleLine:= false;
  FTextStyle.Alignment := taCenter;
  FTextStyle.Layout    := tlCenter;

  BlinkiTimer          := TTimer.Create(self);
  BlinkiTimer.SetSubComponent(true);
  BlinkiTimer.Interval := 500;
  BlinkiTimer.Enabled  := true;
  BlinkiTimer.OnTimer  := @OnBlinkiTimer;
  FBlinkiFontColor     := clFuchsia;
end;

destructor THighScoreEdit.Destroy;
begin
  BlinkiTimer.Enabled:= false;
  inherited Destroy;

end;

procedure THighScoreEdit.Paint;
begin
  inherited Paint;
  Canvas.Brush.Color := $00323232;
  Canvas.Pen.Color   := clFuchsia;
  Canvas.Rectangle(0,0,width,height);
  Canvas.Font.Color  := FBlinkiFontColor;
  Canvas.Font.Height:= 18;
  Canvas.TextRect(rect(0,20,width,45),0,0,'New Highscore! Enter Your Name!',FTextStyle);
  Canvas.Font.Height:= 12;
  Canvas.TextOut(100,135,'Press Enter to confirm');
end;

procedure THighScoreEdit.OnBlinkiTimer(Sender: TObject);
begin
  if FBlinkiFontColor = clFuchsia then
  FBlinkiFontColor     := $00323232 else
  FBlinkiFontColor     := clFuchsia;
  invalidate;
  FEdit.SetFocus;
end;

{xxxxxxxxxxxxxxxxxxxxxxxxxx THighScoreDisplay xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

constructor THighScoreDisplay.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  width  := 500;
  height := 300;
  Cursor := crNone;
  FTextStyle.Clipping  := true;
  FTextStyle.Alignment := taCenter;
  FTextStyle.Layout    := tlCenter;
  FDisplayText         := 'Highscores';

  BlinkiTimer          := TTimer.Create(nil);
  BlinkiTimer.SetSubComponent(true);
  BlinkiTimer.Interval := 500;
  BlinkiTimer.Enabled  := true;
  BlinkiTimer.OnTimer  := @OnBlinkiTimer;
  FBlinkiFontColor     := clFuchsia;

  ScoreList := TStringList.Create;
end;

destructor THighScoreDisplay.Destroy;
begin
  inherited Destroy;
  BlinkiTimer.Enabled:= false;
  FreeAndNil(BlinkiTimer);
  ScoreList.Free;
end;

procedure THighScoreDisplay.Paint;
var lv : integer;
begin
  inherited Paint;
  FTextStyle.Alignment := taCenter;
  Canvas.Brush.Color := $00323232;
  Canvas.Pen.Color   := clFuchsia;
  Canvas.FillRect(0,0,width,height);

  Canvas.Font.Color  := FBlinkiFontColor;
  Canvas.Font.Height:= 28;
  canvas.TextRect(rect(0,17,width,54),0,0,FDisplayText,FTextStyle);

  Canvas.Font.Color  := clFuchsia;
  lv:=5;
  while lv<487 do
   begin
   Canvas.TextOut(lv,2,'*');
   inc(lv,12);
   end;
  lv:=14;
  while lv<275 do
   begin
   Canvas.TextOut(5,lv,'*');
   Canvas.TextOut(485,lv,'*');
   inc(lv,12);
   end;
  lv:=5;
  while lv<487 do
   begin
   Canvas.TextOut(lv,280,'*');
   inc(lv,12);
   end;
  Canvas.Font.Height:= 18;
  for lv:= 0 to 9 do
   begin
    FTextStyle.Alignment := taCenter;
    canvas.TextRect(rect(90,55+(lv*22),110,75+(lv*22)),0,0,inttostr(lv+1),FTextStyle);
    FTextStyle.Alignment := taLeftJustify;
    canvas.TextRect(rect(110,55+(lv*22),410,75+(lv*22)),150,0,ScoreList[lv],FTextStyle);

   end;
end;

procedure THighScoreDisplay.OnBlinkiTimer(Sender: TObject);
const i : integer = 0;
begin
 if FBlinkiFontColor = clFuchsia then
  FBlinkiFontColor     := $00323232 else
  FBlinkiFontColor     := clFuchsia;
  if i = 0 then FDisplayText := 'Highscores';
  if i = 2 then FDisplayText := 'Press Enter to continue';
  inc(i);
  if i > 3 then i:=0;
  invalidate;
end;

{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx TDisplay xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

procedure TDisplay.SetDisplayText(AValue: string);
begin
  if FDisplayText=AValue then Exit;
  FDisplayText:=AValue;
  Invalidate;
end;

constructor TDisplay.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  width := 100;
  Height:=  40;
  Cursor := crNone;
  FTextStyle.Clipping  := true;
  FTextStyle.Wordbreak := true;
  FTextStyle.SingleLine:= false;
  FTextStyle.Alignment := taLeftJustify;
  FTextStyle.Layout    := tlCenter;
end;

procedure TDisplay.Paint;
begin
  inherited Paint;
  Canvas.Brush.Color := $00323232;
  //Canvas.Pen.Color   := clFuchsia;
  Canvas.FillRect(0,0,width,height);

  Canvas.Font.Color  := clFuchsia;
  Canvas.Font.Height:= 24;
  Canvas.TextRect(rect(0,0,width,Height),0,0,FDisplayText,FTextStyle);
end;

{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx TInfo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

procedure TInfo.setText(AValue: string);
begin
  if FText=AValue then Exit;
  FText:=AValue;
end;

procedure TInfo.OnBlinkiTimer(Sender: TObject);
begin
 if FBlinkiFontColor = clFuchsia then
  FBlinkiFontColor     := $00323232 else
  FBlinkiFontColor     := clFuchsia;
  invalidate;
end;

procedure TInfo.setBlinkiText(AValue: string);
begin
  if FBlinkiText=AValue then Exit;
  FBlinkiText:=AValue;
end;

procedure TInfo.SetBlinki(AValue: boolean);
begin
  if FBlinki=AValue then Exit;
  FBlinki:=AValue;
  BlinkiTimer.Enabled:= FBlinki;
end;

constructor TInfo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  width  := 500;
  height := 300;
  Cursor := crNone;
  FTextStyle.Clipping  := true;
  FTextStyle.Wordbreak := true;
  FTextStyle.SingleLine:= false;
  FTextStyle.Alignment := taCenter;
  FTextStyle.Layout    := tlCenter;

  BlinkiTimer          := TTimer.Create(nil);
  BlinkiTimer.SetSubComponent(true);
  BlinkiTimer.Interval := 500;
  BlinkiTimer.Enabled  := false;
  BlinkiTimer.OnTimer  := @OnBlinkiTimer;
  FBlinkiFontColor     := clFuchsia;
end;

destructor TInfo.Destroy;
begin

  BlinkiTimer.Enabled  :=false;
  FreeAndNil(BlinkiTimer);//    BlinkiTimer.Free;
  inherited Destroy;
end;

procedure TInfo.Paint;
var lv : integer;
begin
  inherited Paint;

  Canvas.Brush.Color := $00323232;
  Canvas.Pen.Color   := clFuchsia;
  Canvas.FillRect(0,0,width,height);

  Canvas.Font.Color  := clFuchsia;
  Canvas.Font.Height:= 18;
  lv:=5;
  while lv<487 do
   begin
   Canvas.TextOut(lv,2,'*');
   inc(lv,12);
   end;
  lv:=14;
  while lv<275 do
   begin
   Canvas.TextOut(5,lv,'*');
   Canvas.TextOut(485,lv,'*');
   inc(lv,12);
   end;
  lv:=5;
  while lv<487 do
   begin
   Canvas.TextOut(lv,280,'*');
   inc(lv,12);
   end;

  Canvas.Font.Height:= 38;
  Canvas.TextRect(rect(0,0,width,200),0,0,FText,FTextStyle);

  Canvas.Font.Color:= FBlinkiFontColor;
  Canvas.Font.Height:= 28;
  Canvas.TextRect(rect(0,200,width,300),0,0,FBlinkiText,FTextStyle);
end;

end.

