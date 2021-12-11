unit testUnit;

interface

uses
  sysutils,
  IdUDPServer,
  IDSockethandle,
  Classes,
  IdTCPConnection,
  IdTCPServer,
  IdTCPClient,
  IniFiles;

type
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

implementation

procedure indyConsoleUDPMessageClass.writeMessage( ip : string ; port : integer ; msgTitle : string ; msgBody : string );
var
        s : string;
begin
        s := udpServerSocket.LocalName + ':' + msgTitle + ':' + msgBody;
        write( ip , port , s );
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

//                utilClass.getToken( DataStringStream.DataString , ':' , senderName );
//                utilClass.getToken( '' , ':' , title );
  //            utilClass.getToken( '' , ':' , body );

                getMessage( ABinding.PeerIP , ABinding.PeerPort , senderName , title , body );
        finally
                DataStringStream.Free;
        end;
end;

procedure indyConsoleUDPMessageClass.write( ip : string ; port : integer ; msg : string );
begin
        udpServerSocket.Binding.SendTo( ip , port , msg[1] , length(msg));
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

procedure indyConsoleUDPMessageClass.idle;
begin
        while true do;
end;

procedure indyConsoleUDPMessageClass.writeAllMessage(port : integer ; msgTitle : string ; msgBody : string );
var
        s : string;
begin
        s := udpServerSocket.LocalName + ':' + msgTitle + ':' + msgBody;
        write( '255.255.255.255' , port , s );
end;

end.
