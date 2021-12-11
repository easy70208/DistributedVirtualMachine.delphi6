unit componentModule;

//{$DEFINE DEBUG}

interface

uses
        sysutils,IdUDPServer, IDSockethandle, Classes,
        IdTCPConnection, IdTCPServer, IdTCPClient, IniFiles;

const
        // Array type define
        T_CHAR = 5; // charArrayInstanceClass;
        T_BYTE = 8; // byteArrayInstanceClass;
        T_INT = 10; // intArrayInstanceClass
        T_LONG = 11; // longArrayInstanceClass
type
        nameAndValueClass = class
        public
                index : integer;
                name : array[0..1000] of string;
                Integervalue : array[0..1000] of integer;
                int64Value : array[0..1000] of int64;

                function getFieldIndex( fieldName : string ) : integer;

                constructor Create;

                procedure appendFieldIntegervalue( fieldName : string ; IntegerValue : integer );
                function getFieldIntegerValue( fieldIndex : integer ) : integer;
                procedure setFieldIntegerValue( fieldIndex : integer ; IntegerValue : integer );


                {
                        2003-9-2
                        음... long형의 처리를 계산해 넣지 못했다....
                        그래서.. static, 및 필드 변수는 long을 사용하지 못한다...
                        로컬 변수에서는 long을 지원하지만 여기서는 않된다....
                        음....
                        지원하려고 했으나.. 넘무 땜방이 심하여 하지 않는다...
                        아래 함수는 사용되지 않을 것이다.
                }
                procedure appendFieldInt64value( fieldName : string ; Int64value : int64 );
                function getFieldInt64value( fieldIndex : integer ) : int64;
                procedure setFieldInt64value( fieldIndex : integer ; Int64value : int64 );

        end;

        intArrayInstanceClass = class
        public
                size : integer;
                data : array of integer;
                constructor Create( size : integer ); overload;
                constructor Create( data : array of integer ; size : integer ); overload;
                class function getClassData( intArrayInstance : intArrayInstanceClass) : string;
                class function setClassData( data : string ) : intArrayInstanceClass;
        end;

        longArrayInstanceClass = class
        public
                size : integer;
                data : array of int64;
                constructor Create( size : integer ); overload;
                constructor Create( data : array of int64 ; size : integer ); overload;
                class function getClassData( longArrayInstance : longArrayInstanceClass) : string;
                class function setClassData( data : string ) : longArrayInstanceClass;
        end;

        byteArrayInstanceClass = class
        public
                size : integer;
                data : array of byte;
                constructor Create( size : integer ); overload;
                constructor Create( var data : array of byte ; size : integer ); overload;
                class function getClassData( byteArrayInstance : byteArrayInstanceClass ) : string;
                class function setClassData( data : string ) : byteArrayInstanceClass ;
        end;

        charArrayInstanceClass = class
        public
                size : integer;
                data : array of char;
                constructor Create( size : integer ); overload;
                constructor Create( data : pchar ; size : integer ); overload;
                class function getClassData( charArrayInstance : charArrayInstanceClass) : string;
                class function setClassData( data : string ): charArrayInstanceClass;
        end;

        arrayInstanceClass = class
                arrayType : byte;
                arrayObject : TObject;
        public
                class function getClassData( arrayInstance : arrayInstanceClass) : string;
                class function setClassData( data : string ): arrayInstanceClass;
        end;

        newInstanceClass = class( nameAndValueClass )
        public
                classHecheriIndex : integer;
                classHecheriIndexByLoadedClassIndex : array[0..100] of integer;

                // 상속관계에 있는 클래스들을 입력할때 사용한다
                // index는 runtimeEnvironmentArea에 있는 loadedClassIndex;
                // 이것은 init메소드의 의해 초기화 가 된다.
                procedure appendHecheriClass( loadedClassIndex : integer );
        end;

        configClass = class
        private
                IniFile: TIniFile;
                configFile : string;
        public
                constructor Create( configFile : string );
                function getValue( section : string ; field : string ; defaultString : string ) : string;
                procedure setValue( section : string ; field : string ; value : string );
        end;

        // tcp는 가공하지 않고 전달하기 때문에 그대로 사용한다.
        // 아니다 가공한다.
        TTCPgetConnect = procedure() of object;
        TTCPgetMessage = procedure( var msg : string ; var isWrite : boolean ) of object;
        TTCPgetDisconnect = procedure() of object;
        indyConsoleTcpServerClass = class
        private
                tcpServerSocket : TIdTCPServer;
        public
                getConnect : TTCPgetConnect;
                getMessage : TTCPgetMessage;
                getDisconnect : TTCPgetDisconnect;
        public
                constructor Create( port : integer);
                procedure active;
                procedure idle;
        private
                procedure doConnect(AThread: TIdPeerThread); // tcp연결 connect호출
                procedure doExecute(AThread: TIdPeerThread); // tcp연결 Execute호출
                procedure doDisconnect(AThread: TIdPeerThread); // tcp연결 Disconnect호출
        end;

        indyConsoleTcpClientClass = class
        private
                tcpClientSocket : TIdTCPClient;
        public
                constructor Create( host : string ; port : integer );
                procedure writeMessage( msg : string );
                function getMessage : string;
                procedure close;
        end;

        // udp는 가공하여 전달하기 때문에 변형된 형태를 사용한다.
        TUDPgetMessage = procedure( ip : string ; port : integer ; senderName : string ; msgTitle : string ; msgBody : string ) of object;
        indyConsoleUDPMessageClass = class
        private
                udpServerSocket : TIdUDPServer;
        public
                getMessage : TUDPgetMessage;
        private
                procedure read( Sender : TObject ; AData : TStream ; ABinding : TIdSocketHandle );
                procedure write( ip : string ; port : integer ; msg : string );
        public
                constructor Create( port : integer ; isbroadcast : boolean );
                procedure writeMessage( ip : string ; port : integer ; msgTitle : string ; msgBody : string );
                procedure writeAllMessage( port : integer ; msgTitle : string ; msgBody : string );
                procedure start;
                procedure idle;
        end;

        stackClass = class
        public
                statckOffset : integer;
                buffer : array[0..1000] of integer;

                constructor Create;
                procedure coreDump;
                procedure coreDumpBy;
                procedure push( value : integer );
                function pop : integer;

                class function getClassData( st : stackClass ) : string;
                class function setClassData( s : string ) : stackClass;
        end;

        utilClass = class
                class function bitSwitchU2( i : word ) : word;
                class function bitSwitchU4( i : integer ) : integer;
                class function bitSwitchU8( i : int64 ) : int64;

                class function getFixedStringLeftOrder( s : string ; totalLength : integer ; c : string ) : string;
                class function getFixedStringRightOrder( s : string ; totalLength : integer ; c : string ) : string;

                class function changeCharbyChar( s : string ; c1 : char ; c2 : char ) : string;

                class function fileReadU2LittenEndan( fileHandler : integer ) : word;
                class function fileReadU4LittenEndan( fileHandler : integer ) : integer;
                class function fileReadU8LittenEndan( fileHandler : integer ) : int64;

                class function makeU2withHiByteAndLowByte( hibyte : byte ; lowbyte : byte ) : word;

                class function byte2integer( b : byte ) : integer;
                class function word2integer( w : word ) : integer;

                class function compStringIntoS2( s : string ; s2 : string) : boolean;

                class function getCPUPower : string;

                class function getToken( sourceString : string ; t : char ; var token : string ): boolean;// is end token??? return value token
                class function getLeftString : string;
                //class function getTokenAndModString( sourceString : string ; t : char ; var token : string ; var modString : string ): boolean;// is end token??? return value token
                class function convertByteToString( var b : array of byte ; byteLen : integer ) : string;
                class function convertStringToByte( s : string ; var b : array of byte ) : integer;

                class function convertInt64ToString( value : int64 ) : string;
                class function convertStringToInt64( value : string ) : int64;

                class function getTodayDateTime : string;

                class function strToBoolean( s : string ) : boolean;
                class function booleanTostr( b : boolean ) : string;

                class function getMyIPinTIdTCPClient( clientSocket : TIdTCPClient ) : string;
                class function getRemoteIPinTIdTCPClient( clientSocket : TIdTCPClient ) : string;

                class function getMyIPinTIdPeerThread( AThread: TIdPeerThread ) : string;
                class function getRemoteIPinTIdPeerThread( AThread: TIdPeerThread ) : string;

                class function getFileSize( filename : string ) : integer;

                class function makeLong ( low : longword ; hi : longword ) : int64;
                class procedure makeTwoInteger( v : int64 ; var low : integer ; var hi : integer );
        end;



implementation

procedure indyConsoleUDPMessageClass.write( ip : string ; port : integer ; msg : string );
begin
        udpServerSocket.Binding.SendTo( ip , port , msg[1] , length(msg));
end;

procedure indyConsoleUDPMessageClass.writeMessage( ip : string ; port : integer ; msgTitle : string ; msgBody : string );
var
        s : string;
begin
        s := udpServerSocket.LocalName + ':' + msgTitle + ':' + msgBody;
        write( ip , port , s );
end;

procedure indyConsoleUDPMessageClass.writeAllMessage(port : integer ; msgTitle : string ; msgBody : string );
var
        s : string;
begin
        s := udpServerSocket.LocalName + ':' + msgTitle + ':' + msgBody;
        write( '255.255.255.255' , port , s );
end;

procedure indyConsoleUDPMessageClass.start;
begin
        udpServerSocket.Active := true;
end;

constructor indyConsoleUDPMessageClass.Create( port : integer ; isbroadcast : boolean );
begin
        udpServerSocket := TIdUDPServer.Create(nil);
        udpServerSocket.DefaultPort := port;
        udpServerSocket.BroadcastEnabled := isbroadcast;
        udpServerSocket.ThreadedEvent := true;
        udpServerSocket.OnUDPRead := read;
end;

procedure indyConsoleUDPMessageClass.read( Sender : TObject ; AData : TStream ; ABinding : TIdSocketHandle );
var
        DataStringStream : TStringStream;
        senderName : string;
        title : string;
        body : string;
begin
        DataStringStream := nil;

        try
                DataStringStream := TStringStream.Create('');
                DataStringStream.CopyFrom(AData, AData.Size );

                utilClass.getToken( DataStringStream.DataString , ':' , senderName );
                utilClass.getToken( '' , ':' , title );
                utilClass.getToken( '' , ':' , body );

                getMessage( ABinding.PeerIP , ABinding.PeerPort , senderName , title , body );
        finally
                DataStringStream.Free;
        end;
end;

procedure indyConsoleUDPMessageClass.idle;
begin
        while true do;
end;

class function utilClass.getCPUPower : string;
var
        i : integer;
        k : int64;
        DateTime1, DateTime2 : TDateTime;
        maxValue : double;
        s : string;
begin

        DateTime1 := Time;
        k:=0;
        for i:=0 to 10000000 do k := k + i;
        DateTime2 := Time;

        maxValue := 10.0;
        s := format( '%g', [maxValue-(datetime2-datetime1)] );
        s := getFixedStringRightOrder( s , 20 , '0' );
        result := s;
end;

constructor nameAndValueClass.Create;
begin
        self.index := 0;
end;

procedure nameAndValueClass.appendFieldIntegervalue( fieldName : string ; Integervalue : integer );
begin
        name[ index ] := fieldName;
        self.Integervalue[ index ] := Integervalue;

        inc( index );
end;

procedure nameAndValueClass.appendFieldInt64value( fieldName : string ; Int64value : int64 );
begin
        name[ index ] := fieldName;
        self.int64value[ index ] := Int64value;

        inc( index );
end;

function nameAndValueClass.getFieldIndex( fieldName : string ) : integer;
var
        i : integer;
begin
        for i:=0 to index - 1 do
        begin
                if name[ i ] = fieldName then
                begin
                        result := i;
                        exit;
                end;
        end;

        result:= -1;
end;

function nameAndValueClass.getFieldIntegervalue( fieldIndex : integer ) : integer;
begin
        result := Integervalue[ fieldIndex ];
end;

function nameAndValueClass.getFieldint64value( fieldIndex : integer ) : int64;
begin
        result := int64value[ fieldIndex ];
end;

procedure nameAndValueClass.setFieldIntegervalue( fieldIndex : integer ; Integervalue : integer );
begin
        self.Integervalue[ fieldIndex ] := Integervalue;
end;

procedure nameAndValueClass.setFieldInt64value( fieldIndex : integer ; Int64value : int64 );
begin
        self.Int64value[ fieldIndex ] := Int64value;
end;

procedure stackClass.push( value : integer );
begin
        self.buffer[ self.statckOffset ] := value;
        inc( self.statckOffset );
end;

function stackClass.pop : integer;
begin
        dec( self.statckOffset );

        result := self.buffer[ self.statckOffset ];
end;

constructor stackClass.Create;
begin
        statckOffset := 0;
end;

procedure stackClass.coreDumpBy;
begin
        self.coreDump;
        write('Please any key');
        readln;
end;

procedure stackClass.coreDump;
var
        i : integer;
begin
        Writeln( '-stack coreDump' );
        for i:=0 to self.statckOffset - 1 do
        begin
                Writeln( format( 'index : %d  value : %d' , [i,self.buffer[i]] ));
        end;
        Writeln;
end;

class function utilClass.bitSwitchU2( i : word ) : word;
begin
        result := ( i shl 8 ) or ( i shr 8 );
end;


class function utilClass.bitSwitchU4( i : integer ) : integer;
var
        hi,low : word;
begin
        hi := bitSwitchU2( word(i shr 16) );
        low := bitSwitchU2( word(i) );
        result :=  ( integer( low shl 16 ) or integer(hi) );
end;

class function utilClass.bitSwitchU8( i : int64 ) : int64;
var
        hi,low : longword;
//        long1 : int64;
//        long2 : int64;
        long3 : int64;
begin
        low := bitSwitchU4( integer(i shr 32) );
        hi := bitSwitchU4( integer(i) );

        {$ifdef DEBUG}
        write('DEBUG:');
        write( format('bitSwitchU4( integer(i shr 32) ) : %x',[hi]) );
        write( '    ' );
        writeln( format('bitSwitchU4( integer(i) ) : %x',[low]) );
        {$endif}

//        long1 := int64(hi);
//        long2 := int64(low);
        long3 := utilClass.makeLong(low, hi);

        {$ifdef DEBUG}
        write('DEBUG:');
        write('long3 : ' );
        write( long3 );
        write( '    ' );
        writeln( format('hexa : %x',[long3]) );
        {$endif}

        result :=  long3;
end;


class function utilClass.getFixedStringLeftOrder( s : string ; totalLength : integer ; c : string ) : string;
var
a : integer;
r : array[0..100] of char;
p : pchar;
x : String;
i : integer;

begin
        p := @r;
        strpcopy( p , s );
        a := strlen( p );

        x := '';

        for i := 1 to totalLength - a do
        begin
                x := x + c;
        end;

        x := x + s;

        result := x;
end;

class function utilClass.getFixedStringRightOrder( s : string ; totalLength : integer ; c : string ) : string;
var
a : integer;
r : array[0..100] of char;
p : pchar;
x : String;
i : integer;

begin
        p := @r;
        strpcopy( p , s );
        a := strlen( p );

        x := s;

        for i := 1 to totalLength - a do
        begin
                x := x + c;
        end;

        result := x;
end;

class function utilClass.changeCharbyChar( s : string ; c1 : char ; c2 : char ) : string;
var
a : integer;
r : array[0..100] of char;
p : pchar;
i : integer;
x : string;

begin
        p := @r;
        strpcopy( p , s );
        a := strlen( p );

        x := '';

        for i := 0 to a - 1 do
        begin
                if r[i] = c1 then
                        x := x + c2
                else
                        x := x + r[i];
        end;

        result := x;
end;


class function utilClass.fileReadU2LittenEndan( fileHandler : integer ) : word;
var
        u2 : word;
begin
        FileRead( fileHandler, u2 , 2 );
        result := bitSwitchU2( u2 );
end;

class function utilClass.fileReadU4LittenEndan( fileHandler : integer ) : integer;
var
        u4 : integer;
begin
        FileRead( fileHandler, u4 , 4 );

        {$ifdef DEBUG}
        write('DEBUG:');
        writeln( format('FileRead( fileHandler, u4 , 4 ) : %x',[u4]) );
        {$endif}
        result := bitSwitchU4( u4 );
end;

class function utilClass.fileReadU8LittenEndan( fileHandler : integer ) : int64;
var
        u8 : int64;
begin
        FileRead( fileHandler, u8 , 8 );

        {$ifdef DEBUG}
        write('DEBUG:');              
        write( format('FileRead( fileHandler, u8 , 8 ) : %x',[u8]) );
        write( '    ' );
        write( 'int64 value : ' );
        writeln( u8 );        
        {$endif}
        result := bitSwitchU8( u8 );
end;

class function utilClass.makeU2withHiByteAndLowByte( hibyte : byte ; lowbyte : byte ) : word;
begin
        result := ( (word(hibyte)) shl 8 ) or ( (word(lowbyte)) );
end;

class function utilClass.compStringIntoS2( s : string ; s2 : string) : boolean;
var

l : integer;
l2 : integer;

r : array[0..100] of char;
r2 : array[0..100] of char;

p : pchar;
p2 : pchar;

i : integer;
//i2 : integer;

b : boolean;
begin
        p := @r;
        strpcopy( p , s );
        l := strlen( p );

        p2 := @r2;
        strpcopy( p2 , s2 );
        l2 := strlen( p2 );

        b := true;

        while true do
        begin
                if l < l2 then
                        break;

                for i := 0 to l2 - 1 do
                begin
                        if r[i] <> r2[i] then
                        begin
                                b:=false;
                                break;
                        end;
                end;

                break;
        end;

        result := b;
end;


class function utilClass.byte2integer( b : byte ) : integer;
begin
        if b <= 127 then
                result := b
        else
                result := $ffffff00 or b;
end;

class function utilClass.word2integer( w : word ) : integer;
begin

        if w <= 32767 then
                result := w
        else
                result := $ffff0000 or w;


end;


var
saveString : string;
stringLength : integer;
stringPointer : integer;
class function utilClass.getToken( sourceString : string ; t : char ; var token : string ): boolean;// is end token??? return value token
var
        returnValue : boolean;
begin
        if sourceString <> '' then
        begin
                saveString := sourceString;
                stringLength := length( sourceString );
                stringPointer := 1;
        end;

        token := '';
        returnValue := false;
        while true do
        begin
                if stringPointer > stringLength then
                begin
                        returnValue := true;
                        break;
                end;

                if saveString[stringPointer] = t then
                begin
                        inc(stringPointer);
                        break;
                end;

                token := token + saveString[stringPointer];
                inc(stringPointer);
        end;

        result := returnValue;
end;

class function utilclass.getLeftString : string;
var
        s : string;
begin
        s := '';

        while true do
        begin
                if stringPointer > stringLength then break;

                s := s + saveString[stringPointer];
                inc(stringPointer);
        end;

        result := s;
end;

{class function utilClass.getTokenAndModString( sourceString : string ; t : char ; var token : string ; var modString : string ): boolean;// is end token??? return value token
var
        isFind : boolean;
        len : integer;
        i : integer;
begin
        token := '';
        modstring := '';
        isFind := false;
        len := length( sourceString );

        for i:= 1 to len do
        begin
                if isFind = false then
                begin
                        if sourceString[i] = t then
                        begin
                                isFind := true;
                                continue;
                        end;

                        token := token + sourceString[i];
                end
                else
                begin
                        modString := modString + sourceString[i];
                end;
        end;

        result := isFind;
end;}

constructor indyConsoleTcpClientClass.Create( host : string ; port : integer );
begin
        tcpClientSocket := TidTCPClient.Create(nil);
        tcpClientSocket.Host := host;
        tcpClientSocket.Port := port;
        tcpClientSocket.Connect;
end;

procedure indyConsoleTcpClientClass.writeMessage( msg : string );
var
        s : string;
        peerIp : string;
begin
        //writeln( title );    // 환장한다...  writeln(을 write로 변경하니 되지를 않는다......
        //write( ' -> ' ); //
        s := msg ;
        peerIP := utilclass.getRemoteIPinTIdTCPClient(self.tcpClientSocket );

        writeln( format('(%s) TCP write to %s : %s',[utilclass.getTodayDateTime,peerIP,s] ) );
        tcpClientSocket.WriteLn(s);
end;


function indyConsoleTcpClientClass.getMessage : string;
var
        s : string;
        peerIp : string;
begin
        s := tcpClientSocket.ReadLn;
        peerIP := utilclass.getRemoteIPinTIdTCPClient(self.tcpClientSocket );

        writeln( format('(%s) TCP get from %s : %s',[utilclass.getTodayDateTime,peerIP,s] ) );
        result := s;
end;

procedure indyConsoleTcpClientClass.close;
begin
        tcpClientSocket.Disconnect;
end;


constructor indyConsoleTcpServerClass.Create( port : integer);
begin
        // 디폴트 메서드
        tcpServerSocket := TIdTCPServer.Create(nil);
        tcpServerSocket.DefaultPort := port;
        tcpServerSocket.OnConnect := doConnect;
        tcpServerSocket.OnExecute := doExecute;
        tcpServerSocket.OnDisconnect := doDisconnect;
end;

procedure indyConsoleTcpServerClass.active;
begin
        tcpServerSocket.Active := true;
end;

procedure indyConsoleTcpServerClass.doConnect(AThread: TIdPeerThread);
begin
        getConnect();
end;

procedure indyConsoleTcpServerClass.doExecute(AThread: TIdPeerThread);
var
        msg : string;
        isWrite : boolean;
begin
        msg := AThread.Connection.ReadLn();

//        writeln( format('TCP get : %s',[msg] ) );

        isWrite := false;

        getMessage( msg , isWrite );

        if isWrite = true then
        begin
//                writeln( format('TCP write : %s',[msg] ) );
                AThread.Connection.WriteLn( msg );
        end;
end;

procedure indyConsoleTcpServerClass.doDisconnect(AThread: TIdPeerThread);
begin
        getDisconnect();
end;

procedure indyConsoleTcpServerClass.idle;
begin
        while true do;
end;

constructor configClass.Create( configFile : string );
begin
        self.configFile := configFile;
  IniFile := TIniFile.Create(configFile);
end;

function configClass.getValue( section : string ; field : string ; defaultString : string ) : string;
begin
    result := IniFile.ReadString(section, field, defaultString);
end;

procedure configClass.setValue( section : string ; field : string ; value : string );
begin
        IniFile.WriteString(section , field , value);
end;

constructor charArrayInstanceClass.Create( size : integer );
begin
        setlength( self.data ,size );
        self.size := size;
end;

constructor charArrayInstanceClass.Create( data : pchar ; size : integer );
var
        i : integer;
begin
        self.Create(size);

        // 델파이의 강력한 버그인것 같다 애래의 코드를 집어넣으면 i를 먼저 비교하기 때문에
        // for 루프를 수행하지 않고 빠져 나간다.
        //i:=0; // why 'variable 'i'might not have been initialized  Message????
        // 아니다 for i:=0 to i - 1을 해서 바져 나간것이다.
        // 어이가 없다.

        for i:=0 to size - 1 do
        begin
                self.data[i] := data[i];
        end;

end;

constructor byteArrayInstanceClass.Create( var data : array of byte ; size : integer );
var
        i : integer;
begin
        self.Create(size);

        //i:=0; // why 'variable 'i'might not have been initialized  Message????

        for i:=0 to size - 1 do
        begin
                self.data[i] := data[i];
        end;
end;

procedure newInstanceClass.appendHecheriClass( loadedClassIndex : integer );
begin
        classHecheriIndexByLoadedClassIndex[ classHecheriIndex ] := loadedClassIndex;
        inc( classHecheriIndex );
end;

constructor intArrayInstanceClass.Create( size : integer );
begin
        self.size := size;
        setlength( self.data , size );
end;

constructor intArrayInstanceClass.Create( data : array of integer ; size : integer );
var
        i : integer;
begin
        self.Create(size);

        for i:=0 to size - 1 do
        begin
                self.data[i] := data[i];
        end;        
end;

constructor longArrayInstanceClass.Create( size : integer );
begin
        self.size := size;
        setlength( self.data , size );
end;

constructor longArrayInstanceClass.Create( data : array of int64 ; size : integer );
var
        i : integer;
begin
        self.Create(size);

        for i:=0 to size - 1 do
        begin
                self.data[i] := data[i];
        end;        
end;

constructor byteArrayInstanceClass.Create( size : integer );
begin
        setlength( self.data ,size );
        self.size := size;
end;



class function utilClass.convertByteToString( var b : array of byte ; byteLen : integer ) : string;
var
        by : byte;
        i : integer;
        s : string;
begin
        s := '';

        for i := 0 to bytelen - 1 do
        begin
                by := b[i];
                by := by and $f0;

                case by of
                $00 : s := s + '0';
                $10 : s := s + '1';
                $20 : s := s + '2';
                $30 : s := s + '3';
                $40 : s := s + '4';
                $50 : s := s + '5';
                $60 : s := s + '6';
                $70 : s := s + '7';
                $80 : s := s + '8';
                $90 : s := s + '9';
                $a0 : s := s + 'a';
                $b0 : s := s + 'b';
                $c0 : s := s + 'c';
                $d0 : s := s + 'd';
                $e0 : s := s + 'e';
                $f0 : s := s + 'f';
                end;

                by := b[i];
                by := by and $0f;

                case by of
                $00 : s := s + '0';
                $01 : s := s + '1';
                $02 : s := s + '2';
                $03 : s := s + '3';
                $04 : s := s + '4';
                $05 : s := s + '5';
                $06 : s := s + '6';
                $07 : s := s + '7';
                $08 : s := s + '8';
                $09 : s := s + '9';
                $0a : s := s + 'a';
                $0b : s := s + 'b';
                $0c : s := s + 'c';
                $0d : s := s + 'd';
                $0e : s := s + 'e';
                $0f : s := s + 'f';
                end;

        end;

        result := s;
end;

class function utilClass.convertStringToByte( s : string ; var b : array of byte ) : integer;
var
        strLen : integer;
        strIndex : integer;
        byteIndex : integer;
        by : byte;
begin

        strLen := length( s );
        strIndex := 1;
        byteIndex := 0;
        by := $00;

        while true do
        begin
                case s[strIndex] of
                '0' : by := $00;
                '1' : by := $10;
                '2' : by := $20;
                '3' : by := $30;
                '4' : by := $40;
                '5' : by := $50;
                '6' : by := $60;
                '7' : by := $70;
                '8' : by := $80;
                '9' : by := $90;
                'a' : by := $a0;
                'b' : by := $b0;
                'c' : by := $c0;
                'd' : by := $d0;
                'e' : by := $e0;
                'f' : by := $f0;
                end;
                inc(strIndex);

                case s[strIndex] of
                '0' : by := by or $00;
                '1' : by := by or $01;
                '2' : by := by or $02;
                '3' : by := by or $03;
                '4' : by := by or $04;
                '5' : by := by or $05;
                '6' : by := by or $06;
                '7' : by := by or $07;
                '8' : by := by or $08;
                '9' : by := by or $09;
                'a' : by := by or $0a;
                'b' : by := by or $0b;
                'c' : by := by or $0c;
                'd' : by := by or $0d;
                'e' : by := by or $0e;
                'f' : by := by or $0f;
                end;

                b[byteIndex] := by;
                inc(byteIndex);

                if strIndex = strLen then break;

                inc(strIndex);
        end;


        result := byteIndex;
end;


class function arrayInstanceClass.getClassData( arrayInstance : arrayInstanceClass) : string;
var
        classdata : string;
begin

        classdata := inttostr( arrayInstance.arrayType ) + '~';

        case arrayInstance.arrayType of
        T_CHAR: classData := classData + charArrayInstanceClass.getClassData(
                (arrayInstance.arrayObject as charArrayInstanceClass) );

        T_BYTE: classData := classData + byteArrayInstanceClass.getClassData(
                (arrayInstance.arrayObject as byteArrayInstanceClass) );

        T_INT: classData := classData + intArrayInstanceClass.getClassData(
                (arrayInstance.arrayObject as intArrayInstanceClass) );

        T_LONG: classData := classData + longArrayInstanceClass.getClassData(
                (arrayInstance.arrayObject as longArrayInstanceClass) );
        end;

        result := classData;
end;

class function arrayInstanceClass.setClassData( data : string ): arrayInstanceClass;
var
        arrayInstance : arrayInstanceClass;
        arrayType : string;
        otherData : string;
begin
        utilClass.getToken( data , '~' , arrayType );
        utilClass.getToken( '' , '~' , otherData );

        arrayInstance := arrayInstanceClass.Create;
        arrayInstance.arrayType := byte(strtoint( arrayType ));

        case arrayInstance.arrayType of
        T_CHAR: arrayInstance.arrayObject := charArrayInstanceClass.setClassData(otherdata);

        T_BYTE: arrayInstance.arrayObject := byteArrayInstanceClass.setClassData(otherdata);

        T_INT: arrayInstance.arrayObject := intArrayInstanceClass.setClassData(otherdata);

        T_LONG: arrayInstance.arrayObject := longArrayInstanceClass.setClassData(otherdata);

        end;

        result := arrayInstance;
end;


class function byteArrayInstanceClass.getClassData( byteArrayInstance : byteArrayInstanceClass ) : string;
var
        s : string;
begin
        s := inttostr( byteArrayInstance.size ) +
                '!' + utilclass.convertByteToString( byteArrayInstance.data , byteArrayInstance.size );
        result := s;
end;

class function byteArrayInstanceClass.setClassData( data : string ): byteArrayInstanceClass ;
var
        size : string;
        bytedata : string;
        byteArrayInstance : byteArrayInstanceClass;
        ba : array of byte;
begin
        utilClass.getToken(data,'!',size);
        utilClass.getToken('','!',bytedata);

        setlength( ba , strtoint( size ) );
        utilClass.convertStringToByte( bytedata , ba );

        byteArrayInstance := byteArrayInstanceClass.Create( ba , strtoint( size ) );

        result := byteArrayInstance;
end;

class function charArrayInstanceClass.getClassData( charArrayInstance : charArrayInstanceClass) : string;
var
        s : string;
        i : integer;
begin
        s := inttostr( charArrayInstance.size ) + '!';

        for i:=0 to charArrayInstance.size - 1 do s := s + charArrayInstance.data[i];

        {$ifdef DEBUG}
        write( 'DEBUG:charArrayInstanceClass.getClassData : ' );
        writeln( s );
        writeln( 'please any key to continue' );
        {$endif}
        result := s;
end;

class function charArrayInstanceClass.setClassData( data : string ) : charArrayInstanceClass;
var
        size : string;
        chardata : string;
        charArrayInstance : charArrayInstanceClass;
begin
        utilClass.getToken(data,'!',size);
        utilClass.getToken('','!',chardata);


        {$ifdef DEBUG}
        write( 'DEBUG:' );
        writeln( format('charArrayInstanceClass.setClassData : %s,%s',[chardata,size]) );
        {$endif}


        charArrayInstance := charArrayInstanceClass.Create( @chardata[1] , strtoint( size ) );

        result := charArrayInstance;
end;

class function intArrayInstanceClass.getClassData( intArrayInstance : intArrayInstanceClass) : string;
var
        s : string;
        i : integer;
begin
        s := inttostr( intArrayInstance.size );

        for i:=0 to intArrayInstance.size - 1 do s := s + '!' + inttostr(intArrayInstance.data[i]);

        result := s;
end;

class function intArrayInstanceClass.setClassData( data : string ): intArrayInstanceClass;
var
        ai : array of integer;
        size : string;
        intdata : string;
        intArrayInstance : intArrayInstanceClass;
        isize : integer;
        i : integer;
begin
        utilClass.getToken(data,'!',size);
        isize := strtoint( size );

        setlength( ai , isize );

        for i:=0 to isize - 1 do
        begin
                utilClass.getToken('','!',intdata);
                ai[i] := strtoint( intdata );
        end;

        intArrayInstance := intArrayInstanceClass.Create( ai , isize );

        result := intArrayInstance;
end;

class function longArrayInstanceClass.getClassData( longArrayInstance : longArrayInstanceClass) : string;
var
        s : string;
        i : integer;
begin
        s := inttostr( longArrayInstance.size );

        for i:=0 to longArrayInstance.size - 1 do s := s + '!' + utilclass.convertInt64ToString(longArrayInstance.data[i]);

        result := s;
end;

class function longArrayInstanceClass.setClassData( data : string ) : longArrayInstanceClass;
var
        ai : array of int64;
        size : string;
        int64data : string;
        longArrayInstance : longArrayInstanceClass;
        isize : int64;
        i : integer;
begin
        utilClass.getToken(data,'!',size);
        isize := strtoint( size );

        setlength( ai , isize );

        for i:=0 to isize - 1 do
        begin
                utilClass.getToken('','!',int64data);
                ai[i] := utilclass.convertStringToInt64( int64data );
        end;

        longArrayInstance := longArrayInstanceClass.Create( ai , isize );

        result := longArrayInstance;
end;

class function utilclass.convertInt64ToString( value : int64 ) : string;
{
var
        ab : array of byte;
begin
        ab := @value;

        result := utilClass.convertByteToString( ab , 4 );
end;
}
begin
        result := format('%d',[value]);
end;

class function utilclass.convertStringToInt64( value : string ) : int64;
{
var
        i : int64;
        ab : array of byte;
begin
        i := 0;
        ab := @i;

        utilclass.convertStringToByte( value , ab );
        
        result := i;
end;
}
{
var
        a : integer;
        i : int64;
        j : int64;
        ab : array[0..7] of byte;
begin
        utilclass.convertStringToByte( value , ab );

        i := 0;
        for a := 0 to 7 do
        begin
                j := int64(ab[a]);
                j := j shl a*8;
                i := i or j;
        end;
        result := i;
end;
}
begin
        result := strtoint64( value );
end;

class function utilclass.getTodayDateTime : string;
begin
        result := FormatDateTime('yyyy-mm-dd-hh-nn-ss', Now );
end;

class function stackClass.getClassData( st : stackClass ) : string;
var
        i : integer;
        s : string;
begin
        s := inttostr( st.statckOffset );

        for i:=0 to st.statckOffset - 1 do s := s + '@' + inttostr(st.buffer[i]);

        result := s;
end;

class function stackClass.setClassData( s : string ) : stackClass;
var
        i : integer;
        d : string;
        st : stackClass;
begin
        st := stackClass.Create;

        utilClass.getToken(s , '@' , d );
        st.statckOffset := strtoint( d );

        i := 0;
        while true do
        begin
                utilClass.getToken('' , '@' , d );

                if d = '' then break;

                st.buffer[i] := strtoint( d );
                inc(i);
        end;

        result := st;
end;

class function utilClass.strToBoolean( s : string ) : boolean;
begin
        if s = 'true' then
                result := true
        else
                result := false;
end;

class function utilclass.booleanTostr( b : boolean ) : string;
begin
        if b = true then
                result := 'true'
        else
                result := 'false';
end;

class function utilclass.getMyIPinTIdTCPClient( clientSocket : TIdTCPClient ) : string;
begin
        {$ifdef WIN32}
                result := clientsocket.Binding.IP;
        {$else}
                result := clientSocket.Socket.Binding.IP;
        {$endif}
end;

class function utilclass.getRemoteIPinTIdTCPClient( clientSocket : TIdTCPClient ) : string;
begin
        {$ifdef WIN32}
                result := clientsocket.Binding.PeerIP;
        {$else}
                result := clientSocket.Socket.Binding.PeerIP;
        {$endif}
end;

class function utilclass.getMyIPinTIdPeerThread( AThread: TIdPeerThread ) : string;
begin
        {$ifdef WIN32}
                result := AThread.Connection.Binding.IP;
        {$else}
                result := AThread.Connection.Socket.Binding.IP;
        {$endif}
end;

class function utilclass.getRemoteIPinTIdPeerThread( AThread: TIdPeerThread ) : string;
begin
        {$ifdef WIN32}
                result := AThread.Connection.Binding.PeerIP;
        {$else}
                result := AThread.Connection.Socket.Binding.PeerIP;
        {$endif}
end;

class function utilClass.getFileSize( filename : string ) : integer;
var
        f : file of byte;
begin
        assignfile( f , filename );
        reset( f );
        result := filesize( f );
end;

class function utilclass.makeLong ( low : longword ; hi : longword ) : int64;
begin
        {$ifdef DEBUG}
        writeln( format( 'DEGUG:utilclass.makeLong:low : %x  hi : %x',[low,hi] ) );
        {$endif}
        result := int64(low) or (int64(hi) shl 32);
end;

class procedure utilClass.makeTwoInteger( v : int64 ; var low : integer ; var hi : integer );
var
        long1 : int64;
        long2 : int64;
begin
        long1 := v and $00000000ffffffff; // low
        long2 := v and $ffffffff00000000; // hi
        long2 := long2 shr 32;

        hi := integer(longword( long2 ));
        low := integer(longword( long1 ));
end;


end.
