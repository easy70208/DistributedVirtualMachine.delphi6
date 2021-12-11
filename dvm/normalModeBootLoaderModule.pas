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
                // boot loader������ ó���ϴ� �κ�.
                // runtimeEnvironment�� Thread start �ڵ�� ����ϴ� '* '�ΰ��� ����....
                // runtimeenvironment ����
                runtimeEnvironment := runtimeEnvironmentClass.Create( classPath , coredump ) ; // coredump ���� -> �ٸ� ���������͸� �����ÿ� ���ڷ� ���� Thread->start
                className := utilClass.changeCharbyChar( className , '.' , '/' );
                runtimeEnvironment.appendClass( className );

                //(runtimeEnvironment.getLoadedClassObject(0) as classLoader).coreDump;readln;exit;

                //���������� ����
                //*
                interpreter := interpreterClass.Create('MainThread__'+utilclass.getTodayDateTime, coredump);
                // runtimeEnvironemt ����
                // *
                interpreter.runtimeEnvironment := runtimeEnvironment;
                //interpreter.name := 'MainThread';
                //interpreter.coredump := coredump;
                // ���ڰ� ����
                // *
                interpreter.stack.push(0); // dump main(String[] args)

                // ���� ���� ����
                interpreter.loadedClassIndex := 0;
                interpreter.methodIndex := runtimeEnvironment.getMethodsIndexWithAccessFlag( interpreter.loadedClassIndex, $0009 , 'main([Ljava/lang/String;)V' );
                interpreter.codeOffset := 0;
                interpreter.variableOffset := 0;//interpreter.stack.statckOffset - runtimeEnvironment.getTotalLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
                interpreter.codeAttr := runtimeEnvironment.getCodeAttribute( interpreter.loadedClassIndex , interpreter.methodIndex );

                // ���� ���� ����
                interpreter.exitClassIndex := interpreter.loadedClassIndex ;
                interpreter.exitMethodIndex := interpreter.methodIndex ;

                // ���� ���� ���� Ȯ��
                j := runtimeEnvironment.getMethodLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
                for i:=0 to j - 1 do interpreter.stack.push(0);

                // clinit ȣ��...
                j := runtimeEnvironment.getMethodsIndex( interpreter.loadedClassIndex , '<clinit>()V' );
                if j <> -1 then
                begin
                        //
                        // callMethod���� codeOffset�� 3 ���ϱ� ������ 3�� ���Ѵ�.
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
                this ������ null �� ��� �� �ִ� ���� �����ϱ� ���� ���� new �� �����Ѵ�
                �׷��� ������ 1 ���� �Ҵ��� �ȴ�.
                ���� this�� 0�̸� null�� ���� �Ҽ� �ֵ�>
        }
        // 2003-06-04
        // �� null�� ����ϸ� �ȵŴ��� �𸣰ڴ�.
        // �׷��� �ּ�ó���� �ߴ�

                        // �ٽ� �װ� �ƴϰ� overriding�����̴�. ��ü�� null�� ���� �Ͱ� �ν��Ͻ� 0��°��
                        // �Ҵ��� �����Ͱ� overridng�Ҵ� ������ ���� �ʴ´�. �׷��� �׷���......
                        // callInvokeVirtual �κ��� �����϶�.

                        // �ٽ� �ϸ� 0��° �Ҵ���� �ν��Ͻ����� �޼ҵ带 ȣ���ϸ� overrindg�� ó���ϰ� �Ǵµ�
                        // �̰� null������ �˼� ���Եȴ�.
                        // ���� 0���� �ν��Ͻ� ������ ����� �Ѵ�.


        // 2003-7-2
        // static ��ü�� ���� �Ҵ����� �ʰ� new�� �����ν� �ذ��ߴ�.
        // ���� ���̻� 0��° ��ü�� ������� �ʴ� �ڵ尡 �ʿ� ����.
        //runtimeEnvironment.getNewInstance;

         //public static PrintStream out = new PrintStream();

        {
                ���̻� ������ �ʴ���.

        // �̰� ������ boot loader �ڵ尡 �ʿ��ϴ�.
        // ����
        // bootLoader�� load�� callMethod�� ó���ҷ��� ����ߴ�.
        // ó�� ���� �ʵǴ� ���̿���.
        // ù°�� �Ʒ� �ڵ�� ��°�� callMethod���� codeoffset�� 3�� ���ϱ� �����̴�.
        // �׷��� ������ bootloader�ڵ尡 �ݵ�� �ʿ��ϴ�
        // �ణ �ߺ����� �ִ°����� ������ �׷��� �ʴ�.
        runtimeEnvironment.setThreadExitCode( interpreter.codeAttr );

        }


        { getstaticField or putstatcField�� ȣ��ɶ� clinit�� ȣ���ϵ��� �����Ͽ���.
        i := runtimeEnvironment.getMethodsIndex( interpreter.loadedClassIndex , '<clinit>()V' );
        if i <> -1 then
        begin
                // <clinit>�� constant pool���� MethodRefInfo���·� ���������ʰ� UTF8������ ������ �Ѵ� �x��
                // self.runtimeEnvironment.getMethodRefInfoName�� �˻��Ҽ� �� ����.
                // methods���� �����ϱ� �����̴�.
                // �̰��� �ٸ� ������ ȣ������ �ʰ� VM���� �ڵ����� ȣ��Ǳ� �빮�ΰ� ����.
                //x
                runtimeEnvironment.callMethod( className , '<clinit>()V', interpreter.loadedClassIndex , interpreter.methodIndex,
                        interpreter.codeOffset, interpreter.variableOffset,
                        interpreter.codeAttr, interpreter.stack );
                //x
                //
                // callMethod���� invokestatic�� ��ɾ� ��ŭ 3����Ʈ�� ������Ű�� ������ ����Ҽ� ���� �Ǿ���....
                // �ᱹ�� ȣ���� ���ϴ� ������ ������ ��ο� ����� �ϴٰ� �̷��� bootloader�� �ʿ伺�� ���ݴ� ���Ⱑ �Ǿ���....
                // ��ġ�ٴ�....
                // �׷��� <clinit>�� �ڵ��� �߰��� ���Ҵ�.
                //

                // ���Ͻ� ����� ����Ÿ���� ���ÿ� �����Ѵ�
                interpreter.stack.push( interpreter.loadedClassIndex );
                interpreter.stack.push( interpreter.methodIndex );
                interpreter.stack.push( interpreter.codeOffset );
                interpreter.stack.push( interpreter.variableOffset );

                interpreter.methodIndex := i;

                //
                // �� �κ��� �ʿ� ����. clinit�� ���ڰ� ���� �޼ҵ� ������ ����
                //
                //x
                // �޼ҵ��� �޼ҵ� ������ ��´�
                i := runtimeEnvironment.getMethodLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
                // ������ �޼ҵ� ���� ��ŭ ������ �ø���
                for j:=0 to i - 1 do interpreter.stack.push(0);
                // �ش� �޼ҵ��� ���� �ε����� �����Ѵ�.
                interpreter.variableOffset := interpreter.stack.statckOffset - runtimeEnvironment.getTotalLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
                //x

                interpreter.codeAttr := runtimeEnvironment.getCodeAttribute( interpreter.loadedClassIndex , interpreter.methodIndex );


        end;
        }



end.




