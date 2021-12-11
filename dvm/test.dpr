program test;

{$APPTYPE CONSOLE}

uses

  testUnit in 'testUnit.pas';

var

        m : indyConsoleUDPMessageClass;
        a,b : string;
begin

        a := '9.990';
        b := '09.990';

        if a > b then writeln( 'a' );

        readln;


        m := indyConsoleUDPMessageClass.Create(9000,true);
        m.start;
        writeln( 'server stated' );
        m.idle;

end.
