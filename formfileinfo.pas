unit FormFileInfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons;

type

  { TfrmFileInfo }

  TfrmFileInfo = class(TForm)
    BitBtn1: TBitBtn;
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmFileInfo: TfrmFileInfo;

implementation

{ TfrmFileInfo }

procedure TfrmFileInfo.FormShow(Sender: TObject);
var
  txt: String;
begin
  Memo1.SetFocus;
  Memo1.VertScrollBar.Position := Memo1.VertScrollBar.Size;
  //Memo1.VertScrollBar.Page.Position := Memo1.VertScrollBar.Position;
end;

initialization
  {$I formfileinfo.lrs}

end.

