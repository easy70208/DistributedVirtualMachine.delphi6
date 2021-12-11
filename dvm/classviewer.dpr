program classviewer;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  componentModule in 'componentModule.pas',
  classLoaderModule in 'classLoaderModule.pas',
  globalDefine in 'globalDefine.pas',
  readme in 'readme.pas';

var
        classLoader : classLoaderClass;
begin
        try
                if ParamCount <> 1 then
                begin
                        write(DVM_VERSION); writeln( ' - classviewer' );
                        writeln('classviewer classfile.class');
                        exit;
                end;

                classLoader := classLoaderClass.Create;
                classLoader.load( ParamStr( 1 ));
                classLoader.coreDump;
        except
                on e: Exception do writeln( e.Message );                
        end;

end.
