{ <Enemies from Space>

  Copyright (C) <15.11.2022> <Bernd Hübner> <Version 1.0>

  This source is free software; you can redistribute it and/or modify it under the terms of the GNU General Public
  License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later
  version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web at
  <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing to the Free Software Foundation, Inc., 51
  Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.
}

unit enemies_from_space;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Contnrs, ExtCtrls,
  StdCtrls, Types, efs_info, efs_types, efs_field, efs_highscore,PtIn;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure New(aLevelMod: TLevelMod);
    procedure LevelMade;
    procedure RocketTakt(Sender: TObject);
    procedure GameOver;
    procedure CalculateScore;
    procedure OnScoreTimer(Sender: TObject);
    procedure CalculateHighScore;
    procedure EnterHighScoreName(Sender: TObject);
    procedure CreateNewHighScoreList;
    procedure ShowHighScore;

  private
    Info             : TInfo;
    Start            : boolean;
    SpaceShip        : TSpaceShip;
    Barricades       : array [0..3] of TBarricade;
    Takt             : TTimer;
    TaktDelay        : integer;
    TaktCounter      : integer;
    RocketList       : TObjectList;
    ERocketList      : TObjectList;
    EnemieField      : TEnemieField;
    ImpactList       : TObjectList;
    made             : boolean;
    LevelDisplay     : TDisplay;
    Level            : integer;
    ShotsDisplay     : TDisplay;
    Shots            : integer;
    KillsDisplay     : TDisplay;
    Kills            : integer;
    ScoreDisplay     : TDisplay;
    Score            : integer;
    EFTop            : integer;
    EFIntervall      : integer;
    NG               : boolean; //NewGame
    ScoreTimer       : TTimer;
    ScoreDisplayCount: integer;
    BreakDisplay     : TDisplay;
    HScoreDisplay    : THighScoreDisplay;
    HScoreEdit       : THighScoreEdit;
    GO               : boolean; //GameOver
    HighScoreName    : string;
  public

  end;

var
  Form1: TForm1;

implementation

uses LCLType;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var lv : integer;
begin
 EnemieField.TimerOn:=false;
 Cursor := crDefault;
 Takt.Enabled := false;

 for lv:= 0 to RocketList.Count-1 do
  begin
   if assigned(TRocket(RocketList.Items[lv])) then
    begin
     Application.ReleaseComponent(TRocket(RocketList.Items[lv]));
     //TRocket(RocketList.Items[lv]):=nil;
   end;
  end;
 for lv:= 0 to ERocketList.Count-1 do
  begin
   if assigned(TERocket(ERocketList.Items[lv])) then
    begin
     Application.ReleaseComponent(TERocket(ERocketList.Items[lv]));
     //TERocket(ERocketList.Items[lv]):=nil;
   end;
  end;
 FreeAndNil(RocketList);
 FreeAndNil(ERocketList);
 FreeAndNil(ImpactList);
 CanClose:=true;
end;

procedure TForm1.FormCreate(Sender: TObject);
var lv : integer;
begin
 Caption          := 'Enemies From Space';
 Width            := 1000;
 Height           :=  700;
 Left             := (screen.Width div 2) - (width div 2);
 Top              :=   30;
 Color            := $00323232;
 KeyPreview       := true;
 Cursor           := crNone;

 Takt             := TTimer.Create(self);
 Takt.Enabled     := false;
 Takt.Interval    := 10;
 Takt.OnTimer     := @RocketTakt;
 TaktCounter      :=   0;
 TaktDelay        := 100;

 for lv:=0 to 3 do
  begin
   Barricades[lv]       := TBarricade.Create(self);
   Barricades[lv].Parent:= self;
   Barricades[lv].Left  := 120+(lv*220);
   Barricades[lv].Top   := 550;
  end;

 New(NewGame);

 Info             := TInfo.Create(self);
 Info.Parent      := self;
 Info.Left        := 250;
 Info.Top         :=  80;
 Info.Text        := 'Enemies_from_space';
 Info.BlinkiText  := 'Press Enter To Start A New Game';
 Info.Blinki      := true;

 LevelDisplay        := TDisplay.Create(self);
 LevelDisplay.Parent := self;
 LevelDisplay.SetBounds(0,0,100,30);
 Level := 0;

 ShotsDisplay        := TDisplay.Create(self);
 ShotsDisplay.Parent := self;
 ShotsDisplay.SetBounds(100,0,220,30);
 Shots := 0;

 KillsDisplay        := TDisplay.Create(self);
 KillsDisplay.Parent := self;
 KillsDisplay.SetBounds(230,0,380,30);
 Kills := 0;

 ScoreDisplay        := TDisplay.Create(self);
 ScoreDisplay.Parent := self;
 ScoreDisplay.SetBounds(380,0,550,30);
 Score := 0;

 BreakDisplay         := TDisplay.Create(self);
 BreakDisplay .Parent := self;
 BreakDisplay .SetBounds(550,0,650,30);

 if not fileexists('highscore.xml') then WriteANewList;

end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if assigned(HScoreEdit) and (Key=VK_RETURN) then
  begin
   Application.ReleaseComponent(HScoreEdit);
   HScoreEdit:=nil;
   CreateNewHighScoreList;
   ShowHighScore;
   exit;
  end;

  if assigned(HScoreDisplay) and (Key=VK_RETURN) then
  begin
   Application.ReleaseComponent(HScoreDisplay);
   HScoreDisplay:=nil;
   Info.Blinki:=true;
   exit;
  end;

 if Start and (Key=VK_RETURN) then
  begin
   if assigned(Info) then
    begin
     Application.ReleaseComponent(Info);
     Info:=nil;
   end;
   Start:=false;
   GO  := false;
   Takt.Enabled := True;
   EnemieField.TimerOn := true;
   made:=false;
   inc(Level);
   LevelDisplay.DisplayText:='Level '+inttostr(Level);
   BreakDisplay.DisplayText:= 'F10 Break      ESC Exit';
   if NG then
    begin
     Level := 0;
     Kills := 0;
     Shots := 0;
     Score := 0;
     LevelDisplay.DisplayText:='Level 1';
     ShotsDisplay.DisplayText:='';
     KillsDisplay.DisplayText:='';
     ScoreDisplay.DisplayText:='';
    end;
   NG:=false;
 end;

 if Key = VK_ESCAPE then begin
  Close;
 end;

 if start then exit;

 if Key = VK_LEFT then begin
  SpaceShip.MoveLeft;
 end;

 if Key = VK_RIGHT then begin
  SpaceShip.MoveRight;
 end;

 if Key = VK_SPACE then begin
  if RocketList.Count < 5 then  //max Rocket
   begin
    RocketList.Add(TRocket.Create(self));
    TRocket(RocketList.Last).Parent:= self;
    TRocket(RocketList.Last).Top   := SpaceShip.Top-TRocket(RocketList.Last).Height;
    TRocket(RocketList.Last).Left  := SpaceShip.Hotspot.X -1;
    inc(Shots);
    ShotsDisplay.DisplayText:='Shots '+inttostr(Shots);
   end;
 end;

 if Key = VK_F10 then begin
  if Takt.Enabled then Takt.Enabled:=false else Takt.Enabled:=true;
  if EnemieField.TimerOn then EnemieField.TimerOn:=false else EnemieField.TimerOn := true;
 end;

end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 if (Key = VK_LEFT) or (Key = VK_RIGHT) then
    SpaceShip.Stop;
end;

procedure TForm1.New(aLevelMod: TLevelMod);
begin
  if not assigned(SpaceShip) then
   begin
    SpaceShip        := TSpaceShip.Create(self);
    SpaceShip.Parent := self;
    SpaceShip.Left   := (self.Width div 2)-(SpaceShip.Width div 2);
    SpaceShip.Top    := 650;
  end;
  Start            := true;
  EnemieField             := TEnemieField.Create(self);
  EnemieField.Parent      := self;
  EnemieField.OnLevelMade := @LevelMade;
  EnemieField.OnGameOver  := @GameOver;
  if aLevelMod = NewGame then
  begin
   EnemieField.Interval:=500;
   TaktDelay:=100;
  end;
  if aLevelMod = NewLevel then
  begin
   EnemieField.Interval:=EFIntervall;
   if EnemieField.Interval<100 then EnemieField.Interval:=100;
   EnemieField.Interval:=EnemieField.Interval-50;
   EnemieField.Top:= EFTop;
   EnemieField.Top:= EnemieField.Top+10;
   if EnemieField.Top > 370 then EnemieField.Top:=370;
   TaktDelay        := TaktDelay-10;
   If TaktDelay < 50 then TaktDelay:=50;
  end;

  if not assigned(RocketList) then RocketList := TObjectList.Create(True);
  if not assigned(ERocketList) then ERocketList := TObjectList.Create(True);
  if not assigned(ImpactList) then ImpactList := TObjectList.Create(True);
end;

procedure TForm1.LevelMade;
begin
 RocketList.Clear;
 ERocketList.Clear;
 ImpactList.Clear;
 Takt.Enabled        := false;
 EnemieField.TimerOn := false;
 EFTop            := EnemieField.Top;
 EFIntervall      := EnemieField.Interval;
 FreeAndNil(EnemieField);

 New(NewLevel);

 made:=true;
 Info             := TInfo.Create(self);
 Info.Parent      := self;
 Info.Left        := 250;
 Info.Top         :=  80;
 Info.Text        := 'You Win This Level';
 Info.BlinkiText  := 'Press Enter To Start The Next Level';
 Info.Blinki      := true;
 Start            := true;
 ScoreDisplayCount:=0;
 CalculateScore;
end;

procedure TForm1.GameOver;
begin
 RocketList.Clear;
 ERocketList.Clear;
 ImpactList.Clear;
 Takt.Enabled        := false;
 EnemieField.TimerOn := false;
 FreeAndNil(EnemieField);
 ScoreDisplayCount:=0;
 CalculateScore;
 New(NewGame);

 made:=true;
 Info             := TInfo.Create(self);
 Info.Parent      := self;
 Info.Left        := 250;
 Info.Top         :=  80;
 Info.Text        := 'Game Over';
 Info.BlinkiText  := 'Press Enter To Start A New Game';
 Info.Blinki      := true;
 Start            := true;
 NG := true;
 GO  := true;
end;

procedure TForm1.CalculateScore;
begin
  ScoreTimer          := TTimer.Create(nil);
  ScoreTimer.Interval := 100;
  ScoreTimer.Enabled  := true;
  ScoreTimer.OnTimer  := @OnScoreTimer;
end;

procedure TForm1.OnScoreTimer(Sender: TObject);
begin
 ScoreDisplay.DisplayText:='Score '+inttostr(Random(999));
 inc(ScoreDisplayCount);
 if ScoreDisplayCount = 15 then
   begin
    ScoreTimer.Enabled:= false;
    score:= (kills *10) - Shots;
    ScoreDisplay.DisplayText:='Score '+inttostr(score);
    ScoreTimer.Free;
    if GO then CalculateHighScore;
  end;
end;

procedure TForm1.CalculateHighScore;
begin
 if Score > ReadLowest then
   begin
    Info.Blinki:=false;

    if not assigned(HScoreEdit) then
    HScoreEdit               := THighScoreEdit.Create(self);
    HScoreEdit.Parent        := self;
    HScoreEdit.Left          := (width div 2)  - (HScoreEdit.Width div 2) ;
    HScoreEdit.Top           := (Height div 2) - (HScoreEdit.Height div 2);
    HScoreEdit.Edit.OnChange := @EnterHighScoreName;
   end
  else ShowHighScore;
end;

procedure TForm1.EnterHighScoreName(Sender: TObject);
begin
 HighScoreName := HScoreEdit.Edit.Caption;
end;

procedure TForm1.CreateNewHighScoreList;
var str   : TStringList;
    lv    : integer;
begin
 str := TStringList.Create;
 try
  ReadHighScoreList(str);

  for lv:= 1 to 10 do
   if Score > ReadScore(inttostr(lv)) then break;

  str.Insert(lv-1,inttostr(Score)+'   '+HighScoreName);
  WriteHighScoreList(str);
 finally
  str.Free;
 end;
end;

procedure TForm1.ShowHighScore;
var str   : TStringList;
begin
 str := TStringList.Create;
 try
  ReadHighScoreList(str);
  if not assigned(HScoreDisplay) then
   HScoreDisplay             := THighScoreDisplay.Create(self);
   HScoreDisplay.Parent      := self;
   HScoreDisplay.Left        := (width div 2) - (HScoreDisplay.Width div 2) ;
   HScoreDisplay.Top         :=  80;
   HScoreDisplay.ScoreList.AddStrings(str);

 finally
  str.Free;
 end;
end;



procedure TForm1.RocketTakt(Sender: TObject);
var lv,i : integer;
    p    : TPoint;
    Ship : array [0..19] of TPoint;
    brk  : boolean;
begin
 //Rocket bewegen
 for lv:= 0 to RocketList.Count-1 do
  begin
   brk:=false;
   TRocket(RocketList.Items[lv]).MoveRocket;
   If PtInRect(EnemieField.ReadRect,TRocket(RocketList.Items[lv]).Hotspot) then //im Field
    begin //Enemie Abschuß
     if EnemieField.CheckCollision(TRocket(RocketList.Items[lv]).Hotspot) then
      begin
       if not made then RocketList.Delete(lv);
       inc(Kills);
       KillsDisplay.DisplayText:='Kills '+inttostr(Kills);
       break;
      end;
   end;

   If TRocket(RocketList.Items[lv]).Top <= 50 then //außerhalb
    begin
     RocketList.Delete(lv);
     break
   end;

   //in die Barrikade geschossen
   for i:=0 to 3 do
   begin
    If PtInRect(Barricades[i].ReadRect,TRocket(RocketList.Items[lv]).Hotspot) then
    begin
      if Barricades[i].CheckImpact(TRocket(RocketList.Items[lv]).Hotspot) then
      begin
       if not made then
       begin
        ImpactList.Add(TImpact.Create(self));
        TImpact(ImpactList.Last).Parent:= self;
        TImpact(ImpactList.Last).Left:= TRocket(RocketList.Items[lv]).Hotspot.X-13;
        TImpact(ImpactList.Last).Top := TRocket(RocketList.Items[lv]).Hotspot.Y-22;
        TImpact(ImpactList.Last).BringToFront;
        RocketList.Delete(lv);
        brk:=true;
        break;
       end; //not made
      end; //CheckImpact
    end; //PtnIn
   end; //for
   if brk then break;
 end;


 //EnemieRockets abschießen
  inc(TaktCounter);
  if TaktCounter >= TaktDelay then
    begin
     TaktCounter := 0;
     ERocketList.Add(TERocket.Create(self));
     TERocket(ERocketList.Last).Parent:= self;
     p:= EnemieField.ShootingDown;
     TERocket(ERocketList.Last).Top   := p.Y;
     TERocket(ERocketList.Last).Left  := p.X;

  end;

  //EnemieRocket bewegen
  for lv:= 0 to ERocketList.Count-1 do
  begin
   brk:=false;
   TERocket(ERocketList.Items[lv]).EMoveRocket;
  //außerhalb
   If TERocket(ERocketList.Items[lv]).Top >= 680 then
   begin
    if not made then ERocketList.Delete(lv);
    break
   end;
  //in die Barrikade geschossen
   for i:=0 to 3 do
   begin
    If PtInRect(Barricades[i].ReadRect,TERocket(ERocketList.Items[lv]).EHotspot) then
    begin
      if Barricades[i].CheckImpact(TERocket(ERocketList.Items[lv]).EHotspot) then
      begin
      if not made then
       begin
        ImpactList.Add(TImpact.Create(self));
        TImpact(ImpactList.Last).Parent:= self;
        TImpact(ImpactList.Last).Left:= TERocket(ERocketList.Items[lv]).EHotspot.X-13;
        TImpact(ImpactList.Last).Top := TERocket(ERocketList.Items[lv]).EHotspot.Y;
        TImpact(ImpactList.Last).BringToFront;
        ERocketList.Delete(lv);
        brk:=true;
        break;
       end; //not made
      end; //CheckImpact
    end; //PtnIn
   end; //for
   if brk then break;

   //GameOver Abschu0
   SpaceShip.CheckShip(Ship);
   if PtInPoly(Ship,TERocket(ERocketList.Items[lv]).EHotspot) then
   begin
    GameOver;
    break;
   end;
  end;
end;

end.

