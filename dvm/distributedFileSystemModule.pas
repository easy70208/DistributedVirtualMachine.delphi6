unit distributedFileSystemModule;

//{$DEFINE DEBUG}

interface

uses
        IdTCPConnection, IdTCPServer, IdTCPClient, Classes, sysutils, componentModule;

type
        DISTRIBUTED_FILE_SYSTEM_ID = (
                DFS_OUTPUT_OPEN,
                DFS_OUTPUT_OPENAPPEND,
                DFS_OUTPUT_WRITE,
                DFS_OUTPUT_WRITEBYTES,
                DFS_OUTPUT_CLOSE,
                DFS_INPUT_READBYTES,
                DFS_INPUT_READ,
                DFS_INPUT_OPEN,
                DFS_INPUT_AVAILABLE,
                DFS_INPUT_CLOSE,
                DFS_COMMAND_DELETE
        );

        distributedFileSystemListenerClass = class
        private
                tcpServerSocket : TIdTCPServer;
                fileIOStreamIndex : integer;
                fileIOStream : array[0..100] of TFileStream;
                idThread : array[0..100] of TIdPeerThread;
                listenerPath : string;

                iobytes : integer;

        public
                constructor Create( port : integer ; storeagePath : string );
                procedure active;
                procedure idle;
                function getIobytes : integer;
        private
                procedure doConnect(AThread: TIdPeerThread); // tcp연결 connect호출
                procedure doExecute(AThread: TIdPeerThread); // tcp연결 Execute호출
                procedure doDisconnect(AThread: TIdPeerThread); // tcp연결 Disconnect호출

                function getfileIOStream : integer;
                function getOpenFileIOStreamByIdThread( idThread : TIdPeerThread ) : TFileStream;
        end;

        distributedFileSystemRequestClass = class
        private
                tfs : TFileStream;
                tcpClientSocket : TIdTCPClient;

        public
                constructor inputOpen( requestPath : string ; localPath : string ; orginalFileName : string );
                function inputRead : integer;
                function inputReadBytes( var Buffer ; len : integer ) : integer;
                function inputAvailable : integer;
                procedure inputClose;

                constructor outputOpen( newhost : string ; newport : integer ; requestPath : string ; localPath : string ; orginalFileName : string ; mode : integer );
                procedure outputWrite( data : integer );
                procedure outputWriteBytes( const Buffer  ; len : integer );
                procedure outputClose;
        end;

implementation


function distributedFileSystemListenerClass.getfileIOStream() : integer;
var
        i : integer;
begin
        i := self.fileIOStreamIndex ;
        inc( self.fileIOStreamIndex );

        result := i;
end;

function distributedFileSystemListenerClass.getOpenFileIOStreamByIdThread( idThread : TIdPeerThread ) : TFileStream;
var
        i : integer;
begin
        for i:=0 to self.fileIOStreamIndex - 1 do
        begin
                if self.idThread[i] = idThread then break;
        end;

        result := self.fileIOStream[i];
end;

constructor distributedFileSystemListenerClass.Create( port : integer ; storeagePath : string );
begin
        self.fileIOStreamIndex := 0;

        // 디폴트 메서드
        tcpServerSocket := TIdTCPServer.Create(nil);
        tcpServerSocket.DefaultPort := port;
        tcpServerSocket.OnConnect := doConnect;
        tcpServerSocket.OnExecute := doExecute;
        tcpServerSocket.OnDisconnect := doDisconnect;

        self.listenerPath := storeagePath;

        self.iobytes := 0;
end;

procedure distributedFileSystemListenerClass.active;
begin
        tcpServerSocket.Active := true;
end;

procedure distributedFileSystemListenerClass.doConnect(AThread: TIdPeerThread);
begin
        write( format( '(%s) TCP get from %s : ',[utilClass.getTodayDateTime, utilclass.getRemoteIPinTIdPeerThread(AThread)] ) );
        writeln( 'DFS_CONNECT' );
end;

procedure distributedFileSystemListenerClass.doExecute(AThread: TIdPeerThread);
var
//        buff : array of byte; // 동적 array로 하면 exception이 발생하여 아래와 같이 한다.
        buff : array[0..10000] of byte;
        commandType : integer;
        s1 : string;
        i,j : integer;
        f : TFileStream;
        ba : array[0..1] of byte;
begin
        commandType := AThread.Connection.ReadInteger;

        write( format( '(%s) TCP get from %s : ',[utilClass.getTodayDateTime, utilclass.getRemoteIPinTIdPeerThread(AThread)] ) );

        case commandType of
        //
        // OUTPUT
        //
        ord( DFS_OUTPUT_OPEN ) :
        begin
                writeln( 'DFS_OUTPUT_OPEN' );
                s1 := AThread.Connection.ReadLn;
                i := self.getfileIOStream;
                self.fileIOStream[i] := TFileStream.Create( self.listenerPath + s1 , fmCreate );
                self.idThread[i] := AThread;
                AThread.Connection.WriteLn('ok');
        end;

        ord( DFS_OUTPUT_OPENAPPEND ) :
        begin
                writeln( 'DFS_OUTPUT_OPENAPPEND' );
                s1 := AThread.Connection.ReadLn;
                i := self.getfileIOStream;
                try
                        self.fileIOStream[i] := TFileStream.Create( self.listenerPath + s1 , fmOpenWrite );
                        self.fileIOStream[i].seek(0,soFromEnd);
                except
                        self.fileIOStream[i] := TFileStream.Create( self.listenerPath + s1 , fmCreate )
                end;
                self.idThread[i] := AThread;
                AThread.Connection.WriteLn('ok');
        end;

        ord( DFS_OUTPUT_WRITE ) :
        begin
                writeln( 'DFS_OUTPUT_WRITE' );
                i := aThread.Connection.ReadInteger(); // data
                f := self.getOpenFileIOStreamByIdThread(AThread);
                f.Write(byte(i),1);
                AThread.Connection.WriteLn('ok');
                inc(iobytes);
        end;

        ord( DFS_OUTPUT_WRITEBYTES ) :
        begin
        try
                writeln( 'DFS_OUTPUT_WRITEBYTES' );
                i := aThread.Connection.ReadInteger(); // data len
//                setlength( buff , i );
                athread.Connection.ReadBuffer(buff,i);
                f := self.getOpenFileIOStreamByIdThread(AThread);
                f.Write(buff,i);
                AThread.Connection.WriteLn('ok');
                iobytes := iobytes + i;
        except
                on e: Exception do writeln( e.Message );
        end;

        end;

        ord( DFS_OUTPUT_CLOSE ) :
        begin
                writeln( 'DFS_OUTPUT_CLOSE' );
                f := self.getOpenFileIOStreamByIdThread(AThread);
                f.Free;
                AThread.Connection.WriteLn('ok');
        end;

        //
        // INPUT
        //
        ord( DFS_INPUT_READBYTES ) :
        begin
                writeln( 'DFS_INPUT_READBYTES' );
                i := aThread.Connection.ReadInteger(); // data len
//                setlength( buff , i );
                f := self.getOpenFileIOStreamByIdThread(AThread);

                if f.Position = f.size then
                begin
                        AThread.Connection.WriteInteger(-1);
                end
                else
                begin
                        j := f.Read(buff,i);

                        AThread.Connection.WriteInteger( j );

                        athread.Connection.OpenWriteBuffer();
                        athread.Connection.WriteBuffer(buff,j);
                        athread.Connection.CloseWriteBuffer;
                end;
        end;

        ord( DFS_INPUT_READ ) :
        begin
                writeln( 'DFS_INPUT_READ' );
                f := self.getOpenFileIOStreamByIdThread(AThread);

                if f.Position = f.size then
                begin
                        AThread.Connection.WriteInteger(-1);
                end
                else
                begin
                        f.Read( ba , 1 );
                        AThread.Connection.WriteInteger(ba[0]);
                end;
        end;

        ord( DFS_INPUT_OPEN ) :
        begin
                writeln( 'DFS_INPUT_OPEN' );
                s1 := AThread.Connection.ReadLn;
                i := self.getfileIOStream;
                self.fileIOStream[i] := TFileStream.Create( self.listenerPath + s1 , fmOpenRead );
                self.idThread[i] := AThread;
                AThread.Connection.WriteLn('ok');
        end;

        ord( DFS_INPUT_AVAILABLE ) :
        begin
                writeln( 'DFS_INPUT_AVAILABLE' );

                f := self.getOpenFileIOStreamByIdThread(AThread);
                i := f.size - f.Position;
                AThread.Connection.WriteInteger(i);
        end;

        ord( DFS_INPUT_CLOSE ) :
        begin
                writeln( 'DFS_INPUT_CLOSE' );
                f := self.getOpenFileIOStreamByIdThread(AThread);
                f.Free;
                AThread.Connection.WriteLn('ok');
        end;

        //
        // COMMAND
        //
        ord( DFS_COMMAND_DELETE ) :
        begin
                writeln( 'DFS_COMMAND_DELETE' );
                s1 := AThread.Connection.ReadLn;
                i := utilClass.getFileSize( self.listenerPath + s1 );
                self.iobytes := self.iobytes - i;
                DeleteFile( self.listenerPath + s1 );
                AThread.Connection.WriteLn('ok');
        end;

        end;
end;

procedure distributedFileSystemListenerClass.doDisconnect(AThread: TIdPeerThread);
begin
        write( format( '(%s) TCP get from %s : ',[utilClass.getTodayDateTime, utilclass.getRemoteIPinTIdPeerThread(AThread)] ) );
        writeln( 'DFS_DISCONNECT' );
end;

procedure distributedFileSystemListenerClass.idle;
begin
        while true do;
end;

constructor distributedFileSystemRequestClass.inputOpen( requestPath : string ; localPath : string ; orginalFileName : string );
var
        remotefilename : string;
        tf : textfile ;
        host : string;
        port : integer;
begin
        // type1 nomal file
        if orginalFileName[1] <> '@' then
        begin
                tfs := TFileStream.Create(  orginalFileName , fmOpenRead );
                exit;
        end;

        assignfile( tf , requestPath + orginalFileName );
        reset( tf );
        readln( tf , host );
        readln( tf , port );
        readln( tf , remotefilename );
        closefile( tf );

        // type 2 local host file
        if host = 'local' then
        begin
                tfs := TFileStream.Create( localPath + remotefilename , fmOpenRead );
        end
        else
        // type 3 remote host file
        begin
                self.tfs := nil;
                
                tcpClientsocket := TIdTCPClient.Create(nil);
                tcpClientSocket.Host := host;
                tcpClientSocket.port := port;
                tcpClientSocket.Connect;

                tcpClientsocket.WriteInteger(ord(DFS_INPUT_OPEN));
                tcpClientsocket.WriteLn(remotefilename);
                tcpClientsocket.ReadLn; // dumy
        end;        
end;

function distributedFileSystemRequestClass.inputRead : integer;
var
        ba : array[0..1] of byte;
begin
        if self.tfs = nil then
        begin
                tcpClientsocket.WriteInteger(ord(DFS_INPUT_READ));
                result := tcpClientsocket.ReadInteger;
        end
        else
        begin
                if self.tfs.Position = self.tfs.size then
                        result := -1
                else
                begin
                        self.tfs.Read( ba , 1 );
                        result := integer( ba[0] );
                end;
        end;
end;

function distributedFileSystemRequestClass.inputReadBytes( var Buffer ; len : integer ) : integer;
begin
        if self.tfs = nil then
        begin
                tcpClientsocket.WriteInteger(ord(DFS_INPUT_READBYTES));
                tcpClientsocket.WriteInteger(len);

                result := tcpClientsocket.ReadInteger;

//                write( 'result : ' );
//                writeln( result );

                if result = -1 then exit;
                
                tcpClientsocket.readBuffer(Buffer,result);
        end
        else
        begin
                if self.tfs.Position = self.tfs.size then
                        result := -1
                else
                begin
                        result := self.tfs.Read( Buffer , len );
                end;
        end;
end;

function distributedFileSystemRequestClass.inputAvailable : integer;
begin
        if self.tfs = nil then
        begin
                tcpClientsocket.WriteInteger(ord(DFS_INPUT_AVAILABLE));
                result := tcpClientsocket.ReadInteger;
        end
        else
        begin
                result := self.tfs.size - self.tfs.Position;
        end;
end;

procedure distributedFileSystemRequestClass.inputClose;
begin
        if self.tfs = nil then
        begin
                tcpClientsocket.WriteInteger(ord(DFS_INPUT_CLOSE));
                tcpClientsocket.ReadLn; // dumy
                tcpClientsocket.Disconnect;
        end
        else
        begin
                self.tfs.Free;
        end
end;

constructor distributedFileSystemRequestClass.outputOpen( newhost : string ; newport : integer ; requestPath : string ; localPath : string ; orginalFileName : string ; mode : integer );
var
        newremotefilename : string;
        f : textfile ;
        oldhost : string;
        oldport : integer;
        oldremotefilename : string;
begin
        self.tfs := nil;

        {$ifdef DEBUG}
        write( 'DEBUG:' );
        writeln( format('newhost : %s',[newhost]) );
        {$endif}


        if orginalFileName[1] <> '@' then
        begin
                if mode = ord(DFS_OUTPUT_OPEN) then
                        tfs := TFileStream.Create( orginalFileName , fmCreate )
                else
                begin
                        try
                                tfs := TFileStream.Create( orginalFileName , fmOpenWrite );
                                tfs.Seek(0,soFromEnd);
                        except
                                tfs := TFileStream.Create( orginalFileName , fmCreate )
                        end;
                end;

                exit;
        end;

        if FileExists( requestPath + orginalFileName ) = true then
        begin
                assignfile( f , requestPath + orginalFileName );
                reset( f );
                readln( f , oldhost );
                readln( f , oldport );
                readln( f , oldremotefilename );
                closefile( f );

                if mode = ord(DFS_OUTPUT_OPEN) then
                begin
                        //
                        // delete file
                        //
                        if oldhost = 'local' then
                        begin
                                DeleteFile( localPath + oldremotefilename );
                        end
                        else
                        begin
                                tcpClientsocket := TIdTCPClient.Create(nil);
                                tcpClientsocket.Host := oldhost;
                                tcpclientsocket.Port := oldport;
                                tcpClientSocket.Connect;
                                tcpClientsocket.WriteInteger(ord(DFS_COMMAND_DELETE));
                                tcpClientSocket.WriteLn(oldremotefilename);
                                tcpClientsocket.ReadLn();
                                tcpClientSocket.Free;
                                tcpclientsocket := nil;
                        end;
                
                        if newHost = '' then
                        begin
                                newHost := 'local';
                                newPort := -1;
                                newremotefilename := 'local_' + format('%e.dfs',[Now]);
                                tfs := TFileStream.Create( localPath + newremotefilename , fmCreate )
                        end
                        else
                        begin
                                tcpClientsocket := TIdTCPClient.Create(nil);
                                tcpClientsocket.Host := newhost;
                                tcpclientsocket.Port := newport;
                                tcpClientSocket.Connect;
                                newremotefilename := utilclass.getMyIPinTIdTCPClient( self.tcpClientSocket ) + '_' + format('%e.dfs',[Now]);
                                tcpClientsocket.WriteInteger(ord(DFS_OUTPUT_OPEN));
                                tcpClientsocket.WriteLn( newremotefilename );
                                tcpClientsocket.ReadLn; // dumy
                        end;
                end;

                if mode = ord(DFS_OUTPUT_OPENAPPEND) then
                        if oldHost = 'local' then
                        begin
                                newHost := 'local';
                                newPort := -1;
                                newremotefilename := oldremotefilename;
                                try
                                        tfs := TFileStream.Create( localPath + newremotefilename , fmOpenWrite );
                                        tfs.Seek(0,soFromEnd);
                                except
                                        tfs := TFileStream.Create( localPath + newremotefilename , fmCreate )
                                end;                        
                        end
                        else
                        begin
                                newHost := oldhost;
                                newPort := oldPort;
                                newremotefilename := oldremotefilename;
                                tcpClientsocket := TIdTCPClient.Create(nil);
                                tcpClientsocket.Host := newhost;
                                tcpclientsocket.Port := newport;
                                tcpClientSocket.Connect;
                                tcpClientsocket.WriteInteger(ord(DFS_OUTPUT_OPENAPPEND));
                                tcpClientsocket.WriteLn( newremotefilename );
                                tcpClientsocket.ReadLn; // dumy
                        end;
        end
        else
        begin
                if mode = ord(DFS_OUTPUT_OPEN) then
                        if newhost = '' then
                        begin
                                newHost := 'local';
                                newPort := -1;
                                newremotefilename := 'local_' + format('%e.dfs',[Now]);
                                tfs := TFileStream.Create( localPath + newremotefilename , fmCreate )
                        end
                        else
                        begin
                                tcpClientsocket := TIdTCPClient.Create(nil);
                                tcpClientsocket.Host := newhost;
                                tcpclientsocket.Port := newport;
                                tcpClientSocket.Connect;
                                newremotefilename := utilclass.getMyIPinTIdTCPClient( self.tcpClientSocket ) + '_' + format('%e.dfs',[Now]);
                                tcpClientsocket.WriteInteger(ord(DFS_OUTPUT_OPEN));
                                tcpClientsocket.WriteLn( newremotefilename );
                                tcpClientsocket.ReadLn; // dumy
                        end;

                if mode = ord(DFS_OUTPUT_OPENAPPEND) then
                        if newhost = '' then
                        begin
                                newHost := 'local';
                                newPort := -1;
                                newremotefilename := 'local_' + format('%e.dfs',[Now]);
                                try
                                        tfs := TFileStream.Create( localPath + newremotefilename , fmOpenWrite );
                                        tfs.Seek(0,soFromEnd);
                                except
                                        tfs := TFileStream.Create( localPath + newremotefilename , fmCreate )
                                end;
                        end
                        else
                        begin
                                tcpClientsocket := TIdTCPClient.Create(nil);
                                tcpClientsocket.Host := newhost;
                                tcpclientsocket.Port := newport;
                                tcpClientSocket.Connect;
                                newremotefilename := utilclass.getMyIPinTIdTCPClient( self.tcpClientSocket ) + '_' + format('%e.dfs',[Now]);
                                tcpClientsocket.WriteInteger(ord(DFS_OUTPUT_OPENAPPEND));
                                tcpClientsocket.WriteLn( newremotefilename );
                                tcpClientsocket.ReadLn; // dumy
                        end;
        
        end;

        assignfile( f , requestPath + orginalFileName );
        rewrite( f );
        writeln( f , newHost );
        writeln( f , newPort );
        writeln ( f , newremotefilename );
        closefile( f );
end;

procedure distributedFileSystemRequestClass.outputWrite( data : integer );
begin
        if tfs = nil then
        begin
                tcpClientsocket.WriteInteger(ord(DFS_OUTPUT_WRITE));
                tcpClientsocket.WriteInteger(data);
                tcpClientsocket.ReadLn; // dumy
        end
        else
        begin
                tfs.Write( byte(data) , 1 );
        end;
end;

procedure distributedFileSystemRequestClass.outputWriteBytes( const buffer  ; len : integer );
begin
        if tfs = nil then
        begin
                tcpClientsocket.WriteInteger(ord(DFS_OUTPUT_WRITEBYTES));
                tcpClientsocket.WriteInteger(len);
                tcpClientsocket.OpenWriteBuffer();
                tcpClientsocket.WriteBuffer(buffer,len);
                tcpClientsocket.CloseWriteBuffer;
                tcpClientsocket.ReadLn; // dumy
        end
        else
        begin
                tfs.Write( buffer , len );
        end;
end;

procedure distributedFileSystemRequestClass.outputClose;
begin
        if tfs = nil then
        begin
                tcpClientsocket.WriteInteger(ord(DFS_OUTPUT_CLOSE));
                tcpClientsocket.ReadLn; // dumy
                tcpClientsocket.Disconnect;
        end
        else
        begin
                self.tfs.Free;
        end;
end;


function distributedFileSystemListenerClass.getIobytes : integer;
begin
        result := self.iobytes ;
end;

end.
