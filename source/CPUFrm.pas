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

unit CPUFrm;

interface

uses
{$IFDEF WIN32}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, SynEdit, StrUtils;
{$ENDIF}
{$IFDEF LINUX}
  SysUtils, Variants, Classes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QButtons, QSynEdit;
{$ENDIF}

type
  TCPUForm = class(TForm)
    gbAsm: TGroupBox;
    gbSyntax: TGroupBox;
    rbIntel: TRadioButton;
    rbATT: TRadioButton;
    edFunc: TEdit;
    lblFunc: TLabel;
    CodeList: TSynEdit;
    gbRegisters: TGroupBox;
    lblEIP: TLabel;
    EIPText: TEdit;
    EAXText: TEdit;
    lblEAX: TLabel;
    EBXText: TEdit;
    lblEBX: TLabel;
    lblECX: TLabel;
    ECXText: TEdit;
    lblEDX: TLabel;
    EDXText: TEdit;
    lblESI: TLabel;
    ESIText: TEdit;
    lblEDI: TLabel;
    EDIText: TEdit;
    lblEBP: TLabel;
    EBPText: TEdit;
    lblESP: TLabel;
    ESPText: TEdit;
    lblCS: TLabel;
    CSText: TEdit;
    lblDS: TLabel;
    DSText: TEdit;
    lblSS: TLabel;
    SSText: TEdit;
    lblES: TLabel;
    ESText: TEdit;
    lblFS: TLabel;
    FSText: TEdit;
    lblGS: TLabel;
    GSText: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edFuncKeyPress(Sender: TObject; var Key: Char);
    procedure rbSyntaxClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    ActiveLine : integer;

    procedure LoadText;

    procedure OnActiveLine(Sender: TObject; Line: Integer;var Special: Boolean; var FG, BG: TColor);

  public
    procedure OnRegistersReady;
  end;

var
  CPUForm: TCPUForm;

implementation

uses 
  main, version, MultiLangSupport, debugger, utils,
  devcfg, debugwait, Types; 

{$R *.dfm}

procedure TCPUForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainForm.fDebugger.OnRegistersReady := nil;
  action := caFree;
end;

procedure TCPUForm.edFuncKeyPress(Sender: TObject; var Key: Char);
var
	tmp : AnsiString;
begin
	if key = #13 then begin
		if (MainForm.fDebugger.Executing) then
			CodeList.Lines.Clear;
			tmp:=edFunc.Text;
			if EndsStr('()',edFunc.Text) then begin
				Delete(tmp,length(tmp)-1,2);
				edFunc.Text:=tmp;
			end;
			MainForm.fDebugger.SendCommand(GDB_DISASSEMBLE,tmp);
	end;
end;

procedure TCPUForm.rbSyntaxClick(Sender: TObject);
var
	cb : TCheckBox;
	tmp : AnsiString;
begin
  cb := TCheckBox(sender);
  while (MainForm.fDebugger.InAssembler) do
   sleep(20);
  if (MainForm.fDebugger.Executing) then begin
    CodeList.Lines.Clear;
    if cb.Tag = 0 then
      MainForm.fDebugger.SendCommand(GDB_SETFLAVOR, GDB_ATT)
    else
      MainForm.fDebugger.SendCommand(GDB_SETFLAVOR, GDB_INTEL);

    MainForm.fDebugger.Idle;

    if EndsStr('()',edFunc.Text) then begin
		Delete(tmp,length(tmp)-1,2);
		edFunc.Text:=tmp;
	end;
    MainForm.fDebugger.SendCommand(GDB_DISASSEMBLE,tmp);
    MainForm.fDebugger.Idle;
  end;
end;

procedure TCPUForm.LoadText;
begin
  with Lang do begin
    Caption := Strings[ID_CPU_CAPTION];
    gbAsm.Caption := '  '+Strings[ID_CPU_ASMCODE]+'  ';
    gbSyntax.Caption := '  '+Strings[ID_CPU_SYNTAX]+'  ';
    gbRegisters.Caption := '  '+Strings[ID_CPU_REGISTERS]+'  ';
    lblFunc.Caption := Strings[ID_CPU_FUNC];
  end;
end;

procedure TCPUForm.FormCreate(Sender: TObject);
begin
  ActiveLine := -1;
  CodeList.OnSpecialLineColors := OnActiveLine;
  MainForm.fDebugger.OnRegistersReady := OnRegistersReady;
  LoadText;
end;

procedure TCPUForm.OnRegistersReady;
var
	i : integer;
begin
	// Set interface font
	Font.Name := devData.InterfaceFont;
	Font.Size := devData.InterfaceFontSize;

  EAXText.Text := MainForm.fDebugger.Registers[EAX];
  EBXText.Text := MainForm.fDebugger.Registers[EBX];
  ECXText.Text := MainForm.fDebugger.Registers[ECX];
  EDXText.Text := MainForm.fDebugger.Registers[EDX];
  ESIText.Text := MainForm.fDebugger.Registers[ESI];
  EDIText.Text := MainForm.fDebugger.Registers[EDI];
  EBPText.Text := MainForm.fDebugger.Registers[EBP];
  ESPText.Text := MainForm.fDebugger.Registers[ESP];
  EIPText.Text := MainForm.fDebugger.Registers[EIP];
  CSText.Text :=  MainForm.fDebugger.Registers[CS];
  DSText.Text :=  MainForm.fDebugger.Registers[DS];
  SSText.Text :=  MainForm.fDebugger.Registers[SS];
  ESText.Text :=  MainForm.fDebugger.Registers[ES];
  FSText.Text :=  MainForm.fDebugger.Registers[FS];
  GSText.Text :=  MainForm.fDebugger.Registers[GS];
  for i := 0 to CodeList.Lines.Count - 1 do
    if pos(EIPText.Text, CodeList.Lines[i]) <> 0 then begin
      if (ActiveLine <> i) and (ActiveLine <> -1) then
        CodeList.InvalidateLine(ActiveLine);
      ActiveLine := i + 1;
      CodeList.InvalidateLine(ActiveLine);
      CodeList.CaretY := ActiveLine;
      CodeList.EnsureCursorPosVisible;
      break;
    end;
end;

procedure TCPUForm.OnActiveLine(Sender: TObject; Line: Integer;var Special: Boolean; var FG, BG: TColor);
var pt : TPoint;
begin
   if (Line = ActiveLine) then begin
     StrtoPoint(pt, devEditor.Syntax.Values[cABP]);
     BG:= pt.X;
     FG:= pt.Y;
     Special:= TRUE;
   end;
end;

end.
