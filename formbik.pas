unit FormBik;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons;

type

  { TfrmBIK }

  TfrmBIK = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    lblNewSize: TLabel;
    lblSize: TLabel;
    pnlRegij: TPanel;
    tbQuality: TTrackBar;
    procedure BitBtn1Click(Sender: TObject);
    procedure tbQualityChange(Sender: TObject);
  private
    { private declarations }
  public
    commandline: String;
    class function getCommandLine(path: String; qty: Integer): String;
    { public declarations }
  end; 

var
  frmBIK: TfrmBIK;

implementation

{ TfrmBIK }

class function TfrmBIK.getCommandLine(path: String; qty: Integer): String;
begin
  result := Format ('%s <ifile> <ofile> /d%d /m3.0 /l4 /p8 /#', [path, qty]);
end;

procedure TfrmBIK.BitBtn1Click(Sender: TObject);
begin
  commandline := TfrmBIK.getCommandLine(commandline, tbQuality.Position);
end;

procedure TfrmBIK.tbQualityChange(Sender: TObject);
begin
  lblSize.Caption := Format ('%d%%', [tbQuality.Position]);
end;

initialization
  {$I formbik.lrs}

end.

