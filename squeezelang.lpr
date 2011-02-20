program squeezelang;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, FormMain, RegExpr, LResources, FormErrors, FormAbout, FileCommands,
  FormBik, videoencode, formm2v, FormConfig, FormFileInfo;

{$IFDEF WINDOWS}{$R squeezelang.rc}{$ENDIF}

begin
  {$I squeezelang.lrs}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

