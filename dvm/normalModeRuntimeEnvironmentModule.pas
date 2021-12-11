unit normalModeRuntimeEnvironmentModule;

//{$DEFINE DEBUG}

interface

uses
        sysutils, classLoaderModule, componentModule, classes, distributedFileSystemModule,globalDefine, SyncObjs;

type
        runtimeEnvironmentClass = class(TThread)
        protected
                procedure Execute; override;         
        private
                // ���������Ϳ��� �����ڵ带 ������ ���������͸��� �ϱ� ����
                // �ι��̷���Ʈ �����ڵ带 �����߰���
                // �׷��� �ι��̷���Ʈ �����鿡 ���� ������ �ڵ带 ���� �Է��ؾ� �ϱ� ������
                // �̷��� Ǯ�� ���Ҵ�.
                // 2003-7-24
                // ���������Ͱ� ���� ��忡�� ����� ���� ����Ǹ� �� ������ �ʿ� �ϱ� �빮��
                // �̰��� �ٽ� �޼���� �����Ѵ�.

                 // ���������Ͱ� �����ɶ� ���� �� ���� �ݵ�� ���� ���Ѿ� �Ѵ�.
                interpreterThreadCounter : integer;

                // �޸𸮿� �ε�� Ŭ������ �ε���
                loaderClassIndex : integer;
                loadedClass : array[0..1000000] of classLoaderClass;

                // ����ƽ �ʵ��� Ŭ���� ����
                staticField : nameAndValueClass;

                // new�� ������ Ŭ���� ����
                newInstanceIndex : integer;
                newInstance : array[0..10000000] of newInstanceClass;

                // �迭 ����
                arrayInstanceIndex : integer;
                arrayInstance : array[0..1000000] of arrayInstanceClass;

                // ��Ʈ�� �� �ִ� ���� ������ cpu Power�� ����
                cpuPowerIndex : integer;
                cpuPowerip : array[0..100] of string;
                cpuPower : array[0..100] of string;

                // ��Ʈ�� �� �ִ� �л� ���� �ý��� ������ ����
                diskPowerIndex : integer;
                diskPowerip : array[0..100] of string;
                diskPowerSize : array[0..100] of integer;

                classPath : string;
                coredumpflag : boolean;

                // config
                dvmConfig : configClass;

                // udp message listener
                // IMES : Instance Message Exchange System
                IMES : indyConsoleUDPMessageClass;

                // tcp processer listener
                // DPM : Distributed Process Manager
                DPMListener : indyConsoleTcpServerClass;

                // FileIn/Out Stream
                fileIOStreamIndex : integer;
                // Distrubuted File System
                DFSRequester : array[0..100] of distributedFileSystemRequestClass;

                tcsTCP : TCriticalSection;
                //tcsUDP : TCriticalSection;
        public
                constructor Create( classPath : string ; coredumpflag : boolean ) ;

                procedure mainLoop; // ���α׷��� ���� ������ ���α׷��� �̸� ����Ǵ� ���� ���´�.

        public
                // SYSTEM CALL DEFINE HERE//
                // ���� ����
                private function getfileIOStream() : integer; public // with fileIOStreamIndex

                // �迭 ����
                function appendArray( var arrayInst : arrayInstanceClass ) : integer; // with array
                private function getArray( index : integer ) : arrayInstanceclass; public
                // �߰��Ȱ�
                function getArrayInstanceStructByIndexarrayType( index : integer ) : byte; // �迭 Ÿ��
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

                // Ŭ���� ����
                procedure appendClassHecheri( newInstanceIndex : integer ; loadedClassIndex : integer ); // with newInstance
                function getNewInstance() : integer;
                procedure appendField( newInstanceIndex : integer ; fieldName : string ; fieldValue : integer );
                function getFieldIndex( newInstanceIndex : integer ; fieldName : string ) : integer;
                function getFieldValue( newInstanceIndex : integer ; fieldIndex : integer ) : integer;
                procedure setFieldValue( newInstanceIndex : integer ; fieldIndex : integer ; fieldValue : integer );
                function getOverridingMethodClassName(newInstanceIndex : integer ; methodName : string ) : string;
                // �߰� �Ȱ�
                function getNewInstanceClassByIndexclassHecheriIndex( index : integer ) : integer;
                function getNewInstanceClassByIndexclassHecheriIndexByLoadedClassIndexByIndex( index1 : integer ; index2 : integer ) : integer;
                function getNewInstanceClassByIndexIndex( index : integer ) : integer;
                function getNewInstanceClassByIndexnameByIndex( index1 : integer ; index2 : integer ) : string;
                function getNewInstanceClassByIndexvalueByIndex( index1 : integer ; index2 : integer ) : integer;


                // classLoaderClass ����
                procedure appendClass( className : string ); // with loadedclass
                function getLoadedClassIndex( name : string) : integer;
                function getLoadedClassName( index : integer ) : string;
                //function getLoadedClassObject( index : integer ) : classLoaderClass;

                // ���ͷ�Ʈ ����
                procedure incInterpreterThreadCounter; // with InterpreterThreadCounter
                procedure decInterpreterThreadCounter;

                // ����Ʈ �ڵ� ����
                // callMethod �޼���� constant Pool�� �������� �ʴ´�
                // methods �ڷῡ���� �̸��� ������ ������ �����Ѵ�
                // ���� : �Ʒ��� ��ɾ ����Ʈ�ڵ�� ȣ���ϴ� ���̾ƴ϶�� codeoffset ���� 3�� ���� ������Ѿ� �Ѵ�
                procedure callInvokeSpecial( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                procedure callInvokeVirtual( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                procedure callInvokeStatic( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                //procedure callMethodType1( callClassName : string ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                procedure callMethodType2( findLoadedClassIndex : integer ; findMethodIndex : integer; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                //procedure callMethodType3( findLoadedClassIndex : integer ; callMethodName : string; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
                //procedure callMethodType4( callClassName : string ; findMethodIndex : integer; var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );

                procedure returnMethod( var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );

                procedure callNativeMethod( nativeClassName : string ; nativeMethodName : string ; var stack : stackClass ; isStatic : boolean ); // with native method call

                // ����ƽ �ʵ� ����
                procedure appendStaticField( fieldName : string ; fieldValue : integer ); // with staticfield Ŭ�������ʵ���ʵ�Ÿ��
                function getStaticFieldIndexByFieldName( fieldName : string ) : integer; // �ʵ��̸��� ã�� �ε��� ��ġ
                function getStaticFieldValue( fieldIndex : integer ) : integer; // �ʵ���ġ �ε����� ã�� ��
                procedure setStaticFieldValue( fieldIndex : integer ; fieldValue : integer );
                // �߰� �Ȱ�
                function getStaticFieldIndex : integer; // ��ü �ʵ��� ����
                function getStaticFieldnameByIndex( index : integer ) : string;
                function getStaticFieldvalueByIndex( index : integer ) : integer;


                // String ����
                // String�� Ŭ�����̱� ������ newInstandIndex�� ���ڷ� ��� ����.
                private procedure getStringByStringInstance( var s : string ; newInstanceIndex : integer ); public // s�� ����� ��Ʈ��

                // with constant pool
                // ���⼭ ���Ǵ� constantPoolIndex�� ���Ǯ�� �ε����̴�. �װ��� ȥ���ϸ� �ʵȴ�.
                // ���� ���ڿ� ����
                // �ڹ� Ŭ���� ������ �ڽ��� ȣ���ϰ� ����ϴ� ��� �ڿ��� ��� Ǯ�� ��Ͻ��� ���´�. �̰��� �װ��� ��� �ִ�����
                // ����Ű�� ȭ��ǥ�� ����. �׷����� ���� �޼ҵ�� �ʵ带 methods�� fiels���� ã�´�.
                // �ֳ��ϸ� ����Ʈ�ڵ忡���� ���� �̸��� ����Ű�� �ʰ� ������� �ִ� �ε����� ����Ű�� �����̴�.
                // ���� �ڽ��� �޼ҵ带 �����ϴ� �޼ҵ嵵 �̿� ���� ������ ���ľ� �Ѵ�.
                private function getUTF8Name( loadedClassIndex : integer ; constantPoolIndex : integer ) : string; public                  // ��� Ǯ���� ���ǵȴ� ������ �ٸ� Ŭ������ �޼��� ���� , ū����(long), ���ڿ�, ����̴�
                private function getClassInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ) : string; public                  // Ŭ���� ID �˻� �ؼ� Ŭ���� �̸� ����
                private function getNameAndTypeName( loadedClassIndex : integer ; constantPoolIndex : integer) : string; public                 // �̸��� Ÿ��
                procedure getMethodRefInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ; var className : string ; var nameAndType : string ) ;                 //getClassInfoName, getNameAndTypeName�� ���ʷ� ȣ���Ͽ� ����
                procedure getFieldRefInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ; var className : string ; var nameAndType : string ) ;                 //getClassInfoName, getNameAndTypeName�� ���ʷ� ȣ���Ͽ� ����
                // �߰� �Ȱ�... classLoaderclass ��ü�� �������� �ʱ� ���ؼ�....
                function getConstantPoolTagByIndex( loadedClassIndex : integer ; index : integer ) : byte;
                function getConstantPoolconstantIntegerBytesByIndex( loadedClassIndex : integer ; index : integer ) : integer;
                function getConstantPoolconstantStringstringIndexByIndex( loadedClassIndex : integer ; index : integer ) : integer;
                function getConstantPoolconstantUTF8InfolengthByIndex( loadedClassIndex : integer ; index : integer ) : integer;
                function getConstantPoolconstantUTF8InfoBytesByIndex( loadedClassIndex : integer ; index : integer ) : pchar;
                function getConstantPoolconstantLongbytesByIndex( loadedClassIndex : integer ; index : integer ) : int64;
                function getAccessFlagLoadedClassByIndexMethodsByIndex( index1 : integer ; index2 : integer ) : word;

                // with methods
                // �Ʒ��� �ִ� ���� Ŭ������ ���� �����ϴ� �޼������ ������ methods �ڷ�������
                // �˻��� �Ѵ�.

                { boot loader ���� ��� } function getMethodsIndexWithAccessFlag( loadedClassIndex : integer ; accessFlag : integer ; name : string ) : integer;
                function getMethodsIndex( loadedClassIndex : integer ; name : string ) : integer ;
                function getTotalLocalVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;
                function getMethodLocalVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;

                function getMethodArgsVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;
                function getMethodname( loadedClassIndex : integer ; methodsIndex : integer ) : string;
                function getCodeAttribute( loadedClassIndex : integer ; methodsIndex : integer) : codeAttribute;

                // runtimeEnvironment ���� ���
                function getInterpreterThreadCounter : integer;
                function getLoaderClassIndex : integer;
                //function getStaticField : nameAndValueClass;
                function getNewInstanceIndex : integer;
                //function getnewInstanceClass( index : integer) : newInstanceClass;
                function getArrayInstanceStructIndex : integer;
                //function getarrayInstanceStruct( index : integer) : arrayInstanceClass;

        private
                // cpu Power����
                procedure appendCpuPower( ip : string ; cpuPower : string );
                function getIPofBestCpuPower : string;
                //function NgetCpuPowerWithIP( ip : string ) : string;
                function getCpuPowerIndexWithIP( ip : string ) : integer;

                // disk power ����
                procedure appendDiskPower(ip : string ; size : integer );
                function getIPofBestdiskPower : string;
                function getdiskPowerIndexWithIP( ip : string ) : integer;


                // �޼��� ����
                procedure UDPgetMessage( ip : string ; port : integer ; senderName : string ; msgTitle : string ; msgBody : string );

                // process ����
                procedure TCPgetConnect();
                procedure TCPgetMessage( var msg : string ; var isWrite : boolean );
                procedure TCPgetDisconnect();
        end;



implementation

uses
        normalModeInterpreterModule;


procedure runtimeEnvironmentClass.Execute;
begin
        while interpreterThreadCounter > 0 do
                self.appendCpuPower('local',utilClass.getCPUPower);
end;

function runtimeEnvironmentClass.getfileIOStream() : integer;
var
        i : integer;
begin
        i := self.fileIOStreamIndex ;
        inc( self.fileIOStreamIndex );

        result := i;
end;

constructor runtimeEnvironmentClass.Create( classPath : string ; coredumpflag : boolean ) ;
var
        s : string;
begin
        inherited Create( true );
        
        // ��� �ε� ���� ��
        interpreterThreadCounter := 0;

        loaderClassIndex := 0;

        staticField := nameAndValueClass.Create;

        newInstanceIndex := 0;

        arrayInstanceIndex := 0;

        fileIOStreamIndex := 0;

        self.classPath := classPath; // ���̺귯�� ���� Ŭ���� ���

        self.coredumpflag := coredumpflag; // �ٸ� ���������Ϳ��� ���� ��å�� �����Ҷ� ���ȴ�.

        cpuPowerIndex := 0;

        diskPowerIndex := 0;


        dvmConfig := configClass.Create(DVM_INI_PATH);
        s := dvmConfig.getValue('DVMSYSTEM', 'CPUPOWER' ,'' );
        if s = '' then
        begin
                s := utilClass.getCPUPower;
                dvmConfig.setValue('DVMSYSTEM','CPUPOWER',s);
        end;
        self.appendCpuPower('local','0' + s);

        
        IMES := indyConsoleUDPMessageClass.Create( NORMAL_MODE_MESSAGE_LISTENER_PORT , true );
        IMES.getMessage := self.UDPgetMessage;
        IMES.start;

        IMES.writeAllMessage( SERVICE_MODE_MESSAGE_LISTENER_PORT , inttostr(ord(GET_CPUPOWER_MESSAGE)) , '' );
        IMES.writeAllMessage( SERVICE_MODE_MESSAGE_LISTENER_PORT , inttostr(ord(GET_DISKPOWER_MESSAGE)) , '' );

        DPMListener := indyConsoleTcpServerClass.Create( PROCESS_LISTENER_PORT );
        DPMListener.getConnect := TCPgetConnect;
        DPMListener.getMessage := TCPgetMessage;
        DPMListener.getDisconnect := TCPgetDisconnect;
        DPMListener.active;


        tcsTCP := TCriticalSection.Create;
//        tcsUDP := TCriticalSection.Create;        
end;

procedure runtimeEnvironmentClass.appendClass( className : string );
begin
        self.loadedClass[ self.loaderClassIndex ] := classLoaderClass.Create;
        self.loadedClass[ self.loaderClassIndex ].load( classPath , className );
        inc( self.loaderClassIndex );
end;

procedure runtimeEnvironmentClass.mainLoop;
begin
        Resume;
        WaitFor;
end;

function runtimeEnvironmentClass.getCodeAttribute( loadedClassIndex : integer ; methodsIndex : integer ) : codeAttribute;
begin
        result := (self.loadedClass[ loadedClassIndex ].methods[ methodsIndex ].attributes[0].attribute as codeAttribute );
end;

function runtimeEnvironmentClass.getUTF8Name( loadedClassIndex : integer ; constantPoolIndex : integer ) : string;
begin
        result := (self.loadedClass[loadedClassIndex].constantPool[constantPoolIndex].info as constantUtf8Info).bytesName;
end;

function runtimeEnvironmentClass.getClassInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ) : string;
var
        index2 : integer;
begin
        index2 := (self.loadedClass[loadedClassIndex].constantPool[constantPoolIndex].info as constantClassInfo).nameIndex;
        result := getUTF8Name( loadedClassIndex , index2 );
end;

function runtimeEnvironmentClass.getNameAndTypeName( loadedClassIndex : integer ; constantPoolIndex : integer) : string;
var
        index2 : integer;
        index3 : integer;
        s : string;
begin
        index2 := (self.loadedClass[loadedClassIndex].constantPool[constantPoolIndex].info as constantNameAndType).nameIndex ;
        index3 := (self.loadedClass[loadedClassIndex].constantPool[constantPoolIndex].info as constantNameAndType).descriptorIndex ;

        s := getUTF8Name( loadedClassIndex ,index2 );
        s := s + getUTF8Name( loadedClassIndex ,index3 );

        result := s;
end;

procedure runtimeEnvironmentClass.getMethodRefInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ;
                        var className : string ; var nameAndType : string ) ;
var
        index2 : integer;
begin

        index2 := (self.loadedClass[loadedClassIndex].constantPool[constantPoolIndex].info as constantMethodref).classIndex;
        className := getClassInfoName( loadedClassIndex , index2 );
        index2 := (self.loadedClass[loadedClassIndex].constantPool[constantPoolIndex].info as constantMethodref).nameAndTypeIndex;
        nameAndType := getNameAndTypeName( loadedClassIndex , index2 );
end;




function runtimeEnvironmentClass.getMethodsIndex( loadedClassIndex : integer ; name : string ) : integer;
var
        i : integer;
        n : string;
begin
        for i:=0 to self.loadedClass[loadedClassIndex].methodsCount - 1 do
        begin
                n := getUTF8Name( loadedClassIndex , self.loadedClass[loadedClassIndex].methods[i].nameIndex );
                n := n + getUTF8Name( loadedClassIndex , self.loadedClass[loadedClassIndex].methods[i].descriptorIndex );

                if n = name then
                begin
                        result := i;
                        exit;
                end;
        end;

        result := -1;
        //raise Exception.CreateFmt('not found method : %s',[name]);
end;


function runtimeEnvironmentClass.getMethodsIndexWithAccessFlag( loadedClassIndex : integer ; accessFlag : integer; name : string ) : integer;
var
        i : integer;
        n : string;
begin
        for i:=0 to self.loadedClass[loadedClassIndex].methodsCount - 1 do
        begin
                if self.loadedClass[loadedClassIndex].methods[i].accessFlags = accessFlag then
                begin
                        n := getUTF8Name( loadedClassIndex , self.loadedClass[loadedClassIndex].methods[i].nameIndex );
                        n := n + getUTF8Name( loadedClassIndex , self.loadedClass[loadedClassIndex].methods[i].descriptorIndex );

                        if n = name then
                        begin
                                result := i;
                                exit;
                        end;
                end;
        end;

        //result := -1;
        raise Exception.CreateFmt('not found method : %s',[name]);
end;
             
function runtimeEnvironmentClass.getloadedClassIndex( name : string) : integer;
var
        i : integer;
        s : string;
begin
        for i:=0 to self.loaderClassIndex - 1 do
        begin
                s := self.getClassInfoName( i, self.loadedClass[i].thisClass );
                if s = name then
                begin
                        result := i;
                        exit;
                end;
        end;

        result := -1;
end;

function runtimeEnvironmentClass.getTotalLocalVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;
var
        codeAttr : codeAttribute;
begin
        codeAttr := self.getCodeAttribute( loadedClassIndex , methodsIndex );

        result := codeAttr.maxLocals;
end;

function runtimeEnvironmentClass.getMethodLocalVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer;
begin
        result := getTotalLocalVariableNumber( loadedClassIndex , methodsIndex ) -
                        getMethodArgsVariableNumber( loadedClassIndex , methodsIndex );
end;

function runtimeEnvironmentClass.getMethodArgsVariableNumber( loadedClassIndex : integer ; methodsIndex : integer ) : integer ;
var
        i : integer;
        s : string;
        p : pchar;
        ar : array[0..100] of char;
        v : integer;
begin

        i := self.loadedClass[ loadedClassIndex ].methods[methodsIndex].descriptorIndex;
        s := self.getUTF8Name( loadedClassIndex , i );

        p := @ar;
        strpcopy( p , s );
        v := 0;

        i := 0;
        while( ar[i] <> ')' ) do
        begin
                case ar[i] of

                'S' : inc(v); // short
                'F' : raise Exception.Create('float arg not support'); // float
                'D' : raise Exception.Create('double arg not support'); // double
                'J' : v := v + 2;  // long // bug fixed inc(v)
                'I' : inc(v); // integer
                'C' : inc(v); // char
                'B' : inc(v); // byte
                'Z' : inc(v); // boolean;
                'L' :
                begin
                        inc(v);
                        inc(i);
                        while( true ) do
                        begin
                                if ar[i] = ';' then
                                        break;
                                inc(i);
                        end;
                end;

                end;

                inc(i);
        end;

        i := self.loadedClass[ loadedClassIndex ].methods[ methodsIndex ].accessFlags and ACC_STATIC;
        if i <> ACC_STATIC then
                inc(v);

        result := v;
end;


procedure runtimeEnvironmentClass.incInterpreterThreadCounter;
begin
        inc( self.interpreterThreadCounter );
end;

procedure runtimeEnvironmentClass.decInterpreterThreadCounter;
begin
        dec( self.interpreterThreadCounter );
end;

procedure runtimeEnvironmentClass.appendStaticField( fieldName : string ; fieldValue : integer );
begin
        self.staticField.appendFieldIntegervalue( fieldname , fieldValue );
end;

function runtimeEnvironmentClass.getStaticFieldIndexByFieldName( fieldName : string ) : integer;
begin
        result:= self.staticField.getFieldIndex( fieldName );
end;

function runtimeEnvironmentClass.getStaticFieldValue( fieldIndex : integer ) : integer;
begin
        result := self.staticField.getFieldIntegervalue( fieldIndex );
end;

{
procedure runtimeEnvironmentClass.callMethodType4( callClassName : string ; findMethodIndex : integer;
        var loadedClassIndex : integer ;
        var methodIndex : integer ; var codeOffset : integer ;
        var variableOffset : integer ; var codeAttr : codeAttribute  ;
        var stack : stackClass );
var
        j,k,m,n : integer;
begin
        // �ε�� Ŭ������ �ε����� ��f��
        j := self.getLoadedClassIndex( callClassName );

        // Ŭ������ �޼ҵ带 ��´�
        k := findMethodIndex;

        // �޼ҵ��� �޼ҵ� ������ ��´�
        m := getMethodLocalVariableNumber( j , k );

        // ������ �޼ҵ� ���� ��ŭ ������ �ø���
        for n:=0 to m - 1 do stack.push(0);

        // �ش� �޼ҵ��� ���� �ε����� �����Ѵ�.
        m := stack.statckOffset - getTotalLocalVariableNumber( j , k );

        // ���Ͻ� ������ codeoffset�� ������Ų��
        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);

        // ���Ͻ� ����� ����Ÿ���� ���ÿ� �����Ѵ�
        stack.push( loadedClassIndex );
        stack.push( methodIndex );
        stack.push( codeOffset );
        stack.push( variableOffset );

        // ȣ�� �޼ҵ带 �����ϱ� ���� �ʱ�ȭ�� �Ѵ�.
        loadedClassIndex := j;
        methodIndex := k;
        codeOffset := 0;
        variableOffset := m;

        codeAttr := getCodeAttribute( loadedClassIndex , methodIndex );
end;
}

procedure runtimeEnvironmentClass.callMethodType2( findLoadedClassIndex : integer ; findMethodIndex : integer;
        var loadedClassIndex : integer ;
        var methodIndex : integer ; var codeOffset : integer ;
        var variableOffset : integer ; var codeAttr : codeAttribute  ;
        var stack : stackClass );
var
        j,k,m,n : integer;
begin
        // �ε�� Ŭ������ �ε����� ��f��
        j := findLoadedClassIndex;

        // Ŭ������ �޼ҵ带 ��´�
        k := findMethodIndex;

        // �޼ҵ��� �޼ҵ� ������ ��´�
        m := getMethodLocalVariableNumber( j , k );

        // ������ �޼ҵ� ���� ��ŭ ������ �ø���
        for n:=0 to m - 1 do stack.push(0);

        // �ش� �޼ҵ��� ���� �ε����� �����Ѵ�.
        m := stack.statckOffset - getTotalLocalVariableNumber( j , k );

        // ���Ͻ� ������ codeoffset�� ������Ų��
        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);

        // ���Ͻ� ����� ����Ÿ���� ���ÿ� �����Ѵ�
        stack.push( loadedClassIndex );
        stack.push( methodIndex );
        stack.push( codeOffset );
        stack.push( variableOffset );

        // ȣ�� �޼ҵ带 �����ϱ� ���� �ʱ�ȭ�� �Ѵ�.
        loadedClassIndex := j;
        methodIndex := k;
        codeOffset := 0;
        variableOffset := m;

        codeAttr := getCodeAttribute( loadedClassIndex , methodIndex );
end;

//
// callMethod �޼���� constant Pool�� �������� �ʴ´�
// methods �ڷῡ���� �̸��� ������ ������ �����Ѵ�
{procedure runtimeEnvironmentClass.callMethodType1( callClassName : string ; callMethodName : string;
        var loadedClassIndex : integer ;
        var methodIndex : integer ; var codeOffset : integer ;
        var variableOffset : integer ; var codeAttr : codeAttribute  ;
        var stack : stackClass );
var
        j,k,m,n : integer;
begin
        // �ε�� Ŭ������ �ε����� ��f��
        j := self.getLoadedClassIndex( callClassName );

        // Ŭ������ �޼ҵ带 ��´�
        k := self.getMethodsIndex(j,callMethodName);

        // �޼ҵ��� �޼ҵ� ������ ��´�
        m := getMethodLocalVariableNumber( j , k );

        // ������ �޼ҵ� ���� ��ŭ ������ �ø���
        for n:=0 to m - 1 do stack.push(0);

        // �ش� �޼ҵ��� ���� �ε����� �����Ѵ�.
        m := stack.statckOffset - getTotalLocalVariableNumber( j , k );

        // ���Ͻ� ������ codeoffset�� ������Ų��
        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);

        // ���Ͻ� ����� ����Ÿ���� ���ÿ� �����Ѵ�
        stack.push( loadedClassIndex );
        stack.push( methodIndex );
        stack.push( codeOffset );
        stack.push( variableOffset );

        // ȣ�� �޼ҵ带 �����ϱ� ���� �ʱ�ȭ�� �Ѵ�.
        loadedClassIndex := j;
        methodIndex := k;
        codeOffset := 0;
        variableOffset := m;

        codeAttr := getCodeAttribute( loadedClassIndex , methodIndex );
end;}

{
procedure runtimeEnvironmentClass.callMethodType3( findLoadedClassIndex : integer ; callMethodName : string;
        var loadedClassIndex : integer ;
        var methodIndex : integer ; var codeOffset : integer ;
        var variableOffset : integer ; var codeAttr : codeAttribute  ;
        var stack : stackClass );
var
        j,k,m,n : integer;
begin
        // �ε�� Ŭ������ �ε����� ��f��
        j := findLoadedClassIndex;

        // Ŭ������ �޼ҵ带 ��´�
        k := self.getMethodsIndex(j,callMethodName);

        // �޼ҵ��� �޼ҵ� ������ ��´�
        m := getMethodLocalVariableNumber( j , k );

        // ������ �޼ҵ� ���� ��ŭ ������ �ø���
        for n:=0 to m - 1 do stack.push(0);

        // �ش� �޼ҵ��� ���� �ε����� �����Ѵ�.
        m := stack.statckOffset - getTotalLocalVariableNumber( j , k );

        // ���Ͻ� ������ codeoffset�� ������Ų��
        inc(codeOffset);
        inc(codeOffset);
        inc(codeOffset);

        // ���Ͻ� ����� ����Ÿ���� ���ÿ� �����Ѵ�
        stack.push( loadedClassIndex );
        stack.push( methodIndex );
        stack.push( codeOffset );
        stack.push( variableOffset );

        // ȣ�� �޼ҵ带 �����ϱ� ���� �ʱ�ȭ�� �Ѵ�.
        loadedClassIndex := j;
        methodIndex := k;
        codeOffset := 0;
        variableOffset := m;

        codeAttr := getCodeAttribute( loadedClassIndex , methodIndex );
end;
}

//
// ��� Ŭ���� ���
//
//
// ��Ӱ��� ���
procedure runtimeEnvironmentClass.callInvokeSpecial( callClassName : string ; callMethodName : string;
        var loadedClassIndex : integer ;
        var methodIndex : integer ; var codeOffset : integer ;
        var variableOffset : integer ; var codeAttr : codeAttribute  ;
        var stack : stackClass );
var
        j,k,m : integer;
begin
        // �ε�� Ŭ������ �ε����� ��f��
        j := self.getLoadedClassIndex( callClassName );
        if j = -1 then
        begin
                self.appendClass( callClassName );
                j := self.getLoadedClassIndex( callClassName );
        end;

        // Ŭ������ �޼ҵ带 ��´�
        k := self.getMethodsIndex(j,callMethodName);

        // native �޼ҵ带 �˻��Ѵ�.
        m := getAccessFlagLoadedClassByIndexMethodsByIndex(j,k) and ACC_NATIVE;
        if m = ACC_NATIVE then
        begin
                //m := getMethodArgsVariableNumber( j , k );
                self.callNativeMethod( callClassName, callMethodName , stack , false );//, m );
                inc(codeOffset);
                inc(codeOffset);
                inc(codeOffset);
                // stack.pop; // virtual ȣ���� this ���ڸ� ������ �ֱ� �빮�� this�� ���� �Ͽ� �ش�.
                // new
                // �׷��� ����Ÿ�Զ����� callNativeMethod���� this ���� ���� �ϰ� �Ѵ�.

                exit;
        end;

        self.callMethodType2( j, k, loadedClassIndex, methodIndex, codeOffset, variableOffset , codeAttr, stack );

        self.appendClassHecheri( stack.buffer[variableOffset], loadedClassIndex );
end;

//
// overriding �� ó���ؾ� �Ѵ�.
//
procedure runtimeEnvironmentClass.callInvokeVirtual( callClassName : string ; callMethodName : string;
        var loadedClassIndex : integer ;
        var methodIndex : integer ; var codeOffset : integer ;
        var variableOffset : integer ; var codeAttr : codeAttribute  ;
        var stack : stackClass );
var
        j,k,m,n : integer;
        s1 : string;
begin
{        m := self.getMethodArgsVariableNumber( j , k );
        n := stack.buffer[ stack.statckOffset - m ];
        callClassName := self.getOverridingMethodClassName(n , callMethodName );}
        // �ε�� Ŭ������ �ε����� ��f��
        j := self.getLoadedClassIndex( callClassName );
        if j = -1 then
        begin
                self.appendClass( callClassName );
                j := self.getLoadedClassIndex( callClassName );
        end;


        // Ŭ������ �޼ҵ带 ��´�
        k := self.getMethodsIndex(j,callMethodName);
//        writeln( k ); readln;
        // natifve �޼ҵ带 �˻��Ѵ�.
        m := getAccessFlagLoadedClassByIndexMethodsByIndex(j,k) and ACC_NATIVE;
        if m = ACC_NATIVE then
        begin
                //m := getMethodArgsVariableNumber( j , k );
                self.callNativeMethod( callClassName, callMethodName , stack , false );//, m );
                inc(codeOffset);
                inc(codeOffset);
                inc(codeOffset);
                // stack.pop; // virtual ȣ���� this ���ڸ� ������ �ֱ� �빮�� this�� ���� �Ͽ� �ش�.
                // new
                // �׷��� ����Ÿ�Զ����� callNativeMethod���� this ���� ���� �ϰ� �Ѵ�.

                exit;
        end;

        if j = loadedClassIndex then
        begin
                // this�� ������ ���ڰ����� ��´�.
                m := self.getMethodArgsVariableNumber( j , k );
                // this��
                n := stack.buffer[ stack.statckOffset - m ];

                //
                // n -> this�� null�̸� �Ҵ޵��� ���� ���� ��ü�� �Ǵ��Ѵ�.
                //
                //
                // bootloaderModule ���� 0��° ���� �־���. 
                //

                // 2003-7-2
                // static ��ü�� ���� �Ҵ����� �ʰ� new�� �����ν� �ذ��ߴ�.
                // ���� ���̻� 0��° ��ü�� ������� �ʴ� �ڵ尡 �ʿ� ����.
//                if n <> 0 then
//                begin
{

2003-9-1
jdk 1.4�� ������ �ϸ� �ڵ尡 �Ʒ��� ����
44 invokespecial #21 <ThreadTest.<init>>
47 invokevirtual #24 <ThreadTest.start>

1.3, 1.2�� ������ �ϸ� �ڵ尡 �Ʒ��� ����.
44 invokespecial #22 <ThreadTest.<init>>
47 invokevirtual #28 <java/lang/Thread.start>

�ι��� �ڵ��� ��� dvm���� �ν��ϴµ� �װ��� �ش� �޼��尡 ���ǵ� Ŭ������ �ٷ� ȣ���ϱ� �����̴�.
�̰��� ���� getMethodArgsVariableNumber�� k���� �𸣱� ������ ó���� �Ҽ� �� ����.


MinerVersion 0 MajorVersion 46 1.4
MinerVersion 3 MajorVersion 45 1.2.2
}
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

//
// �ƹ��͵� ����
//
procedure runtimeEnvironmentClass.callInvokeStatic( callClassName : string ; callMethodName : string;
        var loadedClassIndex : integer ;
        var methodIndex : integer ; var codeOffset : integer ;
        var variableOffset : integer ; var codeAttr : codeAttribute  ;
        var stack : stackClass );
var
        j,k,m : integer;
begin
        // �ε�� Ŭ������ �ε����� ��f��
        j := self.getLoadedClassIndex( callClassName );
        if j = -1 then
        begin
                self.appendClass( callClassName );
                j := self.getLoadedClassIndex( callClassName );
        end;

        // Ŭ������ �޼ҵ带 ��´�
        k := self.getMethodsIndex(j,callMethodName);

        // native �޼ҵ带 �˻��Ѵ�.
        //
        // ���� ������ static navive method �� ����.
        //
        m := getAccessFlagLoadedClassByIndexMethodsByIndex(j,k) and ACC_NATIVE;
        if m = ACC_NATIVE then
        begin
                //m := getMethodArgsVariableNumber( j , k );
                // native method�� static�̸� true �� �Ѱ��ش�.
                self.callNativeMethod( callClassName , callMethodName , stack , true );//, m );
                inc(codeOffset);
                inc(codeOffset);
                inc(codeOffset);
                // stack.pop; static�� this ���� �빮�� ���ֱ� �ʴ´�. callNativeMethod������ ���� ���ڸ� pop�Ѵ�.
                // new
                // �׷��� ����Ÿ�Զ����� callNativeMethod���� this ���� ���� �ϰ� �Ѵ�.
                // ���ؿ� loadedClassIndex, methodIndex, codeOffset, variableOffset �� �������� �ʴ´�
                // ȣ��� �ʿ��� ������ �����ϰ� �ϴ� ���� �´�
                exit;
        end;

        self.callMethodType2( j, k, loadedClassIndex, methodIndex, codeOffset, variableOffset , codeAttr, stack );
end;



procedure runtimeEnvironmentClass.returnMethod( var loadedClassIndex : integer ; var methodIndex : integer ; var codeOffset : integer ; var variableOffset : integer ; var codeAttr : codeAttribute ; var stack : stackClass );
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

procedure runtimeEnvironmentClass.setStaticFieldValue( fieldIndex : integer ; fieldValue : integer );
begin
        self.staticField.setFieldIntegervalue( fieldIndex , fieldValue );
end;

procedure runtimeEnvironmentClass.getFieldRefInfoName( loadedClassIndex : integer ; constantPoolIndex : integer ;
                        var className : string ; var nameAndType : string ) ;
var
        index2 : integer;
begin
        index2 := (self.loadedClass[loadedClassIndex].constantPool[constantPoolIndex].info as constantFieldref).classIndex;
        className := getClassInfoName( loadedClassIndex , index2 );
        index2 := (self.loadedClass[loadedClassIndex].constantPool[constantPoolIndex].info as constantFieldref).nameAndTypeIndex;
        nameAndType := getNameAndTypeName( loadedClassIndex , index2 );

end;

procedure runtimeEnvironmentClass.callNativeMethod(  nativeClassName : string ; nativeMethodName : string ; var stack : stackClass ; isStatic : boolean );//; methodArgsVariableNumber : integer );

var
        i,j,k,m,n,o,p,q : integer; // ���� ����
        s1,s2 : string; // ���ڿ� ���� ����
        interpreter : interpreterClass;
//        ba : array[0..1] of byte;
        arrayi : arrayInstanceClass;
        bytea : byteArrayInstanceClass;
        chara : charArrayInstanceClass;
        i64 : int64;

begin

try
        //
        // this ������ ���Ŵ� ���⼭ �Ѵ�.
        //
        // �ٵ� isStatic�� �׻� false�̴�.
        // �ֳ��ϸ� staitc���� ����� ���� ���� �빮��.
        // ���� �ӵ��� ���� �ּ�ó���Ѵ�.

        //if isStatic = true then begin end;
        {
                2003-9-4 02:44

                Thread.activeCount() �� static���� ����Ǿ��� ������
                isStatic�� ����ؾ� ������ �׷��� ���� �ڵ��� ������ �Ұ��� �ϴ�..
                ���� ���⼭ static �ΰ��� this�� ���� ���� �ʴ� �������� �ϰڴ�.. ��¥�� ����.��......
        }

        if nativeClassName = 'java/io/PrintStream' then
        begin
                if nativeMethodName = 'print(C)V' then
                begin
                        write( char(stack.pop) );
                        stack.pop; // this ����
                end
                else
                if nativeMethodName = 'println(C)V' then
                begin
                        writeln( char(stack.pop) );
                        stack.pop; // this ����
                end
                else
                if nativeMethodName = 'print(I)V' then
                begin
                        write( stack.pop );
                        stack.pop; // this ����
                end
                else
                if nativeMethodName = 'println(I)V' then
                begin
                        writeln( stack.pop );
                        stack.pop; // this ����
                end
                else
                if nativeMethodName = 'print(J)V' then
                begin
                        // ���� pop ���� low ���� pop ���� high
                        i := stack.pop; //low
                        j := stack.pop; // hi
                        i64 := utilclass.makeLong(i, j);

                        write( i64 );
                        stack.pop; // this ����
                end
                else
                if nativeMethodName = 'println(J)V' then
                begin
                        i := stack.pop; //low
                        j := stack.pop; // hi
                        i64 := utilclass.makeLong(i, j);

                        writeln( i64 );
                        stack.pop; // this ����
                end
                else
                if nativeMethodName = 'print(Ljava/lang/String;)V' then
                begin
                        i := stack.pop; // String instance
                        self.getStringByStringInstance( s1 , i );
                        write( s1 );
                        stack.pop; // this ����
                end
                else
                if nativeMethodName = 'println(Ljava/lang/String;)V' then
                begin
                        i := stack.pop; // String instance
                        self.getStringByStringInstance( s1 , i );
                        writeln( s1 );
                        stack.pop; // this ����
                end
                else
                begin
                        raise Exception.CreateFmt('not found native method : %s.%s',[nativeClassName,nativeMethodName]);
                end;

        end
        else
        if nativeClassName = 'java/io/FileInputStream' then
        begin
                if nativeMethodName = 'readBytes([BII)I' then
                begin
                        i := stack.pop; // len
                        j := stack.pop; // offset
                        k := stack.pop; // byte[]  --> byte array index
                        m := stack.pop; // this

                        n := self.getFieldIndex( m , 'java/io/FileInputStreamfileHandlerI' ); // field index
                        o := self.getFieldValue( m , n ); // fielIOStream index;

                        arrayi := self.getArray(k);
                        bytea := (arrayi.arrayObject as byteArrayInstanceClass);

                        p := bytea.size - j;
                        if p < i then i := p;

                        q := self.DFSRequester[o].inputreadBytes( bytea.data , i );

                        stack.push(q);
                end
                else
                if nativeMethodName = 'read()I' then
                begin
                        i := stack.pop; // this

                        j := self.getFieldIndex( i , 'java/io/FileInputStreamfileHandlerI' );
                        k := self.getFieldValue( i , j ); // fielIOStream index;

                        m := self.DFSRequester[k].inputread;

                        stack.push(m);
                end
                else
                if nativeMethodName = 'open(Ljava/lang/String;)I' then
                begin
                        i := stack.pop; // String
                        stack.pop; // this

                        self.getStringByStringInstance( s1 , i );

                        j := self.getfileIOStream;

                        self.DFSRequester[j] := distributedFileSystemRequestClass.inputopen( DFS_REQUEST_PATH , DFS_LOCAL_PATH , s1 );

                        stack.push(j);
                end
{                else
                if nativeMethodName = 'skip(J)J' then
                begin

                //
                // ����� ���װ� �ְ� ... ������ �𸣰ڴ�.......
                // 2003-07-03
                //
                        longint := int64( stack.pop ) or int64( stack.pop shl 32 ); // value
                        i := stack.pop; // this

                        j := self.getFieldIndex( i , 'java/io/FileOutputStreamfileHandlerI' );
                        k := self.getFieldValue( i , j ); // fielIOStream index;

                        //longint2 := self.fileIOStream[k].Position;
                        //longint3 := self.fileIOStream[k].Seek( longint , soFromCurrent ) - longint2;

                        i := integer( longint3 shr 32  ); // hi
                        j := integer( longint3 ); // low

                        stack.push(i);
                        stack.push(j);
                end}
                else
                if nativeMethodName = 'available()I' then
                begin
                        i := stack.pop; // this

                        j := self.getFieldIndex( i , 'java/io/FileInputStreamfileHandlerI' );
                        k := self.getFieldValue( i , j ); // fielIOStream index;

                        m := self.DFSRequester[k].inputavailable;

                        stack.push(m);
                end
                else
                if nativeMethodName = 'close()V' then
                begin
                        i := stack.pop; // this

                        j := self.getFieldIndex( i , 'java/io/FileInputStreamfileHandlerI' );
                        k := self.getFieldValue( i , j ); // fielIOStream index;

                        //f := self.fileIOStream[k];
                        self.DFSRequester[k].inputclose;
                end
                else
                begin
                        raise Exception.CreateFmt('not found native method : %s.%s',[nativeClassName,nativeMethodName]);
                end;

        end
        else
        if nativeClassName = 'java/io/FileOutputStream' then
        begin
                if nativeMethodName = 'open(Ljava/lang/String;)I' then
                begin
                        i := stack.pop; // String
                        stack.pop; // this

                        self.getStringByStringInstance( s1 , i );

                        j := self.getfileIOStream;

                        self.DFSRequester[j] := distributedFileSystemRequestClass.outputopen( getIPofBestdiskPower,
                                        DISTRIBUTED_FILE_SYSTEM_LISTENER_PORT , DFS_REQUEST_PATH , DFS_LOCAL_PATH, s1, ord(DFS_OUTPUT_OPEN));

                        stack.push(j);
                        //writeln( s1 );readln;
                end
                else
                if nativeMethodName = 'openAppend(Ljava/lang/String;)I' then
                begin
                        i := stack.pop; // String
                        stack.pop; // this

                        self.getStringByStringInstance( s1 , i );

                        j := self.getfileIOStream;

                        self.DFSRequester[j] := distributedFileSystemRequestClass.outputopen( getIPofBestdiskPower,
                                        DISTRIBUTED_FILE_SYSTEM_LISTENER_PORT , DFS_REQUEST_PATH , DFS_LOCAL_PATH, s1, ord(DFS_OUTPUT_OPENAPPEND));

                        stack.push(j);
                end
                else
                if nativeMethodName = 'write(I)V' then
                begin
                        i := stack.pop; // value
                        j := stack.pop; // this

                        k := self.getFieldIndex( j , 'java/io/FileOutputStreamfileHandlerI' );
                        m := self.getFieldValue( j , k ); // fielIOStream index;

                        self.DFSRequester[m].outputwrite(i);
                end
                else
                if nativeMethodName = 'writeBytes([BII)V' then
                begin
                        i := stack.pop; // len
                        j := stack.pop; // offset
                        k := stack.pop; // byte array index
                        m := stack.pop; // this

                        n := self.getFieldIndex( m , 'java/io/FileOutputStreamfileHandlerI' );
                        o := self.getFieldValue( m , n ); // fielIOStream index;

                        arrayi := self.getArray(k);
                        bytea := (arrayi.arrayObject as byteArrayInstanceClass);
                        //pBy := @bytea.data[j];

                        p := bytea.size - j;
                        if p < i then i := p;

                        self.DFSRequester[o].outputwriteBytes( bytea.data , i );
                end
                else
                if nativeMethodName = 'close()V' then
                begin
                        i := stack.pop; // this

                        j := self.getFieldIndex( i , 'java/io/FileOutputStreamfileHandlerI' );
                        k := self.getFieldValue( i , j ); // fielIOStream index;

                        self.DFSRequester[k].outputclose;
                end
                else
                begin
                        raise Exception.CreateFmt('not found native method : %s.%s',[nativeClassName,nativeMethodName]);
                end;
        end
        else
        if nativeClassName = 'java/lang/StringBuffer' then
        begin
                if nativeMethodName = 'inttostr(I)[C' then
                begin
                        i := stack.pop; // value
                        stack.pop; // this
                        
                        s1 := inttostr( i );

                        arrayi := arrayInstanceClass.Create;                        
                        arrayi.arrayObject := charArrayInstanceClass.Create( length(s1) ); // string size
                        arrayi.arrayType := T_CHAR;

                        chara := (arrayi.arrayObject as charArrayInstanceClass);
                        for j := 0 to chara.size - 1 do chara.data[j] := s1[j+1];

                        stack.push( appendArray( arrayi ) ); // array index save
                end
                else
                if nativeMethodName = 'longtostr(J)[C' then
                begin
                        i := stack.pop; //low
                        j := stack.pop; // hi
                        i64 := utilclass.makeLong(i, j);

                        stack.pop; // this

                        s1 := format('%d',[i64] );

                        arrayi := arrayInstanceClass.Create;
                        arrayi.arrayObject := charArrayInstanceClass.Create( length(s1) ); // string size
                        arrayi.arrayType := T_CHAR;

                        chara := (arrayi.arrayObject as charArrayInstanceClass);
                        for j := 0 to chara.size - 1 do chara.data[j] := s1[j+1];

                        stack.push( appendArray( arrayi ) ); // array index save
                end
                else
                begin
                        raise Exception.CreateFmt('not found native method : %s.%s',[nativeClassName,nativeMethodName]);
                end;
        end
        else
        if nativeClassName = 'java/lang/Thread' then
        begin
                if nativeMethodName = 'activeCount()I' then // this is static method so don't remove this instance
                begin
                        stack.push( self.interpreterThreadCounter );
                end
                else
                if nativeMethodName = 'start()V' then
                begin
                        i := stack.pop; // this

                        //
                        // i -> this�� null�̸� �Ҵ޵��� ���� ���� ��ü�� �Ǵ��Ѵ�.
                        //
                        // 2003-6-4
                        // null�� �� ������� �ʴ°�?
                        // �ν��Ͻ� ������ null�� ���� �Ͱ� ù��°�� newInstance�� �Ҵ�޾� 0�ΰͰ� ������ ����
                        // �ʾƼ� �Ѱ� ����
                        // ������ ��ü�� null�� �Ҵ��� �޼ҵ忡�� ��ü�� ���� ������ ���� ���°� ����.

                        //
                        // �ٽ� �װ� �ƴϰ� overriding�����̴�. ��ü�� null�� ���� �Ͱ� �ν��Ͻ� 0��°��
                        // �Ҵ��� �����Ͱ� overridng�Ҵ� ������ ���� �ʴ´�. �׷��� �׷���......

                        // 2003-7-2
                        // static ��ü�� ���� �Ҵ����� �ʰ� new�� �����ν� �ذ��ߴ�.
                        // ���� ���̻� 0��° ��ü�� ������� �ʴ� �ڵ尡 �ʿ� ����.
                        // if i = 0 then raise Exception.Create('null reference in Thread');
                        s1 := getIPofBestCpuPower; //writeln( format('DVM:DPMS:%s',[s1]) );

                        {$ifdef DEBUG}
                        write( 'DEBUG:' );
                        writeln( format('get cpupower : %s',[s1]) );
                        {$endif}

                        //s1 := '192.168.2.8';
                        if s1 <> 'local' then
                        begin
                                s2 := format( '%d$%d' , [i,interpreterThreadCounter] ); // s2 this
                                self.IMES.writeMessage( s1 , SERVICE_MODE_MESSAGE_LISTENER_PORT , inttostr(ord(START_PROCESS_MESSAGE)) , s2 );
                                self.incInterpreterThreadCounter; // service mode���� ����Ǳ� ���� ������ ���� ���´�.
                                exit;
                        end;

                        s2 := 'run()V';
                        s1 := self.getOverridingMethodClassName(i , s2 );

                        j := self.getLoadedClassIndex(s1);
                        k := self.getMethodsIndex(j,s2);

                        // ���ͷ�Ʈ ����
                        interpreter := interpreterClass.Create('SubThread__' +
                                utilClass.getTodayDateTime + '__' +
                                format('%d',[interpreterThreadCounter]) , coredumpflag );
                        // runtimeEnvironemt ����
                        interpreter.runtimeEnvironment := self;
                        //interpreter.name := 'SubThread';
                        // ���ڰ� ����
                        interpreter.stack.push(i); // push this

                        // ���� ���� ����
                        interpreter.loadedClassIndex := j;
                        interpreter.methodIndex := k;
                        interpreter.codeOffset := 0;
                        interpreter.variableOffset := 0;//interpreter.stack.statckOffset - runtimeEnvironment.getTotalLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
                        interpreter.codeAttr := getCodeAttribute( interpreter.loadedClassIndex , interpreter.methodIndex );

                        // ���� ���� ����
                        interpreter.exitClassIndex := interpreter.loadedClassIndex ;
                        interpreter.exitMethodIndex := interpreter.methodIndex ;

                        // ���� ���� ���� Ȯ��
                        j := getMethodLocalVariableNumber( interpreter.loadedClassIndex , interpreter.methodIndex );
                        for i:=0 to j - 1 do interpreter.stack.push(0);

                        interpreter.run;
                end
                else
                begin
                        raise Exception.CreateFmt('not found native method : %s.%s',[nativeClassName,nativeMethodName]);
                end;
        end
        else
        begin
                raise Exception.CreateFmt('not found native method : %s.%s',[nativeClassName,nativeMethodName]);
        end;

except
        on e: Exception do writeln( e.Message );
end;

end;

function runtimeEnvironmentClass.getLoadedClassName( index : integer ) : string;
var
        i : integer;
begin
        i := self.loadedClass[index].thisClass;
        result := self.getClassInfoName( index , i );
end;

function runtimeEnvironmentClass.getMethodname( loadedClassIndex : integer ; methodsIndex : integer ) : string;
var
        i,j : integer;
        s : string;
begin

        i := self.loadedClass[loadedClassIndex].methods[methodsIndex].nameIndex;
        j := self.loadedClass[loadedClassIndex].methods[methodsIndex].descriptorIndex ;

        s := self.getUTF8Name( loadedClassIndex , i );
        s := s + self.getUTF8Name( loadedClassIndex , j );

        result := s;

end;

function runtimeEnvironmentClass.getNewInstance() : integer;
var
        i : integer;
begin
        self.newInstance[ self.newInstanceIndex ] := newInstanceClass.Create;
        i := self.newInstanceIndex ;

        inc(self.newInstanceIndex);
        result := i;
end;

procedure runtimeEnvironmentClass.appendClassHecheri( newInstanceIndex : integer ; loadedClassIndex : integer );
begin
        self.newInstance[ newInstanceIndex ].appendHecheriClass( loadedClassIndex );
end;

procedure runtimeEnvironmentClass.appendField( newInstanceIndex : integer ; fieldName : string ; fieldValue : integer );
begin
        self.newInstance[ newInstanceIndex ].appendFieldIntegervalue( fieldName, fieldValue );
end;

function runtimeEnvironmentClass.getFieldIndex( newInstanceIndex : integer ; fieldName : string ) : integer;
begin
        result := self.newInstance[ newInstanceIndex ].getFieldIndex( fieldName );
end;

function runtimeEnvironmentClass.getFieldValue( newInstanceIndex : integer ; fieldIndex : integer ) : integer;
begin
        result := self.newInstance[ newInstanceIndex ].getFieldIntegervalue( fieldIndex );
end;

procedure runtimeEnvironmentClass.setFieldValue( newInstanceIndex : integer ; fieldIndex : integer ; fieldValue : integer );
begin
        self.newInstance[ newInstanceIndex ].setFieldIntegervalue( fieldIndex , fieldValue );
end;

{function runtimeEnvironmentClass.getLoadedClassObject( index : integer ) : classLoaderClass;
begin
        result := self.loadedClass[ index ];
end;}

function runtimeEnvironmentClass.appendArray( var arrayInst : arrayInstanceClass ) : integer ;
var
        i : integer;
begin
        i := self.arrayInstanceIndex ;
        self.arrayInstance[ self.arrayInstanceIndex ] := arrayInst;
        inc( self.arrayInstanceIndex );

        result := i;
end;

function runtimeEnvironmentClass.getArray( index : integer ) : arrayInstanceClass;
begin
        result := self.arrayInstance[index];
end;

function runtimeEnvironmentClass.getOverridingMethodClassName(newInstanceIndex : integer ; methodName : string ) : string;
var
        i,j,k : integer;

begin
        for i:=0 to (self.newInstance[ newInstanceIndex ] as newInstanceClass).classHecheriIndex - 1 do
        begin
                j := (self.newInstance[ newInstanceIndex ] as newInstanceClass).classHecheriIndexByLoadedClassIndex[i];
                k := self.getMethodsIndex( j , methodName );
                if k <> -1 then
                begin
                        result := self.getLoadedClassName(j);
                        exit;
                end;
        end;

        result := '';
end;

procedure runtimeEnvironmentClass.getStringByStringInstance( var s : string ; newInstanceIndex : integer );
var
        j,k : integer;
        p : pChar;
        arrayi : arrayInstanceClass;

begin
        j := self.getFieldIndex( newInstanceIndex , 'java/lang/Stringb[C' );
        k := self.getFieldValue( newInstanceIndex , j ); // char �迭 �ε���
        arrayi := self.getArray(k);
        p := @(arrayi.arrayObject as charArrayInstanceClass).data[0];
        SetString( s , p , (arrayi.arrayObject as charArrayInstanceClass).size );
end;

function runtimeEnvironmentClass.getInterpreterThreadCounter : integer;
begin
        result := self.interpreterThreadCounter ;
end;

function runtimeEnvironmentClass.getLoaderClassIndex : integer;
begin
        result := loaderClassIndex;
end;

{function runtimeEnvironmentClass.getStaticField : nameAndValueClass;
begin
        result := staticField ;
end;}

function runtimeEnvironmentClass.getNewInstanceIndex : integer;
begin
        result := newInstanceIndex;
end;

{function runtimeEnvironmentClass.getNewInstanceClass( index : integer) : newInstanceClass;
begin
        result := newInstance[index];
end;}

function runtimeEnvironmentClass.getArrayInstanceStructIndex : integer;
begin
        result := arrayInstanceIndex
end;

{function runtimeEnvironmentClass.getArrayInstanceStruct( index : integer) : arrayInstanceClass;
begin
        result := arrayInstance[ index ];
end;}

procedure runtimeEnvironmentClass.appendCpuPower( ip : string ; cpuPower : string );
var
        a : integer;
begin
        a := getCpuPowerIndexWithIP( ip );

        if a <> -1 then
        begin
                self.cpuPowerip[a] := ip;
                self.cpuPower[a] := cpuPower;

                {$ifdef DEBUG}
                writeln( 'DEBUG:appendCpuPower : ' );
                for a:=0 to cpuPowerIndex - 1 do
                        writeln( format('ip : %s  cpupower : %s',[cpuPowerip[a],cpuPower[a]] ) );
                {$endif}
                
                exit;
        end;

        self.cpuPowerip[cpuPowerIndex] := ip;
        self.cpuPower[cpuPowerIndex] := cpuPower;

        inc(cpuPowerIndex);

        {$ifdef DEBUG}
        writeln( 'DEBUG:appendCpuPower : ' );
        for a:=0 to cpuPowerIndex - 1 do
                writeln( format('ip : %s  cpupower : %s',[cpuPowerip[a],cpuPower[a]] ) );
        {$endif}
        
end;

function runtimeEnvironmentClass.getCpuPowerIndexWithIP( ip : string ) : integer;
var
        a : integer;
begin
        result := -1;

        {$ifdef DEBUG}
        writeln( 'DEBUG:getCpuPowerIndexWithIP : ' );
        for a:=0 to cpuPowerIndex - 1 do
                writeln( format('ip : %s  cpupower : %s',[cpuPowerip[a],cpuPower[a]] ) );
        {$endif}

        if cpuPowerIndex = 0 then exit;

        for a:=0 to cpuPowerIndex - 1 do
        begin
                if self.cpuPowerip[a] = ip then
                begin
                        result := a;
                        exit;
                end;
        end;
end;

function runtimeEnvironmentClass.getdiskPowerIndexWithIP( ip : string ) : integer;
var
        a : integer;
begin
        result := -1;

        if diskPowerIndex = 0 then exit;

        for a:=0 to diskPowerIndex - 1 do
        begin
                if self.diskPowerip[a] = ip then
                begin
                        result := a;
                        exit;
                end;
        end;
end;

function runtimeEnvironmentClass.getIPofBestCpuPower : string;
var
        a : integer;
        bestCpuPower : string;
        bestCpuPowerIndex : integer;
begin

        {$ifdef DEBUG}
        writeln( 'DEBUG:getIPofBestCpuPower : ' );
        for a:=0 to cpuPowerIndex - 1 do
                writeln( format('ip : %s  cpupower : %s',[cpuPowerip[a],cpuPower[a]] ) );
        {$endif}

        if cpuPowerIndex = 0 then
        begin
                result := '';
                exit;
        end;

        bestCpuPower := '';
        bestCpuPowerIndex := 0;
        for a:=0 to cpuPowerIndex - 1 do
        begin
                if bestCpuPower < cpuPower[a] then
                begin
                        bestCpuPower := cpuPower[a];
                        bestCpuPowerIndex := a;
                end;
        end;

        result := cpuPowerip[bestCpuPowerIndex];
        cpuPower[bestCpuPowerIndex] := '0' + cpuPower[bestCpuPowerIndex];
end;

function runtimeEnvironmentClass.getIPofBestdiskPower : string;
var
        a : integer;
        bestdiskPowerSize : integer;
        bestdiskPowerIndex : integer;
begin
        if diskPowerIndex = 0 then
        begin
                result := '';
                exit;
        end;

        bestdiskPowerSize := 0;
        bestDiskPowerIndex := 0;
        for a:=0 to diskPowerIndex - 1 do
        begin
                if bestdiskPowerSize < diskPowerSize[a] then
                begin
                        bestdiskPowerSize := diskPowerSize[a];
                        bestdiskPowerIndex := a;
                end;
        end;

        {$ifdef DEBUG}
        write('DEBUG:getIPofBestdiskPower : ' );
        writeln( bestdiskPowersize );
        {$endif}

        if bestdiskPowersize = 0 then
                result := ''
        else
                result := diskPowerip[bestdiskPowerIndex];
end;

procedure runtimeEnvironmentClass.appendDiskPower( ip : string ; size : integer );
var
        a : integer;
begin
        a := getdiskPowerIndexWithIP( ip );

        if a <> -1 then
        begin
                self.diskPowerip[a] := ip;
                self.diskPowerSize[a] := size;
                exit;
        end;

        self.diskPowerip[diskPowerIndex] := ip;
        self.diskPowerSize[diskPowerIndex] := size;

        inc(diskPowerIndex);
end;

procedure runtimeEnvironmentClass.UDPgetMessage( ip : string ; port : integer ; senderName : string ; msgTitle : string ; msgBody : string );
begin

//tcsTCP.Acquire;

//try
//begin

        if msgTitle = inttostr(ord(GET_CPUPOWER_MESSAGE)) then // msgBody -> cpuPower
                self.appendCpuPower( ip , msgBody )
        else
        if msgTitle = inttostr(ord(GET_DISKPOWER_MESSAGE)) then
                self.appendDiskPower( ip, strtoint( msgbody ) )
        else
                writeln( format('DVM:Unknow UDP Message : %s', [msgTitle] ));

//end;
//finally
//        tcsTCP.Release;
//end;

end;


procedure runtimeEnvironmentClass.TCPgetConnect();
begin
//
end;

procedure runtimeEnvironmentClass.TCPgetMessage( var msg : string ; var isWrite : boolean );
var
        s1,s2,s3,s4 : string;
        arrayInstance : arrayInstanceClass;
        codeAttr : codeAttribute;
        stack : stackClass;
        msgType : integer;
        b : byte;
        i : integer;
        i64 : int64;
        c : char;
        w : word;
        bl : boolean;
begin
//        writeln( msg );


tcsTCP.Acquire;
try
begin

        utilClass.getToken(msg,':',s1);
        msgType := strtoint( s1 );
                         
        case msgType of
//        ord(PROCESS_MESSAGE_ID_getfileIOStream) :;
        ord(PROCESS_MESSAGE_ID_appendArray) :
        begin
                s1 := utilClass.getLeftString;

                arrayInstance := arrayInstanceClass.setClassData(s1);
                i := appendArray( arrayInstance );
                msg := inttostr( i );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getArrayInstanceStructByIndexarrayType) :
        begin
                utilClass.getToken('',':',s1);
                b := getArrayInstanceStructByIndexarrayType( strtoint( s1 ) );
                msg := inttostr(b);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getArrayByIndexintArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getArrayByIndexintArrayInstanceClassDataByIndex( strtoint( s1 ) , strtoint( s2 ) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getArrayByIndexlongArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i64 := getArrayByIndexlongArrayInstanceClassDataByIndex( strtoint( s1 ) , strtoint( s2 ) );
                msg := utilClass.convertInt64ToString(i64);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getArrayByIndexbyteArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                b := getArrayByIndexbyteArrayInstanceClassDataByIndex( strtoint( s1 ) , strtoint( s2 ) );
                msg := inttostr(b);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getArrayByIndexcharArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                c := getArrayByIndexcharArrayInstanceClassDataByIndex( strtoint( s1 ) , strtoint( s2 ) );
                msg := c;
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_setArrayByIndexintArrayInstanceClassDataByIndex) : 
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                utilClass.getToken('',':',s3);                
                setArrayByIndexintArrayInstanceClassDataByIndex( strtoint( s1 ) ,
                                                strtoint( s2 ), strtoint( s3 ) );
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_setArrayByIndexlongArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                utilClass.getToken('',':',s3);
                setArrayByIndexlongArrayInstanceClassDataByIndex( strtoint( s1 ) , strtoint( s2 ),
                                                utilClass.convertStringToInt64(s3) );
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_setArrayByIndexbyteArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                utilClass.getToken('',':',s3);
                setArrayByIndexbyteArrayInstanceClassDataByIndex( strtoint( s1 ) , strtoint( s2 ),
                                                strtoint( s3 ) );
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_setArrayByIndexcharArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                utilClass.getToken('',':',s3);
                setArrayByIndexcharArrayInstanceClassDataByIndex( strtoint( s1 ) , strtoint( s2 ), s3[1] );
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getArraySizeByIndexintArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                i := getArraySizeByIndexintArrayInstanceClassDataByIndex( strtoint( s1 ) );
                msg := inttostr( i );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getArraySizeByIndexlongArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                i := getArraySizeByIndexlongArrayInstanceClassDataByIndex( strtoint( s1 ) );
                msg := inttostr( i );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getArraySizeByIndexbyteArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                i := getArraySizeByIndexbyteArrayInstanceClassDataByIndex( strtoint( s1 ) );
                msg := inttostr( i );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getArraySizeByIndexcharArrayInstanceClassDataByIndex) :
        begin
                utilClass.getToken('',':',s1);
                i := getArraySizeByIndexcharArrayInstanceClassDataByIndex( strtoint( s1 ) );
                msg := inttostr( i );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_appendClassHecheri) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                appendClassHecheri( strtoint( s1 ), strtoint( s2 ) );
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getNewInstance) :
        begin
                i := getNewInstance;
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_appendField) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                utilClass.getToken('',':',s3);
                appendField( strtoint( s1 ) , s2, strtoint(s3) );
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getFieldIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getFieldIndex( strtoint( s1 ) , s2 );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getFieldValue) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getFieldValue( strtoint( s1 ) , strtoint(s2) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_setFieldValue) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                utilClass.getToken('',':',s3);
                setFieldValue( strtoint( s1 ) , strtoint(s2), strtoint(s3) );
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getOverridingMethodClassName) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                msg := getOverridingMethodClassName( strtoint( s1 ) , s2 );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getNewInstanceClassByIndexclassHecheriIndex) :
        begin
                utilClass.getToken('',':',s1);
                i := getNewInstanceClassByIndexclassHecheriIndex( strtoint( s1 ) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getNewInstanceClassByIndexclassHecheriIndexByLoadedClassIndexByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getNewInstanceClassByIndexclassHecheriIndexByLoadedClassIndexByIndex( strtoint( s1 ), strtoint( s2 ) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getNewInstanceClassByIndexIndex) :
        begin
                utilClass.getToken('',':',s1);
                i := getNewInstanceClassByIndexIndex( strtoint( s1 ) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getNewInstanceClassByIndexnameByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                msg := getNewInstanceClassByIndexnameByIndex( strtoint( s1 ), strtoint( s2 ) );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getNewInstanceClassByIndexvalueByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getNewInstanceClassByIndexvalueByIndex( strtoint( s1 ), strtoint( s2 ) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_appendClass) :
        begin
                utilClass.getToken('',':',s1);
                appendClass( s1 );
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getLoadedClassIndex) :
        begin
                utilClass.getToken('',':',s1);
                i := getLoadedClassIndex( s1 );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getLoadedClassName) :
        begin
                utilClass.getToken('',':',s1);
                msg := getLoadedClassName( strtoint(s1) );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_incInterpreterThreadCounter) :
        begin
                // UDP�޼����� ������ �̹� �������ױ� ������ ������Ű�� �ʴ´�.
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_decInterpreterThreadCounter) :
        begin
                decInterpreterThreadCounter;
                msg := 'ok';
                isWrite := true;
        end;

//      ord(PROCESS_MESSAGE_ID_callInvokeSpecial) :;
//      ord(PROCESS_MESSAGE_ID_callInvokeVirtual) :;
//        ord(PROCESS_MESSAGE_ID_callInvokeStatic) :;
//        ord(PROCESS_MESSAGE_ID_callMethodType1) :;
//        ord(PROCESS_MESSAGE_ID_callMethodType2) :; 
//        ord(PROCESS_MESSAGE_ID_callMethodType3) :;
//        ord(PROCESS_MESSAGE_ID_callMethodType4) :;
//        ord(PROCESS_MESSAGE_ID_returnMethod) :; 
        ord(PROCESS_MESSAGE_ID_callNativeMethod) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                utilClass.getToken('',':',s3);
                utilClass.getToken('',':',s4);
                stack := stackClass.setClassData(s3);
                bl := utilclass.strToBoolean(s4);
                callNativeMethod( s1 , s2 , stack , bl );
                msg := stackClass.getClassData(stack);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_appendStaticField) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                appendStaticField( s1 , strtoint( s2 ) );
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getStaticFieldIndex) :
        begin
                i := getStaticFieldIndex;
                msg := inttostr( i );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getStaticFieldValue) :
        begin
                utilClass.getToken('',':',s1);
                i := getStaticFieldValue(strtoint(s1));
                msg := inttostr( i );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_setStaticFieldValue) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                setStaticFieldValue(strtoint(s1), strtoint(s2) );
                msg := 'ok';
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getStaticFieldIndexByFieldName) :
        begin
                utilClass.getToken('',':',s1);
                i := getStaticFieldIndexByFieldName(s1);
                msg := inttostr( i );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getStaticFieldnameByIndex) :
        begin
                utilClass.getToken('',':',s1);
                msg := getStaticFieldnameByIndex(strtoint(s1) );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getStaticFieldvalueByIndex) :
        begin
                utilClass.getToken('',':',s1);
                i := getStaticFieldvalueByIndex(strtoint(s1) );
                msg := inttostr( i );
                isWrite := true;
        end;

//        ord(PROCESS_MESSAGE_ID_getStringByStringInstance) :
//        ord(PROCESS_MESSAGE_ID_getUTF8Name) :;
//        ord(PROCESS_MESSAGE_ID_getClassInfoName) :;
//        ord(PROCESS_MESSAGE_ID_getNameAndTypeName) :;
        ord(PROCESS_MESSAGE_ID_getMethodRefInfoName) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                getMethodRefInfoName(strtoint(s1), strtoint(s2), s3 , s4 );
                msg := s3 + ':' + s4;
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getFieldRefInfoName) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                getFieldRefInfoName(strtoint(s1), strtoint(s2), s3 , s4 );
                msg := s3 + ':' + s4;
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getConstantPoolTagByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                b := getConstantPoolTagByIndex(strtoint(s1), strtoint(s2) );
                msg := inttostr(integer(b));
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getConstantPoolconstantIntegerBytesByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getConstantPoolconstantIntegerBytesByIndex(strtoint(s1), strtoint(s2) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getConstantPoolconstantStringstringIndexByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getConstantPoolconstantStringstringIndexByIndex(strtoint(s1), strtoint(s2) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getConstantPoolconstantUTF8InfolengthByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getConstantPoolconstantUTF8InfolengthByIndex(strtoint(s1), strtoint(s2) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getConstantPoolconstantUTF8InfoBytesByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                msg := ( self.loadedClass[ strtoint(s1) ].constantPool[strtoint(s2)].info as constantUTF8Info).bytesName ;
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getConstantPoolconstantLongbytesByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i64 := getConstantPoolconstantLongbytesByIndex(strtoint(s1), strtoint(s2) );
                msg := utilclass.convertInt64ToString(i64);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getAccessFlagLoadedClassByIndexMethodsByIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                w := getAccessFlagLoadedClassByIndexMethodsByIndex(strtoint(s1), strtoint(s2) );
                msg := inttostr(integer(w));
                isWrite := true;
        end;

//        ord(PROCESS_MESSAGE_ID_getMethodsIndexWithAccessFlag) :;
        ord(PROCESS_MESSAGE_ID_getMethodsIndex) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getMethodsIndex(strtoint(s1), s2 );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getTotalLocalVariableNumber) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getTotalLocalVariableNumber(strtoint(s1), strtoint(s2) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getMethodLocalVariableNumber) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getMethodLocalVariableNumber(strtoint(s1), strtoint(s2) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getMethodArgsVariableNumber) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                i := getMethodArgsVariableNumber(strtoint(s1), strtoint(s2) );
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getMethodname) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                msg := getMethodname(strtoint(s1), strtoint(s2) );
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getCodeAttribute) :
        begin
                utilClass.getToken('',':',s1);
                utilClass.getToken('',':',s2);
                codeattr := getCodeAttribute(strtoint(s1), strtoint(s2) );
                msg := codeAttribute.getClassData(codeattr);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getInterpreterThreadCounter) :
        begin
                i := getInterpreterThreadCounter;
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getLoaderClassIndex) :
        begin
                i := getLoaderClassIndex;
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getNewInstanceIndex) :
        begin
                i := getNewInstanceIndex;
                msg := inttostr(i);
                isWrite := true;
        end;

        ord(PROCESS_MESSAGE_ID_getArrayInstanceStructIndex) :
        begin
                i := getArrayInstanceStructIndex;
                msg := inttostr(i);
                isWrite := true;
        end;

        else
        begin
                writeln('DVM:unkonw tcp message');
        end;

        end;

end;
finally
        tcsTCP.Release;
end;

end;

procedure runtimeEnvironmentClass.TCPgetDisconnect();
begin
//
end;



// �߰� �Ȱ�...

function runtimeEnvironmentClass.getConstantPoolTagByIndex( loadedClassIndex : integer ; index : integer ) : byte;
begin
        result := self.loadedClass[ loadedClassIndex ].constantPool[index].tag;
end;

function runtimeEnvironmentClass.getConstantPoolconstantIntegerBytesByIndex( loadedClassIndex : integer ; index : integer ) : integer;
begin
        result := ( self.loadedClass[ loadedClassIndex ].constantPool[index].info as constantInteger).bytes;
end;

function runtimeEnvironmentClass.getConstantPoolconstantStringstringIndexByIndex( loadedClassIndex : integer ; index : integer ) : integer;
begin
        result := ( self.loadedClass[ loadedClassIndex ].constantPool[index].info as constantString).stringIndex;
end;

function runtimeEnvironmentClass.getConstantPoolconstantUTF8InfolengthByIndex( loadedClassIndex : integer ; index : integer ) : integer;
begin
        result := ( self.loadedClass[ loadedClassIndex ].constantPool[index].info as constantUTF8Info).length ;
end;

function runtimeEnvironmentClass.getConstantPoolconstantUTF8InfoBytesByIndex( loadedClassIndex : integer ; index : integer ) : pchar;
begin
        result := ( self.loadedClass[ loadedClassIndex ].constantPool[index].info as constantUTF8Info).Bytes ;
end;

function runtimeEnvironmentClass.getConstantPoolconstantLongbytesByIndex( loadedClassIndex : integer ; index : integer ) : int64;
begin
        result := ( self.loadedClass[ loadedClassIndex ].constantPool[index].info as constantLong).bytes ;
end;

function runtimeEnvironmentClass.getStaticFieldIndex : integer;
begin
        result := staticField.index;
end;

function runtimeEnvironmentClass.getStaticFieldnameByIndex( index : integer ) : string;
begin
        result := staticField.name[index];
end;

function runtimeEnvironmentClass.getStaticFieldvalueByIndex( index : integer ) : integer;
begin
        result := staticField.Integervalue[index];
end;


function runtimeEnvironmentClass.getNewInstanceClassByIndexclassHecheriIndex( index : integer ) : integer;
begin
        result := newInstance[index].classHecheriIndex;
end;


function runtimeEnvironmentClass.getNewInstanceClassByIndexclassHecheriIndexByLoadedClassIndexByIndex( index1 : integer ; index2 : integer ) : integer;
begin
        result := newInstance[index1].classHecheriIndexByLoadedClassIndex[index2];
end;

function runtimeEnvironmentClass.getNewInstanceClassByIndexIndex( index : integer ) : integer;
begin
        result := newInstance[index].index;
end;

function runtimeEnvironmentClass.getNewInstanceClassByIndexnameByIndex( index1 : integer ; index2 : integer ) : string;
begin
        result := newInstance[index1].name[index2];
end;

function runtimeEnvironmentClass.getNewInstanceClassByIndexvalueByIndex( index1 : integer ; index2 : integer ) : integer;
begin
        result := newInstance[index1].Integervalue[index2];
end;



function runtimeEnvironmentClass.getArrayInstanceStructByIndexarrayType( index : integer ) : byte;
begin
        result := arrayInstance[ index ].arrayType;
end;


function runtimeEnvironmentClass.getArrayByIndexintArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : integer;
begin
        result := (self.arrayInstance[index1].arrayObject as intArrayInstanceClass).data[index2] ;
end;

function runtimeEnvironmentClass.getArrayByIndexlongArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : int64;
begin
        result := (self.arrayInstance[index1].arrayObject as longArrayInstanceClass).data[index2] ;
end;

function runtimeEnvironmentClass.getArrayByIndexbyteArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : byte;
begin
        result := (self.arrayInstance[index1].arrayObject as byteArrayInstanceClass).data[index2] ;
end;

function runtimeEnvironmentClass.getArrayByIndexcharArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ) : char;
begin
        result := (self.arrayInstance[index1].arrayObject as charArrayInstanceClass).data[index2];
end;

procedure runtimeEnvironmentClass.setArrayByIndexintArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : integer );
begin
        (self.arrayInstance[index1].arrayObject as intArrayInstanceClass).data[index2] := v;
end;

procedure runtimeEnvironmentClass.setArrayByIndexlongArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : int64 );
begin
        (self.arrayInstance[index1].arrayObject as longArrayInstanceClass).data[index2] := v;
end;

procedure runtimeEnvironmentClass.setArrayByIndexbyteArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : byte );
begin
        (self.arrayInstance[index1].arrayObject as byteArrayInstanceClass).data[index2] := v;
end;

procedure runtimeEnvironmentClass.setArrayByIndexcharArrayInstanceClassDataByIndex( index1 : integer ; index2 : integer ; v : char );
begin
        (self.arrayInstance[index1].arrayObject as charArrayInstanceClass).data[index2] := v;
end;


function runtimeEnvironmentClass.getArraySizeByIndexintArrayInstanceClassDataByIndex( index : integer  ) : integer;
begin
        result := (self.arrayInstance[index].arrayObject as intArrayInstanceClass).size ;
end;

function runtimeEnvironmentClass.getArraySizeByIndexlongArrayInstanceClassDataByIndex( index : integer  ) : integer;
begin
        result := (self.arrayInstance[index].arrayObject as longArrayInstanceClass).size ;
end;

function runtimeEnvironmentClass.getArraySizeByIndexbyteArrayInstanceClassDataByIndex( index : integer  ) : integer;
begin
        result := (self.arrayInstance[index].arrayObject as byteArrayInstanceClass).size ;
end;

function runtimeEnvironmentClass.getArraySizeByIndexcharArrayInstanceClassDataByIndex( index : integer  ) : integer;
begin
        result := (self.arrayInstance[index].arrayObject as charArrayInstanceClass).size ;
end;

function runtimeEnvironmentClass.getAccessFlagLoadedClassByIndexMethodsByIndex( index1 : integer ; index2 : integer ) : word;
begin
        result := self.loadedClass[index1].methods[index2].accessFlags;
end;


end.



