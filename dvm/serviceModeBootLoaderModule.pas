unit serviceModeBootLoaderModule;

interface

uses
        sysutils, Classes, serviceModeRuntimeEnvironmentModule,
        classLoaderModule, componentModule,globalDefine;
type
        bootLoaderClass = class
        public
                procedure load( var runtimeEnvironment : runtimeEnvironmentClass );
                procedure help;
        end;

implementation

procedure bootLoaderClass.help;
begin
        writeln('dvms -run|-r [-coredump|-c]');
        writeln('examples');
        writeln('dvms -r -c');
end;

procedure bootLoaderClass.load( var runtimeEnvironment : runtimeEnvironmentClass );
var
        i : integer;

//        classPath : string;
        coredump : boolean;
        runFlag : boolean;
begin

        write(DVM_VERSION); writeln( ' - dvms' );
        
        try
                i := 1;
                coredump := false;
                runflag := false;

                if ParamCount = 0 then help;

                while i <= ParamCount do
                begin
                        if ParamStr( i ) = '-run' then
                        begin
                                runFlag := true;
                        end
                        else
                        if ParamStr( i ) = '-r' then
                        begin
                                runFlag := true;
                        end
                        else
                        if ParamStr( i ) = '-coredump' then
                        begin
                                coredump := true;
                        end
                        else
                        if ParamStr( i ) = '-c' then
                        begin
                                coredump := true;
                        end
                        else
                                raise Exception.Create('unknow option');

                        inc(i);
                end;

                if runFlag = false then raise Exception.Create('must set the run option');

                runtimeEnvironment := runtimeEnvironmentClass.Create( coredump ) ;
        except
                on e: Exception do writeln( e.Message );
        end;
end;

end.




