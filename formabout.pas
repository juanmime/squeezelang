unit FormAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    BitBtn1: TBitBtn;
    Memo1: TMemo;
    Memo2: TMemo;
    Notebook1: TNotebook;
    Page1: TPage;
    Page2: TPage;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmAbout: TfrmAbout;

implementation

initialization
  {$I formabout.lrs}

end.

