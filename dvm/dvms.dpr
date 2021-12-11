program dvms;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  serviceModeRuntimeEnvironmentModule in 'serviceModeRuntimeEnvironmentModule.pas',
  serviceModeBootLoaderModule in 'serviceModeBootLoaderModule.pas',
  serviceModeInterpreterModule in 'serviceModeInterpreterModule.pas',
  distributedFileSystemModule in 'distributedFileSystemModule.pas';

var
        runtimeEnvironment : runtimeEnvironmentClass;
        bootLoader : bootLoaderClass;
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
