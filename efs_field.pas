unit efs_field;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls, Contnrs,Types;

const
  moveleft    = 0;
  moveright   = 1;

type
  TLevelMade = procedure of object;
  TOver      = procedure of object;
type

  { TRubber }

  { TRubber }

  TRubber = class(TGraphicControl)
  private

  public
    constructor Create(AOwner: TComponent); override;
    procedure   Paint; override;
  end;

type

 { TEnemies }

  TEnemies = class(TCustomControl)
   private

  public
    constructor Create(AOwner: TComponent); override;
    procedure   Paint; override;
    function ReadRect : TRect;
  end;


type
  { TEnemieField }

  TEnemieField = class(TCustomControl)
  private
    EnemieList    : TObjectList;
    RubberList    : TObjectList;
    FOnGameOver   : TOver;
    FOnLevelMade  : TLevelMade;
    //FReadRect: TRect;
    MoveTimer     : TTimer;
    EnemiesTrend  : byte;
    FInterval     : integer;
    FTimerOn      : boolean;
    procedure SetInterval(AValue: integer);
    procedure SetTimerOn(AValue: boolean);
    procedure Dye;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure  MoveFieldTimer(Sender:TObject);
    function CheckCollision(aPoint: TPoint): boolean;
    function ReadRect : TRect;
    function ShootingDown : TPoint;
    property Interval : integer read FInterval write SetInterval;
    property TimerOn : boolean read FTimerOn write SetTimerOn;
    property OnLevelMade : TLevelMade read FOnLevelMade write FOnLevelMade;
    property OnGameOver : TOver read FOnGameOver write FOnGameOver;
  end;

implementation

{ TRupper }

constructor TRubber.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  width  := 1000;
  height :=   10;
end;

procedure TRubber.Paint;
begin
  inherited Paint;
  canvas.Brush.Color:= $00323232;
  canvas.FillRect(0,0,width,height);
end;

{xxxxxxxxxxxxxxxxxxx TEnemies xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

constructor TEnemies.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  width  := 30;
  height := 30;
  Cursor := crNone;

end;


procedure TEnemies.Paint;
begin
  inherited Paint;
  canvas.Brush.Color:=clWhite;
  canvas.FillRect(0,0,width,height);
  canvas.Brush.Color:= $00323232;
  canvas.FillRect(0,10,10,20);
  canvas.FillRect(20,10,30,20);
  canvas.FillRect(5,0,25,5);
  canvas.FillRect(5,25,25,30);
end;

function TEnemies.ReadRect: TRect;
begin
 result:= Rect(parent.Left+Left,parent.Top+Top,parent.Left+left+Width,parent.Top+top+Height);
end;

{xxxxxxxxxxxxxxxxxx TEnemieField xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

procedure TEnemieField.SetInterval(AValue: integer);
begin
  if FInterval=AValue then Exit;
  FInterval:=AValue;
  MoveTimer.Interval:=AValue;
end;

procedure TEnemieField.SetTimerOn(AValue: boolean);
begin
  if FTimerOn=AValue then Exit;
  FTimerOn:=aValue;
  MoveTimer.Enabled  := AValue;

end;

procedure TEnemieField.Dye;
var lv : integer;

begin
 if not  assigned(RubberList) then
 begin
  RubberList  := TObjectList.Create(true);
  for lv:=0 to 5 do
   begin
    RubberList.add(TRubber.Create(self));
    TRubber(RubberList.Last).Parent := Parent;
    TRubber(RubberList.Last).Top   := 550+(lv*10);
    TRubber(RubberList.Last).Left  := 0;
    TRubber(RubberList.Last).Visible:= false;
   end;

 end;

 for lv:=0 to 5 do
 begin
  if (Top + height) >= 550+(lv*10) then TRubber(RubberList.Items[lv]).Visible:= true;
 end;
end;

constructor TEnemieField.Create(AOwner: TComponent);
var lv,i,j : integer;
begin
  inherited Create(AOwner);
  width  := 580;
  left   := 500 - (width div 2);
  height := 180;
  Top    := 100;
  //FInterval     := 500;
  Cursor := crNone;
  j:=0;

  EnemieList := TObjectList.Create(true);

   for lv:=3 downto 0 do
  begin
   for i:=0 to 11 do
    begin
     EnemieList.add(TEnemies.Create(self));
     TEnemies(EnemieList.Last).Parent := self;
     TEnemies(EnemieList.Last).Top   := 0 + (lv*50);
     TEnemies(EnemieList.Last).Left  := 0 + (i*50);
     TEnemies(EnemieList.Last).Tag   := j;
     inc(j);
    end;
  end;
  FTimerOn:= false;
  MoveTimer          := TTimer.Create(self);
  MoveTimer.Interval := FInterval;
  MoveTimer.Enabled  := FTimerOn;
  MoveTimer.OnTimer  := @MoveFieldTimer;
  Randomize;

end;

destructor TEnemieField.Destroy;
begin
  MoveTimer.Enabled:= false;
  EnemieList.Free;
  RubberList.Free;
  inherited Destroy;
end;

procedure TEnemieField.MoveFieldTimer(Sender:TObject);
var i,i2,j,lv,ReversalLeft, ReversalRight : integer;
begin
  //Höhe anpassen / Umkehrung ausrechnen
 ReversalLeft := Left;
 ReversalRight:= Left +Width;
 i:=1000;j:=0;i2:=0;
  for lv:= 0 to EnemieList.Count-1 do
   begin
     if TEnemies(EnemieList.Items[lv]).Left < i then
     i:=TEnemies(EnemieList.Items[lv]).Left;
     if TEnemies(EnemieList.Items[lv]).top + 30  > j then
     j:=TEnemies(EnemieList.Items[lv]).top + 30;
     if TEnemies(EnemieList.Items[lv]).Left > i2 then
     i2:=TEnemies(EnemieList.Items[lv]).Left;
   end;
   Height:=j;
   ReversalLeft:= ReversalLeft+ i;
   ReversalRight:=Left+i2+30;

 //nach unten bewegen
 if ReversalLeft <= 10 then
  begin
   EnemiesTrend := moveright;
   Top:= Top + 10;
  end;
 if ReversalRight >= 990 then
  begin
   EnemiesTrend := moveleft;
   Top:=Top + 10;
  end;
 //links und rechts bewegen
 if EnemiesTrend = moveright then
  Left:=Left+10;
 if EnemiesTrend = moveleft then
  Left:=Left-10;

 if (Top+Height ) > 550 then Dye;

 //ganz unten
 if (Top+Height ) >= 650 then
 begin
  if Assigned(OnGameOver) then OnGameOver;
 end;
end;

function TEnemieField.CheckCollision(aPoint: TPoint):boolean;
var lv : integer;
begin
 result:=false;
 for lv:=0 to EnemieList.Count-1 do
    begin
     if PtInRect(TEnemies(EnemieList.Items[lv]).ReadRect,aPoint) then
      begin
      EnemieList.Delete(lv);
      result:=true;
      if EnemieList.Count=0 then
       begin
        if Assigned(OnLevelMade) then OnLevelMade;
       end;
      break;
      end;
    end;
end;

function TEnemieField.ReadRect: TRect;
begin
 result:= Rect(Left,Top,left+Width,top+Height);
end;

function TEnemieField.ShootingDown: TPoint;
var digits   : TStringList;
    lv,j,i,h : integer;
    P : TPoint;
begin
   //vordereste Enemiereihe ermitteln
   digits := TStringList.Create;
   for lv:=0 to 11 do
    begin
     for i:=0 to 3 do
      begin
       h:=10;
       if EnemieList.Count = 0 then break;
       for j:=0 to EnemieList.Count-1 do
        begin
         if TEnemies(EnemieList.Items[j]).Left = lv*50 then
          begin
           if TEnemies(EnemieList.Items[j]).Height>h then
            begin
             h:= TEnemies(EnemieList.Items[j]).Height;
             digits.Add(inttostr(TEnemies(EnemieList.Items[j]).Tag));
             break;
           end;
          end;

        end;
     end;
   end;
  //Abschuss Enemie ermitteln
  i:= random(digits.Count-1);
  j:= strtoint(digits[i]);
  //parent.caption:=inttostr(j);
  for lv:=0 to EnemieList.Count-1 do
   begin
    if (TEnemies(EnemieList.Items[lv]).Tag) = j then
    begin
     P.X:= TEnemies(EnemieList.Items[lv]).Left+Left+15;
     P.Y:= TEnemies(EnemieList.Items[lv]).Top +30+Top;
     Result:=P;
    end;
  end;
  digits.Free;
end;

end.

