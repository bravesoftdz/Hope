unit Hope.Dialogs.GotoLineNumber;

{$I Hope.inc}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, 
  Vcl.StdCtrls, Hope.Dialog;

type
  TFormGotoLineNumber = class(TFormDialog)
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

end.
