program classViewer;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  dvm in 'dvm.pas',
  dvmDataType in 'dvmDataType.pas',
  dvmUtil in 'dvmUtil.pas';



        
var
a : classLoader;

begin
  { TODO -oUser -cConsole Main : Insert code here }

  a := classLoader.Create;
  a.load('Untitled1.class' );
  //a.load('Thread.class' );
  a.coreDump ;

  write('Please any key is exit');
  readln;


end.
