unit FormConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons;

type

  { TfrmConfig }

  TfrmConfig = class(TForm)
    BitBtn1: TBitBtn;
    btnFolder: TBitBtn;
    btnFolder1: TBitBtn;
    btnFolder2: TBitBtn;
    btnFolder3: TBitBtn;
    eRejig: TEdit;
    eFFmpeg: TEdit;
    eFFPlay: TEdit;
    eBink: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    openDlg: TOpenDialog;
    openDirDlg: TSelectDirectoryDialog;
    procedure btnFolder1Click(Sender: TObject);
    procedure btnFolder2Click(Sender: TObject);
    procedure btnFolder3Click(Sender: TObject);
    procedure btnFolderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label5Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmConfig: TfrmConfig;

implementation

{ TfrmConfig }

uses Config;

procedure TfrmConfig.btnFolderClick(Sender: TObject);
begin
  openDlg.FileName := eFFmpeg.Text;

  if (openDlg.Execute) then
    eFFmpeg.Text := openDlg.FileName;
end;

procedure TfrmConfig.FormCreate(Sender: TObject);
begin

end;

procedure TfrmConfig.Label5Click(Sender: TObject);
begin
  launchUrl(TLabel(Sender).Caption);
end;

procedure TfrmConfig.btnFolder1Click(Sender: TObject);
begin
  openDlg.FileName := eFFPlay.Text;

  if (openDlg.Execute) then
    eFFPlay.Text := openDlg.FileName;
end;

procedure TfrmConfig.btnFolder2Click(Sender: TObject);
begin
  openDirDlg.FileName := eBink.Text;

  if (openDirDlg.Execute) then
    eBink.Text := openDirDlg.FileName;
end;

procedure TfrmConfig.btnFolder3Click(Sender: TObject);
begin
  openDlg.FileName := eRejig.Text;

  if (openDlg.Execute) then
    eRejig.Text := openDlg.FileName;
end;

initialization
  {$I formconfig.lrs}

end.

