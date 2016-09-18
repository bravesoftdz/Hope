unit Hope.Compiler;

{$I Hope.inc}

interface

uses
  System.SysUtils, dwsUtils, dwsComp, dwsCompiler, dwsExprs, dwsJSCodeGen,
  dwsJSLibModule, dwsCodeGen, dwsErrors, dwsFunctions, Hope.Project,
  Hope.Compiler.Base;

type
  THopeCompileErrorEvent = procedure(Sender: TObject; Messages: TdwsMessageList) of object;
  THopeCompilationEvent = procedure(Sender: TObject; Prog: IdwsProgram) of object;
  THopeGetMainScriptEvent = procedure(Sender: TObject; out Script: string) of object;
  THopeGetSourceCodeEvent = function(Sender: TObject; const UnitName: string; out SourceCode: string): Boolean of object;
  THopeGetTextEvent = function(Sender: TObject; const FileName: string; out Text: string): Boolean of object;

  THopeCompiler = class(THopeBaseCompiler)
  private
    FOnError: THopeCompileErrorEvent;
    FOnCompilation: THopeCompilationEvent;
    FOnGetSourceCode: THopeGetSourceCodeEvent;
    FOnGetMainScript: THopeGetMainScriptEvent;
    FOnGetText: THopeGetTextEvent;

    function GetMainScript(Project: THopeProject): string;
    procedure OnIncludeEventHandler(const ScriptName: string;
      var ScriptSource: string);
    function OnNeedUnitEventHandler(const UnitName: string;
      var UnitSource: string) : IdwsUnit;
  public
    constructor Create;
    destructor Destroy; override;

    function SyntaxCheck(Project: THopeProject): Boolean;
    function CompileProject(Project: THopeProject): IdwsProgram;
    procedure BuildProject(Project: THopeProject);

    property OnError: THopeCompileErrorEvent read FOnError write FOnError;
    property OnCompilation: THopeCompilationEvent read FOnCompilation write FOnCompilation;
    property OnGetSourceCode: THopeGetSourceCodeEvent read FOnGetSourceCode write FOnGetSourceCode;
    property OnGetText: THopeGetTextEvent read FOnGetText write FOnGetText;
    property OnGetMainScript: THopeGetMainScriptEvent read FOnGetMainScript write FOnGetMainScript;
  end;

implementation

uses
  dwsXPlatform, dwsExprList, Hope.Common.Constants;

{ THopeCompiler }

constructor THopeCompiler.Create;
begin
  // create DWS compiler
  DelphiWebScript.OnNeedUnit := OnNeedUnitEventHandler;
  DelphiWebScript.OnInclude := OnIncludeEventHandler;
end;

destructor THopeCompiler.Destroy;
begin
  inherited;
end;

function THopeCompiler.GetMainScript(Project: THopeProject): string;
begin
  // get main script
  if Assigned(FOnGetMainScript) then
    FOnGetMainScript(Self, Result)
  else
    Result := LoadTextFromFile(Project.MainScript.FileName);
end;

procedure THopeCompiler.OnIncludeEventHandler(const ScriptName: string;
  var ScriptSource: string);
begin
  if Assigned(FOnGetText) then
    if FOnGetText(Self, ScriptName, ScriptSource) then
      Exit;

  if FileExists(scriptName) then
    ScriptSource := LoadTextFromFile(ScriptName);
end;

function THopeCompiler.OnNeedUnitEventHandler(const UnitName: string;
  var UnitSource: string): IdwsUnit;
var
  FileName: TFileName;
begin
  if Assigned(FOnGetSourceCode) then
    if FOnGetSourceCode(Self, FileName, UnitSource) then
      Exit;

  FileName := UnitName + CExtensionPascal;

  if FileExists(FileName) then
    UnitSource := LoadTextFromFile(FileName);
end;

function THopeCompiler.SyntaxCheck(Project: THopeProject): Boolean;
var
  Prog: IdwsProgram;
begin
  Prog := DelphiWebScript.Compile(GetMainScript(Project));

  if Prog.Msgs.HasErrors then
  begin
    if Assigned(FOnError) then
      FOnError(Self, Prog.Msgs);
    Exit;
  end;

  // fire compilation event
  if Assigned(FOnCompilation) then
    FOnCompilation(Self, Prog);
end;

function THopeCompiler.CompileProject(Project: THopeProject): IdwsProgram;
var
  Prog: IdwsProgram;
  CodeJS: string;
begin
  Prog := DelphiWebScript.Compile(GetMainScript(Project));

  if Prog.Msgs.HasErrors then
  begin
    if Assigned(FOnError) then
      FOnError(Self, Prog.Msgs);
    Exit;
  end;

  // fire compilation event
  if Assigned(FOnCompilation) then
    FOnCompilation(Self, Prog);


(*
  FCodeGen.Clear;
  FCodeGen.CompileProgram(Prog);
  CodeJS := FCodeGen.CompiledOutput(Prog);
*)
end;

procedure THopeCompiler.BuildProject(Project: THopeProject);
var
  Prog: IdwsProgram;
begin
  Prog := DelphiWebScript.Compile(GetMainScript(Project));

  if Prog.Msgs.HasErrors then
  begin
    if Assigned(FOnError) then
      FOnError(Self, Prog.Msgs);
    Exit;
  end;

  // fire compilation event
  if Assigned(FOnCompilation) then
    FOnCompilation(Self, Prog);
end;

end.
