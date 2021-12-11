unit dvmUtil;

interface

uses sysutils;

function bitSwitchInteger( i : word ) : word;
function bitSwitchLong( i : longint ) : longint;
function getFixedStringLeftOrder( s : string ; totalLength : integer ; c : string ) : string;
function getFixedStringRightOrder( s : string ; totalLength : integer ; c : string ) : string;

function fileReadWordLittenEndan( fileHandler : integer ) : word;
function fileReadLongIntLittenEndan( fileHandler : integer ) : longint;

function makeWordLittenEndanWidhTwoByte( c1 : byte ; c2 : byte ) : word;
procedure z();


implementation

function bitSwitchInteger( i : word ) : word;
{
var
        j : integer;
begin
        j := 0;

        j := ( i and 0x00ff ) shl 8;
        j := j or ( ( i and 0xff00 ) shr 8 );

        result := j;
end;
}
begin
        result := ( i shl 8 ) or ( i shr 8 );
end;


function bitSwitchLong( i : longint ) : longint;
var
        hi,low : word;
begin
        hi := bitSwitchInteger( word(i shr 16) );
        low := bitSwitchInteger( word(i) );
        result :=  ( longint( low shl 16 ) or longint(hi) );
end;


function getFixedStringLeftOrder( s : string ; totalLength : integer ; c : string ) : string;
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

function getFixedStringRightOrder( s : string ; totalLength : integer ; c : string ) : string;
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

function fileReadWordLittenEndan( fileHandler : integer ) : word;
var
        u2 : integer;
begin
        FileRead( fileHandler, u2 , 2 );
        result := bitSwitchInteger( u2 );
end;

function fileReadLongIntLittenEndan( fileHandler : integer ) : longint;
var
        u4 : longint;
begin
        FileRead( fileHandler, u4 , 4 );
        //writeln( format('-----> %x',[u4]) );
        result := bitSwitchLong( u4 );
end;

function makeWordLittenEndanWidhTwoByte( c1 : byte ; c2 : byte ) : word;
begin
        result := ( (word(c1)) shl 8 ) or ( (word(c2)) );
end;

procedure z();
begin
        writeln('*****************');
end;


end.
