unit efs_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls;

type
 TLevelMod = (NewGame,NewLevel);

type

  { TImpact }

  TImpact = class(TGraphicControl)
  private
    Poly : array [0..6] of TPoint;
  public
    constructor Create(AOwner: TComponent); override;
    procedure   Paint; override;

    end;


type
  { TSpaceShip }

  TSpaceShip = class(TCustomControl)
  private
    TrendLeft : boolean;
    TrendRight: boolean;
    STimer    : TTimer;
    Ship      : array [0..19] of TPoint;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure  Paint; override;
    procedure MoveRight;
    procedure MoveLeft;
    procedure Stop;
    procedure OnSTimer(Sender: TObject);
    function Hotspot:TPoint;
    procedure CheckShip (out aShip : array of TPoint);
  end;

type

  { TBarricade }

  TBarricade = class(TGraphicControl)
  private

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure   Paint; override;
    function ReadRect : TRect;
    function CheckImpact(aPoint: TPoint): boolean;
    end;

type

  { TRocket }

  TRocket = class(TCustomControl)
   private

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure   Paint; override;
    procedure MoveRocket;
    function Hotspot:TPoint;
  end;

  type

  { TERocket }

  TERocket = class(TCustomControl)
   private

  public
    constructor Create(AOwner: TComponent); override;
    procedure   Paint; override;
    procedure EMoveRocket;
    function EHotspot:TPoint;
  end;

implementation


{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx TSpaceShip xxxxxxxxxxxxxxxxxxxxxxxxxxx}

constructor TSpaceShip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  width := 50;
  height:= 30;
  STimer          := TTimer.Create(nil);
  STimer.SetSubComponent(true);
  STimer.Interval :=  5;
  STimer.Enabled  := false;
  STimer.OnTimer  := @OnSTimer;

  Ship[0].X:=0;
  Ship[0].Y:=30;
  Ship[1].X:=0;
  Ship[1].Y:=25;
  Ship[2].X:=5;
  Ship[2].Y:=25;
  Ship[3].X:=5;
  Ship[3].Y:=15;
  Ship[4].X:=0;
  Ship[4].Y:=15;
  Ship[5].X:=5;
  Ship[5].Y:=10;
  Ship[6].X:=22;
  Ship[6].Y:=10;
  Ship[7].X:=22;
  Ship[7].Y:=0;
  Ship[8].X:=28;
  Ship[8].Y:=0;
  Ship[9].X:=28;
  Ship[9].Y:=10;
  Ship[10].X:=45;
  Ship[10].Y:=10;
  Ship[11].X:=50;
  Ship[11].Y:=15;
  Ship[12].X:=45;
  Ship[12].Y:=15;
  Ship[13].X:=45;
  Ship[13].Y:=25;
  Ship[14].X:=50;
  Ship[14].Y:=25;
  Ship[15].X:=50;
  Ship[15].Y:=30;
  Ship[16].X:=35;
  Ship[16].Y:=30;
  Ship[17].X:=35;
  Ship[17].Y:=20;
  Ship[18].X:=15;
  Ship[18].Y:=20;
  Ship[19].X:=15;
  Ship[19].Y:=30;
end;

destructor TSpaceShip.Destroy;
begin
  inherited Destroy;
  STimer.Free;
end;

procedure TSpaceShip.Paint;
begin
 canvas.Brush.Color := clLime;
 canvas.Pen.Color   := clLime;
 canvas.Polygon(Ship);
end;

procedure TSpaceShip.MoveRight;
begin
 TrendRight:=true;
 TrendLeft :=false;
 STimer.Enabled:=true;
end;

procedure TSpaceShip.MoveLeft;
begin
 TrendRight:=false;
 TrendLeft :=true;
 STimer.Enabled:=true;
end;

procedure TSpaceShip.Stop;
begin
  STimer.Enabled:=false;
end;

procedure TSpaceShip.OnSTimer(Sender: TObject);
begin
 if TrendRight then
  begin
   Left:= Left+1;
   if Left +Width > Parent.Width then Left:= Parent.Width - Width;
   Invalidate;
  end;

 if TrendLeft then
  begin
   Left:= Left-1;
   if Left < 0 then Left:=0;
   Invalidate;
  end;
end;

function TSpaceShip.Hotspot: TPoint;
var p : TPoint;
begin
  p.X:= left + (width div 2);
  p.Y:= top;
  result:= p;
end;

procedure TSpaceShip.CheckShip(out aShip: array of TPoint);
begin
  aShip[0].X:=0+Left;
  aShip[0].Y:=30+Top;
  aShip[1].X:=0+Left;
  aShip[1].Y:=25+Top;
  aShip[2].X:=5+Left;
  aShip[2].Y:=25+Top;
  aShip[3].X:=5+Left;
  aShip[3].Y:=15+Top;
  aShip[4].X:=0+Left;
  aShip[4].Y:=15+Top;
  aShip[5].X:=5+Left;
  aShip[5].Y:=10+Top;
  aShip[6].X:=22+Left;
  aShip[6].Y:=10+Top;
  aShip[7].X:=22+Left;
  aShip[7].Y:=0+Top;
  aShip[8].X:=28+Left;
  aShip[8].Y:=0+Top;
  aShip[9].X:=28+Left;
  aShip[9].Y:=10+Top;
  aShip[10].X:=45+Left;
  aShip[10].Y:=10+Top;
  aShip[11].X:=50+Left;
  aShip[11].Y:=15+Top;
  aShip[12].X:=45+Left;
  aShip[12].Y:=15+Top;
  aShip[13].X:=45+Left;
  aShip[13].Y:=25+Top;
  aShip[14].X:=50+Left;
  aShip[14].Y:=25+Top;
  aShip[15].X:=50+Left;
  aShip[15].Y:=30+Top;
  aShip[16].X:=35+Left;
  aShip[16].Y:=30+Top;
  aShip[17].X:=35+Left;
  aShip[17].Y:=20+Top;
  aShip[18].X:=15+Left;
  aShip[18].Y:=20+Top;
  aShip[19].X:=15+Left;
  aShip[19].Y:=30+Top;

end;


{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx TImpact xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

constructor TImpact.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 width := 26;
 height:= 26;

 Poly[0].SetLocation(0,0);
 Poly[1].SetLocation(8,13);
 Poly[2].SetLocation(0,26);
 Poly[3].SetLocation(26,26);
 Poly[4].SetLocation(18,13);
 Poly[5].SetLocation(26,0);
 Poly[6].SetLocation(0,0);
end;

procedure TImpact.Paint;
begin
 inherited Paint;
 canvas.Brush.Color:= $00323232;
 canvas.Pen.Color  := $00323232;
 canvas.Polygon(Poly);
end;

{xxxxxxxxxxxxxxxxxxxx TBarricade xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

constructor TBarricade.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 width := 100;
 height:=  60;
end;

destructor TBarricade.Destroy;
begin
 inherited Destroy;
end;

procedure TBarricade.Paint;
begin
 inherited Paint;
 canvas.Brush.Color:=clLime;
 canvas.FillRect(0,0,width,height);
end;

function TBarricade.ReadRect: TRect;
begin
 result.Left   := Left;
 result.Top    := Top;
 result.Right  := Left+Width;
 result.Bottom := Top+Height;
end;

function TBarricade.CheckImpact(aPoint:TPoint): boolean;
begin
 result:=false;
 if canvas.Pixels[aPoint.X-left,aPoint.Y-Top] =clLime then
 result:=true;
end;

{xxxxxxxxxxxxxxxxxxxx TRocket xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

constructor TRocket.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 width := 3;
 height:= 8;
end;

destructor TRocket.Destroy;
begin
 inherited Destroy;
end;

procedure TRocket.Paint;
begin
 canvas.Brush.Color:=clLime;
 canvas.FillRect(0,0,width,height);
end;

procedure TRocket.MoveRocket;
begin
 Top := Top-2;
end;

function TRocket.Hotspot: TPoint;
var p : TPoint;
begin
 p.X:= left + (width div 2);
 p.Y:= top;
 result:= p;
end;



{xxxxxxxxxxxxxxxxxxx TERocket xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

constructor TERocket.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 width := 3;
 height:= 8;
end;

procedure TERocket.Paint;
begin
 inherited Paint;
 canvas.Brush.Color:=clLime;
 canvas.FillRect(0,0,width,height);
end;

procedure TERocket.EMoveRocket;
begin
 //Top := Top+2;
 Setbounds(left,top+2,width,height);
end;

function TERocket.EHotspot: TPoint;
var p : TPoint;
begin
 p.X:= left + (width div 2);
 p.Y:= top+height;
 result:= p;
end;


end.

