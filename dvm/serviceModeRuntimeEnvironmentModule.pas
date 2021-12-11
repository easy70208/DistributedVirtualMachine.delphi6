unit serviceModeRuntimeEnvironmentModule;

interface

uses
        sysutils, classLoaderModule, componentModule, classes ,
        distributedFileSystemModule, SyncObjs,globalDefine ;
type
        runtimeEnvironmentClass = class(TThread)
        protected
                procedure Execute; override;        
        private
                //classPath : string;
                coredumpflag : boolean;
                myCpuPower : string;
                usedDiskPower : integer; // avariable disk power : allowsizeDFS - usedDiskPower


                
                // for dvms config
                dvmConfig : configClass;

                // IME : Instance Message Exchange System
                IMES : indyConsoleUDPMessageClass;

                // DFS : Distrubuted File System
                DFSListener : distributedFileSystemListenerClass;


                // read from dvms.ini
                isProcessListener : boolean;
                isDFSListener : boolean;
                allowsizeDFS : integer; // per byte
        public
                constructor Create( {classPath : string ; }coredumpflag : boolean ) ;

                procedure mainLoop; // 프로그램의 메인 루프로 프로그램이 미리 종료되는 것을 막는다.
        private
                procedure getUDPMessage( ip : string ; port : integer ; senderName : string ; msgTitle : string ; msgBody : string );
                function getMyDiskPower : integer;
        end;

implementation

uses                             
        serviceModeInterpreterModule;

procedure runtimeEnvironmentClass.Execute;
begin
        while true do
        begin
                sleep(1000);

                if self.isProcessListener = true then
                begin
                        myCpuPower := utilClass.getCPUPower;

                        {$ifdef DEBUG}
                        writeln( format('(%s) UDP write to 255.255.255.255 : %s:%s',[utilClass.getTodayDateTime,inttostr(ord(GET_CPUPOWER_MESSAGE)),myCpuPower] ));
                        {$endif}

                        IMES.writeAllMessage(NORMAL_MODE_MESSAGE_LISTENER_PORT, inttostr(ord(GET_CPUPOWER_MESSAGE)) , myCpuPower );
                end;

                if self.isDFSListener = true then
                begin
                        {$ifdef DEBUG}
                        writeln( format('(%s) UDP write to 255.255.255.255 : %s:%s',[utilClass.getTodayDateTime,inttostr(ord(GET_DISKPOWER_MESSAGE)),inttostr(getMyDiskPower)] ));
                        {$endif}
                        
                        IMES.writeAllMessage(NORMAL_MODE_MESSAGE_LISTENER_PORT, inttostr(ord(GET_DISKPOWER_MESSAGE)) , inttostr(getMyDiskPower) );
                end;
        end;
end;

constructor runtimeEnvironmentClass.Create( coredumpflag : boolean ) ;
var
        s : string;
        sr: TSearchRec;
        FileAttrs: Integer;
begin
        inherited Create( true );

        //self.classPath := classPath;

        self.coredumpflag := coredumpflag;
        self.myCpuPower := '';
        self.usedDiskPower := 0;

        dvmConfig := configClass.Create(DVMS_INI_PATH);
        s := dvmConfig.getValue('DVMSMAIN','isProcessListener','');
        if s = '' then
        begin
                s := 'true';
                dvmConfig.setValue('DVMSMAIN','isProcessListener',s);
        end;
        if s = 'true' then
        begin
                self.isProcessListener := true;
                writeln( 'isProcessListener is true');
        end
        else
        begin
                self.isProcessListener := false;
                writeln( 'isProcessListener is false');
        end;

        s := dvmConfig.getValue('DVMSMAIN','isDFSListener','');
        if s = '' then
        begin
                s := 'true';
                dvmConfig.setValue('DVMSMAIN','isDFSListener',s);
        end;
        if s = 'true' then
        begin
                writeln( 'isDFSListener is true');
                self.isDFSListener := true;
        end
        else
        begin
                writeln( 'isDFSListener is false');
                self.isDFSListener := false;
        end;

        s := dvmConfig.getValue('DVMSMAIN','allowsizeDFS','');
        if s = '' then
        begin
                s := inttostr(1024*1024*10);
                dvmConfig.setValue('DVMSMAIN','allowsizeDFS',s); // 10Mb
        end;
        self.allowsizeDFS := strtoint( s );
        write( 'allowsizeDFS is ' ); write( s ); writeln( ' byte(s)' );






        IMES := indyConsoleUDPMessageClass.Create( SERVICE_MODE_MESSAGE_LISTENER_PORT , true );
        IMES.getMessage := getUDPMessage;
        IMES.start;
        writeln( format('message Listener started with %d udp port', [SERVICE_MODE_MESSAGE_LISTENER_PORT] ) );



        if isProcessListener = true then
        begin
                write( 'myCpuPower is ' );
                myCpuPower := utilClass.getCPUPower;
                writeln( myCpupower );
                IMES.writeAllMessage( NORMAL_MODE_MESSAGE_LISTENER_PORT , inttostr(ord(GET_CPUPOWER_MESSAGE)) , myCpuPower );
                writeln( format('process Listener started with %d tcp port', [PROCESS_LISTENER_PORT] ) );                
        end;

        if isDFSListener = true then
        begin
                write( 'usedDiskPower is ' );
                FileAttrs := faAnyFile;
                if FindFirst( DFS_LISTENER_PATH + '*.dfs', FileAttrs, sr) = 0 then
                begin
                repeat
                        if (sr.Attr and FileAttrs) = sr.Attr then
                        begin
                                self.usedDiskPower := self.usedDiskPower + sr.Size;
                        end;
                until FindNext(sr) <> 0;

                FindClose(sr);
                end;
                write( usedDiskPower );
                writeln( ' byte(s)' );                

                write( 'myDiskPower is ' );
                write( self.allowsizeDFS - self.usedDiskPower );
                writeln( ' byte(s)' );

                dfsListener := distributedFileSystemListenerClass.Create( DISTRIBUTED_FILE_SYSTEM_LISTENER_PORT , DFS_LISTENER_PATH );
                dfsListener.active;

                IMES.writeAllMessage( NORMAL_MODE_MESSAGE_LISTENER_PORT , inttostr(ord(GET_DISKPOWER_MESSAGE)) , inttostr(getMyDiskPower) );

                writeln( format('distributed File System Listener started with %d tcp port', [DISTRIBUTED_FILE_SYSTEM_LISTENER_PORT] ) );
        end;

        writeln( 'service mode runtimeEnvironment runed.....' );
end;

procedure runtimeEnvironmentClass.getUDPMessage( ip : string ; port : integer ; senderName : string ; msgTitle : string ; msgBody : string );
var
        s1,s2 : string;
        interpreter : interpreterClass;
begin
        writeln( format('(%s) UDP get from %s : %s:%s:%s',[utilClass.getTodayDateTime,ip,senderName,msgTitle,MsgBody] ));

        if msgTitle = inttostr(ord(GET_CPUPOWER_MESSAGE)) then
        begin
                if isProcessListener = true then
                begin
                        writeln( format('(%s) UDP write to %s : %s:%s',[utilClass.getTodayDateTime,ip,inttostr(ord(GET_CPUPOWER_MESSAGE)),myCpuPower] ));
                        IMES.writeMessage(ip,port, inttostr(ord(GET_CPUPOWER_MESSAGE)) , myCpuPower );
                end;
        end
        else
        if msgTitle = inttostr(ord(START_PROCESS_MESSAGE)) then // msgBody -> this$threadCounter
        begin
                if isProcessListener = true then
                begin
                        utilClass.getToken( msgBody , '$' , s1 );
                        utilClass.getToken( '' , '$' , s2 );
                        interpreter := interpreterClass.Create( ip , PROCESS_LISTENER_PORT ,  format( 'SubThread__%s__%s__%s', [ip,
                                utilclass.getTodayDateTime , s2] ) , strtoint( s1 ) , coredumpflag );
                        interpreter.run;
                end;
        end
        else
        if msgTitle = inttostr(ord(GET_DISKPOWER_MESSAGE)) then
        begin
                if self.isDFSListener = true then
                begin
                        writeln( format('(%s) UDP write to %s : %s:%s',[utilClass.getTodayDateTime,ip,inttostr(ord(GET_DISKPOWER_MESSAGE)),inttostr(getMyDiskPower)] ));
                        IMES.writeMessage(ip,port, inttostr(ord(GET_DISKPOWER_MESSAGE)) , inttostr(getMyDiskPower) );
                end;
        end
        else
                writeln( 'Unknow Message' );
end;


procedure runtimeEnvironmentClass.mainLoop; // 프로그램의 메인 루프로 프로그램이 미리 종료되는 것을 막는다.
begin
        {$ifdef WIN32}
//                self.Priority := tpIdle;
        {$else}
//                self.Priority := tpIdle;
        {$endif}

        Resume;
        WaitFor;

end;

function runtimeEnvironmentClass.getMyDiskPower : integer;
begin
        result := self.allowsizeDFS - ( self.usedDiskPower + self.dfsListener.getIobytes );
end;

end.
