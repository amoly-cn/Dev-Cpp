{
    This file is part of Dev-C++
    Copyright (c) 2004 Bloodshed Software

    Dev-C++ is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Dev-C++ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Dev-C++; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

unit EditorList;

interface

uses
{$IFDEF WIN32}
  Windows, SysUtils, Dialogs, StdCtrls, Controls, ComCtrls, Forms, Editor, ExtCtrls,
  devrun, version, project, utils, ProjectTypes, Classes, Graphics, Math;
{$ENDIF}
{$IFDEF LINUX}
SysUtils, QDialogs, QStdCtrls, QComCtrls, QForms,
devrun, version, project, utils, prjtypes, Classes, QGraphics;
{$ENDIF}

type
  TLayoutShowType = (lstLeft, lstRight, lstBoth, lstNone);
  TEditorList = class
  private
    fLayout: TLayoutShowType;
    fLeftPageControl: TPageControl;
    fRightPageControl: TPageControl;
    fSplitter: TSplitter;
    fUpdateCount: integer;
    fPanel: TPanel;
    function GetForEachEditor(index: integer): TEditor;
    function GetPageCount: integer;
    function GetFocusedPageControl: TPageControl;
    procedure ShowLayout(Layout: TLayoutShowType);
    procedure Update; // reconfigures layout
  public
    function NewEditor(const Filename: AnsiString; InProject, NewFile: boolean; PageControl: TPageControl = nil):
      TEditor;
    function FileIsOpen(const FileName: AnsiString; ProjectOnly: boolean = FALSE): TEditor;
    function GetEditor(PageIndex: integer = -1; PageControl: TPageControl = nil): TEditor;
    function GetEditorFromFileName(const FileName: AnsiString): TEditor;
    function GetEditorFromTag(tag: integer): TEditor;
    function CloseEditor(Editor: TEditor): Boolean;
    function CloseAll: boolean;
    function CloseAllButThis: boolean;
    function SwapEditor(Editor: TEditor): boolean;
    procedure OnPanelResize(Sender: TObject);
    procedure SelectNextPage;
    procedure SelectPrevPage;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure GetVisibleEditors(var Left: TEditor; var Right: TEditor);
    procedure SetPreferences(TabPosition: TTabPosition; MultiLine: boolean);
    property LeftPageControl: TPageControl read fLeftPageControl write fLeftPageControl;
    property RightPageControl: TPageControl read fRightPageControl write fRightPageControl;
    property Splitter: TSplitter read fSplitter write fSplitter;
    property Panel: TPanel read fPanel write fPanel;
    property PageCount: integer read GetPageCount;
    property Editors[Index: integer]: TEditor read GetForEachEditor; default;
    property FocusedPageControl: TPageControl read GetFocusedPageControl;
  end;

implementation

uses
  main, MultiLangSupport, DataFrm;

function TEditorList.GetPageCount: integer;
begin
  Result := fLeftPageControl.PageCount + fRightPageControl.PageCount;
end;

function TEditorList.GetFocusedPageControl: TPageControl;
begin
  if Assigned(fLeftPageControl.ActivePage) and TEditor(fLeftPageControl.ActivePage.Tag).Text.Focused then
    Result := fLeftPageControl
  else if Assigned(fRightPageControl.ActivePage) and TEditor(fRightPageControl.ActivePage.Tag).Text.Focused then
    Result := fRightPageControl
  else
    Result := fLeftPageControl; // default one
end;

procedure TEditorList.BeginUpdate;
begin
  Inc(fUpdateCount);
end;

procedure TEditorList.EndUpdate;
begin
  Dec(fUpdateCount);
  if fUpdateCount = 0 then
    Update;
end;

function TEditorList.GetForEachEditor(index: integer): TEditor;
begin
  // Is it within range of the first one?
  if (index >= 0) and (index < fLeftPageControl.PageCount) then begin
    result := TEditor(fLeftPageControl.Pages[index].Tag);
    Exit;
  end;

  // Nope? Check second one
  Dec(index, fLeftPageControl.PageCount);
  if (index >= 0) and (index < fRightPageControl.PageCount) then begin
    result := TEditor(fRightPageControl.Pages[index].Tag);
    Exit;
  end;

  Result := nil;
end;

function TEditorList.NewEditor(const Filename: AnsiString; InProject, NewFile: boolean; PageControl: TPageControl =
  nil):
  TEditor;
var
  ParentPageControl: TPageControl;
begin
  BeginUpdate;
  try
    if PageControl = nil then
      ParentPageControl := GetFocusedPageControl
    else
      ParentPageControl := PageControl;
    Result := TEditor.Create(FileName, InProject, NewFile, ParentPageControl);
  finally
    EndUpdate;
  end;
end;

function TEditorList.FileIsOpen(const FileName: AnsiString; ProjectOnly: boolean = FALSE): TEditor;
var
  e: TEditor;
  I: integer;
begin
  // Check first page control
  for I := 0 to fLeftPageControl.PageCount - 1 do begin
    e := GetEditor(I, fLeftPageControl);
    if SameFileName(e.FileName, FileName) then

      // Accept the file if it's in a project OR if it doesn't have to be in a project
      if (not ProjectOnly) or e.InProject then begin
        Result := e;
        Exit;
      end;
  end;

  // Same for the right page control
  for I := 0 to fRightPageControl.PageCount - 1 do begin
    e := GetEditor(I, fRightPageControl);
    if SameFileName(e.FileName, FileName) then

      // Accept the file if it's in a project OR if it doesn't have to be in a project
      if (not ProjectOnly) or e.InProject then begin
        Result := e;
        Exit;
      end;
  end;

  Result := nil;
end;

function TEditorList.GetEditor(PageIndex: integer = -1; PageControl: TPageControl = nil): TEditor;
var
  SelectedPageControl: TPageControl;
  TabSheet: TTabSheet;
begin
  Result := nil;

  // Select page control
  if PageControl = nil then
    SelectedPageControl := GetFocusedPageControl
  else
    SelectedPageControl := PageControl;
  if not Assigned(SelectedPageControl) then
    Exit;

  // Select tab in selected pagecontrol
  case PageIndex of
    -1: TabSheet := SelectedPageControl.ActivePage;
  else
    TabSheet := SelectedPageControl.Pages[PageIndex];
  end;
  if not Assigned(TabSheet) then
    Exit;

  Result := TEditor(TabSheet.Tag);
end;

function TEditorList.CloseEditor(Editor: TEditor): Boolean;
var
  projindex: integer;
begin
  Result := False;
  if not Assigned(Editor) then
    Exit;

  BeginUpdate;
  try
    // Ask user if he wants to save
    if Editor.Text.Modified and not Editor.Text.IsEmpty then begin
      case MessageDlg(Format(Lang[ID_MSG_ASKSAVECLOSE], [Editor.FileName]), mtConfirmation, mbYesNoCancel, 0) of
        mrYes:
          if not Editor.Save then
            Exit;
        mrCancel:
          Exit; // stop closing
      end;
    end;

    // Using this thing, because WM_SETREDRAW doesn't work
    LockWindowUpdate(Editor.PageControl.Handle);
    try
      // We're allowed to close...
      Result := True;
      if Editor.InProject and Assigned(MainForm.Project) then begin
        projindex := MainForm.Project.Units.IndexOf(Editor);
        if projindex <> -1 then
          MainForm.Project.CloseUnit(projindex);
      end else begin
        dmMain.AddtoHistory(Editor.FileName);
        FreeAndNil(Editor);
      end;
    finally
      LockWindowUpdate(0);
    end;
  finally
    EndUpdate;
  end;
end;

function TEditorList.CloseAll: boolean;
begin
  BeginUpdate;
  try
    Result := False;
    // Keep closing the first one to prevent redrawing
    while fLeftPageControl.PageCount > 0 do
      if not CloseEditor(GetEditor(0, fLeftPageControl)) then
        Exit;

    // Same for the right page control
    while fRightPageControl.PageCount > 0 do
      if not CloseEditor(GetEditor(0, fRightPageControl)) then
        Exit;

    Result := True;
  finally
    EndUpdate;
  end;
end;

function TEditorList.CloseAllButThis: boolean;
var
  I: integer;
  ActiveEditor, Editor: TEditor;
begin
  BeginUpdate;
  try
    Result := False;
    // Keep closing the first one to prevent redrawing
    ActiveEditor := GetEditor(-1, fLeftPageControl);
    for I := fLeftPageControl.PageCount - 1 downto 0 do begin
      Editor := GetEditor(I, fLeftPageControl);
      if Assigned(Editor) and (Editor <> ActiveEditor) then
        if not CloseEditor(Editor) then
          Exit;
    end;

    // Keep closing the first one to prevent redrawing
    ActiveEditor := GetEditor(-1, fRightPageControl);
    for I := fRightPageControl.PageCount - 1 downto 0 do begin
      Editor := GetEditor(I, fRightPageControl);
      if Assigned(Editor) and (Editor <> ActiveEditor) then
        if not CloseEditor(Editor) then
          Exit;
    end;

    Result := True;
  finally
    EndUpdate;
  end;
end;

function TEditorList.GetEditorFromFileName(const FileName: AnsiString): TEditor;
var
  FullFileName: AnsiString;
  I: integer;
  e: TEditor;
begin
  Result := nil;

  // ExpandFileName reduces all the "\..\" in the path
  FullFileName := ExpandFileName(FileName);

  // First, check wether the file is already open
  for I := 0 to fLeftPageControl.PageCount - 1 do begin
    e := GetEditor(I, fLeftPageControl);
    if Assigned(e) then begin
      if SameFileName(e.FileName, FullFileName) then begin
        Result := e;
        Exit;
      end;
    end;
  end;

  // Same for the right page control
  for I := 0 to fRightPageControl.PageCount - 1 do begin
    e := GetEditor(I, fRightPageControl);
    if Assigned(e) then begin
      if SameFileName(e.FileName, FullFileName) then begin
        Result := e;
        Exit;
      end;
    end;
  end;

  // Then check the project...
  if Assigned(MainForm.Project) then begin
    I := MainForm.Project.GetUnitFromString(FullFileName);
    if I <> -1 then begin
      result := MainForm.Project.OpenUnit(I);
      Exit;
    end;
  end;

  // Else, just open from disk
  if FileExists(FullFileName) then
    Result := NewEditor(FullFileName, False, False);
end;

function TEditorList.GetEditorFromTag(tag: integer): TEditor;
var
  I: integer;
begin
  result := nil;

  // First, check wether the file is already open
  for I := 0 to fLeftPageControl.PageCount - 1 do begin
    if fLeftPageControl.Pages[i].Tag = tag then begin
      result := TEditor(fLeftPageControl.Pages[i].Tag);
      break;
    end;
  end;

  // Same for the right page control
  for I := 0 to fRightPageControl.PageCount - 1 do begin
    if fRightPageControl.Pages[i].Tag = tag then begin
      result := TEditor(fRightPageControl.Pages[i].Tag);
      break;
    end;
  end;
end;

function TEditorList.SwapEditor(Editor: TEditor): boolean;
var
  FromPageControl: TPageControl;
  FromPageControlIndex: integer;
begin
  BeginUpdate;
  try
    Result := True;

    // Remember old index
    FromPageControl := Editor.PageControl;
    FromPageControlIndex := Editor.PageControl.ActivePageIndex;

    // Determine how to swap
    if Editor.PageControl = fLeftPageControl then
      Editor.PageControl := fRightPageControl
    else
      Editor.PageControl := fLeftPageControl;

    // Switch to previous editor in the other one
    FromPageControl.ActivePageIndex := max(0, FromPageControlIndex - 1);

    // Notify component of changes
    Editor.Activate;
  finally
    EndUpdate;
  end;
end;

procedure TEditorList.Update;
begin
  if (fLeftPageControl.PageCount = 0) and (fRightPageControl.PageCount = 0) then
    ShowLayout(lstNone)
  else if (fLeftPageControl.PageCount > 0) and (fRightPageControl.PageCount = 0) then
    ShowLayout(lstLeft)
  else if (fLeftPageControl.PageCount = 0) and (fRightPageControl.PageCount > 0) then
    ShowLayout(lstRight)
  else if (fLeftPageControl.PageCount > 0) and (fRightPageControl.PageCount > 0) then
    ShowLayout(lstBoth);
end;

procedure TEditorList.ShowLayout(Layout: TLayoutShowType);
begin
  if Layout = fLayout then
    Exit;

  // Apply widths if layout does not change
  case Layout of
    lstLeft: begin
        fLeftPageControl.Align := alClient;
        fLeftPageControl.Visible := True;

        // Hide other components
        fRightPageControl.Visible := False;
        fRightPageControl.Width := 0;
        fSplitter.Visible := False;
        fSplitter.Width := 0;
      end;
    lstRight: begin
        fRightPageControl.Align := alClient;
        fRightPageControl.Visible := True;

        // Hide other components
        fLeftPageControl.Visible := False;
        fLeftPageControl.Width := 0;
        fSplitter.Visible := False;
        fSplitter.Width := 0;
      end;
    lstBoth: begin
        // Align to the left, assign 50% area
        fLeftPageControl.Align := alClient;
        fLeftPageControl.Visible := True;
        fLeftPageControl.Width := (fPanel.Width - 3) div 2;
        fLeftPageControl.Left := 0;

        // Put splitter in between
        fSplitter.Align := alRight;
        fSplitter.Visible := True;
        fSplitter.Width := 3;
        fSplitter.Left := fLeftPageControl.Width;

        // Align other one to the right
        fRightPageControl.Align := alRight;
        fRightPageControl.Visible := True;
        fRightPageControl.Width := (fPanel.Width - 3) div 2;
        fRightPageControl.Left := fLeftPageControl.Width + 3;
      end;
    lstNone: begin
        fLeftPageControl.Visible := False;
        fLeftPageControl.Width := 0;
        fRightPageControl.Visible := False;
        fRightPageControl.Width := 0;
        fSplitter.Visible := False;
        fSplitter.Width := 0;

        // Normally, change events are trigger by editor focus, but since there's no one left, fake it
        fRightPageControl.OnChange(fRightPageControl);
      end;
  end;
  fLayout := Layout;
end;

procedure TEditorList.SelectNextPage;
var
  PageControl: TPageControl;
begin
  PageControl := GetFocusedPageControl;
  if Assigned(PageControl) then
    PageControl.SelectNextPage(True);
end;

procedure TEditorList.SelectPrevPage;
var
  PageControl: TPageControl;
begin
  PageControl := GetFocusedPageControl;
  if Assigned(PageControl) then
    PageControl.SelectNextPage(False);
end;

procedure TEditorList.GetVisibleEditors(var Left: TEditor; var Right: TEditor);
begin
  Left := nil;
  Right := nil;
  case fLayout of
    lstLeft: begin
        Left := GetEditor(-1, fLeftPageControl);
      end;
    lstRight: begin
        Right := GetEditor(-1, fLeftPageControl);
      end;
    lstBoth: begin
        Left := GetEditor(-1, fLeftPageControl);
        Right := GetEditor(-1, fLeftPageControl);
      end;
  end;
end;

procedure TEditorList.SetPreferences(TabPosition: TTabPosition; MultiLine: boolean);
begin
  LeftPageControl.TabPosition := TabPosition;
  LeftPageControl.MultiLine := MultiLine;
  RightPageControl.TabPosition := TabPosition;
  RightPageControl.MultiLine := MultiLine;
end;

procedure TEditorList.OnPanelResize(Sender: TObject);
//var
//  LeftPageWidthPercent : integer;
begin
  if fLayout = lstBoth then begin
    // Force 50% layout
    // TODO: better option would be to remember pagecontrol width percentages of parent panel
    fLayout := lstNone;
    ShowLayout(lstBoth);
  end;
end;

end.

