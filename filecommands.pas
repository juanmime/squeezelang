unit FileCommands;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, FileUtil, RegExpr;

const
  CMDFILE                      = '<file>';
  CMDINPUTFILE                 = '<ifile>';
  CMDOUTPUTFILE                = '<ofile>';

type

PSearchRec = ^TSearchRec;

TString = record
  str: String;
end;

PString = ^TString;

TFileCommand = class(TObject)
private
public
  procedure execute(fname: String); virtual; abstract;
end;

TFCShrink = class(TFileCommand)
private
public
  procedure execute(fname: String); override;
end;

TFCDelete = class(TFileCommand)
private
public
  procedure execute(fname: String); override;
end;

TFCExecute = class(TFileCommand)
protected
  fCmd: String;
  fProcess: TProcess;
public
  constructor Create(); virtual;
  destructor Destroy(); override;
  procedure execute(fname: String); override;
  procedure setCmd(cmd: String);

  property Process: TProcess read fProcess;
end;

TFCReplace = class(TFileCommand)
private
  fSrc: String;
public
  constructor Create();
  procedure execute(fname: String); override;
  procedure setSrc(src: String);
end;

TFCExecReplace = class(TFCExecute)
public
  procedure execute(fname: String); override;
end;

TFCBinkAudioReplace = class(TFCExecReplace)
private
  fAt: TStrings;
  fNTracks: Integer;
public
  constructor Create(); override;
  procedure execute(fname: String); override;
  procedure setAudioTrack(at: TStrings);
  procedure setAudioNTracks(nt: Integer);
end;

function WhatPatternMatch(f: String; ptrn: TStrings): integer;

implementation

// ------------------- Misc Funtions --------------------- //
function WhatPatternMatch(f: String; ptrn: TStrings): integer;
var
  i: Integer;
  fRegExp: TRegExpr;
begin
  result := 0;
  fRegExp := TRegExpr.Create();
  for i := 0 to ptrn.Count-1 do
  begin
    fRegExp.Expression := ptrn[i];
    if (fRegExp.Exec(f)) then
    begin
      result := i;
      Break;
    end;
  end;
  fRegExp.Free();
end;

// ------------------- TFCShrink --------------------- //
procedure TFCShrink.execute(fname: String);
var
  f: THandle;
begin
  f := FileCreate(fname);
  FileClose(f);
end;

// ------------------- TFCDelete --------------------- //

procedure TFCDelete.execute(fname: String);
var
  mF: TextFile;
begin
  if (FileExists(fname)) then
  begin
    System.Assign(mF, fname);
    Erase(mf);
  end;
end;

// ------------------- TFCExecute --------------------- //
constructor TFCExecute.Create();
begin
  inherited Create();
  fCmd := '';
  fProcess := TProcess.Create(nil);
  fProcess.Options := fProcess.Options + [poWaitOnExit];
end;

destructor TFCExecute.Destroy();
begin
  fProcess.Free();
  inherited;
end;

procedure TFCExecute.execute(fname: String);
var
  cmdStr: String;
begin
  fname := '"' + fname + '"';

  if (Pos(CMDFILE, fCmd)>0) then
    cmdStr := StringReplace(fCmd, CMDFILE, fname, [rfReplaceAll])
  else
    cmdStr := fCmd + ' ' + fname;

  fProcess.CommandLine := cmdStr;
  fProcess.Execute;
end;

procedure TFCExecute.setCmd(cmd: String);
begin
  fCmd := cmd;
end;

// ------------------- TFCReplace --------------------- //
constructor TFCReplace.Create();
begin
  inherited Create();
  fSrc := '';
end;

procedure TFCReplace.execute(fname: String);
begin
  CopyFile(fSrc, fname);
end;

procedure TFCReplace.setSrc(src: String);
begin
  fSrc := src;
end;


// ------------------- TFCExecReplace --------------------- //

//TFCExecReplace = class(TFileCommand)

procedure TFCExecReplace.execute(fname: String);
var
  cmdStr: String;
  tmpFile: String;
  mF: TextFile;
begin
  if (Trim(fCmd)='') then
    Exit;

  tmpFile := IncludeTrailingPathDelimiter(ExtractFilePath(fname)) + 'tmp_' + SysUtils.ExtractFileName(fname);

  // Input File
  if (Pos(CMDINPUTFILE, fCmd)>0) then
    cmdStr := StringReplace(fCmd, CMDINPUTFILE, '"' + fname + '"', [rfReplaceAll]);

  // Output File
  if (Pos(CMDOUTPUTFILE, cmdStr)>0) then
    cmdStr := StringReplace(cmdStr, CMDOUTPUTFILE, '"' + tmpFile + '"', [rfReplaceAll]);

  // Execute
  fProcess.CommandLine := cmdStr;
  fProcess.Execute;

  if FileSize(tmpFile)>0 then
  begin
    // Delete old
    System.Assign(mF, fname);
    Erase(mf);

    // Rename new
    System.Assign(mF, tmpFile);
    System.Rename(mf, fname);
  end;
end;



constructor TFCBinkAudioReplace.Create();
begin
  inherited;
  fAt := NIL;
end;

procedure TFCBinkAudioReplace.execute(fname: String);
var
  cmdStr: String;
  tmpFile: String;
  tmpFile2: String;
  mF: TextFile;
  i: Integer;
begin
  if (Trim(fCmd)='') then
    Exit;

  tmpFile := IncludeTrailingPathDelimiter(ExtractFilePath(fname)) + 'tmp_' + SysUtils.ExtractFileName(fname);
  tmpFile2 := IncludeTrailingPathDelimiter(ExtractFilePath(fname)) + 'tmp2_' + SysUtils.ExtractFileName(fname);

  // Input File


  {if (fAt=fNTracks) then}
  if (fAt.IndexOf(IntToStr(fNTracks))>=0) then
    Dec(fNTracks);

  i := fNTracks;

  cmdStr := Format ('%s "%s" - "%s" /o /l4 /t%d /#', [fCmd, fname, tmpFile, i]);

  repeat
    // 1.- Execute command
    fProcess.CommandLine := cmdStr;
    fProcess.Execute;

    if (i<fNTracks) then
    begin
      // 2.- Delete old file
     System.Assign(mF, tmpFile);
     Erase(mf);

      // 3.- Rename tmp file
      System.Assign(mF, tmpFile2);
      System.Rename(mf, tmpFile);
    end;

    // 4.- Construct new command

    Dec(i);

{    if (fAt=i) then}
    if (fAt.IndexOf(IntToStr(i))>=0) then
      Dec(i);

    cmdStr := Format ('%s "%s" - "%s" /o /l4 /t%d /#', [fCmd, tmpFile, tmpFile2, i]);

  until (i<0);

{  // 5.- Mix de audio track
  cmdStr := Format ('%s %s %s %s /o /l4 /t%d /i%d /#', [fCmd, tmpFile, fname, tmpFile2, fAt, fAt]);
  fProcess.CommandLine := cmdStr;
  fProcess.Execute;
}

  // Replace file.
  if FileSize(tmpFile)>0 then
  begin
    // Delete old
    System.Assign(mF, fname);
    Erase(mf);

    // Rename new
    System.Assign(mF, tmpFile);
    System.Rename(mf, fname);
  end;

  if FileSize(tmpFile2)>0 then
  begin
    // Delete old
    System.Assign(mF, tmpFile2);
    Erase(mf);
  end;
end;

procedure TFCBinkAudioReplace.setAudioNTracks(nt: Integer);
begin
  fNTracks := nt;
end;

procedure TFCBinkAudioReplace.setAudioTrack(at: TStrings);
begin
  fAt := at;
end;

end.

