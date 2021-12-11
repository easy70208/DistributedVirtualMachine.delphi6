unit normalModeBootLoaderModule;

interface

uses
        sysutils, Classes, normalModeRuntimeEnvironmentModule,
        normalModeInterpreterModule, componentModule,globalDefine;
type
        bootLoaderClass = class
        private
                interpreter : interpreterClass;
        public
                procedure load( var runtimeEnvironment : runtimeEnvironmentClass );
                procedure help;
        end;

implementation

procedure bootLoaderClass.help;
begin
        write(DVM_VERSION); writeln( ' - dvm' );
        writeln('dvm -classpath|-cp /pathname/ [-coredump|-c] classname');
        writeln('examples');
        writeln('dvm -classpath ./classlib/classes/ sampleProgram' );
        writeln('dvm -cp ./classlib/classes/ -c sampleProgram');
end;

procedure bootLoaderClass.load( var runtimeEnvironment : runtimeEnvironmentClass );
var
        i,j : integer;

        classPath : string;
        className : string;
        coredump : boolean;
begin

        try
                i := 1;
                classPath := '';
                className := '';
                coredump := false;

                if ParamCount = 0 then help;

                while i <= ParamCount do
                begin
                        if ParamStr( i ) = '-classpath' then
                        begin
                                inc(i);
                                classPath := ParamStr(i);
                        end
                        else
                        if ParamStr( i ) = '-cp' then
                        begin
                                inc(i);
                                classPath := ParamStr(i);
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
                        begin
                                className := ParamStr(i);
                        end;

                        inc(i);
                end;

                if classPath = '' then raise Exception.Create('classPath not found');

                if className = '' then raise Exception.Create('classfile not found');

                //
                // boot loader에서만 처리하는 부분.
                // runtimeEnvironment의 Thread start 코드와 비슷하다 '* '인곳만 빼고....
                // runtimeenvironment 생성
                runtimeEnvironment := runtimeEnvironmentClass.Create( classPath , coredump ) ; // coredump 저장 -> 다른 인터프리터를 생성시에 인자로 사용됨 Thread->start
                className := utilClass.changeCharbyChar( className , '.' , '/' );
                runtimeEnvironment.appendClass( className );

                //(runtimeEnvironment.getLoadedClassObject(0) as classLoader).coreDump;readln;exit;

                //인터프리터 생성
                //*
                interpreter := interpreterClass.Create('MainThread__'+utilclass.getTodayDateTime, coredump);
                // runtimeEnvironemt 설정
                // *
                interpreter.runtimeEnvironment := runtimeEnvironment;
                //interpreter.name := 'MainThread';
                //interpreter.coredump := coredump;
                // 인자값 설정
                // *
                interpreter.stack.push(0); // dump main(String[] args)

                // 실행 정보 설정
                interpreter.loadedClassIndex := 0;
                interpreter.methodIndex := runtimeEnvironment.getMethodsIndexWithAccessFlag( interpreter.loadedClassIndex, $0009 , 'main([Ljava/lang/String;)V' );
                interpreter.codeOffset := 0;
                interpreter.variableOffset := 0;//interpreter.stack.statckOffset - runtimeEnvironment.getTotalLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
                interpreter.codeAttr := runtimeEnvironment.getCodeAttribute( interpreter.loadedClassIndex , interpreter.methodIndex );

                // 종료 정보 설정
                interpreter.exitClassIndex := interpreter.loadedClassIndex ;
                interpreter.exitMethodIndex := interpreter.methodIndex ;

                // 로컬 변수 영역 확보
                j := runtimeEnvironment.getMethodLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
                for i:=0 to j - 1 do interpreter.stack.push(0);

                // clinit 호출...
                j := runtimeEnvironment.getMethodsIndex( interpreter.loadedClassIndex , '<clinit>()V' );
                if j <> -1 then
                begin
                        //
                        // callMethod에서 codeOffset를 3 더하기 때문에 3을 감한다.
                        //
                        dec(interpreter.codeOffset);
                        dec(interpreter.codeOffset);
                        dec(interpreter.codeOffset);
                        runtimeEnvironment.callMethodType2( interpreter.loadedClassIndex,
                                j , interpreter.loadedClassIndex ,
                                interpreter.methodIndex , interpreter.codeOffset ,
                                interpreter.variableOffset , interpreter.codeAttr,
                                interpreter.stack );
                end;

                interpreter.run;
        except
                on e: Exception do writeln( e.Message );
        end;
end;



        {
                this 변수에 null 이 들어 가 있는 것을 구별하기 위해 더미 new 를 시행한다
                그러면 시작은 1 부터 할당이 된다.
                따라서 this가 0이면 null로 간주 할수 있따>
        }
        // 2003-06-04
        // 왜 null을 사용하면 안돼는지 모르겠다.
        // 그래서 주석처리를 했다

                        // 다시 그게 아니고 overriding때문이다. 객체에 null을 넣은 것과 인스턴스 0번째에
                        // 할당을 받은것과 overridng할대 구별이 가지 않는다. 그래서 그렇다......
                        // callInvokeVirtual 부분을 참조하라.

                        // 다시 하면 0번째 할당받은 인스턴스에서 메소드를 호출하면 overrindg을 처리하게 되는데
                        // 이게 null인지는 알수 없게된다.
                        // 따라서 0번재 인스턴스 변수를 비워야 한다.


        // 2003-7-2
        // static 객체에 널을 할당하지 않고 new을 함으로써 해결했다.
        // 따라서 더이상 0번째 객체를 사용하지 않는 코드가 필요 없다.
        //runtimeEnvironment.getNewInstance;

         //public static PrintStream out = new PrintStream();

        {
                더이상 사용되지 않느다.

        // 이것 때문에 boot loader 코드가 필요하다.
        // 유머
        // bootLoader의 load를 callMethod로 처리할려고 고심했다.
        // 처음 부터 않되는 것이였다.
        // 첫째는 아래 코드고 둘째는 callMethod에서 codeoffset에 3을 더하기 때문이다.
        // 그렇기 때문에 bootloader코드가 반드시 필요하다
        // 약간 중복감이 있는것지만 실제는 그렇지 않다.
        runtimeEnvironment.setThreadExitCode( interpreter.codeAttr );

        }


        { getstaticField or putstatcField가 호출될때 clinit를 호출하도록 변경하였다.
        i := runtimeEnvironment.getMethodsIndex( interpreter.loadedClassIndex , '<clinit>()V' );
        if i <> -1 then
        begin
                // <clinit>는 constant pool에서 MethodRefInfo형태로 존재하지않고 UTF8형으로 만존재 한다 땨라서
                // self.runtimeEnvironment.getMethodRefInfoName로 검색할수 가 없다.
                // methods에만 존재하기 때문이다.
                // 이것은 다른 곳에서 호출하지 않고 VM에서 자동으로 호출되기 대문인것 같다.
                //x
                runtimeEnvironment.callMethod( className , '<clinit>()V', interpreter.loadedClassIndex , interpreter.methodIndex,
                        interpreter.codeOffset, interpreter.variableOffset,
                        interpreter.codeAttr, interpreter.stack );
                //x
                //
                // callMethod에서 invokestatic의 명령어 만큼 3바이트를 증가시키기 때문에 사용할수 없게 되었다....
                // 결국은 호출을 못하는 문제를 가지고 고민에 고민을 하다가 이렇게 bootloader의 필요성을 깨닫는 개기가 되었다....
                // 미치겟다....
                // 그러나 <clinit>의 코드의 추가는 좋았다.
                //

                // 리턴시 사용할 데이타들을 스택에 저장한다
                interpreter.stack.push( interpreter.loadedClassIndex );
                interpreter.stack.push( interpreter.methodIndex );
                interpreter.stack.push( interpreter.codeOffset );
                interpreter.stack.push( interpreter.variableOffset );

                interpreter.methodIndex := i;

                //
                // 이 부분은 필요 없다. clinit는 인자가 없고 메소드 변수도 없다
                //
                //x
                // 메소드의 메소드 변수를 얻는다
                i := runtimeEnvironment.getMethodLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
                // 지정된 메소드 변수 만큼 스택을 늘린다
                for j:=0 to i - 1 do interpreter.stack.push(0);
                // 해당 메소드의 변수 인덱스를 저장한다.
                interpreter.variableOffset := interpreter.stack.statckOffset - runtimeEnvironment.getTotalLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
                //x

                interpreter.codeAttr := runtimeEnvironment.getCodeAttribute( interpreter.loadedClassIndex , interpreter.methodIndex );


        end;
        }



end.




