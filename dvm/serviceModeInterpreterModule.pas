unit serviceModeInterpreterModule;

interface

uses
        sysutils, Classes , classLoaderModule, //serviceModeRuntimeEnvironmentModule, ,
        componentModule,globalDefine;

type
        interpreterClass = class(TThread)
        protected
                host : string;
                port : integer;
                this : integer;
                DPMResquester : indyConsoleTcpClientClass;

                 // 인터프리터의 코드를 변경하지 않기 위해 runtimeenv에 있는 classLoader와 관련된 것들을 위해...
                ca : codeAttribute;

                // classLoader 관ㄹ녀
                cl : classLoaderClass;

                stack : stackClass;

                name : string;
                coredumpflag : boolean;

                f : textfile ;
        protected
                procedure Execute; override;

        protected
                // 종료시 필요한 것들.
                // 종료 클래스와 메소드 index
                // 인터럽트 시작시에 설정된다.
                exitClassIndex : integer;
                exitMethodIndex : integer;

                // 실행시 필요한 것들.
                // 다른 메서드를 참조할때 마다 설정
                // classLoader의 배열인덱스 이다
                loadedClassIndex : integer;
                // methods의 배열인덱스 이다.
                methodIndex : integer;
                // 해당 methods의 offset이다.
                codeOffset : integer;
                // 스택에서의 offset이다.
                variableOffset : integer;
                // 코드 저장
                codeAttr : codeAttribute;
        public
                procedure run;

                constructor Create( host : string ; port : integer ; name : string ; this : integer ; coredumpFlag : boolean );
                destructor Destroy;
                procedure coreDump;
                procedure coreDumpPleaseAnyKey;

                procedure dumpWrite( s : string ); overload;
                procedure dumpWrite( c : char ); overload;
                procedure dumpWriteln( s : string ); overload;
                procedure dumpWriteln; overload;



                //////////// import from runtimeEnvironment
        private
                // 파일 관련
                //private function getfileIOStream() : integer; public // with fileIOStreamIndex

                // 배열 관련
                function appendArray( var arrayInst : arrayInstanceClass ) : integer; // with array
                //private function getArray( index : integer ) : arrayInstanceclass; public
                // 추가된것
                function getArrayInstanceStructByIndexarrayType( index : integer ) : byte; // 배열 타입
                function getArrayByIndexintArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : integer;
                function getArrayByIndexlongArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : int64;
                function getArrayByIndexbyteArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : byte;
                function getArrayByIndexcharArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : char;

                procedure setArrayByIndexintArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : integer );
                procedure setArrayByIndexlongArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : int64 );
                procedure setArrayByIndexbyteArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : byte );
                procedure setArrayByIndexcharArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : char );

                function getArraySizeByIndexintArrayInstanceClassDataByIndex( index : integer  ) : integer;
                function getArraySizeByIndexlongArrayInstanceClassDataByIndex( index : integer  ) : integer;
                function getArraySizeByIndexbyteArrayInstanceClassDataByIndex( index : integer  ) : integer;
                function getArraySizeByIndexcharArrayInstanceClassDataByIndex( index : integer  ) : integer;

                // 클래스 관련
                procedure appendClassHecheri( newInstanceIndex : integer ; loadedClassIndex : integer ); // with newInstance
                function getNewInstance() : integer;
                procedure appendField( newInstanceIndex : integer ; fieldName : string ; fieldValue : integer );
                function getFieldIndex( newInstanceIndex : integer ; fieldName : string ) : integer;
                function getFieldValue( newInstanceIndex : integer ; fieldIndex : integer ) : integer;
                procedure setFieldValue( newInstanceIndex : integer ; fieldIndex : integer ; fieldValue : integer );
                function getOverridingMethodClassName(newInstanceIndex : integer ; methodName : string ) : string;
                // 추가 된것
                function getNewInstanceClassByIndexclassHecheriIndex( index : integer ) : integer;
                function getNewInstanceClassByIndexclassHecheriIndexByLoadedClassIndexByIndex( index1 : integer ; index2 : integer ) : integer;
                function getNewInstanceClassByIndexIndex( index : integer ) : integer;
                function getNewInstanceClassByIndexnameByIndex( index1 : integer ; index2 : integer ) : string;
                function getNewInstanceClassByIndexvalueByIndex( index1 : integer ; index2 : integer ) : integer;


                // classLoaderClass 관련
                procedure appendClass( className : string ); // with loadedclass
                function getLoadedClassIndex( name : string) : integer;
                function getLoadedClassName( index : integer ) : string;
                //function getLoadedClassObject( index : integer ) : classLoaderClass;

                // 인터럽트 관련
                procedure incInterpreterThreadCounter; // with InterpreterThreadCounter
                procedure decInterpreterThreadCounter;

                // 바이트 코드 관련
                // callMethod 메서드는 constant Pool에 접근하지 않는다
                // methods 자료에서만 이름을 가지고 참조를 수행한다
                // 주의 : 아래의 명령어를 바이트코드로 호출하는 것이아니라면 codeoffset 에서 3을 빼고 진행시켜야 한다
                procedure callInvokeSpecial( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                procedure callInvokeVirtual( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                procedure callInvokeStatic( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                //procedure callMethodType1( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                procedure callMethodType2( findLoadedClassIndex : integer ; findMethodIndex : integer; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                //procedure callMethodType3( findLoadedClassIndex : integer ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                //procedure callMethodType4( callClassName : string ; findMethodIndex : integer; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );

                procedure returnMethod( var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );

                procedure callNativeMethod( nativeClassName : string ; nativeMethodName : string ; var stack : stackClass ; isStatic : boolean ); // with native method call

                // 스태틱 필드 관련
                procedure appendStaticField( fieldName : string ; fieldValue : integer ); // with staticfield 클래스명필드명필드타입
                function getStaticFieldIndexByFieldName( fieldName : string ) : integer; // 필드이름으 찾는 인덱스 우치
                function getStaticFieldValue( fieldIndex : integer ) : integer; // 필드위치 인덱스로 찾는 값
                procedure setStaticFieldValue( fieldIndex : integer ; fieldValue : integer );
                // 추가 된것
                function getStaticFieldIndex : integer; // 전체 필드의 갯수
                function getStaticFieldnameByIndex( index : integer ) : string;
                function getStaticFieldvalueByIndex( index : integer ) : integer;


                // String 관련
                // String도 클래스이기 때문에 newInstandIndex가 인자로 들어 간다.
                //private procedure getStringByStringInstance( var s : string ; newInstanceIndex : integer ); public // s는 저장된 스트링

                // with constant pool
                // 여기서 사용되는 constantPoolIndex는 상수풀의 인덱스이다. 그것을 혼동하면 않된다.
                // 순수 문자열 리턴
                // 자바 클래스 파일은 자신이 호출하고 사용하는 모든 자원을 상수 풀에 등록시켜 놓는다. 이것은 그것이 어디에 있는지를
                // 가리키는 화살표와 같다. 그런다음 실제 메소드및 필드를 methods와 fiels에서 찾는다.
                // 왜냐하면 바이트코드에서는 실제 이름을 가리키지 않고 상수폴에 있는 인덱스를 가리키기 때문이다.
                // 따라서 자신의 메소드를 참조하는 메소드도 이와 같은 과정을 거쳐야 한다.
                //private function getUTF8Name( loadedClassIndex : integer ; constantPoolIndex : integer ) : string; public                  // 상수 풀에서 정의된는 내용은 다른 클래스와 메서드 정수 , 큰정수(long), 문자열, 등등이다
                //private function getClassInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ) : string; public                  // 클래스 ID 검색 해서 클래스 이름 리턴
                //private function getNameAndTypeName( loadedClassIndex : integer ; constantPoolIndex : integer) : string; public                 // 이름과 타입
                procedure getMethodRefInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ; var className : string ; var nameAndType : string ) ;                 //getClassInfoName, getNameAndTypeName를 차례로 호출하여 얻음
                procedure getFieldRefInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ; var className : string ; var nameAndType : string ) ;                 //getClassInfoName, getNameAndTypeName를 차례로 호출하여 얻음
                // 추가 된것... classLoaderclass 객체를 전송하지 않기 위해서....
                function getConstantPoolTagByIndex( loadedClassIndex : integer ; index : integer ) : byte;
                function getConstantPoolconstantIntegerBytesByIndex( loadedClassIndex : integer ; index : integer ) : integer;
                function getConstantPoolconstantStringstringIndexByIndex( loadedClassIndex : integer ; index : integer ) : integer;
                function getConstantPoolconstantUTF8InfolengthByIndex( loadedClassIndex : integer ; index : integer ) : integer;
                function getConstantPoolconstantUTF8InfoBytesByIndex( loadedClassIndex : integer ; index : integer ) : pchar;
                function getConstantPoolconstantLongbytesByIndex( loadedClassIndex : integer ; index : integer ) : int64;
                function getAccessFlagLoadedClassByIndexMethodsByIndex( index1 : integer ; index2 : integer ) : word;

                // with methods
                // 아래에 있는 것은 클래스에 실제 존재하는 메서드들을 정의한 methods 자료형에서
                // 검색을 한다.

                //{ boot loader 에서 사용 } function getMethodsIndexWithAccessFlag( loadedClassIndex : integer ; accessFlag : integer ; name : string ) : integer;
                function getMethodsIndex( loadedClassIndex : integer ; name : string ) : integer ;
                function getTotalLocalVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;
                function getMethodLocalVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;

                function getMethodArgsVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;
                function getMethodname( loadedClassIndex : integer ; methodsIndex : integer ) : string;
                function getCodeAttribute( loadedClassIndex : integer ; methodsIndex : integer) : codeAttribute;

                // runtimeEnvironment 변수 얻기
                function getInterpreterThreadCounter : integer;
                function getLoaderClassIndex : integer;
                //function getStaticField : nameAndValueClass;
                function getNewInstanceIndex : integer;
                //function getnewInstanceClass( index : integer) : newInstanceClass;
                function getArrayInstanceStructIndex : integer;
                //function getarrayInstanceStruct( index : integer) : arrayInstanceClass;

        end;

implementation

procedure interpreterClass.dumpWrite( s : string );
begin
        write( f , s );
end;

procedure interpreterClass.dumpWrite( c : char );
begin
        write( f , c );
end;

procedure interpreterClass.dumpWriteln( s : string );
begin
        writeln( f , s );
end;

procedure interpreterClass.dumpWriteln;
begin
        writeln( f , '' );
end;

procedure interpreterClass.coreDump;
var
        i,j : integer;
        s1 , s2 : string;
begin

        dumpWriteln( '-runtimeEnvironmentArea coreDump' );

        dumpWriteln( format('interpreterThreadCounter : %d',[self.getInterpreterThreadCounter] ) );
        dumpwriteln;

        dumpWriteln( '-loadedClass' );
        for i:=0 to self.getLoaderClassIndex - 1 do
        begin
                dumpWriteln( format('loadedClassIndex : %d  loadedClassName : %s',[i,self.getLoadedClassName(i)] ) );
        end;
        dumpwriteln;

        dumpWriteln( '-staticField' );
        for i:=0 to self.getStaticFieldIndex - 1 do
        begin
                dumpWriteln( format( 'staticFieldIndex : %d  loadedStaticFieldName : %s  loadedStaticFieldValue : %d',
                        [i,self.getStaticFieldnameByIndex(i) ,self.getStaticFieldvalueByIndex(i)] ) );
        end;
        dumpwriteln;

        dumpWriteln( '-newInstanceArea' );
        for i:=0 to self.getNewInstanceIndex - 1 do
        begin
                dumpWriteln( format('newInstanceIndex : %d', [i] ) );
                dumpWriteln( 'classHecheri' );
                for j:=0 to self.getNewInstanceClassByIndexclassHecheriIndex(i)  - 1 do
                begin
                        dumpWriteln( format( 'Index : %d' , [self.getNewInstanceClassByIndexclassHecheriIndexByLoadedClassIndexByIndex(i,j)] ) );
                end;

                dumpWriteln( 'Field' );
                for j:=0 to self.getNewInstanceClassByIndexIndex(i) - 1 do
                begin
                        dumpWriteln( format( 'Index : %d  Name : %s  Value %d', [j, self.getNewInstanceClassByIndexnameByIndex(i,j), self.getNewInstanceClassByIndexvalueByIndex(i,j) ] ) );
                end;
        end;
        dumpwriteln;

        dumpWriteln( '-arrayInstanceArea' );
        for i:=0 to self.getArrayInstanceStructIndex - 1 do
        begin
                dumpWrite( format('arrayInstanceIndex : %d  type : %d   ', [i, self.getArrayInstanceStructByIndexarrayType( i ) ] ) );
                if self.getArrayInstanceStructByIndexarrayType( i ) = T_CHAR then
                begin
                        dumpWrite('charArrayInstanceArea data : ');
                        for j:=0 to self.getArraySizeByIndexcharArrayInstanceClassDataByIndex( i ) - 1 do
                        begin
                                dumpWrite( self.getArrayByIndexcharArrayInstanceClassDataByIndex( i , j ) );
                        end;
                end;

                dumpwriteln;
        end;
        dumpwriteln;




        dumpWriteln( format('-interpreter coreDump(%s)', [name] ) );
        s1 := self.getLoadedClassName(loadedClassIndex);
        s2 := self.getMethodname( loadedClassIndex , methodIndex );
        dumpWriteln( format('loadedClassIndex : %d   name : %s', [loadedClassIndex, s1 ] ) );
        dumpWriteln( format('methodIndex : %d  name : %s', [methodIndex, s2 ] ) );
        dumpWriteln( format('codeOffset : %d', [codeOffset] ) );
        dumpWriteln( format('variableOffset : %d', [variableOffset] ) );
        dumpWriteln;




        dumpWriteln( '-stack coreDump' );
        for i:=0 to self.stack.statckOffset - 1 do
        begin
                dumpWriteln( format( 'index : %d  value : %d' , [i,self.stack.buffer[i]] ));
        end;
        dumpWriteln;



//      self.getMethodRefInfoName(loadedClassIndex, methodIndex , s1 , s2 );
//
//      위의 코드에서 에러가 발생했다. 이유는 methods인덱스를 가지고 , 상수 인덱스로 사용했기 때문이다.
//      그래서 형변환이 일어나지 못했기 대문이다.
//      methods 에서는 name 과 type 두가지를 가지고 있다.
//      하지만 상수 풀에서는 MethodRef로 하나를 참조한다.
//
        // classLoadModule 에 있는 함수사용
        getCodeString( codeAttr.code , codeOffset , s1 , s2 );
        s2 := utilClass.getFixedStringRightOrder( s2 , 20 , ' ' );
        dumpWriteln( format('%s : %s',[s2,s1] ) );

        dumpWriteln;
        dumpWriteln;

end;

procedure interpreterClass.coreDumpPleaseAnyKey;
begin
        self.coreDump;
        write('Please any key');
        readln;
end;

constructor interpreterClass.Create( host : string ; port : integer ; name : string ; this : integer ; coredumpFlag : boolean );
var
        s1,s2 : string;
        i,j,k : integer;
begin
        inherited Create( true );

        {
                초기설정.....
        }
        self.host := host;
        self.port := port;
        self.this := this;
        self.coredumpflag := coredumpflag;

        DPMResquester := indyConsoleTcpClientClass.Create( host , port );
        ca := codeAttribute.create;
        cl := classLoaderClass.Create;

        self.name := name;
        stack := stackClass.Create;

        if coredumpFlag = true then
        begin
                assignfile( f , DVMS_DUMP_PATH + name + '.txt' );
                rewrite( f );
        end;

        {
                실행설정.....
        }
        s2 := 'run()V';
        s1 := self.getOverridingMethodClassName( this , s2 );

        j := self.getLoadedClassIndex(s1);
        k := self.getMethodsIndex(j,s2);

        // 인자값 설정
        stack.push(this); // push this

        // 실행 정보 설정
        loadedClassIndex := j;
        methodIndex := k;
        codeOffset := 0;
        variableOffset := 0;//interpreter.stack.statckOffset - self.getTotalLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
        codeAttr := getCodeAttribute( loadedClassIndex , methodIndex );

        // 종료 정보 설정
        exitClassIndex := loadedClassIndex ;
        exitMethodIndex := methodIndex ;

        // 로컬 변수 영역 확보
        j := getMethodLocalVariableNumber( loadedClassIndex , methodIndex );
        for i:=0 to j - 1 do stack.push(0);
end;

destructor interpreterClass.Destroy;

begin
        if coredumpflag = true then closefile(f);

        inherited Destroy;


end;



//
// ---------------------------- Execute Start ----------------------------------
//
procedure interpreterClass.Execute;
var
        i,j,k,m : integer;
        i2,j2 : integer;
        s1 : string;
        s2 : string;
        arrayi : arrayInstanceClass;
        longint : int64;
        longint2 : int64;
        longint3 : int64;        
        b : boolean;
begin

try

while true do
begin


if coredumpFlag = true then coredump;

case codeAttr.code[ self.codeOffset ] of


00 : //(0x00) nop
// do nothing
begin
        inc(codeOffset);
end;

01 : //(0x01) aconst_null
// push the null object reference onto the operand stack
begin
        self.stack.push( 0 );

        inc(codeOffset);
end;

02 : //(0x02) iconst_m1
// push int constant(-1)
begin
        self.stack.push( -1 );
        inc(codeOffset);
end;


03 : //(0x03) iconst_0
// push int constant 0
begin
        self.stack.push(0);
        inc(codeOffset);
end;
               

04 : //(0x04) iconst_1
// push int constant 1
begin
        self.stack.push(1);
        inc(codeOffset);
end;

05 : //(0x05) iconst_2
// push int constant 2
begin
        self.stack.push(2);
        inc(codeOffset);
end;

06 : //(0x06) iconst_3
// push int constant 3
begin
        self.stack.push(3);
        inc(codeOffset);
end;

07 : //(0x07) iconst_4
// push int constant 4
begin
        self.stack.push(4);
        inc(codeOffset);
end;

08 : //(0x08) iconst_5
// push int constant 5
begin
        self.stack.push(5);
        inc(codeOffset);
end;

09 : //(0x09) lconst_0
// push long constant 0
begin
        self.stack.push(0);
        self.stack.push(0);

        inc(codeOffset);
end;

10 : //(0x0a) lconst_1
// push long constant 1
begin
        self.stack.push(0); // hi
        self.stack.push(1); // low

        inc(codeOffset);
end;

11 : //(0x0b) fconst_0
// push float 0
begin
        raise Exception.Create('fconst_0');
        inc(codeOffset);
end;

12 : //(0x0c) fconst_1
// push float 1
begin
        raise Exception.Create('fconst_1');
        inc(codeOffset);
end;

13 : //(0x0d) fconst_2
// push float 2
begin
        raise Exception.Create('fconst_2');
        inc(codeOffset);
end;

14 : //(0x0e) dconst_0
// push double 0
begin
        raise Exception.Create('dconst_0');
        inc(codeOffset);
end;

15 : //(0x0f) dconst_1
// push double 1
begin
        raise Exception.Create('dconst_1');
        inc(codeOffset);
end;

16 : //(0x10) bipush
// push byte
begin
        self.stack.push( utilClass.byte2integer( codeAttr.code[ (self.codeOffset+1) ] ) );

        inc(codeOffset);
        inc(codeOffset);
end;

17 : //(0x11) sipush
// push short
{
the immediate unsigned byte1 and byte2 values are assembled into an intermediate
short where the value of the short is (byte1 <<8) | byte2.
the intermediate value is then sign-extended to an int value.
That values is pushed onto the operand stack
}
begin
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
        stack.push(utilClass.word2integer(i));

        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

18 : //(0x12) ldc
// push intem from runtime constant pool
begin
        i := codeAttr.code[ self.codeOffset+1 ];

        // String type은 생성자를 호출해야 하기 대문에 먼저 codeoffset을 증가 시킨다.
        inc(codeOffset);
        inc(codeOffset);


        case self.getConstantPoolTagByIndex(loadedClassIndex,i) of

        CONSTANT_Integer :
        begin
                self.stack.push( self.getConstantPoolconstantIntegerBytesByIndex(loadedClassIndex,i) );
        end;

        CONSTANT_String :
        begin
                i := self.getConstantPoolconstantStringstringIndexByIndex(loadedClassIndex,i);
                j := self.getConstantPoolconstantUTF8InfolengthByIndex(loadedClassIndex,i);

                arrayi := arrayInstanceClass.Create;

                arrayi.arrayType := T_CHAR;
                arrayi.arrayObject := charArrayInstanceClass.Create(
                self.getConstantPoolconstantUTF8InfoBytesByIndex(loadedClassIndex,i) , j );

                k := self.appendArray( arrayi );

                // new
                m := self.getNewInstance();
                self.stack.push( m );

                // dup
                self.stack.push( m );

                // byte[]
                self.stack.push( k );

                // callInvokeSpecial 에서 명령어로 codeoffset을 3을 증가 시키기 때문에
                // 3을 빼준다
                dec(codeOffset);
                dec(codeOffset);
                dec(codeOffset);

                // public String(char[] b)
                self.callInvokeSpecial( 'java/lang/String', '<init>([C)V' , loadedClassIndex , methodIndex , codeOffset , variableOffset , codeAttr , stack );
        end;

        else
        begin
                raise Exception.Create('not support ldc type');
        end;

        end;
end;

19 : //(0x13) ldc_w
// push item from untime constant pool(wide index)
{
The unsigned indexybte1 and indexbyte2 are assembled into an unsigned 16-bit index
into the runtime constant pool of the current class, where the value of the index is
calculated as (indexbyte1 <<8) | indexbyte2. the index
must be a valid index ito the runtime constant pool of the current class.
}
begin
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );

        case self.getConstantPoolTagByIndex(loadedClassIndex,i) of

        CONSTANT_Integer :
        begin
        self.stack.push( self.getConstantPoolconstantIntegerBytesByIndex(loadedClassIndex,i) );
        end;

        else
        begin
                raise Exception.Create('not support ldc_w type');
        end;

        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

20 : //(0x14) ldc2_w
// push long or double from runtime constant pool
begin
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );

        case self.getConstantPoolTagByIndex(loadedClassIndex,i) of

        CONSTANT_Long :
        begin
                longint := self.getConstantPoolconstantLongbytesByIndex(loadedClassIndex,i);

                {$ifdef DEBUG}
                write('DEBUG:ldc2_w:');
                write( longint );
                {$endif}

                // j is hi
                utilClass.makeTwoInteger( longint , k , j );

                {$ifdef DEBUG}
                writeln( format('   j : %x  k : %x',[j,k] ) );
                {$endif}

                self.stack.push( j );
                self.stack.push( k );
        end;

        else
        begin
                raise Exception.Create('not support ldc2_w type');
        end;

        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

21 : //(0x15) iload
// load int from local variable
begin
        self.stack.push( self.stack.buffer[ variableOffset + codeAttr.code[ self.codeOffset +1] ]);

        inc(codeOffset);
        inc(codeOffset);
end;

22 : //(0x16) lload
// load long from local variable
begin
        self.stack.push( self.stack.buffer[ variableOffset + codeAttr.code[ self.codeOffset +1] ]); // hi
        self.stack.push( self.stack.buffer[ variableOffset + 1 + codeAttr.code[ self.codeOffset +1] ]); // low

        inc(codeOffset);
        inc(codeOffset);
end;

23 : //(0x17) fload
// load float from local variable
begin
        raise Exception.Create('fload');
        inc(codeOffset);
        inc(codeOffset);
end;

24 : //(0x18) dload
// load double from local variable
begin
        raise Exception.Create('dload');
        inc(codeOffset);
        inc(codeOffset);
end;

25 : //(0x19) aload
// load reference from local variable
begin
        self.stack.push( self.stack.buffer[ variableOffset + codeAttr.code[ self.codeOffset +1] ]);

        inc(codeOffset);
        inc(codeOffset);
end;

26 : //(0x1a) iload_0
// load int from local variable 0
begin
        self.stack.push( self.stack.buffer[ variableOffset + 0 ]);
        inc(codeOffset);
end;

27 : //(0x1b) iload_1
// load int from local variable 1
begin
        self.stack.push( self.stack.buffer[ variableOffset + 1 ]);
        inc(codeOffset);
end;

28 : //(0x1c) iload_2
// load int from local variable 2
begin
        self.stack.push( self.stack.buffer[ variableOffset + 2 ]);
        inc(codeOffset);
end;

29 : //(0x1d) iload_3
// load int from local variable 3
begin
        self.stack.push( self.stack.buffer[ variableOffset + 3 ]);
        inc(codeOffset);
end;


30 : //(0x1e) lload_0
// load long from local variable 0
begin
        self.stack.push( self.stack.buffer[ variableOffset ]);
        self.stack.push( self.stack.buffer[ variableOffset + 1 ]);
        inc(codeOffset);
end;


31 : //(0x1f) lload_1
// load long from local variable 1
begin
        {$ifdef DEBUG}
        write('DEBUG:lload_1:');
        self.stack.push( self.stack.buffer[ variableOffset + 1 ]);
        self.stack.push( self.stack.buffer[ variableOffset + 2 ]);

        i := stack.pop;
        j := stack.pop;

        writeln( format( 'i : %x  j : %x ',[i,j] ));

        stack.push(j);
        stack.push(i);
        {$else}
        self.stack.push( self.stack.buffer[ variableOffset + 1 ]);
        self.stack.push( self.stack.buffer[ variableOffset + 2 ]);
        {$endif}

        inc(codeOffset);
end;


32 : //(0x20) lload_2
// load long from local variable 2
begin
        self.stack.push( self.stack.buffer[ variableOffset + 2 ]);
        self.stack.push( self.stack.buffer[ variableOffset + 3 ]);

        inc(codeOffset);
end;


33 : //(0x21) lload_3
// load long from local variable 3
begin
        self.stack.push( self.stack.buffer[ variableOffset + 3 ]);
        self.stack.push( self.stack.buffer[ variableOffset + 4 ]);

        inc(codeOffset);
end;


34 : //(0x22) fload_0
// load float from local variable 0
begin
        raise Exception.Create('fload_0');
        inc(codeOffset);
end;


35 : //(0x23) fload_1
// load float from local variable 1
begin
        raise Exception.Create('fload_1');
        inc(codeOffset);
end;


36 : //(0x24) fload_2
// load float from local variable 2
begin
        raise Exception.Create('fload_2');
        inc(codeOffset);
end;


37 : //(0x25) fload_3
// load float from local variable 3
begin
        raise Exception.Create('fload_3');
        inc(codeOffset);
end;


38 : //(0x26) dload_0
// load double from local variable 0
begin
        raise Exception.Create('dload_0');
        inc(codeOffset);
end;


39 : //(0x27) dload_1
// load double from local variable 1
begin
        raise Exception.Create('dload_1');
        inc(codeOffset);
end;


40 : //(0x28) dload_2
// load double from local variable 2
begin
        raise Exception.Create('dload_2');
        inc(codeOffset);
end;


41 : //(0x29) dload_3
// load double from local variable 3
begin
        raise Exception.Create('dload_3');
        inc(codeOffset);
end;


42 : //(0x2a) aload_0
// load rerfence from local variable 0
begin
        self.stack.push( self.stack.buffer[ variableOffset ]);
        inc(codeOffset);
end;

43 : //(0x2b) aload_1
// load rerfence from local variable 1
begin
        self.stack.push( self.stack.buffer[ variableOffset + 1]);
        inc(codeOffset);
end;

44 : //(0x2c) aload_2
// load rerfence from local variable 2
begin
        self.stack.push( self.stack.buffer[ variableOffset + 2]);
        inc(codeOffset);
end;

45 : //(0x2d) aload_3
// load rerfence from local variable 3
begin
        self.stack.push( self.stack.buffer[ variableOffset + 3]);
        s2 := 'aload_3';
        inc(codeOffset);
end;

46 : //(0x2e) iaload
// load int from array
begin
        i:= self.stack.pop; // index
        j:= self.stack.pop; // arrayref

        self.stack.push( self.getArrayByIndexintArrayInstanceClassDataByIndex( j , i ) );

        inc(codeOffset);
end;

47 : //(0x2f) laload
// load long from array
begin
        i:= self.stack.pop; // index
        j:= self.stack.pop; // arrayref

        longint := getArrayByIndexlongArrayInstanceClassDataByIndex(j,i);
        utilClass.makeTwoInteger(longint , k , m );

        self.stack.push( m ); // hi
        self.stack.push( k ); // low

        inc(codeOffset);
end;

48 : //(0x30) faload
// load float from array
begin
        raise Exception.Create('faload');
        inc(codeOffset);
end;

49 : //(0x31) daload
// load double from array
begin
        raise Exception.Create('daload');
        inc(codeOffset);
end;

50 : //(0x32) aaload
// load reference from array
begin
        raise Exception.Create('aaload');
        inc(codeOffset);
end;

51 : //(0x33) baload
// load byte or boolean from array
begin
        i:= self.stack.pop; // index
        j:= self.stack.pop; // arrayref

        self.stack.push( getArrayByIndexbyteArrayInstanceClassDataByIndex(j,i) );

        inc(codeOffset);
end;

52 : //(0x34) caload
// load char from array
begin
        i:= self.stack.pop; // index
        j:= self.stack.pop; // arrayref

        self.stack.push( integer(getArrayByIndexcharArrayInstanceClassDataByIndex(j,i)) );

        inc(codeOffset);
end;


53 : //(0x35) saload
// load short from array
begin
        raise Exception.Create('saload');
        inc(codeOffset);
end;

54 : //(0x36) istore
// store int into local variable
begin
        self.stack.buffer[ self.variableOffset + codeAttr.code[ self.codeOffset +1] ] := self.stack.pop;

        inc(codeOffset);
        inc(codeOffset);
end;

55 : //(0x37) lstore
// store long into local variable
begin
        self.stack.buffer[ self.variableOffset + 1 + codeAttr.code[ self.codeOffset +1] ] := self.stack.pop; // low

        self.stack.buffer[ self.variableOffset + codeAttr.code[ self.codeOffset +1] ] := self.stack.pop; // hi

        inc(codeOffset);
        inc(codeOffset);
end;

56 : //(0x38) fstore
// store float into local variable
begin
        raise Exception.Create('fstore');
        inc(codeOffset);
end;

57 : //(0x39) dstore
// store double into local variable
begin
        raise Exception.Create('dstore');
        inc(codeOffset);
end;

58 : //(0x3a) astore
// store reference into local variable
begin
        self.stack.buffer[ self.variableOffset + codeAttr.code[codeOffset + 1] ] := self.stack.pop;

        inc(codeOffset);
        inc(codeOffset);
end;

59 : //(0x3b) istore_0
// store int into local variable 0
begin
        self.stack.buffer[ self.variableOffset + 0 ] := self.stack.pop;
        inc(codeOffset);
end;

60 : //(0x3c) istore_1
// store int into local variable 1
begin
        self.stack.buffer[ self.variableOffset + 1 ] := self.stack.pop;
        inc(codeOffset);
end;


61 : //(0x3d) istore_2
// store int into local variable 2
begin
        i := self.stack.pop;
        self.stack.buffer[ self.variableOffset + 2 ] := i;
        inc(codeOffset);
end;

62 : //(0x3e) istore_3
// store int into local variable 3
begin
        self.stack.buffer[ self.variableOffset + 3 ] := self.stack.pop;
        inc(codeOffset);
end;



63 : //(0x3f) lstore_0
// store long into local variable 0
begin
        i := self.stack.pop; // low
        j := self.stack.pop; // hi

        self.stack.buffer[ self.variableOffset ] := j; //hi order
        self.stack.buffer[ self.variableOffset + 1 ] := i; //low order

        inc(codeOffset);
end;


64 : //(0x40) lstore_1
// store long into local variable 1
begin
        i := self.stack.pop; // low
        j := self.stack.pop; // hi

        {$ifdef DEBUG}
        write('DEBUG:lstore_1:');
        writeln( format( 'i : %x  j : %x',[i,j] ) );
        {$endif}


        self.stack.buffer[ self.variableOffset + 1 ] := j; //hi order
        self.stack.buffer[ self.variableOffset + 2 ] := i; //low order

        inc(codeOffset);
end;


65 : //(0x41) lstore_2
// store long into local variable 2
begin
        i := self.stack.pop; // low
        j := self.stack.pop; // hi

        self.stack.buffer[ self.variableOffset + 2 ] := j; //hi order
        self.stack.buffer[ self.variableOffset + 3 ] := i; //low order

        inc(codeOffset);
end;


66 : //(0x42) lstore_3
// store long into local variable 3
begin
        i := self.stack.pop; // low
        j := self.stack.pop; // hi

        self.stack.buffer[ self.variableOffset + 3 ] := j; //hi order
        self.stack.buffer[ self.variableOffset + 4 ] := i; //low order

        inc(codeOffset);
end;


67 : //(0x43) fstore_0
// store float into local variable 0
begin
        raise Exception.Create('fstore_0');
        inc(codeOffset);
end;


68 : //(0x44) fstore_1
// store float into local variable 1
begin
        raise Exception.Create('fstore_1');
        inc(codeOffset);
end;


69 : //(0x45) fstore_2
// store float into local variable 2
begin
        raise Exception.Create('fstore_2');
        inc(codeOffset);
end;


70 : //(0x46) fstore_3
// store float into local variable 3
begin
        raise Exception.Create('fstore_3');
        inc(codeOffset);
end;


71 : //(0x47) dstore_0
// store double into local variable 0
begin
        raise Exception.Create('dstore_0');
        inc(codeOffset);
end;


72 : //(0x48) dstore_1
// store double into local variable 1
begin
        raise Exception.Create('dstore_1');
        inc(codeOffset);
end;


73 : //(0x49) dstore_2
// store double into local variable 2
begin
        raise Exception.Create('dstore_2');
        inc(codeOffset);
end;


74 : //(0x4a) dstore_3
// store double into local variable 3
begin
        raise Exception.Create('dstore_3');
        inc(codeOffset);
end;


75 : //(0x4b) astore_0
// store reference into local variable 0
begin
        self.stack.buffer[ self.variableOffset + 0 ] := self.stack.pop;
        inc(codeOffset);
end;

76 : //(0x4c) astore_1
// store reference into local variable 1
begin
        self.stack.buffer[ self.variableOffset + 1 ] := self.stack.pop;
        inc(codeOffset);
end;

77 : //(0x4d) astore_2
// store reference into local variable 2
begin
        self.stack.buffer[ self.variableOffset + 2 ] := self.stack.pop;
        inc(codeOffset);
end;

78 : //(0x4e) astore_3
// store reference into local variable 3
begin
        self.stack.buffer[ self.variableOffset + 3 ] := self.stack.pop;
        inc(codeOffset);
end;


79 : //(0x4f) iastore
// store into int array
begin
        i:= self.stack.pop; // value
        j:= self.stack.pop; // index;
        k:= self.stack.pop; // arrayref

        setArrayByIndexintArrayInstanceClassDataByIndex(k,j,i);

        inc(codeOffset);
end;

80 : //(0x50) lastore
// store into long array
begin
        i := stack.pop; // low
        j := stack.pop; // hi

        longint := utilclass.makeLong(i , j);

        j:= self.stack.pop; // index;
        k:= self.stack.pop; // arrayref

        setArrayByIndexlongArrayInstanceClassDataByIndex(k,j,longint);

        inc(codeOffset);
end;

81 : //(0x51) fastore
// store into float array
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

82 : //(0x52) dastore
// store into double array
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

83 : //(0x53) aastore
// store into reference array
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

84 : //(0x54) bastore
// store into byte or boolean array
begin
        i:= self.stack.pop; // value
        j:= self.stack.pop; // index;
        k:= self.stack.pop; // arrayref

        setArrayByIndexbyteArrayInstanceClassDataByIndex(k,j,i);

        inc(codeOffset);
end;

85 : //(0x55) castore
// store into char array
begin
        i:= self.stack.pop; // value
        j:= self.stack.pop; // index;
        k:= self.stack.pop; // arrayref

        setArrayByIndexcharArrayInstanceClassDataByIndex(k,j,char(i));

        inc(codeOffset);
end;

86 : //(0x56) sastore
// store into short array
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

87 : //(0x57) pop
// pop the top operand stack value
begin
        self.stack.pop;
        inc(codeOffset);
end;

88 : //(0x58) pop2
// pop the top one or two operand stack values
begin
        self.stack.pop;
        self.stack.pop;
        
        inc(codeOffset);
end;

089 : //(0x59) dup
// duplicate the top operand stack value
begin
        i := self.stack.pop;

        self.stack.push(i);
        self.stack.push(i);

        inc(codeOffset);
end;


090 : //(0x5a) dup_x1
// duplicate the top operand stack value and insert two values down
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

091 : //(0x5b) dup_x2
// duplicate the top operand stack value and insert two or three values down
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

092 : //(0x5c) dup2
// duplicate the top one or two operand stack values
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

093 : //(0x5d) dup2_x1
// duplicate the top one or two operand stack values and insert two or three values down
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

094 : //(0x5e) dup2_x2
// duplicate the top one or two operand stack values and insert two, three, or four values down
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

095 : //(0x5f) swap
// swap the top two operand stack values
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

096 : //(0x60) iadd
// add int
begin
        i := self.stack.pop;
        j := self.stack.pop;

        self.stack.push(i+j);

        inc(codeOffset);
end;

097 : //(0x61) ladd
// add long
begin
        i := stack.pop; //low
        j := stack.pop; // hi
        longint2 := utilclass.makeLong(i, j);

        {$ifdef DEBUG}
        write('DEBUG:ladd:');
        write( 'longint2 : ' );
        write( longint2 );
        {$endif}

        i := stack.pop; //low
        j := stack.pop; // hi
        longint := utilclass.makeLong(i, j);

        {$ifdef DEBUG}
        write( '  longint : ' );
        write( longint );
        writeln( format( '   %x' , [longint] ) );
        {$endif}

        longint3 := longint + longint2;

        utilclass.makeTwoInteger(longint3,i,j);

        stack.push( j ); // hi
        stack.push( i ); // low

        inc(codeOffset);
end;

098 : //(0x62) fadd
// add float
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

099 : //(0x63) dadd
// add double
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

100 : //(0x64) isub
// substract int
begin
        i := self.stack.pop;
        j := self.stack.pop;

        self.stack.push(i-j);

        inc(codeOffset);
end;

101 : //(0x65) lsub
// substract long
begin
        i := stack.pop; //low
        j := stack.pop; // hi
        longint2 := utilclass.makeLong(i, j);

        {$ifdef DEBUG}
        write('DEBUG:lsub:');
        write( 'longint2 : ' );
        write( longint2 );
        {$endif}

        i := stack.pop; //low
        j := stack.pop; // hi
        longint := utilclass.makeLong(i, j);

        {$ifdef DEBUG}
        write( '  longint : ' );
        write( longint );
        writeln( format( '   %x' , [longint] ) );
        {$endif}

        longint3 := longint - longint2;

        utilclass.makeTwoInteger(longint3,i,j);

        stack.push( j ); // hi
        stack.push( i ); // low

        inc(codeOffset);
end;

102 : //(0x66) fsub
// substract float
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

103 : //(0x67) dsub
// substract double
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

104 : //(0x68) imul
// multiply int
begin
        i := self.stack.pop;
        j := self.stack.pop;

        self.stack.push( i*j );

        inc(codeOffset);
end;

105 : //(0x69) lmul
// multiply long
begin
        i := stack.pop; //low
        j := stack.pop; // hi
        longint2 := utilclass.makeLong(i, j);

        {$ifdef DEBUG}
        write('DEBUG:lmul:');
        write( 'longint2 : ' );
        write( longint2 );
        {$endif}

        i := stack.pop; //low
        j := stack.pop; // hi
        longint := utilclass.makeLong(i, j);

        {$ifdef DEBUG}
        write( '  longint : ' );
        write( longint );
        writeln( format( '   %x' , [longint] ) );
        {$endif}

        longint3 := longint * longint2;

        utilclass.makeTwoInteger(longint3,i,j);


        stack.push( j ); // hi
        stack.push( i ); // low

        inc(codeOffset);
end;

106 : //(0x6a) fmul
// multiply float
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

107 : //(0x6b) dmul
// multiply double
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

108 : //(0x6c) idiv
// divide int
begin
        i := self.stack.pop;
        j := self.stack.pop;
        k := i div j;

        self.stack.push( k );
        inc(codeOffset);
end;

109 : //(0x6d) ldiv
// divide long
begin
        i := stack.pop; //low
        j := stack.pop; // hi
        longint2 := utilclass.makeLong(i, j);

        {$ifdef DEBUG}
        write('DEBUG:ldiv:');
        write( 'longint2 : ' );
        write( longint2 );
        {$endif}

        i := stack.pop; //low
        j := stack.pop; // hi
        longint := utilclass.makeLong(i, j);

        {$ifdef DEBUG}
        write( '  longint : ' );
        write( longint );
        writeln( format( '   %x' , [longint] ) );
        {$endif}

        longint3 := longint div longint2;

        utilclass.makeTwoInteger(longint3,i,j);


        stack.push( j ); // hi
        stack.push( i ); // low

        inc(codeOffset);
end;

110 : //(0x6e) fdiv
// divide float
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

111 : //(0x6f) ddiv
// divide double
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

112 : //(0x70) irem
// remainder int
{
        나머지 연산
}
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

113 : //(0x71) lrem
// remainder long
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

114 : //(0x72) frem
// remainder float
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

115 : //(0x73) drem
// remainder double
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

116 :  //(0x74)ineg
// negate int
// 부정
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

117 : //(0x75) lneg
// negate long
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

118 : //(0x76) fneg
// negate float
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

119 : //(0x77) dneg
// negate double(부정)
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

120 : //(0x78) ishl
// shift left int
begin
        i := stack.pop; //value1
        j := stack.pop; // value2
        k := i shl j;
        stack.push(k);

        inc(codeOffset);
end;

121 : //(0x79) lshl
// shift left long
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

122 : //(0x7a) ishr
// arithmetic shift right int
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

123 : //(0x7b) lshr
// arithmetic shift right long
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

124 : //(0x7c) iushr
// logical shift right int
begin
        i := stack.pop; //value1
        j := stack.pop; // value2
        k := i shl j;
        stack.push(k);

        inc(codeOffset);
end;

125 : //(0x7d) lushr
// logical shift right long
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

126 : //(0x7e) iand
// boolean and int
begin
        raise Exception.Create('$$$$$');;
        inc(codeOffset);
end;

127 : //(0x7f) land
// boolean and long
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

128 : //(0x80) ior
// boolean or int
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

129 : //(0x81) lor
// boolean or long
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

130 : //(0x82) ixor
// boolean xor int
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

131 : //(0x83) lxor
// boolean xor long
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

132 : //(0x84) iinc
// increnent local variable by constant
begin
        i := codeAttr.code[ self.codeOffset +1];
        j := codeAttr.code[ self.codeOffset +2] ;

        self.stack.buffer[ self.variableOffset + i ] := self.stack.buffer[ self.variableOffset + i ] + j;
        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

133 : //(0x85) i2l
// convert int to long
begin
        i := stack.pop;
        longint := int64(i);

        utilClass.makeTwoInteger(longint, j , k );

        stack.push( k ); // hi
        stack.push( j );

        inc(codeOffset);
end;

134 : //(0x86) i2f
// convert int to float
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

135 : //(0x87) i2d
// convert int to double
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

136 : //(0x88) l2i
// convert long to int
begin
        i := stack.pop; // low
        j := stack.pop; // hi

        longint := utilclass.makeLong(i , j);

        k := integer( longint );

        stack.push(k);

        inc(codeOffset);
end;

137 : //(0x89) l2f
// convert long to float
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

138 : //(0x8a) l2d
// convert long to double
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

139 : //(0x8b) f2i
// convert float to int
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

140 : //(0x8c) f2l
// convert float to long
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

141 : //(0x8d) f2d
// convert float to double
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

142 : //(0x8e) d2i
// convert double to int
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

143 : //(0x8f) d2l
// convert float to long
begin
        raise Exception.Create('$$$$$');;
        inc(codeOffset);
end;

144 : //(0x90) d2f
// convert float to float
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

145 : //(0x91) i2b
// convert int to byte
begin
        self.stack.push( self.stack.pop and $000f );
        inc(codeOffset);
end;

146 : //(0x92) i2c
// convert int to char
begin
        self.stack.push( self.stack.pop and $000f );
        inc(codeOffset);
end;

147 : //(0x93) i2s
// convert int to short
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;

148 : //(0x94) lcmp
// compare long
begin
        i := stack.pop; //low
        j := stack.pop; // hi
        longint2 := utilclass.makeLong(i, j);

        {$ifdef DEBUG}
        write('DEBUG:lcmp:');
        write( 'longint2 : ' );
        write( longint2 );
        {$endif}

        i := stack.pop; //low
        j := stack.pop; // hi
        longint := utilclass.makeLong(i, j);

        {$ifdef DEBUG}
        write( '  longint : ' );
        write( longint );
        writeln( format( '   %x' , [longint] ) );
        {$endif}

        if longint > longint2 then self.stack.push(1) // value1 and value 2
        else
        if longint = longint2 then self.stack.push(0)
        else
        self.stack.push(-1);        

        inc(codeOffset);
end;

149 : //(0x95) fcmpl
// compare float
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;


150 : //(0x96) fcmpg
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;


151 : //(0x97) dcmpl
// compare double
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;


152 : //(0x98) dcmpg
begin
        raise Exception.Create('$$$$$');
        inc(codeOffset);
end;


153 : //(0x99) ifeq
// branch if int comparison with zero succeeds
begin
        i := self.stack.pop; //value

        if i = 0 then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;


154 : //(0x9a) ifne
// branch if int comparison with zero succeeds
begin
        i := self.stack.pop; //value

        if i <> 0 then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;


155 : //(0x9b) iflt
// branch if int comparison with zero succeeds
begin
        i := self.stack.pop; //value

        if i < 0 then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);

end;


156 : //(0x9c) ifge
// branch if int comparison with zero succeeds
begin
        i := self.stack.pop; //value

        if i >= 0 then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);

end;


157 : //(0x9d) ifgt
// branch if int comparison with zero succeeds
begin
        i := self.stack.pop; //value

        if i > 0 then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);

end;


158 : //(0x9e) ifle
// branch if int comparison with zero succeeds
begin
        i := self.stack.pop; //value

        if i <= 0 then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);

end;


159 : //(0x9f) if_icmpeq
// branh if int comparison succeeds
begin
        i := self.stack.pop; //value 2
        j := self.stack.pop; // value 1

        if j = i then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

160 : //(0xa0) if_icmpne
begin
        i := self.stack.pop;
        j := self.stack.pop;

        if j <> i then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                //write( 'dvm : ' );writeln( self.codeOffset );
                continue;
        end;



        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

161 : //(0xa1) if_icmplt
begin
        i := self.stack.pop; // value 2
        j := self.stack.pop; // value 1

        if j < i then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;



        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

162 : //(0xa2) if_icmpge
begin
        i := self.stack.pop;
        j := self.stack.pop;

        if j >= i then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;



        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

163 : //(0xa3) if_icmpgt
begin
        i := self.stack.pop;
        j := self.stack.pop;

        if j > i then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;



        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

164 : //(0xa4) if_icmple
begin
        i := self.stack.pop;
        j := self.stack.pop;

        if j <= i then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;



        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;


165 : //(0xa5) if_acmpeq
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

166 : //(0xa6) if_acmpne
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

167 : //(0xa7) goto
// branch always
begin
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
        self.codeOffset := self.codeOffset + utilClass.word2integer(i);
end;

168 : //(0xa8) jsr
// jump subroutine
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

169 : //(0xa9) ret
// return from subroutine
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
        inc(codeOffset);
end;

170 : //(0xaa) tableswitch
// access jump table by index and jump
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
        inc(codeOffset);
end;

171 : //(0xab) lookupswitch
// access jump table by key match and jump
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
        inc(codeOffset);
end;


172 : //(0xac) ireturn
// return int from method
begin
        // 저장된 정수값 저장
        k := self.stack.pop;

        self.returnMethod( loadedClassIndex, methodIndex, codeOffset, variableOffset, codeAttr, stack );

        self.stack.push(k);
end;

173 : //(0xad) lreturn
// return long from method
begin
        i := stack.pop; //low
        j := stack.pop; // hi

        self.returnMethod( loadedClassIndex, methodIndex, codeOffset, variableOffset, codeAttr, stack );

        stack.push( j );
        stack.push( i );
end;

174 : //(0xae) freturn
// return float from method
begin
                raise Exception.Create('$$$$$');
                inc(codeOffset);
end;

175 : //(0xaf) dreturn
// return double from method
begin
                raise Exception.Create('$$$$$');
                inc(codeOffset);
end;

176 : //(0xb0) areturn
// return reference from method
begin
        k := self.stack.pop; // reference

        self.returnMethod( loadedClassIndex, methodIndex, codeOffset, variableOffset, codeAttr, stack );

        self.stack.push(k);
end;

177 : //(0xb1) return
// return void from method
begin
        if self.loadedClassIndex = self.exitClassIndex then
                if self.methodIndex = self.exitMethodIndex then
                        break;

        self.returnMethod( loadedClassIndex, methodIndex, codeOffset, variableOffset, codeAttr, stack );
end;


178 : //(0xb2) getstatic
// get static field from class
{
        static 자료형은 clinit에의해서 먼저 초기화 된다
        따라서 static 자료형 요청시 clinit를  찾아 실행한후 에 설정을 하여야 한다.ㄴ
}
begin
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
        self.getFieldRefInfoName( self.loadedClassIndex , i , s1 , s2 );
        if s2[length(s2)] = 'J' then b := true else b := false;

        if b = false then
        begin
                i := self.getStaticFieldIndexByFieldName( s1+s2 );
                if i = -1 then
                begin
                        self.appendStaticField( s1+s2 , 0 );

                        j := self.getLoadedClassIndex( s1 );
                        // 2003-8-9 새벽 3시
                        // 클래스 가 로드 되지 않았으면 초기화가 일어나고 로드되었으면
                        // 초기화가 일어나지 않는다.. 이것 수정.
                        k := i or j; // if문에서 다중 비교를 지원하지 않아서 이렇게 한다....
                        k := k and -1;
                        if k = -1 then
                        begin
                                self.appendClass( s1 );
                                j := self.getLoadedClassIndex( s1 );

                                k := self.getMethodsIndex( j , '<clinit>()V' );
                                if k <> -1 then
                                begin
                                        //
                                        // callMethod에서 codeOffset를 3 더하기 때문에 3을 감한다.
                                        //
                                        dec(codeOffset);
                                        dec(codeOffset);
                                        dec(codeOffset);
                                        self.callMethodType2( j , k ,
                                                loadedClassIndex , methodIndex , codeOffset , variableOffset , codeAttr, stack );
                                        // <clinit>를 실행한후 getstatic를 다시 실행한다
                                        continue;
                                end;
                        end;

                        i := self.getStaticFieldIndexByFieldName( s1+s2 );
                end;

                j := self.getStaticFieldValue(i);

                self.stack.push(j);
        end
        else
        begin
                i := self.getStaticFieldIndexByFieldName( s1+s2 +'1' );
                i2 := self.getStaticFieldIndexByFieldName( s1+s2 +'2' );

                if i = -1 then
                begin
                        self.appendStaticField( s1+s2 +'1', 0 );
                        self.appendStaticField( s1+s2 +'2', 0 );

                        j := self.getLoadedClassIndex( s1 );
                        // 2003-8-9 새벽 3시
                        // 클래스 가 로드 되지 않았으면 초기화가 일어나고 로드되었으면
                        // 초기화가 일어나지 않는다.. 이것 수정.
                        k := i or j; // if문에서 다중 비교를 지원하지 않아서 이렇게 한다....
                        k := k and -1;
                        if k = -1 then
                        begin
                                self.appendClass( s1 );
                                j := self.getLoadedClassIndex( s1 );

                                k := self.getMethodsIndex( j , '<clinit>()V' );
                                if k <> -1 then
                                begin
                                        //
                                        // callMethod에서 codeOffset를 3 더하기 때문에 3을 감한다.
                                        //
                                        dec(codeOffset);
                                        dec(codeOffset);
                                        dec(codeOffset);
                                        self.callMethodType2( j , k ,
                                                loadedClassIndex , methodIndex , codeOffset , variableOffset , codeAttr, stack );
                                        // <clinit>를 실행한후 getstatic를 다시 실행한다
                                        continue;
                                end;
                        end;

                        i := self.getStaticFieldIndexByFieldName( s1+s2 +'1');
                        i2 := self.getStaticFieldIndexByFieldName( s1+s2 +'2');
                end;

                j := self.getStaticFieldValue(i);
                j2 := self.getStaticFieldValue(i2);

                self.stack.push(j);
                self.stack.push(j2);                
        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;


179 : //(0xb3) putstatic
// set static field from class
{
        static 자료형은 clinit에의해서 먼저 초기화 된다
        따라서 static 자료형 요청시 clinit를  찾아 실행한후 에 설정을 하여야 한다.ㄴ
}
begin
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
        self.getFieldRefInfoName( self.loadedClassIndex , i , s1 , s2 );
        if s2[length(s2)] = 'J' then b := true else b := false;

        if b = false then
        begin
                i := self.getStaticFieldIndexByFieldName( s1+s2 );
                if i = -1 then
                begin
                        self.appendStaticField( s1+s2, 0 );

                        j := self.getLoadedClassIndex( s1 );

                        // 2003-8-9 새벽 3시
                        // 클래스 가 로드 되지 않았으면 초기화가 일어나고 로드되었으면
                        // 초기화가 일어나지 않는다.. 이것 수정.
                        if j = -1 then
                        begin
                                self.appendClass( s1 );
                                j := self.getLoadedClassIndex( s1 );

                                k := self.getMethodsIndex( j , '<clinit>()V' );
                                if k <> -1 then
                                begin
                                        //
                                        // callMethod에서 codeOffset를 3 더하기 때문에 3을 감한다.
                                        //
                                        dec(codeOffset);
                                        dec(codeOffset);
                                        dec(codeOffset);
                                        self.callMethodType2( j, k, loadedClassIndex , methodIndex , codeOffset , variableOffset , codeAttr, stack );
                                        // <clinit>를 실행한후 putstatic를 다시 실행한다
                                        continue;
                                end;
                        end;

                        i := self.getStaticFieldIndexByFieldName( s1+s2 );
                end;

                j := self.stack.pop;

                self.setStaticFieldValue(i,j);
        end
        else
        begin
                i := self.getStaticFieldIndexByFieldName( s1+s2+'1' );
                i2 := self.getStaticFieldIndexByFieldName( s1+s2+'2' );

                if i = -1 then
                begin
                        self.appendStaticField( s1+s2+'1', 0 );
                        self.appendStaticField( s1+s2+'2', 0 );

                        j := self.getLoadedClassIndex( s1 );

                        // 2003-8-9 새벽 3시
                        // 클래스 가 로드 되지 않았으면 초기화가 일어나고 로드되었으면
                        // 초기화가 일어나지 않는다.. 이것 수정.
                        if j = -1 then
                        begin
                                self.appendClass( s1 );
                                j := self.getLoadedClassIndex( s1 );

                                k := self.getMethodsIndex( j , '<clinit>()V' );
                                if k <> -1 then
                                begin
                                        //
                                        // callMethod에서 codeOffset를 3 더하기 때문에 3을 감한다.
                                        //
                                        dec(codeOffset);
                                        dec(codeOffset);
                                        dec(codeOffset);
                                        self.callMethodType2( j, k, loadedClassIndex , methodIndex , codeOffset , variableOffset , codeAttr, stack );
                                        // <clinit>를 실행한후 putstatic를 다시 실행한다
                                        continue;
                                end;
                        end;

                        i := self.getStaticFieldIndexByFieldName( s1+s2+'1' );
                        i2 := self.getStaticFieldIndexByFieldName( s1+s2+'2' );
                end;

                j2 := self.stack.pop; // 하위 바이트가 위에 있다.
                j := self.stack.pop;

                self.setStaticFieldValue(i,j);
                self.setStaticFieldValue(i2,j2);
        end;

        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

180 : //(0xb4) getfield
// fetch field from object
{
        class 자료형은 바이트 코드에 의해 init가 호출되고 처리된다
        따라서 별도의 호출 코드가 필요 없다.
}
begin
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
        self.getFieldRefInfoName( self.loadedClassIndex , i , s1 , s2 );

        // 해당 new instance 인덱스
        i := self.stack.pop;

        if s2[length(s2)] = 'J' then b := true else b := false;

        if b = false then
        begin
                j := self.getFieldIndex( i,s1+s2 );
                if j = -1 then
                begin
                        self.appendField( i , s1+s2 , 0 );
                        self.stack.push(0);
                end
                else
                begin
                        j := self.getFieldValue(i, j);
                        self.stack.push(j);
                end;
        end
        else
        begin
                j := self.getFieldIndex( i,s1+s2+'1' );
                j2 := self.getFieldIndex( i,s1+s2+'2' );

                if j = -1 then
                begin
                        self.appendField( i , s1+s2+'1' , 0 );
                        self.appendField( i , s1+s2+'2' , 0 );
                        self.stack.push(0);
                        self.stack.push(0);                        
                end
                else
                begin
                        j := self.getFieldValue(i, j);
                        j2 := self.getFieldValue(i, j2);
                        self.stack.push(j);
                        self.stack.push(j2);                        
                end;
        end;

        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

181 : //(0xb5) putfield
// set field in object
{
        class 자료형은 바이트 코드에 의해 init가 호출되고 처리된다
        따라서 별도의 호출 코드가 필요 없다.
}
begin
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
        self.getFieldRefInfoName( self.loadedClassIndex , i , s1 , s2 );

        if s2[length(s2)] = 'J' then b := true else b := false;


        if b = false then
        begin
                i := self.stack.pop; // value;

                j := self.stack.pop; // new instance

                m := self.getFieldIndex( j, s1+s2 ); // get fieldindex
                if m = -1 then
                        self.appendField( j , s1+s2 , i )
                else
                        self.setFieldValue(j,m,i);
        end
        else
        begin
                i2 := self.stack.pop; // value; low
                i := self.stack.pop; // value; high

                j := self.stack.pop; // new instance

                m := self.getFieldIndex( j, s1+s2+'1' ); // get fieldindex
                if m = -1 then
                        self.appendField( j , s1+s2+'1' , i )
                else
                        self.setFieldValue(j,m,i);

                m := self.getFieldIndex( j, s1+s2+'2' ); // get fieldindex
                if m = -1 then
                        self.appendField( j , s1+s2+'2' , i2 )
                else
                        self.setFieldValue(j,m,i2);

        end;

        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

182 : //(0xb6) invokevirtual
// invoke instance method; displatch based on class
begin
        // 현재 클래스이 상수 플 인덱스를 얻는다
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );

        // 인덱스를 가지고 클래스명과 메소드명타입을 얻는다
        self.getMethodRefInfoName( loadedClassIndex , i , s1 , s2 );

        self.callInvokeVirtual( s1, s2 , loadedClassIndex , methodIndex , codeOffset , variableOffset , codeAttr , stack );
end;


183 : //(0xb7) invokespecial
// invoke instance method; special handling for superclass, private, and instance initialization method invocations
begin
        // 현재 클래스이 상수 플 인덱스를 얻는다
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );

        // 인덱스를 가지고 클래스명과 메소드명타입을 얻는다
        self.getMethodRefInfoName( loadedClassIndex , i , s1 , s2 );

        self.callInvokeSpecial( s1, s2 , loadedClassIndex , methodIndex , codeOffset , variableOffset , codeAttr , stack );
end;

184 : //(0xb8) invokestatic
// invoke a class (static) method
begin
        // 현재 클래스이 상수 플 인덱스를 얻는다
        i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );

        // 인덱스를 가지고 클래스명과 메소드명타입을 얻는다
        self.getMethodRefInfoName( loadedClassIndex , i , s1 , s2 );

        self.callInvokeStatic( s1, s2 , loadedClassIndex , methodIndex , codeOffset , variableOffset , codeAttr , stack );
end;

185 : //(0xb9) invokeinterface
// invoke interface method
begin
                raise Exception.Create('$$$$$');  inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

186 : ; //(0xba) xxxunusedxxx1

187 : //(0xbb) new
// create new object
begin
        // 클래스 타입 무시
        //i := makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
        self.stack.push( self.getNewInstance() );

        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

188 : //(0xbc) newarray
// create new byte array
begin
        i := codeAttr.code[ self.codeOffset + 1]; // array type
        j := self.stack.pop;

        arrayi := arrayInstanceClass.Create;

        case i of

        T_CHAR:
        begin
                arrayi.arrayObject := charArrayInstanceClass.Create( j );
        end;

        T_BYTE:
        begin
                arrayi.arrayObject := byteArrayInstanceClass.Create( j );
        end;

        T_INT:
        begin
                arrayi.arrayObject := intArrayInstanceClass.Create( j );
        end;

        T_LONG:
        begin
                arrayi.arrayObject := longArrayInstanceClass.Create( j );
        end;

        else
        begin
                raise Exception.Create('not support array type');
        end;

        end;

        arrayi.arrayType := i;
        self.stack.push( self.appendArray( arrayi ) ); // array index save

        inc(codeOffset);
        inc(codeOffset);
end;

189 : //(0xbd) anewarray
// create new array of reference
begin
                raise Exception.Create('$$$$$');  inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

190 : //(0xbe) arraylength
// get length of array
begin
        i := self.stack.pop;

        case getArrayInstanceStructByIndexarrayType(i) of

        T_CHAR:
        begin
                self.stack.push( getArraySizeByIndexcharArrayInstanceClassDataByIndex(i) );
        end;

        T_BYTE:
        begin
                self.stack.push( getArraySizeByIndexbyteArrayInstanceClassDataByIndex(i) );
        end;

        T_INT:
        begin
                self.stack.push( getArraySizeByIndexintArrayInstanceClassDataByIndex(i) );
        end;

        T_LONG:
        begin
                self.stack.push( getArraySizeByIndexlongArrayInstanceClassDataByIndex(i) );
        end;

        end;

        inc(codeOffset);
end;

191 : //(0xbf) athrow
// throw exception or error
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
end;

192 : //(0xc0) checkcast
// check whether object is of given type
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

193 : //(0xc1) instanceof
// determine if object is of given type(monitorenter 뒤에 설명이 나옴)
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

194 : //(0xc2) monitorenter
// Enter monitor for object
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
end;

195 : //(0xc3) monitorexit
// exit monitor for object
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
end;

196 : //(0xc4) wide
// extend local variable index by additional bytes
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
end;

197 : //(0xc5) multianewarray
// create new multidimensional array
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
end;


198 : //(0xc6) ifnull
// branch if reference is null
begin
        i := self.stack.pop;

        if i = 0  then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

199 : //(0xc7) ifnonnull
// branch if reference not null
begin
        i := self.stack.pop;

        if i <> 0  then
        begin
                i := utilClass.makeU2withHiByteAndLowByte( codeAttr.code[ self.codeOffset +1], codeAttr.code[ self.codeOffset +2] );
                self.codeOffset := self.codeOffset + utilClass.word2integer(i);
                continue;
        end;


        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);
end;

200 : //(0xc8) goto_w
// branch always(wide index)
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
end;


201 : //(0xc9) jsr_w
// jump subroutine
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
end;

//Reserved opcodes:

{
        더이상 사용되지 않느다. 
202 : //(0xca) breakpoint
begin
        i := self.getTotalLocalVariableNumber( self.loadedClassIndex , self.methodIndex );

        // delete variable
        for j:=0 to i - 1 do self.stack.pop;

        break;
end;
}

254 : //(0xfe) impdep1
// 자료 없음
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
end;

255 : //(0xff) impdep2
// 자료 없음
begin
                raise Exception.Create('$$$$$'); inc(codeOffset);
end;


end; // case of

end; // while

except
        on e: Exception do writeln( 'in Exception to interpreter.Exceute : ' + e.Message );
end; // try

decInterpreterThreadCounter ;
end;
//
// ---------------------------- Execute End ------------------------------------
//





procedure interpreterClass.run;
begin
        // thread 가 언제 시작할지 몰라 여기서 증가시킨다
        incInterpreterThreadCounter();

        Resume;
end;






// imnport from runtimeenvironment
{function interpreterClass.getfileIOStream( ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getfileIOStream));
        processResquester.writeMessage(msg);
        msg := processResquester.getMessage;
        result := strtoint( msg );
end;}

function interpreterClass.appendArray(  var arrayInst : arrayInstanceClass ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_appendArray));
        msg := msg + ':' + arrayInstanceClass.getClassData(arrayInst);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

procedure interpreterClass.appendClassHecheri( newInstanceIndex : integer ; loadedClassIndex : integer );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_appendClassHecheri));
        msg := msg + ':' + inttostr(newInstanceIndex);
        msg := msg + ':' + inttostr(loadedClassIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
end;

function interpreterClass.getNewInstance() : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getNewInstance));
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

procedure interpreterClass.appendField( newInstanceIndex : integer ; fieldName : string ; fieldValue : integer );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_appendField));
        msg := msg + ':' + inttostr(newInstanceIndex);
        msg := msg + ':' + fieldName;
        msg := msg + ':' + inttostr(fieldValue);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;        
end;

function interpreterClass.getFieldIndex( newInstanceIndex : integer ; fieldName : string ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getFieldIndex));
        msg := msg + ':' + inttostr(newInstanceIndex);
        msg := msg + ':' + fieldName;
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getFieldValue( newInstanceIndex : integer ; fieldIndex : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getFieldValue));
        msg := msg + ':' + inttostr(newInstanceIndex);
        msg := msg + ':' + inttostr(fieldIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

procedure interpreterClass.setFieldValue( newInstanceIndex : integer ; fieldIndex : integer ; fieldValue : integer );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_setFieldValue));
        msg := msg + ':' + inttostr(newInstanceIndex);
        msg := msg + ':' + inttostr(fieldIndex);
        msg := msg + ':' + inttostr(fieldValue);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
end;

function interpreterClass.getOverridingMethodClassName(newInstanceIndex : integer ; methodName : string ) : string;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getOverridingMethodClassName));
        msg := msg + ':' + inttostr(newInstanceIndex);
        msg := msg + ':' + methodName;
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := msg;
end;

procedure interpreterClass.appendClass( className : string );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_appendClass));
        msg := msg + ':' + className;
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
end;

function interpreterClass.getLoadedClassIndex( name : string) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getLoadedClassIndex));
        msg := msg + ':' + name;
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getLoadedClassName( index : integer ) : string;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getLoadedClassName));
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := msg;
end;

procedure interpreterClass.incInterpreterThreadCounter();
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_incInterpreterThreadCounter));
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
end;


procedure interpreterClass.decInterpreterThreadCounter();
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_decInterpreterThreadCounter));
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        self.Free;
end;

procedure interpreterClass.callInvokeSpecial( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
var
        j,k,m : integer;
begin
        // 로드될 클래스의 인덱스를 얻늗다
        j := self.getLoadedClassIndex( callClassName );
        if j = -1 then
        begin
                self.appendClass( callClassName );
                j := self.getLoadedClassIndex( callClassName );
        end;

        // 클래스의 메소드를 얻는다
        k := self.getMethodsIndex(j,callMethodName);

        // native 메소드를 검사한다.
        m := getAccessFlagLoadedClassByIndexMethodsByIndex(j,k) and ACC_NATIVE;
        if m = ACC_NATIVE then
        begin
                //m := getMethodArgsVariableNumber( j , k );
                self.callNativeMethod( callClassName, callMethodName , stack , false );//, m );
                inc(codeOffset);
                inc(codeOffset);
                inc(codeOffset);
                // stack.pop; // virtual 호출은 this 인자를 가지고 있기 대문에 this를 삭제 하여 준다.
                // new
                // 그런데 리턴타입때문에 callNativeMethod에서 this 값을 제거 하게 한다.

                exit;
        end;


        self.callMethodType2( j, k, loadedClassIndex, methodIndex, codeOffset, variableOffset , codeAttr, stack );

        self.appendClassHecheri( stack.buffer[variableOffset], loadedClassIndex );
end;

procedure interpreterClass.callInvokeVirtual( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
var
        j,k,m,n : integer;
        s1 : string;
begin
        // 로드될 클래스의 인덱스를 얻늗다
        j := self.getLoadedClassIndex( callClassName );
        if j = -1 then
        begin
                self.appendClass( callClassName );
                j := self.getLoadedClassIndex( callClassName );
        end;


        // 클래스의 메소드를 얻는다
        k := self.getMethodsIndex(j,callMethodName);

        // native 메소드를 검사한다.
        m := getAccessFlagLoadedClassByIndexMethodsByIndex(j,k) and ACC_NATIVE;
        if m = ACC_NATIVE then
        begin
                //m := getMethodArgsVariableNumber( j , k );
                self.callNativeMethod( callClassName, callMethodName , stack , false );//, m );
                inc(codeOffset);
                inc(codeOffset);
                inc(codeOffset);
                // stack.pop; // virtual 호출은 this 인자를 가지고 있기 대문에 this를 삭제 하여 준다.
                // new
                // 그런데 리턴타입때문에 callNativeMethod에서 this 값을 제거 하게 한다.

                exit;
        end;

        if j = loadedClassIndex then
        begin
                // this를 포함한 인자갯수를 얻는다.
                m := self.getMethodArgsVariableNumber( j , k );
                // this값
                n := stack.buffer[ stack.statckOffset - m ];

                //
                // n -> this가 null이면 할달되지 않은 더미 객체로 판단한다.
                //
                //
                // bootloaderModule 에서 0번째 값을 넣었다. 
                //

                // 2003-7-2
                // static 객체에 널을 할당하지 않고 new을 함으로써 해결했다.
                // 따라서 더이상 0번째 객체를 사용하지 않는 코드가 필요 없다.
//                if n <> 0 then
//                begin
                        s1 := self.getOverridingMethodClassName(n , callMethodName );
                        if s1 <> '' then
                        begin
                                j := self.getLoadedClassIndex(s1);
                                k := self.getMethodsIndex(j,callMethodName);
                        end;
//                end;
        end;


        self.callMethodType2( j, k, loadedClassIndex, methodIndex, codeOffset, variableOffset , codeAttr, stack );
end;

procedure interpreterClass.callInvokeStatic( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
var
        j,k,m : integer;
begin
        // 로드될 클래스의 인덱스를 얻늗다
        j := self.getLoadedClassIndex( callClassName );
        if j = -1 then
        begin
                self.appendClass( callClassName );
                j := self.getLoadedClassIndex( callClassName );
        end;

        // 클래스의 메소드를 얻는다
        k := self.getMethodsIndex(j,callMethodName);

        // native 메소드를 검사한다.
        //
        // 현재 까지는 static navive method 가 없다.
        //
        m := getAccessFlagLoadedClassByIndexMethodsByIndex(j,k) and ACC_NATIVE;
        if m = ACC_NATIVE then
        begin
                //m := getMethodArgsVariableNumber( j , k );
                // native method가 static이면 true 를 넘겨준다.
                self.callNativeMethod( callClassName , callMethodName , stack , true );//, m );
                inc(codeOffset);
                inc(codeOffset);
                inc(codeOffset);
                // stack.pop; static은 this 없기 대문에 빼주기 않는다. callNativeMethod에서는 실제 인자만 pop한다.
                // new
                // 그런데 리턴타입때문에 callNativeMethod에서 this 값을 제거 하게 한다.
                // 스텍에 loadedClassIndex, methodIndex, codeOffset, variableOffset 을 저장하지 않는다
                // 호출된 쪽에서 스택을 정리하고 하는 것이 맞다
                exit;
        end;

        self.callMethodType2( j, k, loadedClassIndex, methodIndex, codeOffset, variableOffset , codeAttr, stack );
end;

{procedure interpreterClass.callMethodType1( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
var
        j,k,m,n : integer;
begin
        // 로드될 클래스의 인덱스를 얻늗다
        j := self.getLoadedClassIndex( callClassName );

        // 클래스의 메소드를 얻는다
        k := self.getMethodsIndex(j,callMethodName);

        // 메소드의 메소드 변수를 얻는다
        m := getMethodLocalVariableNumber( j , k );

        // 지정된 메소드 변수 만큼 스택을 늘린다
        for n:=0 to m - 1 do stack.push(0);

        // 해당 메소드의 변수 인덱스를 저장한다.
        m := stack.statckOffset - getTotalLocalVariableNumber( j , k );

        // 리턴시 실행할 codeoffset를 증가시킨다
        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);

        // 리턴시 사용할 데이타들을 스택에 저장한다
        stack.push( loadedClassIndex );
        stack.push( methodIndex );
        stack.push( codeOffset );
        stack.push( variableOffset );

        // 호출 메소드를 실행하기 위해 초기화를 한다.
        loadedClassIndex := j;
        methodIndex := k;
        codeOffset := 0;
        variableOffset := m;

        codeAttr := getCodeAttribute( loadedClassIndex , methodIndex );
end;}

procedure interpreterClass.callMethodType2( findLoadedClassIndex : integer ; findMethodIndex : integer; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
var
        j,k,m,n : integer;
begin
        // 로드될 클래스의 인덱스를 얻늗다
        j := findLoadedClassIndex;

        // 클래스의 메소드를 얻는다
        k := findMethodIndex;

        // 메소드의 메소드 변수를 얻는다
        m := getMethodLocalVariableNumber( j , k );

        // 지정된 메소드 변수 만큼 스택을 늘린다
        for n:=0 to m - 1 do stack.push(0);

        // 해당 메소드의 변수 인덱스를 저장한다.
        m := stack.statckOffset - getTotalLocalVariableNumber( j , k );

        // 리턴시 실행할 codeoffset를 증가시킨다
        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);

        // 리턴시 사용할 데이타들을 스택에 저장한다
        stack.push( loadedClassIndex );
        stack.push( methodIndex );
        stack.push( codeOffset );
        stack.push( variableOffset );

        // 호출 메소드를 실행하기 위해 초기화를 한다.
        loadedClassIndex := j;
        methodIndex := k;
        codeOffset := 0;
        variableOffset := m;

        codeAttr := getCodeAttribute( loadedClassIndex , methodIndex );
end;

{procedure interpreterClass.callMethodType3( findLoadedClassIndex : integer ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
begin
end;}

{procedure interpreterClass.callMethodType4( callClassName : string ; findMethodIndex : integer; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
begin
end;}

procedure interpreterClass.returnMethod( var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
var
        i, j : integer;
begin
        i := getTotalLocalVariableNumber( loadedClassIndex , methodIndex );

        variableOffset := stack.pop;
        codeOffset := stack.pop;
        methodIndex := stack.pop;
        loadedClassIndex := stack.pop;

        codeAttr := getCodeAttribute( loadedClassIndex , methodIndex );

        // delete variable
        for j:=0 to i - 1 do stack.pop;
end;

procedure interpreterClass.callNativeMethod( nativeClassName : string ; nativeMethodName : string ; var stack : stackClass ; isStatic : boolean );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_callNativeMethod));
        msg := msg + ':' + nativeClassName;
        msg := msg + ':' + nativeMethodName;
        msg := msg + ':' + stackClass.getClassData(stack);
        msg := msg + ':' + utilclass.booleanTostr( isStatic );
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        self.stack := stackClass.setClassData(msg);
end;

procedure interpreterClass.appendStaticField( fieldName : string ; fieldValue : integer );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_appendStaticField));
        msg := msg + ':' + fieldName;
        msg := msg + ':' + inttostr(fieldValue);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
end;

function interpreterClass.getStaticFieldIndexByFieldName( fieldName : string ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getStaticFieldIndexByFieldName));
        msg := msg + ':' + fieldName;
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;
function interpreterClass.getStaticFieldValue( fieldIndex : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getStaticFieldValue));
        msg := msg + ':' + inttostr(fieldIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

procedure interpreterClass.setStaticFieldValue( fieldIndex : integer ; fieldValue : integer );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_setStaticFieldValue));
        msg := msg + ':' + inttostr(fieldIndex);
        msg := msg + ':' + inttostr(fieldValue);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
end;

{procedure interpreterClass.getStringByStringInstance( var s : string ; newInstanceIndex : integer );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getStringByStringInstance));
        msg := msg + ':' + inttostr(newInstanceIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        s := msg;
end;}

{function interpreterClass.getUTF8Name( loadedClassIndex : integer ; constantPoolIndex : integer ) : string;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getUTF8Name));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(constantPoolIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := msg ;
end;}

{function interpreterClass.getClassInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ) : string;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getClassInfoName));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(constantPoolIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := msg ;
end;}

{function interpreterClass.getNameAndTypeName( loadedClassIndex : integer ; constantPoolIndex : integer) : string;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getNameAndTypeName));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(constantPoolIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := msg ;
end;}

procedure interpreterClass.getMethodRefInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ; var className : string ; var nameAndType : string ) ;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getMethodRefInfoName));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(constantPoolIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        utilClass.getToken(msg,':',className);
        utilClass.getToken('',':',nameAndType);
end;

procedure interpreterClass.getFieldRefInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ; var className : string ; var nameAndType : string ) ;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getFieldRefInfoName));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(constantPoolIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        utilClass.getToken(msg,':',className);
        utilClass.getToken('',':',nameAndType);
end;

{function interpreterClass.getMethodsIndexWithAccessFlag( loadedClassIndex : integer ; accessFlag : integer ; name : string ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getMethodsIndexWithAccessFlag));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(accessFlag);
        msg := msg + ':' + name;
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;}

function interpreterClass.getMethodsIndex( loadedClassIndex : integer ; name : string ) : integer ;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getMethodsIndex));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + name;
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getTotalLocalVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getTotalLocalVariableNumber));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(methodsIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getMethodLocalVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getMethodLocalVariableNumber));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(methodsIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getMethodArgsVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getMethodArgsVariableNumber));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(methodsIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getMethodname( loadedClassIndex : integer ; methodsIndex : integer ) : string;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getMethodname));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(methodsIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := msg;
end;

function interpreterClass.getCodeAttribute( loadedClassIndex : integer ; methodsIndex : integer) : codeAttribute;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getCodeAttribute));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(methodsIndex);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        self.ca := codeAttribute.setClassData(msg);
        result := self.ca;// 메모리 누수가 일어날 것이다...
end;

function interpreterClass.getInterpreterThreadCounter() : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getInterpreterThreadCounter));
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getLoaderClassIndex() : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getLoaderClassIndex));
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getNewInstanceIndex() : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getNewInstanceIndex));
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getArrayInstanceStructIndex() : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getArrayInstanceStructIndex));
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

// 추가 된것.
function interpreterClass.getConstantPoolTagByIndex( loadedClassIndex : integer ; index : integer ) : byte;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getConstantPoolTagByIndex));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := byte(strtoint( msg ));
end;

function interpreterClass.getConstantPoolconstantIntegerBytesByIndex( loadedClassIndex : integer ; index : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getConstantPoolconstantIntegerBytesByIndex));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;


function interpreterClass.getConstantPoolconstantStringstringIndexByIndex( loadedClassIndex : integer ; index : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getConstantPoolconstantStringstringIndexByIndex));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getConstantPoolconstantUTF8InfolengthByIndex( loadedClassIndex : integer ; index : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getConstantPoolconstantUTF8InfolengthByIndex));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getConstantPoolconstantUTF8InfoBytesByIndex( loadedClassIndex : integer ; index : integer ) : pchar;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getConstantPoolconstantUTF8InfoBytesByIndex));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := @msg[1];
end;

function interpreterClass.getConstantPoolconstantLongbytesByIndex( loadedClassIndex : integer ; index : integer ) : int64;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getConstantPoolconstantLongbytesByIndex));
        msg := msg + ':' + inttostr(loadedClassIndex);
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := utilclass.convertStringToInt64( msg ); // int64 hexa string
end;

function interpreterClass.getStaticFieldIndex : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getStaticFieldIndex));
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getStaticFieldnameByIndex( index : integer ) : string;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getStaticFieldnameByIndex));
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := msg;
end;

function interpreterClass.getStaticFieldvalueByIndex( index : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getStaticFieldvalueByIndex));
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getNewInstanceClassByIndexclassHecheriIndex( index : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getNewInstanceClassByIndexclassHecheriIndex));
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getNewInstanceClassByIndexclassHecheriIndexByLoadedClassIndexByIndex( index1 : integer ; index2 : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getNewInstanceClassByIndexclassHecheriIndexByLoadedClassIndexByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getNewInstanceClassByIndexIndex( index : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getNewInstanceClassByIndexIndex));
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getNewInstanceClassByIndexnameByIndex( index1 : integer ; index2 : integer ) : string;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getNewInstanceClassByIndexnameByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := msg;
end;

function interpreterClass.getNewInstanceClassByIndexvalueByIndex( index1 : integer ; index2 : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getNewInstanceClassByIndexvalueByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getArrayInstanceStructByIndexarrayType( index : integer ) : byte;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getArrayInstanceStructByIndexarrayType));
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := byte(strtoint( msg ));
end;

function interpreterClass.getArrayByIndexintArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getArrayByIndexintArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );
end;

function interpreterClass.getArrayByIndexlongArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : int64;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getArrayByIndexlongArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := utilclass.convertStringToInt64( msg ); // int64 hexa string
end;

function interpreterClass.getArrayByIndexbyteArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : byte;
var
        msg : string;
        ab : array[0..1] of byte;        
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getArrayByIndexbyteArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        utilclass.convertStringToByte( msg , ab );
        result := ab[0];
end;

function interpreterClass.getArrayByIndexcharArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : char;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getArrayByIndexcharArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := msg[1];
end;

procedure interpreterClass.setArrayByIndexintArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : integer );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_setArrayByIndexintArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        msg := msg + ':' + inttostr(v);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
end;

procedure interpreterClass.setArrayByIndexlongArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : int64 );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_setArrayByIndexlongArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        msg := msg + ':' + inttostr(v);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
end;

procedure interpreterClass.setArrayByIndexbyteArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : byte );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_setArrayByIndexbyteArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        msg := msg + ':' + inttostr(v);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
end;

procedure interpreterClass.setArrayByIndexcharArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : char );
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_setArrayByIndexcharArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        msg := msg + ':' + v;
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
end;

function interpreterClass.getArraySizeByIndexintArrayInstanceClassDataByIndex( index : integer  ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getArraySizeByIndexintArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );        
end;

function interpreterClass.getArraySizeByIndexlongArrayInstanceClassDataByIndex( index : integer  ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getArraySizeByIndexlongArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );        
end;

function interpreterClass.getArraySizeByIndexbyteArrayInstanceClassDataByIndex( index : integer  ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getArraySizeByIndexbyteArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );        
end;

function interpreterClass.getArraySizeByIndexcharArrayInstanceClassDataByIndex( index : integer  ) : integer;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getArraySizeByIndexcharArrayInstanceClassDataByIndex));
        msg := msg + ':' + inttostr(index);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := strtoint( msg );        
end;

function interpreterClass.getAccessFlagLoadedClassByIndexMethodsByIndex( index1 : integer ; index2 : integer ) : word;
var
        msg : string;
begin
        msg := inttostr(ord(PROCESS_MESSAGE_ID_getAccessFlagLoadedClassByIndexMethodsByIndex));
        msg := msg + ':' + inttostr(index1);
        msg := msg + ':' + inttostr(index2);
        DPMResquester.writeMessage(msg);
        msg := DPMResquester.getMessage;
        result := word(strtoint( msg ));
end;

end.
