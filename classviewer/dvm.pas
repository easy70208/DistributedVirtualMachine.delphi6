unit dvm;

interface

uses
        sysutils, dvmDataType, dvmUtil ;

type
        classLoader = class
        private
                classfile : string;
                fileHandler : integer;

        protected
                magicNumber : array[0..3] of byte;
                minorVersion : word;
                majorVersion : word;
                constantPoolCount : word;
                constantPool : array of CPInfo;
                accessFlags : word;
                thisClass : word;
                superClass : word;
                interfacesCount : word;
                interfaces : array of word;
                fieldsCount : word;
                fields : array of fieldInfo;
                methodsCount : word;
                methods : array of methodInfo;
                attributesCount : word;
                attributes : array of attributeInfo;


        private
                // 선언된 변수명에 따라 이름을 짖는다.
                procedure loadMagicNumber();
                procedure loadMinorVersion();
                procedure loadMajorVersion();
                procedure loadConstantPoolCount();
                procedure loadConstantPool();
                procedure loadAccessFlags();
                procedure loadThisClass();
                procedure loadSuperClass();
                procedure loadInterfacesCount();
                procedure loadInterfaces();
                procedure loadFieldsCount();
                procedure loadFields();
                procedure loadMethodsCount();
                procedure loadMethods();
                procedure loadAttributesCount();
                procedure loadAttributes( ac : word ; var aoa : array of attributeInfo );

        protected
                function getConstantUTF8InfoByIndex( index : integer ) : string;

        public
                procedure load( classfile : string );

                procedure coreDumpMagicNumber();
                procedure coreDumpMinorVersion();
                procedure coreDumpMajorVersion();
                procedure coreDumpConstantPoolCount();
                procedure coreDumpConstantPool();
                procedure coreDumpAccessFlags();
                procedure coreDumpThisClass();
                procedure coreDumpSuperClass();
                procedure coreDumpInterfacesCount();
                procedure coreDumpInterfaces();
                procedure coreDumpFieldsCount();
                procedure coreDumpFields();
                procedure coreDumpMethodsCount();
                procedure coreDumpMethods();
                procedure coreDumpAttributesCount();
                procedure coreDumpAttributes( ac : word ; var aoa : array of attributeInfo ; depth : integer );
                procedure coreDump();

                procedure coreDumpCode ( cc : integer ; var code : array of byte ; depth : integer );
        end;


implementation

procedure classLoader.loadMethodsCount();
begin
        methodsCount := fileReadWordLittenEndan( fileHandler );
end;

procedure classLoader.loadMethods();
var
        i : integer;
begin
        setLength( self.methods, self.methodsCount );

        for i:=0 to self.methodsCount - 1 do
        begin
                self.methods[i] := methodInfo.Create ;

                with self.methods[i] do
                begin
                        accessFlags := fileReadWordLittenEndan( fileHandler );
                        nameIndex := fileReadWordLittenEndan( fileHandler );
                        descriptorIndex := fileReadWordLittenEndan( fileHandler );
                        attributesCount := fileReadWordLittenEndan( fileHandler );

                        if attributesCount <> 0 then
                        begin
                                setlength( attributes , attributesCount );
                                self.loadAttributes( attributesCount, attributes );
                        end;
                end;
        end;

end;

procedure classLoader.loadAttributesCount();
begin
        attributesCount := fileReadWordLittenEndan( fileHandler );
end;


procedure classLoader.loadAttributes( ac : word ; var aoa : array of attributeInfo );
var
        i : integer;
        j : integer;
        u2 : word;
        u4 : longint;
begin
//
// setLength( aoa  , ac );
// 코드가 에러가 난다. 이유를 몰라 호출측에서 배열을 초기화 해주고 호출하기로
// 했다
//

        for i:=0 to ac - 1 do
        begin
                aoa[i] := attributeInfo.Create ;

                u2 := fileReadWordLittenEndan( fileHandler );
                u4 := fileReadLongIntLittenEndan( fileHandler );

                if getConstantUTF8InfoByIndex( u2 ) = 'Code' then
                        aoa[i].attributeType := PREDEF_Code
                else
                if getConstantUTF8InfoByIndex( u2 ) = 'SourceFile' then
                        aoa[i].attributeType := PREDEF_SourceFile
                else
                if getConstantUTF8InfoByIndex( u2 ) = 'LineNumberTable' then
                        aoa[i].attributeType := PREDEF_LineNumberTable
                else
                if getConstantUTF8InfoByIndex( u2 ) = 'LocalVariableTable' then
                        aoa[i].attributeType := PREDEF_LocalVariableTable
                else
                if getConstantUTF8InfoByIndex( u2 ) = 'ConstantValue' then
                        aoa[i].attributeType := PREDEF_ConstantValue
                else
                if getConstantUTF8InfoByIndex( u2 ) = 'Exceptions' then
                        aoa[i].attributeType := PREDEF_Exceptions
                else
                if getConstantUTF8InfoByIndex( u2 ) = 'InnerClasses' then
                        aoa[i].attributeType := PREDEF_InnerClasses
                else
                if getConstantUTF8InfoByIndex( u2 ) = 'Synthetic' then
                        aoa[i].attributeType := PREDEF_Synthetic
                else
                if getConstantUTF8InfoByIndex( u2 ) = 'Deprecated' then
                        aoa[i].attributeType := PREDEF_Deprecated
                else
                        writeln( 'not defined the attributeType' );

                //writeln( getConstantUTF8InfoByIndex( u2 ));

                case aoa[i].attributeType of
                        PREDEF_ConstantValue :
                        begin
                                aoa[i].attribute := constantValueAttribute.Create;

                                with (aoa[i].attribute as constantValueAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                        constantValueIndex := fileReadWordLittenEndan( fileHandler );
                                end;
                        end;

                        PREDEF_Code :
                        begin
                                aoa[i].attribute := codeAttribute.Create ;

                                with (aoa[i].attribute as codeAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                        maxStack := fileReadWordLittenEndan( fileHandler );
                                        maxLocals := fileReadWordLittenEndan( fileHandler );
                                        codeLength := fileReadLongIntLittenEndan( fileHandler );
                                        FileRead(fileHandler, code , codeLength );
                                        exceptionTableLength := fileReadWordLittenEndan( fileHandler );

                                        for j:=0 to exceptionTableLength - 1 do
                                        begin
                                                startPc[j] := fileReadWordLittenEndan( fileHandler );
                                                endPc[j] := fileReadWordLittenEndan( fileHandler );
                                                handlerPc[j] := fileReadWordLittenEndan( fileHandler );
                                                catchType[j] := fileReadWordLittenEndan( fileHandler );
                                        end;

                                        attributesCount := fileReadWordLittenEndan( fileHandler );

                                        if attributesCount <> 0 then
                                        begin
                                                setlength( attributes , attributesCount );
                                                self.loadAttributes( attributesCount, attributes );
                                        end;
                                end;

                        end;

                        PREDEF_Exceptions :
                        begin
                                aoa[i].attribute := exceptionAttribute.Create ;

                                with (aoa[i].attribute as exceptionAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                        numberOfExceptions := fileReadWordLittenEndan( fileHandler );

                                        for j:=0 to numberOfExceptions - 1 do
                                        begin
                                                exceptionIndexTable[j] := fileReadWordLittenEndan( fileHandler );
                                        end;
                                end;
                        end;

                        PREDEF_InnerClasses :
                        begin
                                aoa[i].attribute := innerClassesAttribute.Create ;

                                with (aoa[i].attribute as innerClassesAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                        numberOfClasses := fileReadWordLittenEndan( fileHandler );

                                        for j:=0 to numberOfClasses - 1 do
                                        begin
                                                innerClassInfoIndex[j] := fileReadWordLittenEndan( fileHandler );
                                                outerClassInfoIndex[j] := fileReadWordLittenEndan( fileHandler );
                                                innerNameIndex[j] := fileReadWordLittenEndan( fileHandler );
                                                innerClassAccessFlags[j] := fileReadWordLittenEndan( fileHandler );
                                        end;
                                end;
                        end;

                        PREDEF_Synthetic :
                        begin
                                aoa[i].attribute := syntheticAttribute.Create ;

                                with (aoa[i].attribute as syntheticAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                end;
                        end;

                        PREDEF_SourceFile :
                        begin
                                aoa[i].attribute := sourceFileAttribute.Create ;
                                with (aoa[i].attribute as sourceFileAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                        sourceFileIndex := fileReadWordLittenEndan( fileHandler );
                                end;
                        end;

                        PREDEF_LineNumberTable :
                        begin
                                aoa[i].attribute := lineNumberTableAttribute.Create ;

                                with (aoa[i].attribute as lineNumberTableAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                        lineNumberTableLength := fileReadWordLittenEndan( fileHandler );

                                        for j:=0 to lineNumberTableLength - 1 do
                                        begin
                                                startPc[j] := fileReadWordLittenEndan( fileHandler );
                                                lineNumber[j] := fileReadWordLittenEndan( fileHandler );
                                        end;
                                end;

                        end;
                        
                        PREDEF_LocalVariableTable :
                        begin
                                aoa[i].attribute := localVariableTableAttribute.Create ;

                                with (aoa[i].attribute as localVariableTableAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                        localVariableTableLength := fileReadWordLittenEndan( fileHandler );

                                        for j:=0 to localVariableTableLength - 1 do
                                        begin
                                                startPc[j] := fileReadWordLittenEndan( fileHandler );
                                                length[j] := fileReadWordLittenEndan( fileHandler );
                                                nameIndex[j] := fileReadWordLittenEndan( fileHandler );
                                                descriptorIndex[j] := fileReadWordLittenEndan( fileHandler );
                                                index[j] := fileReadWordLittenEndan( fileHandler );
                                        end;
                                end;
                        end;

                        PREDEF_Deprecated :
                        begin
                                aoa[i].attribute := deprecatedAttribute.Create ;

                                with (aoa[i].attribute as deprecatedAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                end;
                        end;

                end; //case aoa[i].attributeType of

        end; //for i:=0 to ac - 1 do

end;

function classLoader.getConstantUTF8InfoByIndex( index : integer ) : string;
begin
        result := (self.constantPool[index].info as constantUtf8Info).bytesName;
end;

procedure classLoader.loadFields();
var
        i : integer;
begin
        setLength( self.fields, self.fieldsCount );

        for i:=0 to self.fieldsCount - 1 do
        begin
                self.fields[i] := fieldInfo.Create ;

                with self.fields[i] do
                begin
                        accessFlags := fileReadWordLittenEndan( fileHandler );
                        nameIndex := fileReadWordLittenEndan( fileHandler );
                        descriptorIndex := fileReadWordLittenEndan( fileHandler );
                        attributesCount := fileReadWordLittenEndan( fileHandler );

                        if attributesCount <> 0 then
                        begin
                                setlength( attributes , attributesCount );
                                self.loadAttributes( attributesCount, attributes );
                        end;
                end;
        end;

end;

procedure classLoader.loadFieldsCount();
begin
        fieldsCount := fileReadWordLittenEndan( fileHandler );
end;

procedure classLoader.loadInterfaces();
var
        i : integer;
begin
        setLength ( self.interfaces , interfacesCount );

        for i := 0 to self.interfacesCount - 1 do
        begin
                self.interfaces[i] := fileReadWordLittenEndan( fileHandler );
        end;
end;

procedure classLoader.loadMagicNumber();
begin
        FileRead(fileHandler, magicNumber, 4 );
end;

procedure classLoader.loadMinorVersion();
begin
        minorVersion := fileReadWordLittenEndan( fileHandler );
end;

procedure classLoader.loadMajorVersion();
begin
        majorVersion := fileReadWordLittenEndan( fileHandler );
end;

procedure classLoader.loadConstantPool();
var
        i : integer;
begin
        setLength( self.constantPool , self.constantPoolCount );

        // constantPool[0] is not used because system is reserved
        self.constantPool[0] := CPInfo.Create ;
        self.constantPool[0].tag := 0;

        for i := 1 to self.constantPoolCount - 1 do // for ( i = 1 ; i <= cpc - 1 ; i++ )
        begin
                self.constantPool[i] := CPInfo.Create ;

                FileRead( self.fileHandler , self.constantPool[i].tag , 1 );

                case self.constantPool[i].tag of
                        CONSTANT_Class :
                        begin
                                self.constantPool[i].info := constantClassInfo.Create();
                                (self.constantPool[i].info as constantClassInfo).nameIndex := fileReadWordLittenEndan( fileHandler );
                        end;

                        CONSTANT_Fieldref :
                        begin
                                self.constantPool[i].info := constantFieldref.Create();
                                (self.constantPool[i].info as constantFieldref).classIndex := fileReadWordLittenEndan( fileHandler );
                                (self.constantPool[i].info as constantFieldref).nameAndTypeIndex := fileReadWordLittenEndan( fileHandler );
                        end;

                        CONSTANT_Methodref :
                        begin
                                self.constantPool[i].info := constantMethodref.Create();
                                (self.constantPool[i].info as constantMethodref).classIndex := fileReadWordLittenEndan( fileHandler );
                                (self.constantPool[i].info as constantMethodref).nameAndTypeIndex := fileReadWordLittenEndan( fileHandler );
                        end;

                        CONSTANT_InterfaceMethodref :
                        begin
                                self.constantPool[i].info := constantInterfaceMethodref.Create();
                                (self.constantPool[i].info as constantInterfaceMethodref).classIndex := fileReadWordLittenEndan( fileHandler );
                                (self.constantPool[i].info as constantInterfaceMethodref).nameAndTypeIndex := fileReadWordLittenEndan( fileHandler );
                        end;

                        CONSTANT_String :
                        begin
                                self.constantPool[i].info := constantString.Create();
                                (self.constantPool[i].info as constantString).stringIndex := fileReadWordLittenEndan( fileHandler );
                        end;

                        CONSTANT_Integer :
                        begin
                                self.constantPool[i].info := constantInteger.Create();
                                (self.constantPool[i].info as constantInteger).bytes := fileReadLongIntLittenEndan( fileHandler );
                        end;

                        CONSTANT_Float :
                        begin
                                self.constantPool[i].info := constantFloat.Create();
                                (self.constantPool[i].info as constantFloat).bytes := fileReadLongIntLittenEndan( fileHandler );
                        end;

                        CONSTANT_Long :
                        begin
                                self.constantPool[i].info := constantLong.Create();
                                (self.constantPool[i].info as constantLong).highBytes := fileReadLongIntLittenEndan( fileHandler );
                                (self.constantPool[i].info as constantLong).lowBytes := fileReadLongIntLittenEndan( fileHandler );
                        end;

                        CONSTANT_Double :
                        begin
                                self.constantPool[i].info := constantDouble.Create();
                                (self.constantPool[i].info as constantDouble).highBytes := fileReadLongIntLittenEndan( fileHandler );
                                (self.constantPool[i].info as constantDouble).lowBytes := fileReadLongIntLittenEndan( fileHandler );
                        end;

                        CONSTANT_NameAndType :
                        begin
                                self.constantPool[i].info := constantNameAndType.Create();
                                (self.constantPool[i].info as constantNameAndType).nameIndex := fileReadWordLittenEndan( fileHandler );
                                (self.constantPool[i].info as constantNameAndType).descriptorIndex := fileReadWordLittenEndan( fileHandler );
                        end;
                        CONSTANT_Utf8 :
                        begin
                                self.constantPool[i].info := constantUtf8Info.Create();
                                (self.constantPool[i].info as constantUtf8Info).length := fileReadWordLittenEndan( fileHandler );

                                // setLength가 않되고 있다.  모르겠다.
                                // 그래서 bytes를 정적 배열로 선언했다.
                                //setLength( (self.constantPool[i].info as constantUtf8Info).bytes , u2 );

                                FileRead( self.fileHandler , (self.constantPool[i].info as constantUtf8Info).bytes , (self.constantPool[i].info as constantUtf8Info).length );
                                // 유니코드 처리 .... 않된다.....
                                //(self.constantPool[i].infoClass as constantUtf8Info).name := widecharlentostring( (self.constantPool[i].infoClass as constantUtf8Info).bytes , u2 );
                                SetString( (self.constantPool[i].info as constantUtf8Info).bytesName , (self.constantPool[i].info as constantUtf8Info).bytes , (self.constantPool[i].info as constantUtf8Info).length );
                                //writeln( (self.constantPool[i].infoClass as constantUtf8Info).name );
                        end;
                end;


        end;

end;

procedure classLoader.loadConstantPoolCount();
begin
        constantPoolCount := fileReadWordLittenEndan( fileHandler );
end;

procedure classLoader.loadAccessFlags();
begin
        accessFlags := fileReadWordLittenEndan( fileHandler );
end;

procedure classLoader.loadThisClass();
begin
        thisClass := fileReadWordLittenEndan( fileHandler );
end;

procedure classLoader.loadSuperClass();
begin
        superClass := fileReadWordLittenEndan( fileHandler );
end;

procedure classLoader.loadInterfacesCount();
begin
        interfacesCount := fileReadWordLittenEndan( fileHandler );
end;


procedure classLoader.load( classfile : string );
begin
        self.classfile := classfile;

        self.fileHandler := fileOpen( classfile,  fmOpenRead );

        self.loadMagicNumber;
        self.loadMinorVersion;
        self.loadMajorVersion;
        self.loadConstantPoolCount ;
        self.loadconstantPool ;
        self.loadAccessFlags;
        self.loadThisClass;
        self.loadSuperClass;
        self.loadInterfacesCount;
        self.loadInterfaces;
        self.loadFieldsCount;
        self.loadFields;
        self.loadMethodsCount;

        self.loadMethods;
        self.loadAttributesCount;

        setlength( self.attributes , self.attributesCount );
        self.loadAttributes( self.attributesCount , self.attributes );

        FileClose( fileHandler );

end;

procedure classLoader.coreDumpMagicNumber();
begin
        writeln( format('magicNumber : #%x%x%x%x' ,
                [magicNumber[0], magicNumber[1] ,
                magicNumber[2] , magicNumber[3]] ) );
end;

procedure classLoader.coreDumpMinorVersion();
begin
        writeln( format('minorVersion : %d', [minorVersion] ) );
end;

procedure classLoader.coreDumpMajorVersion();
begin
        writeln( format('majorVersion : %d' , [majorVersion]) );
end;

procedure classLoader.coreDumpConstantPoolCount();
begin
        writeln( format('constantPoolCount : %d' , [constantPoolCount]) );
end;

procedure classLoader.coreDumpConstantPool();
var
        i : integer;
begin
        for i := 0 to self.constantPoolCount - 1 do
        begin
                write( format( 'tag[%d] : ' , [i] ) );

                case self.constantPool[i].tag of
                        CONSTANT_Class :
                        begin
                                write( format( 'CONSTANT_Class(%d) ' , [ self.constantPool[i].tag ]) );
                                write( format( 'nameIndex : %d' ,
                                        [(self.constantPool[i].info as constantClassInfo).nameIndex ] ) );
                        end;

                        CONSTANT_Fieldref :
                        begin
                                write( format( 'CONSTANT_Fieldref(%d) ' , [ self.constantPool[i].tag ]) );
                                write( format( 'classIndex : %d  nameAndTypeIndex : %d' ,
                                        [(self.constantPool[i].info as constantFieldref).classIndex,
                                         (self.constantPool[i].info as constantFieldref).nameAndTypeIndex ] ) );
                        end;

                        CONSTANT_Methodref :
                        begin
                                write( format( 'CONSTANT_Methodref(%d) ' , [ self.constantPool[i].tag ]) );
                                write( format( 'classIndex : %d  nameAndTypeIndex : %d' ,
                                        [(self.constantPool[i].info as constantMethodref).classIndex,
                                         (self.constantPool[i].info as constantMethodref).nameAndTypeIndex ] ) );
                        end;

                        CONSTANT_InterfaceMethodref :
                        begin
                                write( format( 'CONSTANT_InterfaceMethodref(%d)' , [ self.constantPool[i].tag ]) );
                                write( format( 'classIndex : %d  nameAndTypeIndex : %d' ,
                                        [(self.constantPool[i].info as constantInterfaceMethodref).classIndex,
                                         (self.constantPool[i].info as constantInterfaceMethodref).nameAndTypeIndex ] ) );
                        end;

                        CONSTANT_String :
                        begin
                                write( format( 'CONSTANT_String(%d) ' , [ self.constantPool[i].tag ]) );
                                write( format( 'stringIndex : %d' ,
                                        [(self.constantPool[i].info as constantString).stringIndex ] ) );
                        end;

                        CONSTANT_Integer :
                        begin
                                write( format( 'CONSTANT_Integer(%d)  bytes : %d' ,
                                [ self.constantPool[i].tag , (self.constantPool[i].info as constantInteger).bytes ]) );
                        end;

                        CONSTANT_Float :
                        begin
                                write( format( 'CONSTANT_Float(%d) ' , [ self.constantPool[i].tag ]) );
                        end;

                        CONSTANT_Long :
                        begin
                                write( format( 'CONSTANT_Long(%d) ' , [ self.constantPool[i].tag ]) );
                        end;

                        CONSTANT_Double :
                        begin
                                write( format( 'CONSTANT_Double(%d) ' , [ self.constantPool[i].tag ]) );
                        end;

                        CONSTANT_NameAndType :
                        begin
                                write( format( 'CONSTANT_NameAndType(%d) ' , [ self.constantPool[i].tag ]) );
                                write( format( 'nameIndex : %d  descriptorIndex : %d' ,
                                        [(self.constantPool[i].info as constantNameAndType).nameIndex,
                                         (self.constantPool[i].info as constantNameAndType).descriptorIndex ] ) );
                        end;

                        CONSTANT_Utf8 :
                        begin
                                write( format( 'CONSTANT_Utf8(%d) ' , [ self.constantPool[i].tag ]) );
                                write( format( 'length : %d  bytes(string) : %s',
                                [(self.constantPool[i].info as constantUtf8Info).length,
                                (self.constantPool[i].info as constantUtf8Info).bytesName ] ) );

                        end;
                        else
                        begin
                                write( 'vm reserved' );
                        end;
                end; // case self.constantPool[i].tag of

                writeln( '' );
        end; // for i := 1 to self.constantPoolCount do
end;

procedure classLoader.coreDumpAccessFlags();
begin
        writeln( format('accessFlags : #%x  ' , [accessFlags]) );
end;

procedure classLoader.coreDumpThisClass();
begin
        writeln( format('thisClass : %d' , [thisClass]) );
end;

procedure classLoader.coreDumpSuperClass();
begin
        writeln( format('superClass : %d' , [superClass]) );
end;

procedure classLoader.coreDumpInterfacesCount();
begin
        writeln( format('interfacesCount : %d' , [interfacesCount]) );
end;

procedure classLoader.coreDumpInterfaces();
var
        i : integer;
begin
        for i:=0 to self.interfacesCount - 1 do
        begin
                writeln( format( 'interface : %d' , [ self.interfaces[i] ] ) );
        end;
end;

procedure classLoader.coreDumpFieldsCount();
begin
        writeln( format('fieldsCount : %d' , [fieldsCount]) );
end;

procedure classLoader.coreDumpFields();
var
        i : integer;
begin
        for i:=0 to self.fieldsCount - 1 do
        begin
                write( format('field[%d] : ' , [i] ) );
                writeln( format('accessFlags : #%x  nameIndex : %d  descriptorIndex : %d  attributesCount : %d',
                [self.fields[i].accessFlags , self.fields[i].nameIndex , self.fields[i].descriptorIndex , self.fields[i].attributesCount ] ) );

                if self.fields[i].attributesCount <> 0 then
                begin
                        self.coreDumpAttributes(
                        self.fields[i].attributesCount,
                        self.fields[i].attributes,
                        1
                        );
                end;
        end;
end;

procedure classLoader.coreDumpMethodsCount();
begin
        writeln( format('methodsCount : %d' , [methodsCount]) );
end;

procedure classLoader.coreDumpMethods();
var
        i : integer;
begin
        for i:=0 to self.methodsCount - 1 do
        begin
                write( format('method[%d] : ' , [i] ) );
                writeln( format('accessFlags : #%x  nameIndex : %d  descriptorIndex : %d  attributesCount : %d',
                [self.methods[i].accessFlags , self.methods[i].nameIndex , self.methods[i].descriptorIndex , self.methods[i].attributesCount ] ) );


                if self.methods[i].attributesCount <> 0 then
                begin
                        self.coreDumpAttributes(
                        self.methods[i].attributesCount,
                        self.methods[i].attributes,
                        1
                        );
                end;
        end;
end;

procedure classLoader.coreDumpAttributesCount();
begin
        writeln( format('attributesCount : %d' , [attributesCount]) );
end;

procedure classLoader.coreDumpAttributes( ac : word ; var aoa : array of attributeInfo ; depth : integer );
var
        i : integer;
        j : integer;
        d : string;
begin
        d := '';

        for i:=0 to (depth*10) - 1 do
        begin
                d := d + ' ';
        end;

        for i:=0 to ac - 1 do
        begin
                case aoa[i].attributeType of
                        PREDEF_ConstantValue :
                        begin
                                with (aoa[i].attribute as constantValueAttribute) do
                                begin
                                        write(d); writeln( 'ConstantValue attribute' );
                                        write(d); writeln( format('attributeNameIndex : %d', [ attributeNameIndex ] ) );
                                        write(d); writeln( format('attributeLength : %d', [ attributeLength ] ) );
                                        write(d); writeln( format('constantValueIndex : %d', [ constantValueIndex ] ) );
                                end;
                        end;

                        PREDEF_Code :
                        begin
                                with (aoa[i].attribute as codeAttribute) do
                                begin
                                        write(d); writeln( 'Code attribute' );
                                        write(d); writeln( format('attributeNameIndex : %d', [ attributeNameIndex ] ) );
                                        write(d); writeln( format('attributeLength : %d', [ attributeLength ] ) );
                                        write(d); writeln( format('maxStack : %d', [ maxStack ] ) );

                                        write(d); writeln( format('maxLocals : %d', [ maxLocals ] ) );
                                        write(d); writeln( format('codeLength : %d', [ codeLength ] ) );

                                        coreDumpCode( codeLength , code , depth + 1 );

                                        write(d); writeln( format('exceptionTableLength : %d', [ exceptionTableLength ] ) );

                                        for j:=0 to exceptionTableLength - 1 do
                                        begin
                                                write(d);
                                                write( format('startPc[%d] : %d  ', [ j, startPc[j] ] ) );
                                                write( format('endPc[%d] : %d  ', [ j, endPc[j] ] ) );
                                                write( format('handlerPc[%d] : %d  ', [ j, handlerPc[j] ] ) );
                                                writeln( format('catchType[%d] : %d', [ j, catchType[j] ] ) );
                                        end;

                                        write(d); writeln( format('attributesCount : %d', [ attributesCount ] ) );

                                        if attributesCount <> 0 then
                                        begin
                                                self.coreDumpAttributes( attributesCount, attributes , depth + 1 );
                                        end;
                                end;

                        end;

                        PREDEF_Exceptions :
                        begin
                                with (aoa[i].attribute as exceptionAttribute) do
                                begin
                                        write(d); writeln( 'Exceptions attribute' );
                                        write(d); writeln( format('attributeNameIndex : %d', [ attributeNameIndex ] ) );
                                        write(d); writeln( format('attributeLength : %d', [ attributeLength ] ) );
                                        write(d); writeln( format('numberOfExceptions : %d', [ numberOfExceptions ] ) );

                                        for j:=0 to numberOfExceptions - 1 do
                                        begin
                                                write(d); writeln( format('exceptionIndexTable[%d] : %d', [ j, exceptionIndexTable[j] ] ) );
                                        end;
                                end;
                        end;

                        PREDEF_InnerClasses :
                        begin
                                with (aoa[i].attribute as innerClassesAttribute) do
                                begin
                                        write(d); writeln( 'InnerClasses attribute' );
                                        write(d); writeln( format('attributeNameIndex : %d', [ attributeNameIndex ] ) );
                                        write(d); writeln( format('attributeLength : %d', [ attributeLength ] ) );
                                        write(d); writeln( format('numberOfClasses : %d', [ numberOfClasses ] ) );

                                        for j:=0 to numberOfClasses - 1 do
                                        begin
                                                write(d);
                                                write( format('innerClassInfoIndex[%d] : %d  ', [ j, innerClassInfoIndex[j] ] ) );
                                                write( format('outerClassInfoIndex[%d] : %d  ', [ j, outerClassInfoIndex[j] ] ) );
                                                write( format('innerNameIndex[%d] : %d  ', [ j, innerNameIndex[j] ] ) );
                                                writeln( format('innerClassAccessFlags[%d] : %d', [ j, innerClassAccessFlags[j] ] ) );
                                        end;
                                end;
                        end;

                        PREDEF_Synthetic :
                        begin
                                with (aoa[i].attribute as syntheticAttribute) do
                                begin
                                        write(d); writeln( 'Synthetic attribute' );
                                        write(d); writeln( format('attributeNameIndex : %d', [ attributeNameIndex ] ) );
                                        write(d); writeln( format('attributeLength : %d', [ attributeLength ] ) );
                                end;
                        end;

                        PREDEF_SourceFile :
                        begin
                                with (aoa[i].attribute as sourceFileAttribute) do
                                begin
                                        write(d); writeln( 'SourceFile attribute' );
                                        write(d); writeln( format('attributeNameIndex : %d', [ attributeNameIndex ] ) );
                                        write(d); writeln( format('attributeLength : %d', [ attributeLength ] ) );
                                        write(d); writeln( format('sourceFileIndex : %d', [ sourceFileIndex ] ) );
                                end;
                        end;

                        PREDEF_LineNumberTable :
                        begin
                                with (aoa[i].attribute as lineNumberTableAttribute) do
                                begin
                                        write(d); writeln( 'LineNumberTable attribute' );
                                        write(d); writeln( format('attributeNameIndex : %d', [ attributeNameIndex ] ) );
                                        write(d); writeln( format('attributeLength : %d', [ attributeLength ] ) );
                                        write(d); writeln( format('lineNumberTableLength : %d', [ lineNumberTableLength ] ) );

                                        for j:=0 to lineNumberTableLength - 1 do
                                        begin
                                                write(d);
                                                write( format('startPc[%d] : %d  ', [ j, startPc[j] ] ) );
                                                writeln( format('lineNumber[%d] : %d', [ j, lineNumber[j] ] ) );
                                        end;
                                end;

                        end;
                        
                        PREDEF_LocalVariableTable :
                        begin
                                with (aoa[i].attribute as localVariableTableAttribute) do
                                begin
                                        write(d); writeln( 'LocalVariableTable attribute' );
                                        write(d); writeln( format('attributeNameIndex : %d', [ attributeNameIndex ] ) );
                                        write(d); writeln( format('attributeLength : %d', [ attributeLength ] ) );
                                        write(d); writeln( format('localVariableTableLength : %d', [ localVariableTableLength ] ) );

                                        for j:=0 to localVariableTableLength - 1 do
                                        begin
                                                write(d);
                                                write( format('startPc[%d] : %d  ', [ j, startPc[j] ] ) );
                                                write( format('length[%d] : %d  ', [ j, length[j] ] ) );
                                                write( format('nameIndex[%d] : %d  ', [ j, nameIndex[j] ] ) );
                                                write( format('descriptorIndex[%d] : %d  ', [ j, descriptorIndex[j] ] ) );
                                                writeln( format('index[%d] : %d', [ j, index[j] ] ) );
                                        end;
                                end;
                        end;

                        PREDEF_Deprecated :
                        begin
                                with (aoa[i].attribute as deprecatedAttribute) do
                                begin
                                        write(d); writeln( 'Deprecated attribute' );
                                        write(d); writeln( format('attributeNameIndex : %d', [ attributeNameIndex ] ) );
                                        write(d); writeln( format('attributeLength : %d', [ attributeLength ] ) );
                                end;
                        end;

                end; //case aoa[i].attributeType of

        end; //for i:=0 to ac - 1 do
end;

procedure classLoader.coreDump();
begin
        writeln( format('classfile : %s', [classfile]) );

        coreDumpMagicNumber;
        coreDumpMinorVersion;
        coreDumpMajorVersion;
        coreDumpConstantPoolCount;
        coreDumpConstantPool;
        coreDumpAccessFlags;
        coreDumpThisClass;
        coreDumpSuperClass;
        coreDumpInterfacesCount;
        coreDumpInterfaces;
        coreDumpFieldsCount;
        coreDumpFields;
        coreDumpMethodsCount;
        coreDumpMethods;
        coreDumpAttributesCount;
        coreDumpAttributes(self.attributesCount , self.attributes , 0 );
end;


procedure classLoader.coreDumpCode ( cc : integer ; var code : array of byte ; depth : integer );
var
        i : integer;
        ln : integer; // linenumber
        s1 : string;
        s2 : string;
        s3 : string;
        d : string;
begin
        d := '';

        for i:=0 to (depth*10) - 1 do
        begin
                d := d + ' ';
        end;


        write(d);
        writeln( format('code length : %d',[cc]) );

        i := 0;
        ln := 1;


while i < cc do
begin

case code[i] of

00 : //(#00) nop
begin
        s1 := format('%x',[code[i]] );
        s2 := 'nop';
        inc(i);
end;

01 : //(#01) aconst_null
begin
        s1 := format('%x',[code[i]] );
        s2 := 'aconst_null';
        inc(i);
end;

02 : //(#02) iconst_m1
begin
        s1 := format('%x',[code[i]] );
        s2 := 'iconst_m1';
        inc(i);
end;


03 : //(#03) iconst_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iconst_0';
        inc(i);
end;


04 : //(#04) iconst_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iconst_1';
        inc(i);
end;

05 : //(#05) iconst_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iconst_2';
        inc(i);
end;

06 : //(#06) iconst_3
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iconst_3';
        inc(i);
end;

07 : //(#07) iconst_4
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iconst_4';
        inc(i);
end;

08 : //(#08) iconst_5
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iconst_5';
        inc(i);
end;

09 : //(#09) lconst_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lconst_0';
        inc(i);
end;

10 : //(#0a) lconst_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lconst_1';
        inc(i);
end;

11 : //(#0b) fconst_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fconst_0';
        inc(i);
end;

12 : //(#0c) fconst_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fconst_1';
        inc(i);
end;

13 : //(#0d) fconst_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fconst_2';
        inc(i);
end;

14 : //(#0e) dconst_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dconst_0';
        inc(i);
end;

15 : //(#0f) dconst_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dconst_1';
        inc(i);
end;

16 : //(#10) bipush
begin
        s1 := format('%x %x ',[code[i],code[i+1] ] );
        s2 := format('%s %d', ['bipush', code[i+1] ] );
        inc(i);
        inc(i);
end;


17 : //(#11) sipush
begin
        s1 := format('%x %x ',[code[i],code[i+1] ] );
        s2 := format('%s %d', ['sipush', code[i+1] ] );
        inc(i);
        inc(i);
end;

18 : //(#12) ldc
begin
        s1 := format('%x %x',[code[i],code[i+1] ] );
        s2 := format('%s %d', ['ldc', code[i+1] ] );
        inc(i);
        inc(i);
end;

19 : //(#13) ldc_w
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['ldc_w', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

20 : //(#14) ldc2_w
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['ldc2_w', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

21 : //(#15) iload
begin
        s1 := format('%x %x',[code[i],code[i+1] ] );
        s2 := format('%s %d', ['iload', code[i+1] ] );
        inc(i);
        inc(i);
end;

22 : //(#16) lload
begin
        s1 := format('%x %x',[code[i],code[i+1] ] );
        s2 := format('%s %d', ['lload', code[i+1] ] );
        inc(i);
        inc(i);
end;

23 : //(#17) fload
begin
        s1 := format('%x %x',[code[i],code[i+1] ] );
        s2 := format('%s %d', ['fload', code[i+1] ] );
        inc(i);
        inc(i);
end;

24 : //(#18) dload
begin
        s1 := format('%x %x',[code[i],code[i+1] ] );
        s2 := format('%s %d', ['dload', code[i+1] ] );
        inc(i);
        inc(i);
end;

25 : //(#19) aload
begin
        s1 := format('%x',[code[i]] );
        s2 := 'aload';
        inc(i);
end;

26 : //(#1a) iload_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iload_0';
        inc(i);
end;

27 : //(#1b) iload_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iload_1';
        inc(i);
end;

28 : //(#1c) iload_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iload_2';
        inc(i);
end;

29 : //(#1d) iload_3
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iload_3';
        inc(i);
end;


30 : //(#1e) lload_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lload_0';
        inc(i);
end;


31 : //(#1f) lload_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lload_1';
        inc(i);
end;


32 : //(#20) lload_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lload_2';
        inc(i);
end;


33 : //(#21) lload_3
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lload_3';
        inc(i);
end;


34 : //(#22) fload_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fload_0';
        inc(i);
end;


35 : //(#23) fload_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fload_1';
        inc(i);
end;


36 : //(#24) fload_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fload_2';
        inc(i);
end;


37 : //(#25) fload_3
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fload_3';
        inc(i);
end;


38 : //(#26) dload_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dload_0';
        inc(i);
end;


39 : //(#27) dload_1
 begin
        s1 := format('%x',[code[i]]);
        s2 := 'dload_1';
        inc(i);
end;


40 : //(#28) dload_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dload_2';
        inc(i);
end;


41 : //(#29) dload_3
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dload_3';
        inc(i);
end;


42 : //(#2a) aload_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'aload_0';
        inc(i);
end;

43 : //(#2b) aload_1
begin
        s1 := format('%x',[code[i]] );
        s2 := 'aload_1';
        inc(i);
end;

44 : //(#2c) aload_2
begin
        s1 := format('%x',[code[i]] );
        s2 := 'aload_2';
        inc(i);
end;

45 : //(#2d) aload_3
begin
        s1 := format('%x',[code[i]] );
        s2 := 'aload_3';
        inc(i);
end;

46 : //(#2e) iaload
begin
        s1 := format('%x',[code[i]] );
        s2 := 'iaload';
        inc(i);
end;

47 : //(#2f) laload
begin
        s1 := format('%x',[code[i]] );
        s2 := 'laload';
        inc(i);
end;

48 : //(#30) faload
begin
        s1 := format('%x',[code[i]] );
        s2 := 'faload';
        inc(i);
end;

49 : //(#31) daload
begin
        s1 := format('%x',[code[i]] );
        s2 := 'daload';
        inc(i);
end;

50 : //(#32) aaload
begin
        s1 := format('%x',[code[i]]);
        s2 := 'aaload';
        inc(i);
end;

51 : //(#33) baload
begin
        s1 := format('%x',[code[i]]);
        s2 := 'baload';
        inc(i);
end;

52 : //(#34) caload
begin
        s1 := format('%x',[code[i]]);
        s2 := 'caload';
        inc(i);
end;


53 : //(#35) saload
begin
        s1 := format('%x',[code[i]]);
        s2 := 'saload';
        inc(i);
end;

54 : //(#36) istore
begin
        s1 := format('%x',[code[i]]);
        s2 := 'istore';
        inc(i);
end;

55 : //(#37) lstore
begin
        s1 := format('%x %x',[code[i],code[i+1] ] );
        s2 := format('%s %d', ['lstore', code[i+1] ] );
        inc(i);
        inc(i);
end;

56 : //(#38) fstore
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fstore';
        inc(i);
end;

57 : //(#39) dstore
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dstore';
        inc(i);
end;

58 : //(#3a) astore
begin
        s1 := format('%x %x',[code[i],code[i+1] ] );
        s2 := format('%s %d', ['astore', code[i+1] ] );
        inc(i);
        inc(i);
end;

59 : //(#3b) istore_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'istore_0';
        inc(i);
end;

60 : //(#3c) istore_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'istore_1';
        inc(i);
end;


61 : //(#3d) istore_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'istore_2';
        inc(i);
end;

62 : //(#3e) istore_3
begin
        s1 := format('%x',[code[i]]);
        s2 := 'istore_3';
        inc(i);
end;



63 : //(#3f) lstore_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lstore_0';
        inc(i);
end;


64 : //(#40) lstore_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lstore_1';
        inc(i);
end;


65 : //(#41) lstore_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lstore_2';
        inc(i);
end;


66 : //(#42) lstore_3
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lstore_3';
        inc(i);
end;


67 : //(#43) fstore_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fstore_0';
        inc(i);
end;


68 : //(#44) fstore_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fstore_1';
        inc(i);
end;


69 : //(#45) fstore_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fstore_2';
        inc(i);
end;


70 : //(#46) fstore_3
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fstore_3';
        inc(i);
end;


71 : //(#47) dstore_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dstore_0';
        inc(i);
end;


72 : //(#48) dstore_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dstore_1';
        inc(i);
end;


73 : //(#49) dstore_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dstore_2';
        inc(i);
end;


74 : //(#4a) dstore_3
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dstore_3';
        inc(i);
end;


75 : //(#4b) astore_0
begin
        s1 := format('%x',[code[i]]);
        s2 := 'astore_0';
        inc(i);
end;

76 : //(#4c) astore_1
begin
        s1 := format('%x',[code[i]]);
        s2 := 'astore_1';
        inc(i);
end;

77 : //(#4d) astore_2
begin
        s1 := format('%x',[code[i]]);
        s2 := 'astore_2';
        inc(i);
end;

78 : //(#4e) astore_3
begin
        s1 := format('%x',[code[i]]);
        s2 := 'astore_3';
        inc(i);
end;


79 : //(#4f) iastore
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iastore';
        inc(i);
end;

80 : //(#50) lastore
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lastore';
        inc(i);
end;

81 : //(#51) fastore
begin
        s1 := format('%x',[code[i]]);
        s2 := 'fastore';
        inc(i);
end;

82 : //(#52) dastore
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dastore';
        inc(i);
end;

83 : //(#53) aastore
begin
        s1 := format('%x',[code[i]] );
        s2 := 'aastore';
        inc(i);
end;

84 : //(#54) bastore
begin
        s1 := format('%x',[code[i]] );
        s2 := 'bastore';
        inc(i);
end;

85 : //(#55) castore
begin
        s1 := format('%x',[code[i]] );
        s2 := 'castore';
        inc(i);
end;

86 : //(#56) sastore
begin
        s1 := format('%x',[code[i]] );
        s2 := 'sastore';
        inc(i);
end;

87 : //(#57) pop
begin
        s1 := format('%x',[code[i]] );
        s2 := 'pop';
        inc(i);
end;

88 : //(#58) pop2
begin
        s1 := format('%x',[code[i]] );
        s2 := 'pop2';
        inc(i);
end;

089 : //(#59) dup
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dup';
        inc(i);
end;


090 : //(#5a) dup_x1
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dup_x1';
        inc(i);
end;

091 : //(#5b) dup_x2
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dup_x2';
        inc(i);
end;

092 : //(#5c) dup2
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dup2';
        inc(i);
end;

093 : //(#5d) dup2_x1
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dup2_x1';
        inc(i);
end;

094 : //(#5e) dup2_x2
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dup2_x2';
        inc(i);
end;

095 : //(#5f) swap
begin
        s1 := format('%x',[code[i]] );
        s2 := 'swap';
        inc(i);
end;

096 : //(#60) iadd
begin
        s1 := format('%x',[code[i]]);
        s2 := 'iadd';
        inc(i);
end;

097 : //(#61) ladd
begin
        s1 := format('%x',[code[i]] );
        s2 := 'ladd';
        inc(i);
end;

098 : //(#62) fadd
begin
        s1 := format('%x',[code[i]] );
        s2 := 'fadd';
        inc(i);
end;

099 : //(#63) dadd
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dadd';
        inc(i);
end;

100 : //(#64) isub
begin
        s1 := format('%x',[code[i]] );
        s2 := 'isub';
        inc(i);
end;

101 : //(#65) lsub
begin
        s1 := format('%x',[code[i]] );
        s2 := 'lsub';
        inc(i);
end;

102 : //(#66) fsub
begin
        s1 := format('%x',[code[i]] );
        s2 := 'fsub';
        inc(i);
end;

103 : //(#67) dsub
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dsub';
        inc(i);
end;

104 : //(#68) imul
begin
        s1 := format('%x',[code[i]] );
        s2 := 'imul';
        inc(i);
end;

105 : //(#69) lmul
begin
        s1 := format('%x',[code[i]] );
        s2 := 'lmul';
        inc(i);
end;

106 : //(#6a) fmul
begin
        s1 := format('%x',[code[i]] );
        s2 := 'fmul';
        inc(i);
end;

107 : //(#6b) dmul
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dmul';
        inc(i);
end;

108 : //(#6c) idiv
begin
        s1 := format('%x',[code[i]] );
        s2 := 'idiv';
        inc(i);
end;

109 : //(#6d) ldiv
begin
        s1 := format('%x',[code[i]] );
        s2 := 'ldiv';
        inc(i);
end;

110 : //(#6e) fdiv
begin
        s1 := format('%x',[code[i]] );
        s2 := 'fdiv';
        inc(i);
end;

111 : //(#6f) ddiv
begin
        s1 := format('%x',[code[i]] );
        s2 := 'ddiv';
        inc(i);
end;

112 : //(#70) irem
begin
        s1 := format('%x',[code[i]] );
        s2 := 'irem';
        inc(i);
end;

113 : //(#71) lrem
begin
        s1 := format('%x',[code[i]] );
        s2 := 'lrem';
        inc(i);
end;

114 : //(#72) frem
begin
        s1 := format('%x',[code[i]] );
        s2 := 'frem';
        inc(i);
end;

115 : //(#73) drem
begin
        s1 := format('%x',[code[i]] );
        s2 := 'drem';
        inc(i);
end;

116 : ; //(#74).......ineg

117 : //(#75) lneg
begin
        s1 := format('%x',[code[i]] );
        s2 := 'lneg';
        inc(i);
end;

118 : //(#76) fneg
begin
        s1 := format('%x',[code[i]] );
        s2 := 'fneg';
        inc(i);
end;

119 : //(#77) dneg
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dneg';
        inc(i);
end;

120 : //(#78) ishl
begin
        s1 := format('%x',[code[i]] );
        s2 := 'ishl';
        inc(i);
end;

121 : //(#79) lshl
begin
        s1 := format('%x',[code[i]] );
        s2 := 'lshl';
        inc(i);
end;

122 : //(#7a) ishr
begin
        s1 := format('%x',[code[i]] );
        s2 := 'ishr';
        inc(i);
end;

123 : //(#7b) lshr
begin
        s1 := format('%x',[code[i]] );
        s2 := 'lshr';
        inc(i);
end;

124 : //(#7c) iushr
begin
        s1 := format('%x',[code[i]] );
        s2 := 'iushr';
        inc(i);
end;

125 : //(#7d) lushr
begin
        s1 := format('%x',[code[i]] );
        s2 := 'lushr';
        inc(i);
end;

126 : //(#7e) iand
begin
        s1 := format('%x',[code[i]] );
        s2 := 'iand';
        inc(i);
end;

127 : //(#7f) land
begin
        s1 := format('%x',[code[i]] );
        s2 := 'land';
        inc(i);
end;

128 : //(#80) ior
begin
        s1 := format('%x',[code[i]] );
        s2 := 'ior';
        inc(i);
end;

129 : //(#81) lor
begin
        s1 := format('%x',[code[i]] );
        s2 := 'lor';
        inc(i);
end;

130 : //(#82) ixor
begin
        s1 := format('%x',[code[i]] );
        s2 := 'ixor';
        inc(i);
end;

131 : //(#83) lxor
begin
        s1 := format('%x',[code[i]] );
        s2 := 'lxor';
        inc(i);
end;

132 : //(#84) iinc
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d by %d', ['iinc', code[i+1], code[i+2] ] );
        inc(i);
        inc(i);
        inc(i);
end;

133 : //(#85) i2l
begin
        s1 := format('%x',[code[i]] );
        s2 := 'i2l';
        inc(i);
end;

134 : //(#86) i2f
begin
        s1 := format('%x',[code[i]] );
        s2 := 'i2f';
        inc(i);
end;

135 : //(#87) i2d
begin
        s1 := format('%x',[code[i]] );
        s2 := 'i2d';
        inc(i);
end;

136 : //(#88) l2i
begin
        s1 := format('%x',[code[i]] );
        s2 := 'l2i';
        inc(i);
end;

137 : //(#89) l2f
begin
        s1 := format('%x',[code[i]] );
        s2 := 'l2f';
        inc(i);
end;

138 : //(#8a) l2d
begin
        s1 := format('%x',[code[i]] );
        s2 := 'l2d';
        inc(i);
end;

139 : //(#8b) f2i
begin
        s1 := format('%x',[code[i]] );
        s2 := 'f2i';
        inc(i);
end;

140 : //(#8c) f2l
begin
        s1 := format('%x',[code[i]] );
        s2 := 'f2l';
        inc(i);
end;

141 : //(#8d) f2d
begin
        s1 := format('%x',[code[i]] );
        s2 := 'f2d';
        inc(i);
end;

142 : //(#8e) d2i
begin
        s1 := format('%x',[code[i]] );
        s2 := 'd2i';
        inc(i);
end;

143 : //(#8f) d2l
begin
        s1 := format('%x',[code[i]] );
        s2 := 'd2l';
        inc(i);
end;

144 : //(#90) d2f
begin
        s1 := format('%x',[code[i]] );
        s2 := 'd2f';
        inc(i);
end;

145 : //(#91) i2b
begin
        s1 := format('%x',[code[i]] );
        s2 := 'i2b';
        inc(i);
end;

146 : //(#92) i2c
begin
        s1 := format('%x',[code[i]] );
        s2 := 'i2c';
        inc(i);
end;

147 : //(#93) i2s
begin
        s1 := format('%x',[code[i]] );
        s2 := 'i2s';
        inc(i);
end;

148 : //(#94) lcmp
begin
        s1 := format('%x',[code[i]] );
        s2 := 'lcmp';
        inc(i);
end;

149 : //(#95) fcmpl
begin
        s1 := format('%x',[code[i]] );
        s2 := 'fcmpl';
        inc(i);
end;


150 : //(#96) fcmpg
begin
        s1 := format('%x',[code[i]] );
        s2 := 'fcmpg';
        inc(i);
end;


151 : //(#97) dcmpl
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dcmpl';
        inc(i);
end;


152 : //(#98) dcmpg
begin
        s1 := format('%x',[code[i]] );
        s2 := 'dcmpg';
        inc(i);
end;


153 : //(#99) ifeq
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['ifeq', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


154 : //(#9a) ifne
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['ifne', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


155 : //(#9b) iflt
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['iflt', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


156 : //(#9c) ifge
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['ifge', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


157 : //(#9d) ifgt
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['ifgt', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


158 : //(#9e) ifle
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['ifle', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


159 : //(#9f) if_icmpeq
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['if_icmpeq', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

160 : //(#a0) if_icmpne
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['if_icmpne', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

161 : //(#a1) if_icmplt
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['if_icmplt', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

162 : //(#a2) if_icmpge
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['if_icmpge', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

163 : //(#a3) if_icmpgt
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['if_icmpgt', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

164 : //(#a4) if_icmple
 begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['if_icmple', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


165 : //(#a5) if_acmpeq
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['if_acmpeq', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

166 : //(#a6) if_acmpne
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['if_acmpne', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

167 : //(#a7) goto
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['goto', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

168 : //(#a8) jsr
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['jsr', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

169 : //(#a9) ret
begin
        s1 := format('%x %x',[code[i],code[i+1] ] );
        s2 := format('%s %d', ['ret', code[i+1] ] );
        inc(i);
        inc(i);
end;

170 : ; //(#aa) tableswitch

171 : ; //(#ab) lookupswitch

172 : //(#ac) ireturn
begin
        s1 := format('%x',[code[i]]);
        s2 := 'ireturn';
        inc(i);
end;

173 : //(#ad) lreturn
begin
        s1 := format('%x',[code[i]]);
        s2 := 'lreturn';
        inc(i);
end;

174 : //(#ae) freturn
begin
        s1 := format('%x',[code[i]]);
        s2 := 'freturn';
        inc(i);
end;

175 : //(#af) dreturn
begin
        s1 := format('%x',[code[i]]);
        s2 := 'dreturn';
        inc(i);
end;

176 : //(#b0) areturn
begin
        s1 := format('%x',[code[i]] );
        s2 := 'areturn';
        inc(i);
end;

177 : //(#b1) return
begin
        s1 := format('%x',[code[i]]);
        s2 := 'return';
        inc(i);
end;


178 : //(#b2) getstatic
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['getstatic', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


179 : //(#b3) putstatic
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['putstatic', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

180 : //(#b4) getfield
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['getfield', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

181 : //(#b5) putfield
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['putfield', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

182 : //(#b6) invokevirtual
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['invokevirtual', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


183 : //(#b7) invokespecial
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['invokespecial', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

184 : //(#b8) invokestatic
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['invokestatic', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

185 : //(#b9) invokeinterface
begin
        s1 := format('%x %x %x %x %x',[code[i],code[i+1],code[i+2],code[i+3],code[i+4] ] );
        s2 := format('%s %d #####', ['invokeinterface',
        makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ),
        code[i+2] ] );
        inc(i);
        inc(i);
        inc(i);
        inc(i);
        inc(i);
end;

186 : ; //(#ba) xxxunusedxxx1

187 : //(#bb) new
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['new', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

188 : //(#bc) newarray
begin
        s1 := format('%x',[code[i]] );
        s2 := 'newarray';
        inc(i);
end;

189 : //(#bd) anewarray
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['anewarray', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

190 : //(#be) arraylength
begin
        s1 := format('%x',[code[i]] );
        s2 := 'arraylength';
        inc(i);
end;

191 : //(#bf) athrow
begin
        s1 := format('%x',[code[i]] );
        s2 := 'athrow';
        inc(i);
end;

192 : //(#c0) checkcast
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['checkcast', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

193 : //(#c1) instanceof
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['instanceof', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

194 : //(#c2) monitorenter
begin
        s1 := format('%x',[code[i]] );
        s2 := 'monitorenter';
        inc(i);
end;

195 : //(#c3) monitorexit
begin
        s1 := format('%x',[code[i]] );
        s2 := 'monitorexit';
        inc(i);
end;

196 : ; //(#c4) wide

197 : ; //(#c5) multianewarray

198 : //(#c6) ifnull
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['ifnull', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

199 : //(#c7) ifnonnull
begin
        s1 := format('%x %x %x',[code[i],code[i+1],code[i+2] ] );
        s2 := format('%s %d', ['ifnonnull', makeWordLittenEndanWidhTwoByte( code[i+1], code[i+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

200 : ; //(#c8) goto_w

201 : ; //(#c9) jsr_w

//Reserved opcodes:

202 : ; //(#ca) breakpoint

254 : ; //(#fe) impdep1

255 : ; //(#ff) impdep2

end; // case

s3 := getFixedStringleftOrder( format('%d',[ln]) , 5 , '0' );
s2 := getFixedStringRightOrder( s2 , 20 , ' ' );

write(d);
writeln( format('%s : %s  (%s)',[s3,s2,s1] ) );
inc(ln);


end; // for



end; // procedure

end.

