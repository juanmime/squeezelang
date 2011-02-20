unit VideoEncode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileCommands, ComCtrls;

const
  APP_BINK                   = 'bink.exe';
  APP_BINKMIX                = 'binkmix.exe';
  APP_BINKPLAY               = 'binkplay.exe';
  APP_BINKRADINFO            = 'radinfo.exe';

type
  TNotifyStrings = procedure (Sender: TObject; errors: TStrings) of object;
  TVideoEncodeWMode = (veEncode = 0, veMix);

  TVideoEncode = class (TThread)
  private
    fNextFile: TNotifyEvent;
    fExecReplace: TFCExecReplace;
    fAudioReplace: TFCBinkAudioReplace;
    fFinish: TNotifyStrings;
    fErrors: TStrings;
    fListView: TListView;
    fPt: TStrings;
    fPos: Integer;
    fmmpegpath: String;
    fWantedTracks: TStrings;
    fTracks: Integer;
    procedure UnmarkFile();
    procedure NextFile();
    procedure NotifyFinish();
  protected
    fWMode: TVideoEncodeWMode;
    procedure Execute; override;
    procedure RecodeFile(f: String);
  public
    constructor Create(fl: TListView; pt: TStrings);
    destructor Destroy(); override;
    class procedure GetVideoInfo(f: String; ffmpegpath: String; info: TStringList);
    class function GetNAudioTracks(f: String; ffmpegpath: String): Integer;

    procedure setAudioNTracks(nt: Integer);
    procedure setMMPEGPath(p: String);
    procedure setWorkingMode(wk: TVideoEncodeWMode);
    procedure setWantedTracks(strTracks: String);
    property OnNextFile: TNotifyEvent read fNextFile write fNextFile;
    property OnFinish: TNotifyStrings read fFinish write fFinish;
  end;

implementation

uses Process;

constructor TVideoEncode.Create(fl: TListView; pt: TStrings);
begin
  FreeOnTerminate := True;
  fExecReplace := TFCExecReplace.Create();
  fAudioReplace := TFCBinkAudioReplace.Create();
  fWantedTracks := TStringList.Create();
  fErrors := TStringList.Create();
  fListView := fl;
  fPt := pt;
  fTracks := 0;
  fWMode := veEncode;

  inherited Create(true);
end;

destructor TVideoEncode.Destroy();
begin
{  fExecReplace.Free();
  fAudioReplace.Free();
}
  inherited;
end;

procedure TVideoEncode.Execute;
var
  i: Integer;
begin
  // Start Encode
  for i := 0 to fListView.Items.Count - 1 do
  begin
    fPos := i;
    if Terminated then
      Break;

    if (fListView.Items[fPos].Checked) then
      RecodeFile(PSearchRec(fListView.Items[fPos].SubItems.Objects[0])^.Name);
  end;

  Synchronize(@NotifyFinish);
  fErrors.Free();
  fExecReplace.Free();
end;

procedure TVideoEncode.UnmarkFile();
begin
  fListView.Items[fPos].Checked := false;
end;

procedure TVideoEncode.NextFile();
begin
  if Assigned(fNextFile) then
    fNextFile(self);
end;

procedure TVideoEncode.NotifyFinish();
begin
  if Assigned(fFinish) then
    fFinish(self, fErrors);
end;

procedure TVideoEncode.RecodeFile(f: String);
var
  k: Integer;
  cmd: TFileCommand;
begin
  try
    // We see what pattern match
    // Yes this could be done better (Ej: Array), but have no much time.
    // Unmark File
    UnmarkFile;

    k := WhatPatternMatch(f, fPt);

    if ((k=0) and (fWMode=veMix)) then
    begin
      cmd := fAudioReplace;
      fAudioReplace.setCmd(PString(fPt.Objects[k])^.str{'tools\binkmix.exe'});
      fTracks := TVideoEncode.GetNAudioTracks(f, fmmpegpath);
      fAudioReplace.setAudioNTracks(fTracks);
      fAudioReplace.setAudioTrack(fWantedTracks);
    end else
    begin
      cmd := fExecReplace;
      fExecReplace.setCmd(PString(fPt.Objects[k])^.str);
    end;

    // Execute Action
    cmd.Execute(f);

    // Next File
    Synchronize(@NextFile);

  except
    On e: Exception do
      fErrors.Add(f + ' - ' + e.Message);
  end;
end;

procedure TVideoEncode.setAudioNTracks(nt: Integer);
begin
  fTracks := nt;
end;

procedure TVideoEncode.setMMPEGPath(p: String);
begin
  fmmpegpath := p;
end;

procedure TVideoEncode.setWorkingMode(wk: TVideoEncodeWMode);
begin
  fWMode := wk;
end;

procedure TVideoEncode.setWantedTracks(strTracks: String);
begin
  fWantedTracks.Clear;
  fWantedTracks.Delimiter := ',';
  fWantedTracks.DelimitedText := strTracks;
end;

class procedure TVideoEncode.GetVideoInfo(f: String; ffmpegpath: String; info: TStringList);
var
  fc: TFCExecute;
  n, BytesRead: LongInt;
  M: TMemoryStream;
begin
  if (f='') then
    Exit;

  try
    fc := TFCExecute.Create();
    fc.setCmd(Format ('%s -i <file>', [ffmpegpath]));
    fc.Process.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
    fc.execute(f);

    M :=  TMemoryStream.Create;
    BytesRead := 0;

    while fc.Process.Running do
    begin
      if (fc.Process.Output.NumBytesAvailable>0) then
      begin
        M.SetSize(BytesRead + 2048);

        // intentamos leerlo
        n := fc.Process.Output.Read((M.Memory + BytesRead)^, 2048);
        if n > 0 then
          Inc(BytesRead, n)
        else // sin datos, esperamos 100 milisegundos
          Sleep(100);
      end;
    end;
    // leemos la última parte
    repeat
        // nos aseguramos de tener espacio
        M.SetSize(BytesRead + 2048);
        // intentamos leerlo
        if (fc.Process.Output.NumBytesAvailable>0) then
          n := fc.Process.Output.Read((M.Memory + BytesRead)^, 2048)
        else
          n := 0;

        if n > 0 then
         Inc(BytesRead, n);
    until n <= 0;

    M.SetSize(BytesRead);

    Info.LoadFromStream(M);
    //frmFileInfo.Memo1.Lines.LoadFromStream(M);

  finally
    fc.Free;
    if (Assigned(M)) then
      M.Free();
  end;
end;

class function TVideoEncode.GetNAudioTracks(f: String; ffmpegpath: String): Integer;
var
  info: TStringList;
  i: Integer;
begin
  result := 0;

  try
    info := TStringList.Create();
    GetVideoInfo(f, ffmpegpath, info);

    for i := 0 to info.Count-1 do
      if ((Pos('Stream', info[i])>0) AND (Pos('Audio:', info[i])>0)) then
        Inc(result);
  finally
    info.Free();
  end;
end;

end.

