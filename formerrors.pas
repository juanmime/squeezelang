unit FormErrors;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons;

type

  { TfrmErrors }

  TfrmErrors = class(TForm)
    btnOk: TBitBtn;
    lstErrors: TListBox;
    procedure FormResize(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmErrors: TfrmErrors;

implementation

{ TfrmErrors }

procedure TfrmErrors.FormResize(Sender: TObject);
begin
  btnOk.Top := Height - lstErrors.Top - btnOk.Height;
  lstErrors.Width := Width - 2*lstErrors.Left;
  lstErrors.Height := btnOk.Top - 2*lstErrors.Top;
  btnOk.Left := (Width - btnOk.Width) div 2;
end;

initialization
  {$I formerrors.lrs}

end.

