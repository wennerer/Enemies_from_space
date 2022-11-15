{ <This unit is a part of Enemies from Space> }
unit efs_highscore;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, TypInfo, LCLProc, DOM, XMLWrite, XMLRead, XPath;

Type
TPlayer=(Daemon,Lanzelotte,Schokominza,Zorro,Fanta,Melodie,Nussi,Speckes,Pepsi,Waterloo);


procedure WriteANewList;
procedure WriteHighScoreList(aStr : TStringList);
procedure ReadHighScoreList(aStr : TStringList);
function ReadLowest : integer;
function ReadScore(aString : string): integer;

implementation
var i1: integer;


procedure WriteANewList;
var
  Doc               : TXMLDocument;
  RootNode, RankNode,PlayerNode,ScoreNode,Text: TDOMNode;
  lv : integer;

begin
  try
    Doc := TXMLDocument.Create;

    RootNode := Doc.CreateElement('highscore');
    Doc.Appendchild(RootNode);
    RootNode:= Doc.DocumentElement;

    for lv:=1 to 10 do
     begin
     RankNode   := Doc.CreateElement('rank'+unicodestring(inttostr(lv)));
     RootNode.AppendChild(RankNode);

      PlayerNode   := Doc.CreateElement('player');
       Text   := Doc.CreateTextNode(unicodestring(GetEnumName(TypeInfo(TPlayer), ord(lv-1))));
       PlayerNode.AppendChild(Text);
      RankNode.AppendChild(PlayerNode);

      ScoreNode   := Doc.CreateElement('score');
       Text   := Doc.CreateTextNode(unicodestring(inttostr(1000-(lv*99))));
       ScoreNode.AppendChild(Text);
      RankNode.AppendChild(ScoreNode);
     end;
    writeXMLFile(Doc, 'highscore.xml');
  finally
    Doc.Free;
  end;
end;

procedure WriteHighScoreList(aStr: TStringList);
var
  Doc               : TXMLDocument;
  RootNode, RankNode,PlayerNode,ScoreNode,Text: TDOMNode;
  lv : integer;
  Player, Score : string;
 procedure ParseStringList(aString: string; var aPlayer,aScore:string);
 var i : integer;
 begin
  i := Pos(' ',aString);
  aScore := copy(aString,1,i-1);
  aPlayer:= copy(aString,i+3,length(aString));
 end;

begin
  try
    Doc := TXMLDocument.Create;

    RootNode := Doc.CreateElement('highscore');
    Doc.Appendchild(RootNode);
    RootNode:= Doc.DocumentElement;

    for lv:=0 to 9 do
     begin
     ParseStringList(aStr[lv],Player,Score);

     RankNode   := Doc.CreateElement('rank'+unicodestring(inttostr(lv+1)));
     RootNode.AppendChild(RankNode);

      PlayerNode   := Doc.CreateElement('player');
       Text   := Doc.CreateTextNode(unicodestring(Player));
       PlayerNode.AppendChild(Text);
      RankNode.AppendChild(PlayerNode);

      ScoreNode   := Doc.CreateElement('score');
       Text   := Doc.CreateTextNode(unicodestring(Score));
       ScoreNode.AppendChild(Text);
      RankNode.AppendChild(ScoreNode);
     end;
    writeXMLFile(Doc, 'highscore.xml');
  finally
    Doc.Free;
  end;
end;

procedure ReadHighScoreList(aStr : TStringList);
var xml   : TXMLDocument;
    str   : TStringList;
    s1,s2 : string;
  procedure ParseXML(Node : TDomNode);
  begin
    while (Assigned(Node)) do
    begin
      if Node.NodeValue <> '' then
       begin
         if not odd(i1) then
          s1 := string(Node.NodeValue)
         else
          begin
           s2 := string(Node.NodeValue);
           str.Add(s2+'   '+s1);
          end;
         inc(i1);
       end;
      ParseXML(Node.FirstChild);
      Node := Node.NextSibling;
    end;
  end;

begin
 str := TStringList.Create;
 try
  ReadXMLFile(xml, 'highscore.xml');
  ParseXML( xml.FirstChild);
  xml.Free;
  aStr.AddStrings(str);
 finally
  str.Free;
 end;

end;

function ReadLowest: integer;
var
  Xml: TXMLDocument;
  XPathResult: TXPathVariable;
begin
  ReadXMLFile(Xml, 'highscore.xml');
  XPathResult :=EvaluateXPathExpression('/highscore/rank10/score', Xml.DocumentElement);
  Result:= strtoint(String(XPathResult.AsText));
  XPathResult.Free;
  Xml.Free;
end;

function ReadScore(aString : string): integer;
var
  Xml: TXMLDocument;
  XPathResult: TXPathVariable;
begin
  ReadXMLFile(Xml, 'highscore.xml');
  XPathResult :=EvaluateXPathExpression('/highscore/rank'+unicodestring(aString)+'/score', Xml.DocumentElement);
  Result:= strtoint(String(XPathResult.AsText));
  XPathResult.Free;
  Xml.Free;
end;

end.

