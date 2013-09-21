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

unit LangFrm;

interface

uses
{$IFDEF WIN32}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Menus, ComCtrls, FileCtrl;
{$ENDIF}
{$IFDEF LINUX}
  SysUtils, Classes, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QButtons, QExtCtrls, QMenus, QComCtrls;
{$ENDIF}

type
  TLangForm = class(TForm)
    OkBtn: TBitBtn;
    PopupMenu: TPopupMenu;
    N1: TMenuItem;
    ThemeImage: TImage;
    FirstPanel: TPanel;
    ListBox: TListBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ThemeGroupBox: TGroupBox;
    ThemeBox: TComboBox;
    CachePanel: TPanel;
    Label2: TLabel;
    BuildPanel: TPanel;
    YesCache: TRadioButton;
    NoCache: TRadioButton;
    ProgressPanel: TPanel;
    pbCCCache: TProgressBar;
    ParseLabel: TLabel;
    SecondPanel: TPanel;
    SecondLabel: TLabel;
    Label5: TLabel;
    YesClassBrowser: TRadioButton;
    NoClassBrowser: TRadioButton;
    FinishPanel: TPanel;
    Label4: TLabel;
    Label7: TLabel;
    AltCache: TRadioButton;
    AltFileList: TListBox;
    Label3: TLabel;
    ButtonAddFile: TButton;
    ButtonRemove: TButton;
    ButtonAddFolder: TButton;
    EditorBox: TComboBox;
    InterfaceLbl: TLabel;
    EditorLbl: TLabel;
    Label6: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure ThemeChange(Sender: TObject);
    procedure ButtonAddFileClick(Sender: TObject);
    procedure ButtonRemoveClick(Sender: TObject);
    procedure ButtonAddFolderClick(Sender: TObject);
  private
    HasProgressStarted : boolean;

    function GetSelected: integer;
    procedure CppParserTotalProgress(Sender: TObject; FileName: String; Total, Current: Integer);

  public
    procedure UpdateList(const List: TStrings);
    property Selected: integer read GetSelected;
  end;

implementation

uses 
  MultiLangSupport, datamod, DevThemes, devcfg, utils, main, version;

{$R *.dfm}

procedure TLangForm.UpdateList;
var
 idx: integer;
 sel: integer;
begin
  ListBox.Clear;
  for idx:= 0 to pred(List.Count) do
  begin
   sel := ListBox.Items.Add(List.Values[List.Names[idx]]);
   if Pos('english', LowerCase(ListBox.Items[sel])) > 0 then
     ListBox.Selected[sel] := True;
  end;
end;

function TLangForm.GetSelected: integer;
begin
  result:= ListBox.ItemIndex;
end;

procedure TLangForm.FormActivate(Sender: TObject);
var s : array [0..255] of char;
    d : DWORD;
    sl : TStrings;
begin
  HasProgressStarted := false;

	// Themes
	sl := devTheme.ThemeList;
	ThemeBox.Items.AddStrings(sl);
	ThemeBox.ItemIndex := 0;
	sl.Free;

	// Editor styles
	EditorBox.Items.Add('Classic');
	EditorBox.Items.Add('Classic Plus');
	EditorBox.ItemIndex := 1;

	ThemeImage.Picture.Bitmap.LoadFromResourceName(HInstance, 'NEWLOOKCLASSICPLUS');
	GetUserName(s, d);
end;

procedure TLangForm.CppParserTotalProgress(Sender: TObject; FileName: String; Total, Current: Integer);
var
	tmp : string;
begin
	if not HasProgressStarted then begin
		pbCCCache.Max := Total;
		HasProgressStarted := true;
	end;
	pbCCCache.Position := pbCCCache.Position + Current;
	tmp := 'Parsing file:' + #13#10 + FileName;
	ParseLabel.Caption := StringReplace(tmp,devDirs.Exec,'\',[rfReplaceAll, rfIgnoreCase]);
	Application.ProcessMessages;
end;

procedure TLangForm.OkBtnClick(Sender: TObject);
var
	s, f : TStringList;
	i, j : integer;
	fullpath : string;
begin
	if OkBtn.Tag = 0 then begin
		OkBtn.Tag := 1;
		SecondPanel.Visible := true;
		FirstPanel.Visible := false;
		devData.ThemeChange := true;
		devData.Theme := ThemeBox.Items[ThemeBox.ItemIndex];
		dmMain.InitHighlighterFirstTime(EditorBox.ItemIndex);
	end else if OkBtn.Tag = 1 then begin
		if YesClassBrowser.Checked then begin
			OkBtn.Tag := 2;
			CachePanel.Visible := true;
			SecondPanel.Visible := false;
		end else begin
			OkBtn.Tag := 3;
			OkBtn.Kind := bkOK;
			OkBtn.ModalResult := mrOK;
			FinishPanel.Visible := true;
			SecondPanel.Visible := false;
			devCodeCompletion.Enabled := false;
			devCodeCompletion.UseCacheFiles := false;
			devClassBrowsing.Enabled := false;
			devClassBrowsing.ParseLocalHeaders := false;
			devClassBrowsing.ParseGlobalHeaders := false;
			SaveOptions;
		end;
	end else if OkBtn.Tag = 2 then begin
		if YesCache.Checked or AltCache.Checked then begin
			YesCache.Enabled := false;
			NoCache.Enabled := false;
			AltCache.Enabled := false;
			AltFileList.Enabled := false;
			OkBtn.Enabled := false;
			BuildPanel.Visible := False;
			ProgressPanel.Visible := True;
			OkBtn.Caption := 'Please wait...';
			MainForm.CacheCreated := true;
			Application.ProcessMessages;
			devCodeCompletion.Enabled := true;
			devCodeCompletion.UseCacheFiles := true;
			devClassBrowsing.Enabled := true;
			devClassBrowsing.ParseLocalHeaders := true;
			devClassBrowsing.ParseGlobalHeaders := true;
			SaveOptions;

			MainForm.CppParser.ParseLocalHeaders := True;
			MainForm.CppParser.ParseGlobalHeaders := True;
			MainForm.CppParser.OnTotalProgress := CppParserTotalProgress;
			MainForm.CppParser.OnStartParsing := nil;
			MainForm.CppParser.OnEndParsing := nil;
			MainForm.CppParser.Tokenizer:= MainForm.CppTokenizer;
			MainForm.CppParser.Enabled := true;

			MainForm.ClassBrowser1.SetUpdateOff;

			s := TStringList.Create;
			if (AltCache.Checked) then begin
				devClassBrowsing.ParseGlobalHeaders := false; // Too slow
				for I:=0 to AltFileList.Count-1 do begin
					s.Add(AltFileList.Items[I]);
				end;
			end else
				StrToList(devDirs.Cpp, s);

			// Make it look busy
			Screen.Cursor:=crHourglass;
			Application.ProcessMessages;

			f := TStringList.Create;
			if not AltCache.Checked then begin
				for i := 0 to pred(s.Count) do begin
					// Relative paths make the recursive/loop searcher go nuts
					s[i] := StringReplace(s[i],'%path%\',devDirs.exec,[rfReplaceAll]);
					if DirectoryExists(s[i]) then begin
						FilesFromWildcard(s[i], '*.*', f, false, false, false);
						for j := 0 to f.Count - 1 do
							MainForm.CppParser.AddFileToScan(f[j]);
					end else
						MessageDlg('Directory "' + s[i] + '" does not exist', mtWarning, [mbOK], 0);
				end;
			end else begin
				for i := 0 to pred(s.Count) do begin

					// Assemble full path
					if s[i][1] = ':' then
						fullpath := s[i]
					else
						fullpath := devDirs.Cpp + '\' + s[i];

					// Then check for existance
					if FileExists(fullpath) then begin
						MainForm.CppParser.AddFileToScan(fullpath);
					end else
						MessageDlg('File "' + fullpath + '" does not exist', mtWarning, [mbOK], 0);
				end;
			end;

			// Deze regel duurt heel lang
			MainForm.CppParser.ParseList;

			ParseLabel.Caption := 'Saving...';
			Application.ProcessMessages;
			MainForm.CppParser.Save(devDirs.Config+DEV_COMPLETION_CACHE);

			MainForm.CppParser.OnStartParsing := MainForm.CppParserStartParsing;;
			MainForm.CppParser.OnEndParsing := MainForm.CppParserEndParsing;
			MainForm.CppParser.OnTotalProgress := MainForm.CppParserTotalProgress;

			MainForm.ClassBrowser1.SetUpdateOn;

			Application.ProcessMessages;
			Screen.Cursor:=crDefault;
			s.Free;
			f.Free;
		end else begin
			devClassBrowsing.Enabled := true;
			devClassBrowsing.ParseLocalHeaders := true;
			devClassBrowsing.ParseGlobalHeaders := false;
			devClassBrowsing.ShowInheritedMembers := true;
		end;
		OkBtn.Tag := 3;
		OkBtn.Kind := bkOK;
		OkBtn.ModalResult := mrOK;
		OkBtn.Enabled := true;
		FinishPanel.Visible := true;
		CachePanel.Visible := false;
	end
end;

procedure TLangForm.ThemeChange(Sender: TObject);
var
	finalname : string;
begin
	finalname := '';
	case ThemeBox.ItemIndex of
		0: finalname := 'NEWLOOK';
		1: finalname := 'GNOME';
		2: finalname := 'BLUE';
	end;
	case EditorBox.ItemIndex of
		0: finalname := finalname + 'CLASSIC';
		1: finalname := finalname + 'CLASSICPLUS';
	end;
	ThemeImage.Picture.Bitmap.LoadFromResourceName(HInstance, finalname);
end;

procedure TLangForm.ButtonAddFileClick(Sender: TObject);
var
	I: integer;
	s: string;
begin
	with dmMain.OpenDialog do begin
		Filter:= FLT_HEADS;
		Title:= Lang[ID_NV_OPENFILE];
		InitialDir := devDirs.Cpp;
		if Execute then begin
			for i:= 0 to pred(Files.Count) do begin
				s := StringReplace(Files.Strings[i],devDirs.Cpp + '\','',[rfReplaceAll]);
				AltFileList.Items.Add(s);
			end;
		end;
	end;
end;

procedure TLangForm.ButtonRemoveClick(Sender: TObject);
//var
//	I : integer;
begin
	AltFileList.DeleteSelected;
//	for I:= 0 to AltFileList.Count-1 do begin
//		if AltFileList.Selected[I] then begin
//			AltFileList.Items.Delete(i);
//		end;
//	end;
end;

procedure TLangForm.ButtonAddFolderClick(Sender: TObject);
var
	Dir : string;
	f : TStringList;
	I : integer;
	s : string;
begin
	f := TStringList.Create;
	if SelectDirectory('Select Folder', devDirs.Exec, Dir) then begin
		FilesFromWildcard(Dir, '*.*', f, false, false, false);
		for i := 0 to f.Count-1 do begin
			s := StringReplace(f[i],devDirs.Cpp + '\','',[rfReplaceAll]);
			AltFileList.Items.Add(s);
		end;
	end;
end;

end.
