unit FormMain;

{$mode objfpc}{$H+}
{$codepage utf8}
(*
  Program: Squeezelang
  Author: juanmime
  Date: 2010/01/31
  Version:
  0.1.1 (2010/01/23) Shrink a batch of files.
  0.1.2 (2010/01/24) Multilanguage
  0.1.3 (2010/01/25) Why not load and save patterns ?
  0.1.4 (2010/01/26) Why not to do several things (ej: launch external program), not only shrink ?
  0.1.5 (2010/01/27) Why not to replace files ?
  0.1.6 (2010/01/28) About box. Refactor. Actions using Command Pattern Design. I like it.
  0.1.7 (2010/01/29) Why not include the fullpath in search ? Some games set languages digferent folders.
  0.1.8 (2010/01/30) Why not shows the size after and before ?. Why not to clean upgrade files ?
  0.1.9 (2010/01/31) Solved red background in status bar. Change year date in About form (we are in 2011 not 2010) ;)
  0.2.0a(2010/02/12) A lot of functions. Multicolumn File List with sorting columns. Video encoding (M2V, BIK). Multitheads. Save / Open Job List. Play video. Copy Video File path, ...)
  Description: Little tool for replacing language files, by void empty files.
  0.2.0 (2010/02/19) Audio stream selection in BIK files. Multilanguage translation. Some improvements.
  0.2.1 (2010/02/20) Little bug repared when mixing audio (file path with spaces).
  This tool is small and easy. You can use regular expression pattern matching
  to find the file names used in game's internationalization.
  The object of this tool is to reduce the game size cleaning language files
  not dessired by user.

  Licence: Free. GPL/GNU, etc. etc. Use, change or improve the software or code
  as you can. Remember:

   1. This software is provided as it is, without any kind of
      warranty given. Use it at Your own risk.The author is not
      responsible for any consequences of use of this software.
   2. The origin of this software may not be mispresented, You
      must not claim that You wrote the original software. If
      You use this software in any kind of product, it would be
      appreciated that there in a information box, or in the
      documentation would be an acknowledgement like

      juanmime
      http://www.twitter.com/juanmime

   3. And please, if you make changes, dristribute the source code,
      like me.

  Thanks to Andrey V. Sorokin, for TRegExpr class library, and Lazarus'
  project guys.

  Thanks to every console scenners for their hard work.

*)
interface

uses
  {$ifdef windows}Windows, {$endif}Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, CheckLst, ComCtrls, ExtCtrls, Menus, LazHelpHTML,
  Process, RegExpr, IniFiles, FormErrors, FormAbout, FileCommands, VideoEncode,
  Clipbrd, Config, FormBik {$ifdef unix}, cwstring{$endif};

const
  LANGUAGE_FILE                   = 'squeezelang.lng';
  CONFIG_FILE                     = 'squeezelang.cfg';
  PTRN_SECTION                    = 'PATTERNS';
  GLOBAL_SECTION                  = 'GLOBAL';
  CFG_COMMAND                     = 'COMMAND';
  CFG_REPLACE                     = 'REPLACE';
  CFG_CHARCASE                    = 'CHARCASE';
  CFG_INCLUDEPATH                 = 'INCLUDEPATH';
  CFG_UPDATEPUP                   = 'UPDATEPUP';

  CFG_BINK                        = 'BINK';
  CFG_FFMPEG                      = 'FFMPEG';
  CFG_FFPLAY                      = 'FFPLAY';
  CFG_REJIG                       = 'REJIG';
  CFG_M2VPRG                      = 'M2V';

  PTRN_PS3UPDATE                  = 'PS3UPDAT.PUP';

  KWD_GAME_FOLDER                 = 'GAME_FOLDER';
  KWD_SELECT_GAME_FOLDER          = 'SELECT_FOLDER';
  KWD_EXPLORE_BTN                 = 'EXPLORE_BTN';
  KWD_PATTERNS                    = 'FILE_PATTERNS';
  KWD_SEARCH                      = 'SEARCH';
  KWD_SEARCH_BTN                  = 'SEARCH_BTN';
  KWD_CHARCASE                    = 'CHARCASE';
  KWD_INCLUDEPATH                 = 'INCLUDEPATH';
  KWD_FOUND                       = 'FOUND';
  KWD_SHRINK                      = 'SHRINK';
  KWD_SELECTACTION                = 'SELECTACTION';
  KWD_SHRINK_BTN                  = 'SHRINK_BTN';
  KWD_CLOSE                       = 'CLOSE_BTN';
  KWD_CANCELMSG                   = 'CANCELMSG';
  KWD_BYE                         = 'GOODBYE';
  KWD_FILE                        = 'FILE';
  KWD_OPTIONS                     = 'OPTIONS';
  KWD_SELECT                      = 'MNUSELECT';
  KWD_SELECTALL                   = 'SELECTALL';
  KWD_AUDIOTRACKS                 = 'AUDIOTRACKS';
  KWD_SELTRACK                    = 'SELTRACK';
  KWD_SELECTNOTHING               = 'SELECTNOTHING';
  KWD_SELECTINV                   = 'SELECTINV';
  KWD_VIDEOINFO                   = 'VIDEOINFO';
  KWD_PLAY                        = 'VIDEOPLAY';
  KWD_LOADQUEUE                   = 'LOADQUEUE';
  KWD_SAVEQUEUE                   = 'SAVEQUEUE';
  KWD_VIDEOACTION                 = 'VIDEOACTION';
  KWD_RECODEVIDEO                 = 'RECODEVIDEO';
  KWD_MIXADIO                     = 'MIXAUDIO';
  KWD_COPYPATH                    = 'COPYPATH';
  KWD_FILE_OPEN                   = 'FILE_OPEN';
  KWD_FILE_SAVE                   = 'FILE_SAVE';
  KWD_ASK                         = 'ASK';
  KWD_NOCOMMAND                   = 'NOCOMMAND';
  KWD_NOREPLACE                   = 'NOREPLACE';
  KWD_FILENOTEXISTS               = 'FILENOTEXISTS';
  KWD_ABOUT                       = 'ABOUT';
  KWD_SIZEBEFORE                  = 'SIZEBEFORE';
  KWD_SIZEAFTER                   = 'SIZEAFTER';
  KWD_FILEDATE                    = 'DATE';
  KWD_WAIT                        = 'WAIT';
  KWD_PUPFILES                    = 'PUPFILES';
  KWD_COLFILE                     = 'COLFILE';
  KWD_COLSIZE                     = 'COLSIZE';
  KWD_TABLANG                     = 'TABLANG';
  KWD_TABVIDEO                    = 'TABVIDEO';
  KWD_NEWSIZE                     = 'NEWSIZE';
  KWD_ENCODERPATH                 = 'ENCPATH';
  KWD_ASSISTANT                   = 'ASSISTANT';

  KWD_ACTION                      = 'ACTION';

type
  TActionList = (alShrink = 0, alDelete, alExecute, alReplace);

  { TfrmMain }
  TfrmMain = class(TForm)
    btnStopEncode: TBitBtn;
    btnFileReplace: TBitBtn;
    btnCfg1: TBitBtn;
    btnCfg3: TBitBtn;
    btnCfg2: TBitBtn;
    btnFolder:  TBitBtn;
    btnSearch: TBitBtn;
    btnVideoSearch: TBitBtn;
    btnShrink: TBitBtn;
    btnRecode: TBitBtn;
    cbAction: TComboBox;
    cbVideoAction: TComboBox;
    cbLanguage: TComboBox;
    chkCharCase: TCheckBox;
    chkFiles: TListView;
    chkVideoFiles: TListView;
    chkIncludePath: TCheckBox;
    chkUpdateFiles: TCheckBox;
    eCommand: TEdit;
    eAudioTrack: TEdit;
    eNProc: TEdit;
    eGameFolder: TEdit;
    ePatter1: TEdit;
    ePatter2: TEdit;
    ePatter3: TEdit;
    ePatter4: TEdit;
    eBik: TEdit;
    eM2V: TEdit;
    eVP6: TEdit;
    ePatternPUB: TEdit;
    eReplaceFile: TEdit;
    ImageList1: TImageList;
    Label1: TLabel;
    lblAudioTrack: TLabel;
    lblVideoAction: TLabel;
    lblFound: TLabel;
    lblFound1: TLabel;
    lblGameFolder: TLabel;
    lblSect1:   TLabel;
    fDirectory: TSelectDirectoryDialog;
    lblSect2: TLabel;
    lblSect3: TLabel;
    lblSect4: TLabel;
    lblSect5: TLabel;
    lblSect6: TLabel;
    lblSect7: TLabel;
    lblSect8: TLabel;
    lblNProc: TLabel;
    MainMenu1:  TMainMenu;
    MenuItem1: TMenuItem;
    mnuSelect2: TMenuItem;
    mnuSelect1: TMenuItem;
    mnuAll1: TMenuItem;
    mnuNothing1: TMenuItem;
    mnuInvert1: TMenuItem;
    mnuAudioTracks: TMenuItem;
    mnuAll2: TMenuItem;
    mnuNothing2: TMenuItem;
    mnuInvert2: TMenuItem;
    mnuVideoInfo: TMenuItem;
    mnuOptions: TMenuItem;
    mnuPlay: TMenuItem;
    mnuLoadFiles: TMenuItem;
    mnuSaveFiles: TMenuItem;
    mnuFPath: TMenuItem;
    mnuAbout:   TMenuItem;
    mnuFile:    TMenuItem;
    mnuOpen:    TMenuItem;
    mnuSave:    TMenuItem;
    openDlg:    TOpenDialog;
    openDlg1: TOpenDialog;
    openDlg2: TOpenDialog;
    pcMain: TPageControl;
    pgrBar: TProgressBar;
    pgrBarVideo: TProgressBar;
    pnlBottom: TPanel;
    pnlPattern: TPanel;
    popMnu: TPopupMenu;
    popMnu2: TPopupMenu;
    saveDlg:    TSaveDialog;
    saveDlg1: TSaveDialog;
    sbInfo:     TStatusBar;
    pnlConfig: TScrollBox;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    btnUD: TUpDown;
    procedure btnUDClick(Sender: TObject; Button: TUDBtnType);
    procedure btnCfg1Click(Sender: TObject);
    procedure btnCfg2Click(Sender: TObject);
    procedure btnFileReplaceClick(Sender: TObject);
    procedure btnFolderClick(Sender: TObject);
    procedure btnRecodeClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnShrinkClick(Sender: TObject);
    procedure btnStopEncodeClick(Sender: TObject);
    procedure btnVideoSearchClick(Sender: TObject);
    procedure cbActionChange(Sender: TObject);
    procedure cbLanguageChange(Sender: TObject);
    procedure cbVideoActionChange(Sender: TObject);
    procedure chkFilesClick(Sender: TObject);
    procedure chkFilesClickCheck(Sender: TObject);
    procedure chkFilesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure chkUpdateFilesChange(Sender: TObject);
    procedure chkVideoFilesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure eBikEnter(Sender: TObject);
    procedure eGameFolderClick(Sender: TObject);
    procedure eGameFolderExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure chkFilesColumnClick(Sender: TObject; Column: TListColumn);
    procedure chkFilesCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure mnuAll1Click(Sender: TObject);
    procedure mnuNothing1Click(Sender: TObject);
    procedure mnuInvert1Click(Sender: TObject);
    procedure mnuAudioTracksClick(Sender: TObject);
    procedure mnuFPathClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuInvert2Click(Sender: TObject);
    procedure mnuLoadFilesClick(Sender: TObject);
    procedure mnuOpenClick(Sender: TObject);
    procedure mnuOptionsClick(Sender: TObject);
    procedure mnuPlayClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure mnuSaveFilesClick(Sender: TObject);
    procedure mnuAll2Click(Sender: TObject);
    procedure mnuNothing2Click(Sender: TObject);
    procedure mnuVideoInfoClick(Sender: TObject);
    procedure sbInfoDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure EncodeFinish(Sender:TObject; errors: TStrings);
    procedure NextEncodeFile(Sender: TObject);
    procedure LoadConfig();
    procedure SaveConfig();
  private
    { private declarations }
    fRegExp:    TRegExpr;
    Count:      integer;
    fGoodBye:   string;
    fFoundStr:  string;
    fAskStr:    string;
    fNoCmdStr:  string;
    fCancelMsg: String;
    fNoReplaceStr: string;
    fFileNotExists: string;
    fErrors:    TStrings;
    fCalcSizes: boolean;
    fFolderSize: int64;
    fFilesSize: int64;
    fVideosSize: int64;
    fSBefore:   string;
    fSAfter:    string;
    fSWait:     string;
    fSortDescending: Boolean;
    fSortedColumn: Integer;
    fCommandArray: array[alShrink..alReplace] of TFileCommand;
    //fExecReplace: TFCExecReplace;
    fPaterns: TStrings;
    fVideoPaterns: TStrings;
    fVEncode: TList;
    fNEWSIZE: String;
    fENCPATH: String;
    fAssistant: String;
    procedure ResizeLangPanel;
    procedure ResizeVideoPanel;
    function WalkTree(path: string; lv: TListView; ptr: TStrings): Int64;
    function MatchPatterns(fname: string; ptr: TStrings): boolean;
    procedure LoadLanguages();
    procedure LoadLanguage();
    procedure LoadPatterns();
    procedure SavePatterns();
    procedure ProcessFile(f: string);
    procedure ShowInfoBar(wait: boolean = False);
    function CheckPatterns(lst: TStrings): boolean;
    procedure CleanListMemory(fl: TListView);
    procedure CalcGlobalSize();
    procedure LoadFilePaterns();
    procedure LoadVideoPaterns();
    procedure CheckAll(lst: TListView);
    procedure CheckNone(lst: TListView);
    procedure CheckInverse(lst: TListView);
    //procedure RecodeFile(f: String);
    function WhatPatternMatch(f: String; ptrn: TStrings): integer;
    procedure GetVideoInfo(f: String; info: TStringList);
    function GetNAudioTracks(f: String): Integer;
    procedure setEncodeCommands();
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

const
  ACTION_OPTIONS: array[alShrink..alReplace] of string =
    ('SHRINK', 'DELETE', 'EXECUTE', 'REPLACE');

var
  frmMain: TfrmMain;

function getBestSizeUnit(fsize: int64): string;

implementation

uses formm2v, FormConfig, FormFileInfo, Math;

function getBestSizeUnit(fsize: int64): string;
const
  sizes: array[0..3] of string = ('KB', 'MB', 'GB', 'TB');
var
  num: double;
  i:   integer;
begin
  num := fsize;

  for i := Low(sizes) to High(sizes) do
  begin
    num := num / 1024;

    if (num < 1024) then
      break;
  end;

  Result := Format('%0.2f %s', [num, sizes[i]]);
end;

{ TfrmMain }

constructor TfrmMain.Create(AOwner: TComponent);
var
  myFolder: string;
{$ifdef windows}  SystemInfo:TSystemInfo; {$endif}
begin
  inherited Create(AOwner);
{$ifdef windows}
  GetSystemInfo(SystemInfo);
  btnUd.Position := Ceil(SystemInfo.dwNumberOfProcessors / 2);
  eNProc.Text := Format ('%d', [btnUd.Position]);
{$endif}
  fRegExp := TRegExpr.Create;
  GetDir(0, myFolder);
  eGameFolder.Text := myFolder;
  fGoodBye := 'Happy Shrink !!!';
  fFoundStr := '%u files found';
  fErrors := TStringList.Create();
  fCalcSizes := False;
  fSBefore := 'Size before shrink: %s';
  fSAfter := 'Size after shrink: %s';
  fSWait := 'Wait a moment ...';
  ePatternPUB.Text := PTRN_PS3UPDATE;
  //fExecReplace := TFCExecReplace.Create();
  fVEncode := TList.Create;

  fPaterns := TStringList.Create();
  fVideoPaterns := TStringList.Create();

  fFolderSize := 0;
  fFilesSize  := 0;
  fVideosSize := 0;

  // Load Video Patterns
  LoadVideoPaterns();

  // Initialice commands
  fCommandArray[alShrink]  := TFCShrink.Create();
  fCommandArray[alReplace] := TFCReplace.Create();
  fCommandArray[alExecute] := TFCExecute.Create();
  fCommandArray[alDelete]  := TFCDelete.Create();

  // Load Config
  LoadConfig();

  // Load Language Translations
  LoadLanguages();

  // Load Default Language
  LoadLanguage();
end;

destructor TfrmMain.Destroy();
var
  i: TActionList;
begin
  // Save Config
  SaveConfig();

  // je je, be clean my friend
  fRegExp.Free();
  fErrors.Free();
  fPaterns.Free();
  fVideoPaterns.Free();
  fVEncode.Free();

  for i := Low(fCommandArray) to High(Low(fCommandArray)) do
    fCommandArray[i].Free;

  CleanListMemory(chkFiles);

  inherited;
end;

procedure TfrmMain.btnFolderClick(Sender: TObject);
begin
  eGameFolder.Text := Trim(eGameFolder.Text);

  if (eGameFolder.Text <> '') then
    fDirectory.FileName := eGameFolder.Text;

  if (fDirectory.Execute()) then
  begin
    eGameFolder.Text := fDirectory.FileName;
    CalcGlobalSize();
  end;
end;


procedure TfrmMain.EncodeFinish(Sender: TObject; errors: TStrings);
begin
  fVEncode.Remove(sender);

  if (errors.Count > 0) then
  begin
    if (not Assigned(frmErrors)) then
       frmErrors := TfrmErrors.Create(nil);

    frmErrors.lstErrors.Items.AddStrings(errors);
  end;

  if (self.fVEncode.Count=0) then
  begin
    if Assigned(frmErrors) then
    begin
      frmErrors.ShowModal();
      frmErrors.Free();
      frmErrors := nil;
    end else
      ShowMessage('Done');

    mnuLoadFiles.Enabled := True;
    mnuSaveFiles.Enabled := True;
    btnRecode.Enabled := True;
    btnVideoSearch.Enabled := True;
    btnStopEncode.Visible := False;
    btnRecode.Visible := True;
    fVEncode.Clear();
  end;
end;

procedure TfrmMain.NextEncodeFile(Sender: TObject);
begin
  pgrBarVideo.Position := pgrBarVideo.Position + 1;
end;

procedure TfrmMain.btnRecodeClick(Sender: TObject);
var
  i:  integer;
  mx: integer;
  ve: TVideoEncode;
begin
  fErrors.Clear();

  mx := 0;

  for i := 0 to chkVideoFiles.Items.Count - 1 do
    if chkVideoFiles.Items[i].Checked then
      mx := mx + 1;

  // Set the commands to patterns
  if (cbVideoAction.ItemIndex=0) then
  begin
    for i := 0 to pnlConfig.ControlCount - 1 do
    begin
      // Yes, this is a bad trick
      if (pnlConfig.Controls[i] is TEdit) then
        if (TEdit(pnlConfig.Controls[i]).Visible) then
           PString(fVideoPaterns.Objects[TEdit(pnlConfig.Controls[i]).Tag])^.str := TEdit(pnlConfig.Controls[i]).Text;
    end;
  end else
    PString(fVideoPaterns.Objects[0])^.str := IncludeTrailingPathDelimiter(fConfig.binkpath) + VideoEncode.APP_BINKMIX;

  pgrBarVideo.Max := mx;
  pgrBarVideo.Position := 0;
  Count := 0;

  if (MessageDlg(fAskStr, mtWarning, [mbYes, mbNo], 0) = mrYes) then
  begin
    btnStopEncode.Width := btnRecode.Width;
    btnStopEncode.Height := btnRecode.Height;
    btnStopEncode.Left := btnRecode.Left;
    btnStopEncode.Top := btnRecode.Top;

    btnRecode.Enabled := False;
    btnRecode.Visible := False;
    btnStopEncode.Visible := True;
    btnVideoSearch.Enabled := False;
    mnuLoadFiles.Enabled := False;
    mnuSaveFiles.Enabled := False;

    // Create the threads
    for i := 1 to btnUD.Position do
    begin
      ve := TVideoEncode.Create(chkVideoFiles, fVideoPaterns);
      ve.setWantedTracks(eAudioTrack.Text);
      ve.setAudioNTracks(TVideoEncode.GetNAudioTracks(chkVideoFiles.Selected.SubItems[0], fConfig.ffmpegpath));

      if (cbVideoAction.ItemIndex=1) then
        ve.setWorkingMode(veMix)
      else
        ve.setWorkingMode(veEncode);

      ve.setMMPEGPath(fConfig.ffmpegpath);
      ve.OnNextFile := @NextEncodeFile;
      ve.OnFinish := @EncodeFinish;
      ve.Resume();
      fVEncode.Add(ve);

      // Wait 20 ms bettwen threads begining
      sleep(100);
    end;
  end;
end;

procedure TfrmMain.btnFileReplaceClick(Sender: TObject);
begin
  if (eReplaceFile.Visible) then
    openDlg2.FileName := eReplaceFile.Text
  else
    openDlg2.FileName := eCommand.Text;

  if (openDlg2.Execute) then
    if (eReplaceFile.Visible) then
      eReplaceFile.Text := openDlg2.FileName
    else
      eCommand.Text     := openDlg2.FileName;
end;

procedure TfrmMain.btnCfg2Click(Sender: TObject);
begin
  frmM2V := TfrmM2V.Create(nil);
  frmM2V.lblAssistant.Caption := fAssistant;
  frmM2V.lblEncoderPath.Caption := fENCPATH;

  if (frmM2V.ShowModal()=mrOk) then
    eM2V.Text := frmM2V.commandline;

  frmM2V.Free();
end;

procedure TfrmMain.btnCfg1Click(Sender: TObject);
begin
  frmBIK := TfrmBIK.Create(nil);
  if (fNEWSIZE<>'') then
     frmBik.lblNewSize.Caption := fNEWSIZE;

  if (frmBIK.ShowModal()=mrOk) then
  begin
    with fConfig do
    begin
      setEncodeCommands();
    end;
  end;
{
    TfrmBIK.getCommandLine(IncludeTrailingPathDelimiter(binkpath) + VideoEncode.APP_BINKMIX, 50);
    eBik.Text := frmBIK.commandline;
}

  frmBIK.Free();
end;

procedure TfrmMain.btnUDClick(Sender: TObject; Button: TUDBtnType);
begin
  eNProc.Text := Format ('%d', [btnUd.Position]);
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
begin
  LoadFilePaterns();

  if (not CheckPatterns(fPaterns)) then
    Exit;

  Count := 0;

  btnShrink.Enabled := False;

  if (eGameFolder.Text = '') then
  begin
    MessageDlg('First, select a folder', mtError, [mbOK], 0);
    Exit;
  end;

  CleanListMemory(chkFiles);
  chkFiles.Column[1].Width := chkFiles.Width - 2*chkFiles.Column[0].Width - chkFiles.Column[2].Width;

  fFilesSize := WalkTree(eGameFolder.Text, chkFiles, fPaterns);

  btnShrink.Enabled := True;

  if chkFiles.Items.Count > 0 then
    chkFiles.Items[0].Selected := True;

  ShowInfoBar();
  lblFound.Caption := Format(fFoundStr, [chkFiles.Items.Count]);
end;

procedure TfrmMain.btnShrinkClick(Sender: TObject);
var
  i:  integer;
  mx: integer;
begin
  fErrors.Clear();

  // Check commands
  if (cbAction.ItemIndex = integer(alExecute)) then
  begin
    eCommand.Text := Trim(eCommand.Text);

    if (eCommand.Text = '') then
    begin
      MessageDlg(fNoCmdStr, mtWarning, [mbOK], 0);
      Exit;
    end;

    TFCExecute(fCommandArray[alExecute]).setCmd(eCommand.Text);
  end;

  if (cbAction.ItemIndex = integer(alReplace)) then
  begin
    eReplaceFile.Text := Trim(eReplaceFile.Text);

    if (eReplaceFile.Text = '') then
    begin
      MessageDlg(fNoReplaceStr, mtWarning, [mbOK], 0);
      Exit;
    end;

    if (not FileExists(eReplaceFile.Text)) then
    begin
      MessageDlg(Format(fFileNotExists, [eReplaceFile.Text]),
        mtWarning, [mbOK], 0);
      Exit;
    end;

    TFCReplace(fCommandArray[alReplace]).setSrc(eReplaceFile.Text);
  end;

  mx := 0;

  for i := 0 to chkFiles.Items.Count - 1 do
    if chkFiles.Items[i].Checked then
      mx := mx + 1;

  pgrBar.Max := mx;
  pgrBar.Position := 0;
  Count := 0;

  btnShrink.Enabled := False;

  if (MessageDlg(fAskStr, mtWarning, [mbYes, mbNo], 0) = mrYes) then
  begin
    for i := 0 to chkFiles.Items.Count - 1 do
    begin
      if (chkFiles.Items[i].Checked) then
        ProcessFile(PSearchRec(chkFiles.Items[i].SubItems.Objects[0])^.Name);
    end;
  end;

  btnShrink.Enabled := True;

  if (fErrors.Count > 0) then
  begin
    frmErrors := TfrmErrors.Create(nil);
    frmErrors.lstErrors.Items.AddStrings(fErrors);
    frmErrors.ShowModal();
    frmErrors.Free();
  end
  else
    ShowMessage('Done');
end;

procedure TfrmMain.btnStopEncodeClick(Sender: TObject);
var
  i: Integer;
begin
  if (Assigned(fVEncode)) then
    for i := 0 to fVEncode.Count-1 do
      TThread(fVEncode.Items[i]).Terminate;

  MessageDlg(fCancelMsg, mtInformation, [mbOk], 0);
end;

procedure TfrmMain.btnVideoSearchClick(Sender: TObject);
var
  i, aux: Integer;
begin
  // Regular video extensions
  pgrBarVideo.Position := 0;
  Count := 0;
  btnRecode.Enabled := False;

  if (eGameFolder.Text = '') then
  begin
    MessageDlg('First, select a folder', mtError, [mbOK], 0);
    Exit;
  end;

  CleanListMemory(chkVideoFiles);

  aux := chkVideoFiles.Width;
  for i := 0 to chkVideoFiles.Columns.Count-1 do
    if (i<>1) then
       aux := aux - chkVideoFiles.Column[i].Width;

  chkVideoFiles.Column[1].Width := aux - chkVideoFiles.Column[0].Width;

  fVideosSize := WalkTree(eGameFolder.Text, chkVideoFiles, fVideoPaterns);

  btnRecode.Enabled := True;

  if chkVideoFiles.Items.Count > 0 then
    chkVideoFiles.Items[0].Selected := True;

  ShowInfoBar();
  lblFound1.Caption := Format(fFoundStr, [chkVideoFiles.Items.Count]);
end;

procedure TfrmMain.cbActionChange(Sender: TObject);
begin
  eCommand.Visible     := TActionList(cbAction.ItemIndex) = alExecute;
  eReplaceFile.Visible := TActionList(cbAction.ItemIndex) = alReplace;
  btnFileReplace.Visible := eReplaceFile.Visible or eCommand.Visible;

  if (eCommand.Visible) then
    eCommand.SetFocus()
  else
  if (eReplaceFile.Visible) then
    eReplaceFile.SetFocus();
end;

procedure TfrmMain.cbLanguageChange(Sender: TObject);
begin
  LoadLanguage();
end;

procedure TfrmMain.cbVideoActionChange(Sender: TObject);
begin
  if (TVideoEncodeWMode(cbVideoAction.ItemIndex) = veEncode) then
    eBik.Text := TfrmBIK.getCommandLine(IncludeTrailingPathDelimiter(fConfig.binkpath) + VideoEncode.APP_BINK, 50)
  else
    eBik.Text := IncludeTrailingPathDelimiter(fConfig.binkpath) + VideoEncode.APP_BINKMIX;
end;

procedure TfrmMain.chkFilesClick(Sender: TObject);
begin
end;


procedure TfrmMain.chkFilesClickCheck(Sender: TObject);
var
  i: Integer;
begin
  fFilesSize := 0;

  for i := 0 to chkFiles.Items.Count-1 do
    if (chkFiles.Items[i].Checked) then
       fFilesSize := fFilesSize + PSearchRec(chkFiles.Items[i].SubItems.Objects[0])^.Size;

{
  if (chkFiles.ItemIndex < 0) then
    Exit;

  if (not chkFiles.Checked[chkFiles.ItemIndex]) then
    fFilesSize := fFilesSize -
      PSearchRec(chkFiles.Items.Objects[chkFiles.ItemIndex])^.Size
  else
    fFilesSize := fFilesSize +
      PSearchRec(chkFiles.Items.Objects[chkFiles.ItemIndex])^.Size;
}
  ShowInfoBar();
end;

procedure TfrmMain.chkFilesMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
{
  if (X<TListView(Sender).Column[0].Width) then
    TListView(Sender).Selected.Checked := not TListView(Sender).Selected.Checked;
}
  chkFilesClickCheck(Sender);
end;

procedure TfrmMain.chkUpdateFilesChange(Sender: TObject);
begin
  if (chkUpdateFiles.Checked) then
    ePatternPUB.Text := PTRN_PS3UPDATE
  else
    ePatternPUB.Text := '';
end;

procedure TfrmMain.chkVideoFilesMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  fVideosSize := 0;

  for i := 0 to chkVideoFiles.Items.Count-1 do
    if (chkVideoFiles.Items[i].Checked) then
       fVideosSize := fVideosSize + PSearchRec(chkVideoFiles.Items[i].SubItems.Objects[0])^.Size;

  ShowInfoBar();
end;

procedure TfrmMain.eBikEnter(Sender: TObject);
begin
  TEdit(Sender).SelStart:=0;
  TEdit(Sender).SelLength:=Length(TEdit(Sender).Text)
end;

procedure TfrmMain.eGameFolderClick(Sender: TObject);
begin
  eGameFolder.SelectAll;
end;

procedure TfrmMain.eGameFolderExit(Sender: TObject);
begin
  if (Trim(eGameFolder.Text) <> '') and (fFolderSize = 0) then
    CalcGlobalSize();
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ShowMessage(fGoodBye);
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  ResizeLangPanel();
  ResizeVideoPanel();
end;

procedure TfrmMain.Label1Click(Sender: TObject);
begin
  launchURL('http://www.clandragonrojo.es');
end;

procedure TfrmMain.chkFilesColumnClick(Sender: TObject; Column: TListColumn);
begin
  TListView(Sender).SortType := stNone;
  if Column.Index<>fSortedColumn then
  begin
    fSortedColumn := Column.Index;
    fSortDescending := False;
  end else
    fSortDescending := not fSortDescending;

  TListView(Sender).SortType := stText;
end;

procedure TfrmMain.chkFilesCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
begin
  case fSortedColumn of
    2:
      if (Item1.SubItems.Objects[0]<>NIL) and (Item2.SubItems.Objects[0]<>nil) then
        if (PSearchRec(Item1.SubItems.Objects[0])^.Size<PSearchRec(Item2.SubItems.Objects[0])^.Size) then
           Compare := -1
        else
          if (PSearchRec(Item1.SubItems.Objects[0])^.Size>PSearchRec(Item2.SubItems.Objects[0])^.Size) then
            Compare := 1
          else
            Compare := 0;
    3:
      if (Item1.SubItems.Objects[0]<>NIL) and (Item2.SubItems.Objects[0]<>nil) then
        if (PSearchRec(Item1.SubItems.Objects[0])^.Time<PSearchRec(Item2.SubItems.Objects[0])^.Time) then
           Compare := -1
        else
          if (PSearchRec(Item1.SubItems.Objects[0])^.Time>PSearchRec(Item2.SubItems.Objects[0])^.Time) then
            Compare := 1
          else
            Compare := 0;
    else
      if fSortedColumn = 0 then
        Compare := CompareText(Item1.Caption, Item2.Caption)
      else
        Compare := CompareText(Item1.SubItems[fSortedColumn-1], Item2.SubItems[fSortedColumn-1]);
  end;

  if fSortDescending then Compare := -Compare;
end;

procedure TfrmMain.mnuAll1Click(Sender: TObject);
begin
  CheckAll(chkFiles);
end;

procedure TfrmMain.mnuNothing1Click(Sender: TObject);
begin
  CheckNone(chkFiles);
end;

procedure TfrmMain.mnuInvert1Click(Sender: TObject);
begin
  CheckInverse(chkFiles);
end;

procedure TfrmMain.mnuAudioTracksClick(Sender: TObject);
begin
  if (chkVideoFiles.Selected<>nil) then
    ShowMessage(Format ('%d', [TVideoEncode.GetNAudioTracks(chkVideoFiles.Selected.SubItems[0], fConfig.ffmpegpath)]));
end;

procedure TfrmMain.mnuFPathClick(Sender: TObject);
begin
  if (chkVideoFiles.Selected<>nil) then
    Clipboard.SetTextBuf(PChar(PSearchRec(chkVideoFiles.Selected.SubItems.Objects[0])^.Name));
end;

procedure TfrmMain.mnuAboutClick(Sender: TObject);
begin
  frmAbout := TfrmAbout.Create(nil);
  frmAbout.Caption := mnuAbout.Caption;
  frmAbout.ShowModal();
  frmAbout.Free();
end;

procedure TfrmMain.mnuInvert2Click(Sender: TObject);
begin
  CheckInverse(chkVideoFiles);
end;

procedure TfrmMain.mnuLoadFilesClick(Sender: TObject);
var
  f: TextFile;
  s: String;
  p: PSearchRec;
  sz: Int64;
  itm: TListItem;
begin
  if (not openDlg1.Execute) then
    Exit;

  try
    CleanListMemory(chkVideoFiles);

    AssignFile(f, openDlg1.FileName);
    Reset(f);
    fVideosSize := 0;
    pgrBarVideo.Position := 0;

    while not (EOF(f)) do
    begin
      ReadLn(f, s);

      sz := FileSize(s);

      if (sz>0) then
      begin
        New(p);
        p^.Name := s;
        p^.Size := sz;
        p^.Time := FileAge(s);
        fVideosSize := fVideosSize + sz;

        itm := chkVideoFiles.Items.Add();
        itm.Caption := '';
        itm.SubItems.AddObject(s, TObject(p));
        itm.SubItems.Add(getBestSizeUnit(p^.Size));
        itm.SubItems.Add(FormatDateTime(ShortDateFormat, FiledateToDateTime(p^.Time)));
        itm.Checked := True;
      end;
    end;

  finally
    ShowInfoBar();
    CloseFile(f);
    btnRecode.Enabled := chkVideoFiles.Items.Count>0;
  end;
end;

procedure TfrmMain.mnuOpenClick(Sender: TObject);
begin
  if (openDlg.Execute) then
    LoadPatterns();
end;

procedure TfrmMain.mnuOptionsClick(Sender: TObject);
begin
  frmConfig := TfrmConfig.Create(nil);

  // Set config
  frmConfig.eBink.Text := fConfig.binkpath;
  frmConfig.eFFmpeg.Text := fConfig.ffmpegpath;
  frmConfig.eFFPlay.Text := fConfig.ffplaypath;
  frmConfig.eRejig.Text := fConfig.rejigpath;

  if (frmConfig.ShowModal()=mrOk) then
  begin
    // Set new config
    fConfig.binkpath := frmConfig.eBink.Text;
    fConfig.ffmpegpath := frmConfig.eFFmpeg.Text;
    fConfig.ffplaypath := frmConfig.eFFPlay.Text;
    fConfig.rejigpath := frmConfig.eRejig.Text;
  end;

  setEncodeCommands();

  frmConfig.Free();
end;

procedure TfrmMain.mnuPlayClick(Sender: TObject);
var
  prc: TProcess;
  f, cmd: String;
  rg: TRegExpr;
begin
  prc := TProcess.Create(nil);
  f := chkVideoFiles.Selected.SubItems[0];
  rg := TRegExpr.Create;
  rg.Expression := '[.][bB][iI][kK]$';
  cmd := IncludeTrailingPathDelimiter(fConfig.binkpath) + VideoEncode.APP_BINKPLAY;

  if (rg.Exec(f) and FileExists(cmd)) then
  begin
    if (eAudioTrack.Text<>'') then
       cmd := cmd + ' /T' + eAudioTrack.Text;
  end else
  begin
    cmd := fConfig.ffplaypath;
    if (eAudioTrack.Text<>'') then
      cmd := cmd + ' -ast ' + eAudioTrack.Text;
  end;

  cmd := Format ('%s "%s"', [cmd, f]);

  prc.CommandLine := cmd;

  prc.Options := prc.Options + [poNoConsole];
  prc.Execute;

  prc.Free;
  rg.Free;
end;

procedure TfrmMain.mnuSaveClick(Sender: TObject);
begin
  saveDlg.FileName := openDlg.FileName;

  if (saveDlg.Execute) then
    SavePatterns();
end;

procedure TfrmMain.mnuSaveFilesClick(Sender: TObject);
var
  i: Integer;
  f: TextFile;
begin
  if (not saveDlg1.Execute) then
    Exit;

  try
    AssignFile(f, saveDlg1.FileName);
    Rewrite(f);

    for i := 0 to chkVideoFiles.Items.Count-1 do
      if (chkVideoFiles.Items[i].Checked) then
        WriteLn(f, PSearchRec(chkVideoFiles.Items[i].SubItems.Objects[0])^.Name);

  finally
    CloseFile(f);
  end;
end;

procedure TfrmMain.mnuAll2Click(Sender: TObject);
begin
  CheckAll(chkVideoFiles);
end;

procedure TfrmMain.mnuNothing2Click(Sender: TObject);
begin
    CheckNone(chkVideoFiles);
end;

procedure TfrmMain.GetVideoInfo(f: String; info: TStringList);
var
  fc: TFCExecute;
  n, BytesRead: LongInt;
  M: TMemoryStream;
begin
  if (f='') then
    Exit;

  try
    fc := TFCExecute.Create();
    fc.setCmd(Format ('%s -i <file>', [fConfig.ffmpegpath]));
    fc.Process.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
    fc.execute(f);

    frmFileInfo := TfrmFileInfo.Create(nil);

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

function TfrmMain.GetNAudioTracks(f: String): Integer;
var
  info: TStringList;
  i: Integer;
begin
  result := 0;

  try
    info := TStringList.Create();
    TVideoEncode.GetVideoInfo(chkVideoFiles.Selected.SubItems[0], fConfig.ffmpegpath, info);

    for i := 0 to info.Count-1 do
      if ((Pos('Stream', info[i])>0) AND (Pos('Audio:', info[i])>0)) then
        Inc(result);
  finally
    info.Free();
  end;
end;

procedure TfrmMain.mnuVideoInfoClick(Sender: TObject);
var
  info: TStringList;
  rg: TRegExpr;
  f, cmd: String;
  prc: TProcess;
begin
  if (chkVideoFiles.Selected=nil) then
    Exit;

  f := chkVideoFiles.Selected.SubItems[0];

  try
    rg := TRegExpr.Create;
    prc := TProcess.Create(nil);

    rg.Expression := '[.][bB][iI][kK]$';
    cmd := IncludeTrailingPathDelimiter(fConfig.binkpath) + VideoEncode.APP_BINKRADINFO;

    if (rg.Exec(f) and FileExists(cmd)) then
    begin
      prc.CommandLine := Format ('%s "%s"', [cmd, f]);
      prc.Execute();
    end else
    begin
      frmFileInfo := TfrmFileInfo.Create(nil);
      info := TStringList.Create();

      TVideoEncode.GetVideoInfo(f, fConfig.ffmpegpath, info);
      frmFileInfo.Memo1.Lines.Assign(info);
      frmFileInfo.ShowModal();
    end;
  finally
    if Assigned(prc) then
      prc.Free()
    else begin
      frmFileInfo.Free();
      info.Free();
    end;
    frmFileInfo := NIL;
    rg.Free();
  end;
end;

procedure TfrmMain.sbInfoDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  case Panel.Index of
  0: Statusbar.Canvas.Font.Color := clRed;
  1: Statusbar.Canvas.Font.Color := clGreen;
  2: Statusbar.Canvas.Font.Color := clNavy;
  end;

  Statusbar.Canvas.TextRect(Rect, Rect.Left, Rect.Top, Panel.Text);
end;

function TfrmMain.MatchPatterns(fname: string; ptr: TStrings): boolean;
var
  i: integer;
  txtCtrl: TEdit;
begin
  if (chkCharCase.Checked) then
    fname := LowerCase(fname);

  for i := 0 to ptr.Count - 1 do
  begin
    if (Length(ptr.Strings[i]) = 0) then
      continue;

    if (chkCharCase.Checked) then
      fRegExp.Expression := LowerCase(ptr.Strings[i])
    else
      fRegExp.Expression := ptr.Strings[i];

    if (fRegExp.Exec(fname)) then
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

procedure TfrmMain.ProcessFile(f: string);
begin
  try
    Inc(Count);
    pgrBar.Position := pgrBar.Position + 1;

    if (Count = 100) then
    begin
      Count := 0;
      Application.ProcessMessages();
    end;

    // Execute Action
    fCommandArray[TActionList(cbAction.ItemIndex)].Execute(f);
  except
    On e: Exception do
      fErrors.Add(f + ' - ' + e.Message);
  end;
end;

procedure TfrmMain.CleanListMemory(fl: TListView);
var
  i: integer;
begin
  // First clean memory
  for i := 0 to fl.Items.Count - 1 do
  begin
    Dispose(PSearchRec(fl.Items[i].SubItems.Objects[0]));
    fl.Items[i].SubItems.Objects[0] := nil;
  end;

  // Clear items
  fl.Items.Clear();
end;

procedure TfrmMain.CalcGlobalSize();
begin
  // Yes, I think like you that this could be done better, but I have no much time. ;)
  fFolderSize := 0;
  fFilesSize  := 0;
  fVideosSize := 0;
  fCalcSizes  := True;

  ShowInfoBar(True);

  btnSearch.Enabled := False;
  fPaterns.Clear();
  fFolderSize := WalkTree(eGameFolder.Text, chkFiles, fPaterns);
  btnSearch.Enabled := True;

  fCalcSizes := False;

  ShowInfoBar();
end;

procedure TfrmMain.ShowInfoBar(wait: boolean);
begin
  if (wait) then
  begin
    sbInfo.Panels[0].Text := fSWait;
    sbInfo.Panels[1].Text := fSWait;
    sbInfo.Panels[2].Text := fSWait;
  end
  else
  begin
    sbInfo.Panels[0].Text := Format(fSBefore, [getBestSizeUnit(fFolderSize)]);
    //ShowMessage(Format ('%d %d', [fFolderSize, fFilesSize]));
    sbInfo.Panels[1].Text := Format(fSAfter,
      [getBestSizeUnit(fFolderSize - fFilesSize)]);
    sbInfo.Panels[2].Text := Format('Videos: %s',
      [getBestSizeUnit(fVideosSize)]);
  end;
end;

function TfrmMain.WalkTree(path: string; lv: TListView; ptr: TStrings): Int64;
var
  info:  TSearchRec;
  pinfo: PSearchRec;
  fname: string;
  itm: TListItem;
begin
  try
    result := 0;

    // Walk through the folders al files
    // 1.- Get Files and Dirs
    path := IncludeTrailingPathDelimiter(path);

    if FindFirst(path + '*', faAnyFile and faDirectory, info) = 0 then
    begin
      repeat
        if (Count = 100) then
        begin
          Count := 0;
          Application.ProcessMessages();
        end;

        Inc(Count);
        // 2.- Is folder ?
        // 2.1. Yes - Walk Inside
        if ((Info.Name = '.') or (Info.Name = '..')) then
          Continue;

        if (Info.Attr and faDirectory) = faDirectory then
          result := result + WalkTree(path + Info.Name, lv, ptr)
        else
        begin
          // 2.2 Are we computing size ?
          if (fCalcSizes) then
          begin
            // 2.2.1 Yes .-
            result := result + info.Size;
            //fFolderSize := fFolderSize + info.Size;
            Continue;
          end;

          // 2.2.2 No. Check patterns ?
          // 2.2.2.1. Yes - Add to list
          if (chkIncludePath.Checked) then
            fname := path + Info.Name
          else
            fname := Info.Name;

          if (MatchPatterns(fname, ptr)) then
          begin
            New(pinfo);
            pinfo^ := info;
            pinfo^.Name := path + Info.Name;
            //fFilesSize := fFilesSize + info.Size;
            result := result + info.Size;
            itm := lv.Items.Add();
            itm.Caption := '';
            itm.SubItems.AddObject(path + Info.Name, TObject(pinfo));
            //itm.SubItems.Add();
            itm.SubItems.Add(getBestSizeUnit(info.Size));
            if (lv.Columns.Count=4) then
               itm.SubItems.Add(FormatDateTime(ShortDateFormat, FiledateToDateTime(info.Time)));

            itm.Checked := True;
            //chkFiles.Checked[chkFiles.Items.AddObject('(' + getBestSizeUnit(info.Size) + ') ' + path + Info.Name, TObject(pinfo))] := True;
          end;
        end;
      until FindNext(info) <> 0;
    end;

    FindClose(info);
  except
    On E: Exception do
    begin
      MessageDlg('Ops ... something goes wrong. This is the error ' + #13 + E.Message,
        mtError, [mbOK], 0);
      Exit;
    end;
  end;
end;

procedure TfrmMain.ResizeLangPanel;
var
  i: integer;
begin
  for i := 0 to sbInfo.Panels.Count-1 do
    sbInfo.Panels[i].Width := sbInfo.Width div sbInfo.Panels.Count;

  pcMain.Height := Height - eGameFolder.Top - eGameFolder.Height -
                   sbInfo.Height;
  chkFiles.Width    := pcMain.ActivePage.Width - 2 * chkFiles.Left;
  cbLanguage.Left   := pcMain.ActivePage.Width - chkFiles.Left - cbLanguage.Width;
  btnFolder.Left    := cbLanguage.Left - btnFolder.Width - 10;
  btnSearch.Left    := pcMain.ActivePage.Width - btnFolder.Width - chkFiles.Left;
  btnShrink.Left    := btnSearch.Left;
  btnFolder.Height  := eGameFolder.Height;
  btnShrink.Height  := btnFolder.Height;
  btnSearch.Height  := btnFolder.Height;
  btnFileReplace.Height := btnFolder.Height;

  pgrBar.Width      := chkFiles.Width;
  pgrBar.Left       := chkFiles.Left;
  eGameFolder.Width := btnFolder.Left - eGameFolder.Left - 10;
  lblFound.Left     := pcMain.ActivePage.Width - chkFiles.Left - lblFound.Width;
  pnlPattern.Width  := chkFiles.Width;
  chkFiles.Height   := pcMain.ActivePage.Height - pnlBottom.Height - chkFiles.Top{ - chkIncludePath.Height};
  chkIncludePath.Top := chkFiles.Top + chkFiles.Height;
  chkUpdateFiles.Top := chkIncludePath.Top;
  chkUpdateFiles.Left := chkFiles.Left + chkFiles.Width - chkUpdateFiles.Width;
  btnFileReplace.Left := chkFiles.Left + chkFiles.Width - btnFileReplace.Width;
  eReplaceFile.Width := btnFileReplace.Left - chkFiles.Left - 10;
  eCommand.Width  := eReplaceFile.Width;
  chkFiles.Column[1].Width := chkFiles.Width - 2*chkFiles.Column[0].Width -
    chkFiles.Column[2].Width;
  cbAction.Left := chkFiles.Left + chkFiles.Width - cbAction.Width;

  for i := 0 to pnlPattern.ControlCount - 1 do
    TControl(pnlPattern.Controls[i]).Width := chkFiles.Width;
end;

procedure TfrmMain.ResizeVideoPanel;
var
  i: Integer;
begin
  //
  chkVideoFiles.Width := pcMain.ActivePage.Width - 2 * chkVideoFiles.Left;
  btnVideoSearch.Left := chkVideoFiles.Left;
  btnRecode.Left := chkVideoFiles.Left + chkVideoFiles.Width - btnRecode.Width;
  pgrBarVideo.Width := chkVideoFiles.Width;
  pgrBarVideo.Top := pcMain.ActivePage.Height - pnlConfig.Height - pgrBarVideo.Height - 10;

  lblVideoAction.Top := pgrBarVideo.Top - chkVideoFiles.Top + 10;
  lblAudioTrack.Top := lblVideoAction.Top;
//  lblAudioTrack.Left := cbVideoAction.Left + cbVideoAction.Width + 10;
  cbVideoAction.Top := lblAudioTrack.Top-5;
  eAudioTrack.Width := chkVideoFiles.Left + chkVideoFiles.Width - eAudioTrack.Left;
  eAudioTrack.Top := cbVideoAction.Top;

  chkVideoFiles.Height := eAudioTrack.Top - eAudioTrack.Height - 15;
  btnStopEncode.Left := btnRecode.Left;
  btnStopEncode.Top := btnRecode.Top;
  btnStopEncode.Width := btnRecode.Width;
  btnStopEncode.Height := btnRecode.Height;
  btnUD.Left := btnRecode.Left - btnUD.Width - 10;
  eNProc.Left := btnUD.Left - eNProc.Width;
  lblNProc.Left := eNProc.Left - lblNProc.Width;

  chkVideoFiles.Column[1].Width := chkVideoFiles.Width - 2*chkVideoFiles.Column[0].Width -
    chkVideoFiles.Column[2].Width - chkVideoFiles.Column[3].Width;

  for i := 0 to pnlConfig.ControlCount-1 do
  begin
    if (pnlConfig.Controls[i] is TBitBtn) then
      pnlConfig.Controls[i].Left := pcMain.ActivePage.ClientWidth - chkVideoFiles.Left - pnlConfig.Controls[i].Width
    else
      if (pnlConfig.Controls[i] is TEdit) then
        pnlConfig.Controls[i].Width := pcMain.ActivePage.ClientWidth - 2 * pnlConfig.Controls[i].Left - 50;
  end;
end;

procedure TfrmMain.LoadLanguage();
var
  flng: TIniFile;
  sect: string;
  i, k: integer;
begin
  // 1.- We try to load the language file translations
  try
    sect := cbLanguage.Items[cbLanguage.ItemIndex];
    flng := TIniFile.Create(LANGUAGE_FILE);
    lblSect1.Caption := SysToUTF8(flng.ReadString(sect, KWD_SELECT_GAME_FOLDER,
      lblSect1.Caption));
    lblGameFolder.Caption := SysToUTF8(flng.ReadString(sect, KWD_GAME_FOLDER,
      lblGameFolder.Caption));
    btnFolder.Caption := SysToUTF8(flng.ReadString(sect, KWD_EXPLORE_BTN,
      btnFolder.Caption));
    lblSect2.Caption := SysToUTF8(flng.ReadString(sect, KWD_PATTERNS, lblSect2.Caption));
    lblSect3.Caption := SysToUTF8(flng.ReadString(sect, KWD_SEARCH, lblSect3.Caption));
    btnSearch.Caption := SysToUTF8(flng.ReadString(sect, KWD_SEARCH_BTN,
      btnSearch.Caption));
    chkCharCase.Caption := SysToUTF8(flng.ReadString(sect, KWD_CHARCASE,
      chkCharCase.Caption));
    chkIncludePath.Caption :=
      SysToUTF8(flng.ReadString(sect, KWD_INCLUDEPATH, chkIncludePath.Caption));
    lblFound.Caption := SysToUTF8(
      Format(flng.ReadString(sect, KWD_FOUND, fFoundStr), [0]));
    lblFound1.Caption := lblFound.Caption;
    lblSect4.Caption := SysToUTF8(flng.ReadString(sect, KWD_SELECTACTION,
      lblSect4.Caption));
    lblSect5.Caption := SysToUTF8(flng.ReadString(sect, KWD_SHRINK, lblSect5.Caption));
    btnShrink.Caption := SysToUTF8(flng.ReadString(sect, KWD_SHRINK_BTN,
      btnShrink.Caption));
    fGoodBye  := SysToUTF8(flng.ReadString(sect, KWD_BYE, fGoodBye));
    fFoundStr := SysToUTF8(flng.ReadString(sect, KWD_FOUND, fFoundStr));
    mnuFile.Caption := SysToUTF8(flng.ReadString(sect, KWD_FILE, mnuFile.Caption));
    mnuOptions.Caption := SysToUTF8(flng.ReadString(sect, KWD_OPTIONS, mnuOptions.Caption));
    mnuSelect1.Caption := SysToUTF8(flng.ReadString(sect, KWD_SELECT, mnuSelect1.Caption));
    mnuSelect2.Caption := mnuSelect1.Caption;
    mnuAll1.Caption := SysToUTF8(flng.ReadString(sect, KWD_SELECTALL, mnuAll1.Caption));
    mnuAll2.Caption := mnuAll1.Caption;
    mnuNothing1.Caption := SysToUTF8(flng.ReadString(sect, KWD_SELECTNOTHING, mnuNothing1.Caption));
    mnuNothing2.Caption := mnuNothing1.Caption;
    mnuInvert1.Caption := SysToUTF8(flng.ReadString(sect, KWD_SELECTINV, mnuInvert1.Caption));
    mnuInvert2.Caption := mnuInvert1.Caption;
    mnuVideoInfo.Caption := SysToUTF8(flng.ReadString(sect, KWD_VIDEOINFO, mnuVideoInfo.Caption));
    mnuPlay.Caption := SysToUTF8(flng.ReadString(sect, KWD_PLAY, mnuPlay.Caption));
    mnuLoadFiles.Caption := SysToUTF8(flng.ReadString(sect, KWD_LOADQUEUE, mnuLoadFiles.Caption));
    mnuSaveFiles.Caption := SysToUTF8(flng.ReadString(sect, KWD_SAVEQUEUE, mnuSaveFiles.Caption));
    mnuAudioTracks.Caption := SysToUTF8(flng.ReadString(sect, KWD_AUDIOTRACKS, mnuAudioTracks.Caption));
    mnuFPath.Caption := SysToUTF8(flng.ReadString(sect, KWD_COPYPATH, mnuFPath.Caption));
    lblVideoAction.Caption := SysToUTF8(flng.ReadString(sect, KWD_VIDEOACTION, lblVideoAction.Caption));
    cbVideoAction.Items[0] := SysToUTF8(flng.ReadString(sect, KWD_RECODEVIDEO, cbVideoAction.Items[0]));
    cbVideoAction.Items[1] := SysToUTF8(flng.ReadString(sect, KWD_MIXADIO, cbVideoAction.Items[1]));
    lblAudioTrack.Caption := SysToUTF8(flng.ReadString(sect, KWD_AUDIOTRACKS, lblAudioTrack.Caption));
    eAudioTrack.Hint := SysToUTF8(flng.ReadString(sect, KWD_SELTRACK, eAudioTrack.Hint));
    fCancelMsg := SysToUTF8(flng.ReadString(sect, KWD_CANCELMSG, 'Cola de cancelada. El sistema se parará cuando terminen las codificaciones en curso.'));

    mnuOpen.Caption := SysToUTF8(flng.ReadString(sect, KWD_FILE_OPEN, mnuOpen.Caption));
    mnuSave.Caption := SysToUTF8(flng.ReadString(sect, KWD_FILE_SAVE, mnuSave.Caption));
    fAskStr   := SysToUTF8(flng.ReadString(sect, KWD_ASK,
      'Do you really want to shrink these files ?. Do it at your own risk ;)'));
    fNoCmdStr := SysToUTF8(flng.ReadString(sect, KWD_NOCOMMAND,
      'You must write the shell command to perform with files !'));
    fNoReplaceStr := SysToUTF8(flng.ReadString(sect, KWD_NOREPLACE,
      'You must select a file to replace for !'));
    fFileNotExists := SysToUTF8(flng.ReadString(sect, KWD_FILENOTEXISTS,
      'The file %s does not exists'));
    mnuAbout.Caption := SysToUTF8(flng.ReadString(sect, KWD_ABOUT, mnuAbout.Caption));

    fSBefore := SysToUTF8(flng.ReadString(sect, KWD_SIZEBEFORE, fSBefore));
    fSAfter  := SysToUTF8(flng.ReadString(sect, KWD_SIZEAFTER, fSAfter));
    fSWait := SysToUTF8(flng.ReadString(sect, KWD_WAIT, fSWait));
    chkUpdateFiles.Caption := SysToUTF8(flng.ReadString(sect, KWD_PUPFILES, chkUpdateFiles.Caption));
    chkFiles.Column[1].Caption := SysToUTF8(flng.ReadString(sect, KWD_COLFILE, chkFiles.Column[1].Caption));
    chkFiles.Column[2].Caption := SysToUTF8(flng.ReadString(sect, KWD_COLSIZE, chkFiles.Column[2].Caption));

    chkVideoFiles.Column[1].Caption := chkFiles.Column[1].Caption;
    chkVideoFiles.Column[2].Caption := chkFiles.Column[2].Caption;
    chkVideoFiles.Column[3].Caption := SysToUTF8(flng.ReadString(sect, KWD_FILEDATE, chkVideoFiles.Column[3].Caption));

    pcMain.Pages[0].Caption := SysToUTF8(flng.ReadString(sect, KWD_TABLANG, pcMain.Pages[0].Caption));
    pcMain.Pages[1].Caption := SysToUTF8(flng.ReadString(sect, KWD_TABVIDEO, pcMain.Pages[1].Caption));
    btnVideoSearch.Caption := btnSearch.Caption;
    btnRecode.Caption := btnShrink.Caption;

    fNEWSIZE := SysToUTF8(flng.ReadString(sect, KWD_NEWSIZE, ''));
    fENCPATH := SysToUTF8(flng.ReadString(sect, KWD_ENCODERPATH, ''));
    fAssistant := SysToUTF8(flng.ReadString(sect, KWD_ASSISTANT, ''));

    eReplaceFile.Hint := fNoReplaceStr;

    // Load action Translations
    k := cbAction.ItemIndex;

    if (k < 0) then
      k := 0;

    cbAction.Items.Clear();
    for i := integer(Low(ACTION_OPTIONS)) to integer(High(ACTION_OPTIONS)) do
      cbAction.Items.Add(SysToUTF8(flng.ReadString(sect, KWD_ACTION +
        '_' + ACTION_OPTIONS[TActionList(i)], ACTION_OPTIONS[TActionList(i)])));

    cbAction.ItemIndex := k;
  finally
    flng.Free();
  end;
end;

procedure TfrmMain.LoadLanguages();
var
  flng:     TIniFile;
  sections: TStringList;
begin
  // 1.- We try to load the language file translations
  try
    sections := TStringList.Create();
    flng     := TIniFile.Create(LANGUAGE_FILE);
    flng.ReadSections(sections);
    if (sections.Count > 0) then
    begin
      cbLanguage.Items.Clear();
      cbLanguage.Items.AddStrings(sections);
    end;
    sections.Free();
    cbLanguage.ItemIndex := 0;
  finally
    flng.Free();
  end;
end;

procedure TfrmMain.LoadPatterns();
var
  flng: TIniFile;
  patterns: TStringList;
  i: integer;
begin
  try
    flng     := TIniFile.Create(openDlg.FileName);
    patterns := TStringList.Create();
    flng.ReadSection(PTRN_SECTION, patterns);

    // Load Global Options
    cbAction.ItemIndex := flng.ReadInteger(GLOBAL_SECTION, KWD_ACTION, cbAction.ItemIndex);
    eCommand.Text := flng.ReadString(GLOBAL_SECTION, CFG_COMMAND, eCommand.Text);
    eReplaceFile.Text  := flng.ReadString(GLOBAL_SECTION, CFG_REPLACE, eReplaceFile.Text);
    chkCharCase.Checked := flng.ReadBool(GLOBAL_SECTION, CFG_CHARCASE, True);
    chkIncludePath.Checked := flng.ReadBool(GLOBAL_SECTION, CFG_INCLUDEPATH, False);
    chkUpdateFiles.Checked := flng.ReadBool(GLOBAL_SECTION, CFG_UPDATEPUP, True);

    for i := 0 to pnlPattern.ControlCount - 1 do
      if (patterns.Count > i) then
        TEdit(pnlPattern.Controls[i]).Text := flng.ReadString(PTRN_SECTION, patterns.Strings[i], '');

    if (cbAction.ItemIndex <> integer(alExecute)) then
      eCommand.Text := '';

    if (cbAction.ItemIndex <> integer(alReplace)) then
      eReplaceFile.Text := '';

    cbAction.OnChange(cbAction);
  finally
    patterns.Free();
    flng.Free();
  end;
end;

function TfrmMain.CheckPatterns(lst: TStrings): boolean;
var
  i:  integer;
begin
  Result := False;

  for i := 0 to lst.Count - 1 do
  begin
    try
      if (Trim(lst[i]) = '') then
        Continue;

      fRegExp.Expression := lst[i];
      fRegExp.Exec('');
    except
      On E: Exception do
      begin
        MessageDlg(E.Message, mtError, [mbOK], 0);
        Exit;
      end;
    end;
  end;

  Result := True;
end;

procedure TfrmMain.SavePatterns();
var
  flng: TIniFile;
  i:    integer;
begin
  try
    if (Pos('.ptn', LowerCase(saveDlg.FileName)) < 1) then
      saveDlg.FileName := saveDlg.FileName + '.ptn';

    // Delete the file first
    TFCDelete(fCommandArray[alDelete]).execute(saveDlg.FileName);

    // Create new file
    flng := TIniFile.Create(saveDlg.FileName);

    flng.WriteInteger(GLOBAL_SECTION, KWD_ACTION, cbAction.ItemIndex);

    if (cbAction.ItemIndex <> integer(alExecute)) then
      eCommand.Text := '';

    flng.WriteString(GLOBAL_SECTION, CFG_COMMAND, eCommand.Text);

    if (cbAction.ItemIndex <> integer(alReplace)) then
      eReplaceFile.Text := '';

    flng.WriteString(GLOBAL_SECTION, CFG_REPLACE, eReplaceFile.Text);

    flng.WriteBool(GLOBAL_SECTION, CFG_CHARCASE, chkCharCase.Checked);
    flng.WriteBool(GLOBAL_SECTION, CFG_INCLUDEPATH, chkIncludePath.Checked);
    flng.WriteBool(GLOBAL_SECTION, CFG_UPDATEPUP, self.chkUpdateFiles.Checked);

    for i := 0 to pnlPattern.ControlCount - 1 do
      if (pnlPattern.Controls[i]<>ePatternPUB) then
        flng.WriteString(PTRN_SECTION, Format('patern%d', [i]),
          TEdit(pnlPattern.Controls[i]).Text);

  finally
    flng.Free();
  end;
end;

procedure TfrmMain.LoadFilePaterns();
var
  i: Integer;
begin
  fPaterns.Clear;

  for i := 0 to pnlPattern.ControlCount-1 do
    if (pnlPattern.Controls[i] is TEdit) then
       fPaterns.Add(TEdit(pnlPattern.Controls[i]).Text);
end;

procedure TfrmMain.LoadVideoPaterns();
var
  i: Integer;
  pstr: PString;
begin
  with fVideoPaterns do
  begin
    Clear;
    New(pstr);
    pstr^.str := '';
    AddObject('[bB][iI][kK]$', TObject(pstr));

    New(pstr);
    pstr^.str := '';
    AddObject('[mM]2[vV]$', TObject(pstr));

{
    New(pstr);
    pstr^.str := '';
    AddObject('[vV][pP]6$', TObject(pstr));
}
  end;
end;

{
procedure TfrmMain.RecodeFile(f: String);
var
  k: Integer;
begin
  try
    Inc(Count);
    pgrBarVideo.Position := pgrBarVideo.Position + 1;

    if (Count = 100) then
    begin
      Count := 0;
      Application.ProcessMessages();
    end;

    // We see what pattern match
    // Yes this could be done better (Ej: Array), but have no much time.
    k := WhatPatternMatch(f, fVideoPaterns);
    fExecReplace.setCmd(PString(fVideoPaterns.Objects[k])^.str);

    // Execute Action
    fExecReplace.Execute(f);
  except
    On e: Exception do
      fErrors.Add(f + ' - ' + e.Message);
  end;
end;
}

function TfrmMain.WhatPatternMatch(f: String; ptrn: TStrings): integer;
var
  i: Integer;
begin
  for i := 0 to ptrn.Count-1 do
  begin
    fRegExp.Expression := ptrn[i];
    if (fRegExp.Exec(f)) then
    begin
      result := i;
      Exit;
    end;
  end;
end;

procedure TfrmMain.setEncodeCommands();
begin
  with fConfig do
  begin
    if (m2vprg='REJIG') then
      eM2V.Text := TfrmM2V.getCommandLine(rejigpath, true, 70)
    else
      eM2V.Text := TfrmM2V.getCommandLine(ffmpegpath, false, 20000);

    eBik.Text := TfrmBIK.getCommandLine(IncludeTrailingPathDelimiter(binkpath) + VideoEncode.APP_BINK, 50);
  end;
end;

procedure TfrmMain.LoadConfig();
var
  fcfg: TIniFile;
  sect: string;
begin
  // 1.- We try to load the config file
  try
    sect := 'GLOBAL';
    fcfg := TIniFile.Create(CONFIG_FILE);
    with fConfig do
    begin
      binkpath := SysToUTF8(fcfg.ReadString(sect, CFG_BINK, 'tools\bink.exe'));
      ffmpegpath := SysToUTF8(fcfg.ReadString(sect, CFG_FFMPEG, 'tools\ffmpeg.exe'));
      ffplaypath := SysToUTF8(fcfg.ReadString(sect, CFG_FFPLAY, 'tools\ffplay.exe'));
      rejigpath := SysToUTF8(fcfg.ReadString(sect, CFG_REJIG, 'tools\rejig.exe'));
      m2vprg := SysToUTF8(fcfg.ReadString(sect, CFG_M2VPRG, 'REJIG'));

      setEncodeCommands();
    end;
  finally
    fcfg.Free();
  end;

end;

procedure TfrmMain.SaveConfig();
var
  fcfg: TIniFile;
  sect: string;
begin
  // 1.- We try to load the config file
  try
    sect := 'GLOBAL';
    fcfg := TIniFile.Create(CONFIG_FILE);
    fcfg.WriteString(sect, CFG_BINK, fConfig.binkpath);
    fcfg.WriteString(sect, CFG_FFMPEG, fConfig.ffmpegpath);
    fcfg.WriteString(sect, CFG_FFPLAY, fConfig.ffplaypath);
    fcfg.WriteString(sect, CFG_REJIG, fConfig.rejigpath);
    fcfg.WriteString(sect, CFG_M2VPRG, fConfig.m2vprg);
  finally
    fcfg.Free();
  end;
end;

procedure TfrmMain.CheckAll(lst: TListView);
var
  i: Integer;
begin
  for i := 0 to lst.Items.Count-1 do
    lst.Items[i].Checked := True;
end;

procedure TfrmMain.CheckNone(lst: TListView);
var
  i: Integer;
begin
  for i := 0 to lst.Items.Count-1 do
    lst.Items[i].Checked := False;
end;

procedure TfrmMain.CheckInverse(lst: TListView);
var
  i: Integer;
begin
  for i := 0 to lst.Items.Count-1 do
    lst.Items[i].Checked := Not lst.Items[i].Checked;
end;

initialization
  {$I formmain.lrs}

end.

