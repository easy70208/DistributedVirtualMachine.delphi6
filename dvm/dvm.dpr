program dvm;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  normalModeRuntimeEnvironmentModule in 'normalModeRuntimeEnvironmentModule.pas',
  normalModeBootLoaderModule in 'normalModeBootLoaderModule.pas',
  normalModeInterpreterModule in 'normalModeInterpreterModule.pas';

var
        runtimeEnvironment : runtimeEnvironmentClass;
        bootLoader : bootLoaderClass;
        {
                ���� �۾��� �����ؼ� ������ ���� �����Ѵ�.

                java/IOStream -> TFileStream
                interpreter dump -> textfile
                classLoader -> fileHandler
                disiturubte data file -> textfile
        }
begin

        bootLoader := nil;
        runtimeEnvironment := nil;

        try
                bootLoader := bootLoaderClass.Create;
                bootLoader.load( runtimeEnvironment );

                runtimeEnvironment.mainLoop;
        except
                on e: Exception do writeln( e.Message );
        end;

        bootLoader.Free;
        runtimeEnvironment.Free;
end.
