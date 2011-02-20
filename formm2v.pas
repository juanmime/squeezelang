unit formm2v;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons;

type

  { TfrmM2V }

  TfrmM2V = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    cbAssistant: TComboBox;
    eBitRate: TEdit;
    eEncName: TEdit;
    lblEncoderPath: TLabel;
    Label2: TLabel;
    lblAssistant: TLabel;
    lblSize: TLabel;
    pnlRegij: TPanel;
    pnlffmpeg: TPanel;
    tbQuality: TTrackBar;
    procedure BitBtn1Click(Sender: TObject);
    procedure cbAssistantChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure tbQualityChange(Sender: TObject);
  private
    { private declarations }
  public
    commandline: String;
    class function getCommandLine(path: String; rejig: Boolean; qly: Integer): String;
    { public declarations }
  end; 

var
  frmM2V: TfrmM2V;

implementation

{ TfrmM2V }

procedure TfrmM2V.BitBtn1Click(Sender: TObject);
begin
  commandline := eEncName.Text + ' ' ;

  if (cbAssistant.ItemIndex=0) then
    commandline := commandline + Format ('-quiet -auto -close -level %d -o <ofile> -i <ifile>', [tbQuality.Position])
  else
    commandline := commandline + Format ('-i <ifile> -vcodec mpeg2video -b %s -minrate %s -an <ofile>', [eBitRate.Text, eBitRate.Text]);
end;

procedure TfrmM2V.cbAssistantChange(Sender: TObject);
begin
  if (cbAssistant.ItemIndex=0) then
  begin
    eEncName.Text := 'tools\ReJig.exe';
    pnlffmpeg.Visible := False;
  end else
  begin
    eEncName.Text := 'tools\ffmpeg.exe';
    pnlffmpeg.Visible := True;
  end;

  pnlRegij.Visible := not pnlffmpeg.Visible;
  lblSize.Visible := pnlRegij.Visible;
end;

procedure TfrmM2V.FormActivate(Sender: TObject);
begin
  tbQualityChange(Sender);
end;

procedure TfrmM2V.tbQualityChange(Sender: TObject);
begin
  lblSize.Caption := Format ('%d%%', [tbQuality.Position]);
end;

class function TfrmM2V.getCommandLine(path: String; rejig: Boolean; qly: Integer): String;
begin
  if (rejig) then
    result := Format ('%s -quiet -auto -close -level %d -o <ofile> -i <ifile>', [path, qly])
  else
    Format ('%s -i <ifile> -vcodec mpeg2video -b %s -minrate %dk -an <ofile>', [path, qly]);
end;

initialization
  {$I formm2v.lrs}

end.

