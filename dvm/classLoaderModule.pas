unit classLoaderModule;

interface


uses
        sysutils, componentModule;

        //
        // data type define
        //
const
        //
        // Constant Type
        //
        CONSTANT_Class = 7;
        CONSTANT_Fieldref = 9;
        CONSTANT_Methodref = 10;
        CONSTANT_InterfaceMethodref = 11;
        CONSTANT_String = 8;
        CONSTANT_Integer = 3;
        CONSTANT_Float = 4;
        CONSTANT_Long = 5;
        CONSTANT_Double = 6;
        CONSTANT_NameAndType = 12;
        CONSTANT_Utf8 = 1;


        //
        // ACCESS FLAG
        //
        // F : field  M : method  C : class
        ACC_PUBLIC = $0001;             // F M C
        ACC_PRIVATE = $0002;            // F M
        ACC_PROTECTED = $0004;          // F M
        ACC_STATIC = $0008;             // F M
        ACC_FINAL = $0010;              // F M C
        ACC_SUPER = $0020;              //     C
        ACC_SYNCHRONIZED = $0020;       //   M
        ACC_VOLATILE = $0040;           // F
        ACC_TRANSIENT = $0080;          // F
        ACC_NATIVE = $0100;             //   M
        ACC_INTERFACE = $0200;          //     C
        ACC_ABSTRACT = $0400;           //   M C
        ACC_STRICT = $0800;             //   M

        //
        // ACCESS FLAG STRING
        //
        ACC_PUBLIC_STR = 'public';
        ACC_PRIVATE_STR = 'private';
        ACC_PROTECTED_STR = 'protected';
        ACC_STATIC_STR = 'static';
        ACC_FINAL_STR = 'final';
        ACC_SUPER_STR = 'super';
        ACC_SYNCHRONIZED_STR = 'synchronized';
        ACC_VOLATILE_STR = 'volatile';
        ACC_TRANSIENT_STR = 'transient';
        ACC_NATIVE_STR = 'native';
        ACC_INTERFACE_STR = 'interface';
        ACC_ABSTRACT_STR = 'abstract';
        ACC_STRICT_STR = 'strict';


        //
        // PREDEFINED ATTRIBUTE TYPE
        //
        PREDEF_Code = 1;
        PREDEF_SourceFile = 2;
        PREDEF_LineNumberTable = 3;
        PREDEF_LocalVariableTable = 4;
        PREDEF_ConstantValue = 5;
        PREDEF_Exceptions = 6;
        PREDEF_InnerClasses = 7;
        PREDEF_Synthetic = 8;
        PREDEF_Deprecated = 9;


type
        //
        // constant pool
        //
        constantClassInfo = class
        public
                nameIndex : word;
        end;

        constantFieldref = class
        public
                classIndex : word;
                nameAndTypeIndex : word;
        end;

        constantMethodref = class
        public
                classIndex : word;
                nameAndTypeIndex : word;
        end;

        constantInterfaceMethodref = class
        public
                classIndex : word;
                nameAndTypeIndex : word;
        end;

        constantString = class
        public
                stringIndex : word;
        end;

        constantInteger = class
        public
                bytes : integer;
        end;

        constantFloat = class
        public
                bytes : integer;
        end;

        constantLong = class
        public
                bytes : int64;
                {
                highBytes : integer;
                lowBytes : integer;
                } // 작업의 편의를 위해서 int64로 정의해서 작업을 완료한다.
        end;

        constantDouble = class
        public
                highBytes : integer;
                lowBytes : integer;
        end;

        constantNameAndType = class
        public
                nameIndex : word;
                descriptorIndex : word;
        end;

        constantUtf8Info = class
        public
                length : word;
                bytes : array[0..999] of char;
                //bytes : array of char;
                bytesName : string; // append
        end;

        CPInfo = class
        public
                tag : byte;
                info : TObject;
        end;


        //
        // predefined attribute
        //
        attributeInfo = class
        public
                attributeType : word;
                attribute : TObject;
        end;


        sourceFileAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : integer;
                sourceFileIndex : word;
        end;

        codeAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : integer;
                maxStack : word;
                maxLocals : word;
                codeLength : integer;

                code : array[0..10000] of byte;
                //code : array of byte;


                exceptionTableLength : word;

                startPc : array[0..1000] of word;
                endPc : array[0..1000] of word;
                handlerPc : array[0..1000] of word;
                catchType : array[0..1000] of word;

                attributesCount : word;
                attributes : array of attributeInfo;
        class function getClassData( codeAttr : codeAttribute ) : string;
        class function setClassData( data : string ) : codeAttribute;
        end;

        lineNumberTableAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : integer;
                lineNumberTableLength : word;

                startPc : array[0..1000] of word;
                lineNumber : array[0..1000] of word;
        end;

        localVariableTableAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : integer;
                localVariableTableLength : word;

                startPc : array[0..1000] of word;
                length : array[0..1000] of word;
                nameIndex : array[0..1000] of word;
                descriptorIndex : array[0..1000] of word;
                index : array[0..1000] of word;
        end;

        constantValueAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : integer;
                constantValueIndex : word;
        end;

        exceptionAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : integer;
                numberOfExceptions : word;
                exceptionIndexTable : array[0..1000] of word;
        end;

        innerClassesAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : integer;
                numberOfClasses : word;
                innerClassInfoIndex : array[0..1000] of word;
                outerClassInfoIndex : array[0..1000] of word;
                innerNameIndex : array[0..1000] of word;
                innerClassAccessFlags : array[0..1000] of word;
        end;

        syntheticAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : integer;
        end;

        deprecatedAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : integer;
        end;

        //
        // others
        //
        fieldInfo = class
        public
                accessFlags : word;
                nameIndex : word;
                descriptorIndex : word;
                attributesCount : word;
                attributes : array of attributeInfo;
        end;

        methodInfo = class
        public
                accessFlags : word;
                nameIndex : word;
                descriptorIndex : word;
                attributesCount : word;
                attributes : array of attributeInfo;
        end;

        //
        // Exception
        //
        LoadFaileException = class( Exception );
        ClassNotFoundException = class( Exception );

        //
        // main loader
        //
        classLoaderClass = class
        private
                classfile : string;
                fileHandler : integer;

        public
        //private
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
                procedure load( classPath : string ; className : string ) ; overload;
                procedure load( classFullName : string ); overload;
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

        function getCodeString ( var code : array of byte ; codeOffset : integer ; var hexaCodeString : string ; var commandString : string ) : integer;

implementation


procedure classLoaderClass.loadMethodsCount();
begin
        methodsCount := utilClass.fileReadU2LittenEndan( fileHandler );
end;

procedure classLoaderClass.loadMethods();
var
        i : integer;
begin
        setLength( self.methods, self.methodsCount );

        for i:=0 to self.methodsCount - 1 do
        begin
                self.methods[i] := methodInfo.Create ;

                with self.methods[i] do
                begin
                        accessFlags := utilClass.fileReadU2LittenEndan( fileHandler );
                        nameIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                        descriptorIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                        attributesCount := utilClass.fileReadU2LittenEndan( fileHandler );

                        if attributesCount <> 0 then
                        begin
                                setlength( attributes , attributesCount );
                                self.loadAttributes( attributesCount, attributes );
                        end;
                end;
        end;

end;

procedure classLoaderClass.loadAttributesCount();
begin
        attributesCount := utilClass.fileReadU2LittenEndan( fileHandler );
end;


procedure classLoaderClass.loadAttributes( ac : word ; var aoa : array of attributeInfo );
var
        i : integer;
        j : integer;
        u2 : word;
        u4 : integer;
begin
//
// setLength( aoa  , ac );
// 코드가 에러가 난다. 이유를 몰라 호출측에서 배열을 초기화 해주고 호출하기로
// 했다
//

        for i:=0 to ac - 1 do
        begin
                aoa[i] := attributeInfo.Create ;

                u2 := utilClass.fileReadU2LittenEndan( fileHandler );
                u4 := utilClass.fileReadU4LittenEndan( fileHandler );

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
                                        constantValueIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                                end;
                        end;

                        PREDEF_Code :
                        begin
                                aoa[i].attribute := codeAttribute.Create ;

                                with (aoa[i].attribute as codeAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                        maxStack := utilClass.fileReadU2LittenEndan( fileHandler );
                                        maxLocals := utilClass.fileReadU2LittenEndan( fileHandler );
                                        codeLength := utilClass.fileReadU4LittenEndan( fileHandler );
                                        FileRead(fileHandler, code , codeLength );
                                        exceptionTableLength := utilClass.fileReadU2LittenEndan( fileHandler );

                                        for j:=0 to exceptionTableLength - 1 do
                                        begin
                                                startPc[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                endPc[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                handlerPc[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                catchType[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                        end;

                                        attributesCount := utilClass.fileReadU2LittenEndan( fileHandler );

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
                                        numberOfExceptions := utilClass.fileReadU2LittenEndan( fileHandler );

                                        for j:=0 to numberOfExceptions - 1 do
                                        begin
                                                exceptionIndexTable[j] := utilClass.fileReadU2LittenEndan( fileHandler );
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
                                        numberOfClasses := utilClass.fileReadU2LittenEndan( fileHandler );

                                        for j:=0 to numberOfClasses - 1 do
                                        begin
                                                innerClassInfoIndex[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                outerClassInfoIndex[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                innerNameIndex[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                innerClassAccessFlags[j] := utilClass.fileReadU2LittenEndan( fileHandler );
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
                                        sourceFileIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                                end;
                        end;

                        PREDEF_LineNumberTable :
                        begin
                                aoa[i].attribute := lineNumberTableAttribute.Create ;

                                with (aoa[i].attribute as lineNumberTableAttribute) do
                                begin
                                        attributeNameIndex := u2;
                                        attributeLength := u4;
                                        lineNumberTableLength := utilClass.fileReadU2LittenEndan( fileHandler );

                                        for j:=0 to lineNumberTableLength - 1 do
                                        begin
                                                startPc[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                lineNumber[j] := utilClass.fileReadU2LittenEndan( fileHandler );
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
                                        localVariableTableLength := utilClass.fileReadU2LittenEndan( fileHandler );

                                        for j:=0 to localVariableTableLength - 1 do
                                        begin
                                                startPc[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                length[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                nameIndex[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                descriptorIndex[j] := utilClass.fileReadU2LittenEndan( fileHandler );
                                                index[j] := utilClass.fileReadU2LittenEndan( fileHandler );
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

function classLoaderClass.getConstantUTF8InfoByIndex( index : integer ) : string;
begin
        result := (self.constantPool[index].info as constantUtf8Info).bytesName;
end;

procedure classLoaderClass.loadFields();
var
        i : integer;
begin
        setLength( self.fields, self.fieldsCount );

        for i:=0 to self.fieldsCount - 1 do
        begin
                self.fields[i] := fieldInfo.Create ;

                with self.fields[i] do
                begin
                        accessFlags := utilClass.fileReadU2LittenEndan( fileHandler );
                        nameIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                        descriptorIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                        attributesCount := utilClass.fileReadU2LittenEndan( fileHandler );

                        if attributesCount <> 0 then
                        begin
                                setlength( attributes , attributesCount );
                                self.loadAttributes( attributesCount, attributes );
                        end;
                end;
        end;

end;

procedure classLoaderClass.loadFieldsCount();
begin
        fieldsCount := utilClass.fileReadU2LittenEndan( fileHandler );
        //writeln( fieldsCount );
end;

procedure classLoaderClass.loadInterfaces();
var
        i : integer;
begin
        setLength ( self.interfaces , interfacesCount );

        for i := 0 to self.interfacesCount - 1 do
        begin
                self.interfaces[i] := utilClass.fileReadU2LittenEndan( fileHandler );
        end;
end;

procedure classLoaderClass.loadMagicNumber();
begin
        FileRead(fileHandler, magicNumber, 4 );
end;

procedure classLoaderClass.loadMinorVersion();
begin
        minorVersion := utilClass.fileReadU2LittenEndan( fileHandler );
end;

procedure classLoaderClass.loadMajorVersion();
begin
        majorVersion := utilClass.fileReadU2LittenEndan( fileHandler );
end;

procedure classLoaderClass.loadConstantPool();
var
        i : integer;
begin
        setLength( self.constantPool , self.constantPoolCount );

        // constantPool[0] is not used because system is reserved
        self.constantPool[0] := CPInfo.Create ;
        self.constantPool[0].tag := 0;

        //
        // poolCount에서 long 같은 경우는 2개를 차지한다 그래서
        // i하나를 더 증가시켜야 한다. 
        //
        i := 1;

        while i <= (self.constantPoolCount - 1 ) do // for ( i = 1 ; i <= cpc - 1 ; i++ )
        begin
                self.constantPool[i] := CPInfo.Create ;

                FileRead( self.fileHandler , self.constantPool[i].tag , 1 );

                case self.constantPool[i].tag of
                        CONSTANT_Class :
                        begin
                                self.constantPool[i].info := constantClassInfo.Create();
                                (self.constantPool[i].info as constantClassInfo).nameIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                        end;

                        CONSTANT_Fieldref :
                        begin
                                self.constantPool[i].info := constantFieldref.Create();
                                (self.constantPool[i].info as constantFieldref).classIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                                (self.constantPool[i].info as constantFieldref).nameAndTypeIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                        end;

                        CONSTANT_Methodref :
                        begin
                                self.constantPool[i].info := constantMethodref.Create();
                                (self.constantPool[i].info as constantMethodref).classIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                                (self.constantPool[i].info as constantMethodref).nameAndTypeIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                        end;

                        CONSTANT_InterfaceMethodref :
                        begin
                                self.constantPool[i].info := constantInterfaceMethodref.Create();
                                (self.constantPool[i].info as constantInterfaceMethodref).classIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                                (self.constantPool[i].info as constantInterfaceMethodref).nameAndTypeIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                        end;

                        CONSTANT_String :
                        begin
                                self.constantPool[i].info := constantString.Create();
                                (self.constantPool[i].info as constantString).stringIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                        end;

                        CONSTANT_Integer :
                        begin
                                self.constantPool[i].info := constantInteger.Create();
                                (self.constantPool[i].info as constantInteger).bytes := utilClass.fileReadU4LittenEndan( fileHandler );
                        end;

                        CONSTANT_Float :
                        begin
                                self.constantPool[i].info := constantFloat.Create();
                                (self.constantPool[i].info as constantFloat).bytes := utilClass.fileReadU4LittenEndan( fileHandler );
                        end;

                        CONSTANT_Long :
                        begin
                                self.constantPool[i].info := constantLong.Create();
                                (self.constantPool[i].info as constantLong).bytes := utilClass.fileReadU8LittenEndan( fileHandler );
                                inc(i);
                        end;

                        CONSTANT_Double :
                        begin
                                self.constantPool[i].info := constantDouble.Create();
                                (self.constantPool[i].info as constantDouble).highBytes := utilClass.fileReadU4LittenEndan( fileHandler );
                                (self.constantPool[i].info as constantDouble).lowBytes := utilClass.fileReadU4LittenEndan( fileHandler );
                                inc(i);
                        end;

                        CONSTANT_NameAndType :
                        begin
                                self.constantPool[i].info := constantNameAndType.Create();
                                (self.constantPool[i].info as constantNameAndType).nameIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                                (self.constantPool[i].info as constantNameAndType).descriptorIndex := utilClass.fileReadU2LittenEndan( fileHandler );
                        end;
                        CONSTANT_Utf8 :
                        begin
                                self.constantPool[i].info := constantUtf8Info.Create();
                                (self.constantPool[i].info as constantUtf8Info).length := utilClass.fileReadU2LittenEndan( fileHandler );

                                // setLength가 않되고 있다.  모르겠다.
                                // 그래서 bytes를 정적 배열로 선언했다.
                                //setLength( (self.constantPool[i].info as constantUtf8Info).bytes , u2 );

                                FileRead( self.fileHandler , (self.constantPool[i].info as constantUtf8Info).bytes , (self.constantPool[i].info as constantUtf8Info).length );
                                // 유니코드 처리 .... 않된다.....
                                //(self.constantPool[i].infoClass as constantUtf8Info).name := widecharlentostring( (self.constantPool[i].infoClass as constantUtf8Info).bytes , u2 );
                                SetString( (self.constantPool[i].info as constantUtf8Info).bytesName , (self.constantPool[i].info as constantUtf8Info).bytes , (self.constantPool[i].info as constantUtf8Info).length );
                                //writeln( (self.constantPool[i].infoClass as constantUtf8Info).name );
                        end;
                end; // case of

                inc(i);
        end; // while

end;

procedure classLoaderClass.loadConstantPoolCount();
begin
        constantPoolCount := utilClass.fileReadU2LittenEndan( fileHandler );
end;

procedure classLoaderClass.loadAccessFlags();
begin
        accessFlags := utilClass.fileReadU2LittenEndan( fileHandler );
end;

procedure classLoaderClass.loadThisClass();
begin
        thisClass := utilClass.fileReadU2LittenEndan( fileHandler );
end;

procedure classLoaderClass.loadSuperClass();
begin
        superClass := utilClass.fileReadU2LittenEndan( fileHandler );
end;

procedure classLoaderClass.loadInterfacesCount();
begin
        interfacesCount := utilClass.fileReadU2LittenEndan( fileHandler );
end;

procedure classLoaderClass.load( classPath : string ; className : string );
begin

try
        //self.classfile := 'C:/Documents and Settings/fbiskr/jbproject/testvmlib/classes/' + className + '.class';
//        self.classfile := 'C:/testvmlib/classes/' + className + '.class';
        self.classfile := classPath + className + '.class';
//          self.classfile := './classes/' + className + '.class';

        self.fileHandler := fileOpen( self.classfile,  fmOpenRead );
        if self.fileHandler = -1 then
        begin
                className := utilClass.changeCharbyChar( className , '/' , '.' );
                raise ClassNotFoundException.CreateFmt('class not found : %s',[className]);
        end;

        try
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
        except
                raise LoadFaileException.CreateFmt( 'Class format Bad : %s',[className] );
        end;



finally
        if self.fileHandler <> -1 then
                FileClose( fileHandler );
end;


end;

procedure classLoaderClass.load( classFullName : string );
begin

try
        self.classfile := classFullName;

        self.fileHandler := fileOpen( self.classfile,  fmOpenRead );
        if self.fileHandler = -1 then
        begin
                raise ClassNotFoundException.CreateFmt('class not found : %s',[className]);
        end;

        try
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
        except
                raise LoadFaileException.CreateFmt( 'Class format Bad : %s',[className] );
        end;

finally
        if self.fileHandler <> -1 then
                FileClose( fileHandler );
end;


end;

procedure classLoaderClass.coreDumpMagicNumber();
begin
        writeln( format('magicNumber : 0x%x%x%x%x' ,
                [magicNumber[0], magicNumber[1] ,
                magicNumber[2] , magicNumber[3]] ) );
end;

procedure classLoaderClass.coreDumpMinorVersion();
begin
        writeln( format('minorVersion : %d', [minorVersion] ) );
end;

procedure classLoaderClass.coreDumpMajorVersion();
begin
        writeln( format('majorVersion : %d' , [majorVersion]) );
end;

procedure classLoaderClass.coreDumpConstantPoolCount();
begin
        writeln( format('constantPoolCount : %d' , [constantPoolCount]) );
end;

procedure classLoaderClass.coreDumpConstantPool();
var
        i : integer;
begin
        i := 0;
        while i <= ( self.constantPoolCount - 1 ) do
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
                                write( format( 'CONSTANT_Long(%d)  bytes : %d' ,
                                [ self.constantPool[i].tag , (self.constantPool[i].info as constantLong).bytes ]) );
                                writeln( '' );                                
                                inc(i);
                                write( format( 'tag[%d] : large numeric continue' , [i] ) );
                        end;

                        CONSTANT_Double :
                        begin
                                write( format( 'CONSTANT_Double(%d) ' , [ self.constantPool[i].tag ]) );
                                writeln( '' );
                                inc(i);
                                write( format( 'tag[%d] : large numeric continue' , [i] ) );
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

                inc(i);
                writeln( '' );
        end; // for i := 1 to self.constantPoolCount do
end;

procedure classLoaderClass.coreDumpAccessFlags();
begin
        writeln( format('accessFlags : 0x%x  ' , [accessFlags]) );
end;

procedure classLoaderClass.coreDumpThisClass();
begin
        writeln( format('thisClass : %d' , [thisClass]) );
end;

procedure classLoaderClass.coreDumpSuperClass();
begin
        writeln( format('superClass : %d' , [superClass]) );
end;

procedure classLoaderClass.coreDumpInterfacesCount();
begin
        writeln( format('interfacesCount : %d' , [interfacesCount]) );
end;

procedure classLoaderClass.coreDumpInterfaces();
var
        i : integer;
begin
        for i:=0 to self.interfacesCount - 1 do
        begin
                writeln( format( 'interface : %d' , [ self.interfaces[i] ] ) );
        end;
end;

procedure classLoaderClass.coreDumpFieldsCount();
begin
        writeln( format('fieldsCount : %d' , [fieldsCount]) );
end;

procedure classLoaderClass.coreDumpFields();
var
        i : integer;
begin
        for i:=0 to self.fieldsCount - 1 do
        begin
                write( format('field[%d] : ' , [i] ) );
                writeln( format('accessFlags : 0x%x  nameIndex : %d  descriptorIndex : %d  attributesCount : %d',
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

procedure classLoaderClass.coreDumpMethodsCount();
begin
        writeln( format('methodsCount : %d' , [methodsCount]) );
end;

procedure classLoaderClass.coreDumpMethods();
var
        i : integer;
begin
        for i:=0 to self.methodsCount - 1 do
        begin
                write( format('method[%d] : ' , [i] ) );
                writeln( format('accessFlags : 0x%x  nameIndex : %d  descriptorIndex : %d  attributesCount : %d',
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

procedure classLoaderClass.coreDumpAttributesCount();
begin
        writeln( format('attributesCount : %d' , [attributesCount]) );
end;

procedure classLoaderClass.coreDumpAttributes( ac : word ; var aoa : array of attributeInfo ; depth : integer );
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

procedure classLoaderClass.coreDump();
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


procedure classLoaderClass.coreDumpCode ( cc : integer ; var code : array of byte ; depth : integer );
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

i := i + getCodeString( code , i , s1 , s2 );

s3 := utilClass.getFixedStringleftOrder( format('%d',[ln]) , 5 , '0' );
s2 := utilClass.getFixedStringRightOrder( s2 , 20 , ' ' );

write(d);
writeln( format('%s : %s  (%s)',[s3,s2,s1] ) );
inc(ln);


end; // while


end; // procedure







function getCodeString ( var code : array of byte ; codeOffset : integer ; var hexaCodeString : string ; var commandString : string ) : integer;
var
        i : integer;
begin

i := 0;

case code[codeOffset] of

00 : //(0x00) nop
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'nop';
        inc(i);
end;

01 : //(0x01) aconst_null
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'aconst_null';
        inc(i);
end;

02 : //(0x02) iconst_m1
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'iconst_m1';
        inc(i);
end;


03 : //(0x03) iconst_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iconst_0';
        inc(i);
end;


04 : //(0x04) iconst_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iconst_1';
        inc(i);
end;

05 : //(0x05) iconst_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iconst_2';
        inc(i);
end;

06 : //(0x06) iconst_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iconst_3';
        inc(i);
end;

07 : //(0x07) iconst_4
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iconst_4';
        inc(i);
end;

08 : //(0x08) iconst_5
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iconst_5';
        inc(i);
end;

09 : //(0x09) lconst_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lconst_0';
        inc(i);
end;

10 : //(0x0a) lconst_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lconst_1';
        inc(i);
end;

11 : //(0x0b) fconst_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fconst_0';
        inc(i);
end;

12 : //(0x0c) fconst_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fconst_1';
        inc(i);
end;

13 : //(0x0d) fconst_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fconst_2';
        inc(i);
end;

14 : //(0x0e) dconst_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dconst_0';
        inc(i);
end;

15 : //(0x0f) dconst_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dconst_1';
        inc(i);
end;

16 : //(0x10) bipush
begin
        hexaCodeString := format('$%x $%x ',[code[codeOffset],code[codeOffset+1] ] );
        commandString := format('%s %d', ['bipush', code[codeOffset+1] ] );
        inc(i);
        inc(i);
end;


17 : //(0x11) sipush
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['sipush', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
         inc(i);
end;

18 : //(0x12) ldc
begin
        hexaCodeString := format('$%x $%x',[code[codeOffset],code[codeOffset+1] ] );
        commandString := format('%s %d', ['ldc', code[codeOffset+1] ] );
        inc(i);
        inc(i);
end;

19 : //(0x13) ldc_w
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['ldc_w', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

20 : //(0x14) ldc2_w
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['ldc2_w', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

21 : //(0x15) iload
begin
        hexaCodeString := format('$%x $%x',[code[codeOffset],code[codeOffset+1] ] );
        commandString := format('%s %d', ['iload', code[codeOffset+1] ] );
        inc(i);
        inc(i);
end;

22 : //(0x16) lload
begin
        hexaCodeString := format('$%x $%x',[code[codeOffset],code[codeOffset+1] ] );
        commandString := format('%s %d', ['lload', code[codeOffset+1] ] );
        inc(i);
        inc(i);
end;

23 : //(0x17) fload
begin
        hexaCodeString := format('$%x $%x',[code[codeOffset],code[codeOffset+1] ] );
        commandString := format('%s %d', ['fload', code[codeOffset+1] ] );
        inc(i);
        inc(i);
end;

24 : //(0x18) dload
begin
        hexaCodeString := format('$%x $%x',[code[codeOffset],code[codeOffset+1] ] );
        commandString := format('%s %d', ['dload', code[codeOffset+1] ] );
        inc(i);
        inc(i);
end;

25 : //(0x19) aload
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'aload';
        inc(i);
end;

26 : //(0x1a) iload_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iload_0';
        inc(i);
end;

27 : //(0x1b) iload_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iload_1';
        inc(i);
end;

28 : //(0x1c) iload_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iload_2';
        inc(i);
end;

29 : //(0x1d) iload_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iload_3';
        inc(i);
end;


30 : //(0x1e) lload_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lload_0';
        inc(i);
end;


31 : //(0x1f) lload_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lload_1';
        inc(i);
end;


32 : //(0x20) lload_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lload_2';
        inc(i);
end;


33 : //(0x21) lload_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lload_3';
        inc(i);
end;


34 : //(0x22) fload_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fload_0';
        inc(i);
end;


35 : //(0x23) fload_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fload_1';
        inc(i);
end;


36 : //(0x24) fload_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fload_2';
        inc(i);
end;


37 : //(0x25) fload_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fload_3';
        inc(i);
end;


38 : //(0x26) dload_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dload_0';
        inc(i);
end;


39 : //(0x27) dload_1
 begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dload_1';
        inc(i);
end;


40 : //(0x28) dload_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dload_2';
        inc(i);
end;


41 : //(0x29) dload_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dload_3';
        inc(i);
end;


42 : //(0x2a) aload_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'aload_0';
        inc(i);
end;

43 : //(0x2b) aload_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'aload_1';
        inc(i);
end;

44 : //(0x2c) aload_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'aload_2';
        inc(i);
end;

45 : //(0x2d) aload_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'aload_3';
        inc(i);
end;

46 : //(0x2e) iaload
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'iaload';
        inc(i);
end;

47 : //(0x2f) laload
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'laload';
        inc(i);
end;

48 : //(0x30) faload
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'faload';
        inc(i);
end;

49 : //(0x31) daload
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'daload';
        inc(i);
end;

50 : //(0x32) aaload
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'aaload';
        inc(i);
end;

51 : //(0x33) baload
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'baload';
        inc(i);
end;

52 : //(0x34) caload
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'caload';
        inc(i);
end;


53 : //(0x35) saload
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'saload';
        inc(i);
end;

54 : //(0x36) istore
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'istore';
        inc(i);
end;

55 : //(0x37) lstore
begin
        hexaCodeString := format('$%x $%x',[code[codeOffset],code[codeOffset+1] ] );
        commandString := format('%s %d', ['lstore', code[codeOffset+1] ] );
        inc(i);
        inc(i);
end;

56 : //(0x38) fstore
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fstore';
        inc(i);
end;

57 : //(0x39) dstore
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dstore';
        inc(i);
end;

58 : //(0x3a) astore
begin
        hexaCodeString := format('$%x $%x',[code[codeOffset],code[codeOffset+1] ] );
        commandString := format('%s %d', ['astore', code[codeOffset+1] ] );
        inc(i);
        inc(i);
end;

59 : //(0x3b) istore_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'istore_0';
        inc(i);
end;

60 : //(0x3c) istore_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'istore_1';
        inc(i);
end;


61 : //(0x3d) istore_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'istore_2';
        inc(i);
end;

62 : //(0x3e) istore_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'istore_3';
        inc(i);
end;



63 : //(0x3f) lstore_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lstore_0';
        inc(i);
end;


64 : //(0x40) lstore_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lstore_1';
        inc(i);
end;


65 : //(0x41) lstore_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lstore_2';
        inc(i);
end;


66 : //(0x42) lstore_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lstore_3';
        inc(i);
end;


67 : //(0x43) fstore_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fstore_0';
        inc(i);
end;


68 : //(0x44) fstore_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fstore_1';
        inc(i);
end;


69 : //(0x45) fstore_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fstore_2';
        inc(i);
end;


70 : //(0x46) fstore_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fstore_3';
        inc(i);
end;


71 : //(0x47) dstore_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dstore_0';
        inc(i);
end;


72 : //(0x48) dstore_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dstore_1';
        inc(i);
end;


73 : //(0x49) dstore_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dstore_2';
        inc(i);
end;


74 : //(0x4a) dstore_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dstore_3';
        inc(i);
end;


75 : //(0x4b) astore_0
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'astore_0';
        inc(i);
end;

76 : //(0x4c) astore_1
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'astore_1';
        inc(i);
end;

77 : //(0x4d) astore_2
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'astore_2';
        inc(i);
end;

78 : //(0x4e) astore_3
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'astore_3';
        inc(i);
end;


79 : //(0x4f) iastore
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iastore';
        inc(i);
end;

80 : //(0x50) lastore
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lastore';
        inc(i);
end;

81 : //(0x51) fastore
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'fastore';
        inc(i);
end;

82 : //(0x52) dastore
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dastore';
        inc(i);
end;

83 : //(0x53) aastore
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'aastore';
        inc(i);
end;

84 : //(0x54) bastore
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'bastore';
        inc(i);
end;

85 : //(0x55) castore
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'castore';
        inc(i);
end;

86 : //(0x56) sastore
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'sastore';
        inc(i);
end;

87 : //(0x57) pop
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'pop';
        inc(i);
end;

88 : //(0x58) pop2
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'pop2';
        inc(i);
end;

089 : //(0x59) dup
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dup';
        inc(i);
end;


090 : //(0x5a) dup_x1
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dup_x1';
        inc(i);
end;

091 : //(0x5b) dup_x2
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dup_x2';
        inc(i);
end;

092 : //(0x5c) dup2
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dup2';
        inc(i);
end;

093 : //(0x5d) dup2_x1
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dup2_x1';
        inc(i);
end;

094 : //(0x5e) dup2_x2
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dup2_x2';
        inc(i);
end;

095 : //(0x5f) swap
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'swap';
        inc(i);
end;

096 : //(0x60) iadd
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'iadd';
        inc(i);
end;

097 : //(0x61) ladd
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'ladd';
        inc(i);
end;

098 : //(0x62) fadd
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'fadd';
        inc(i);
end;

099 : //(0x63) dadd
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dadd';
        inc(i);
end;

100 : //(0x64) isub
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'isub';
        inc(i);
end;

101 : //(0x65) lsub
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'lsub';
        inc(i);
end;

102 : //(0x66) fsub
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'fsub';
        inc(i);
end;

103 : //(0x67) dsub
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dsub';
        inc(i);
end;

104 : //(0x68) imul
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'imul';
        inc(i);
end;

105 : //(0x69) lmul
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'lmul';
        inc(i);
end;

106 : //(0x6a) fmul
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'fmul';
        inc(i);
end;

107 : //(0x6b) dmul
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dmul';
        inc(i);
end;

108 : //(0x6c) idiv
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'idiv';
        inc(i);
end;

109 : //(0x6d) ldiv
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'ldiv';
        inc(i);
end;

110 : //(0x6e) fdiv
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'fdiv';
        inc(i);
end;

111 : //(0x6f) ddiv
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'ddiv';
        inc(i);
end;

112 : //(0x70) irem
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'irem';
        inc(i);
end;

113 : //(0x71) lrem
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'lrem';
        inc(i);
end;

114 : //(0x72) frem
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'frem';
        inc(i);
end;

115 : //(0x73) drem
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'drem';
        inc(i);
end;

116 : //(0x74) ineg
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'ineg';
        inc(i);
end;

117 : //(0x75) lneg
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'lneg';
        inc(i);
end;

118 : //(0x76) fneg
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'fneg';
        inc(i);
end;

119 : //(0x77) dneg
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dneg';
        inc(i);
end;

120 : //(0x78) ishl
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'ishl';
        inc(i);
end;

121 : //(0x79) lshl
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'lshl';
        inc(i);
end;

122 : //(0x7a) ishr
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'ishr';
        inc(i);
end;

123 : //(0x7b) lshr
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'lshr';
        inc(i);
end;

124 : //(0x7c) iushr
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'iushr';
        inc(i);
end;

125 : //(0x7d) lushr
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'lushr';
        inc(i);
end;

126 : //(0x7e) iand
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'iand';
        inc(i);
end;

127 : //(0x7f) land
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'land';
        inc(i);
end;

128 : //(0x80) ior
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'ior';
        inc(i);
end;

129 : //(0x81) lor
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'lor';
        inc(i);
end;

130 : //(0x82) ixor
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'ixor';
        inc(i);
end;

131 : //(0x83) lxor
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'lxor';
        inc(i);
end;

132 : //(0x84) iinc
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d by %d', ['iinc', code[codeOffset+1], code[codeOffset+2] ] );
        inc(i);
        inc(i);
        inc(i);
end;

133 : //(0x85) i2l
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'i2l';
        inc(i);
end;

134 : //(0x86) i2f
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'i2f';
        inc(i);
end;

135 : //(0x87) i2d
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'i2d';
        inc(i);
end;

136 : //(0x88) l2i
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'l2i';
        inc(i);
end;

137 : //(0x89) l2f
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'l2f';
        inc(i);
end;

138 : //(0x8a) l2d
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'l2d';
        inc(i);
end;

139 : //(0x8b) f2i
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'f2i';
        inc(i);
end;

140 : //(0x8c) f2l
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'f2l';
        inc(i);
end;

141 : //(0x8d) f2d
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'f2d';
        inc(i);
end;

142 : //(0x8e) d2i
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'd2i';
        inc(i);
end;

143 : //(0x8f) d2l
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'd2l';
        inc(i);
end;

144 : //(0x90) d2f
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'd2f';
        inc(i);
end;

145 : //(0x91) i2b
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'i2b';
        inc(i);
end;

146 : //(0x92) i2c
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'i2c';
        inc(i);
end;

147 : //(0x93) i2s
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'i2s';
        inc(i);
end;

148 : //(0x94) lcmp
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'lcmp';
        inc(i);
end;

149 : //(0x95) fcmpl
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'fcmpl';
        inc(i);
end;


150 : //(0x96) fcmpg
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'fcmpg';
        inc(i);
end;


151 : //(0x97) dcmpl
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dcmpl';
        inc(i);
end;


152 : //(0x98) dcmpg
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'dcmpg';
        inc(i);
end;


153 : //(0x99) ifeq
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['ifeq', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


154 : //(0x9a) ifne
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['ifne', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


155 : //(0x9b) iflt
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['iflt', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


156 : //(0x9c) ifge
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['ifge', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


157 : //(0x9d) ifgt
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['ifgt', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


158 : //(0x9e) ifle
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['ifle', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


159 : //(0x9f) if_icmpeq
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['if_icmpeq', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

160 : //(0xa0) if_icmpne
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['if_icmpne', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

161 : //(0xa1) if_icmplt
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['if_icmplt', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

162 : //(0xa2) if_icmpge
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['if_icmpge', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

163 : //(0xa3) if_icmpgt
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['if_icmpgt', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

164 : //(0xa4) if_icmple
 begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['if_icmple', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


165 : //(0xa5) if_acmpeq
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['if_acmpeq', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

166 : //(0xa6) if_acmpne
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['if_acmpne', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

167 : //(0xa7) goto
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['goto', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

168 : //(0xa8) jsr
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['jsr', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

169 : //(0xa9) ret
begin
        hexaCodeString := format('$%x $%x',[code[codeOffset],code[codeOffset+1] ] );
        commandString := format('%s %d', ['ret', code[codeOffset+1] ] );
        inc(i);
        inc(i);
end;

170 : //(0xaa) tableswitch
begin
        raise Exception.Create( 'tableswitch' );
end;

171 : //(0xab) lookupswitch
begin
        raise Exception.Create( 'lookupswitch' );
end;

172 : //(0xac) ireturn
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'ireturn';
        inc(i);
end;

173 : //(0xad) lreturn
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'lreturn';
        inc(i);
end;

174 : //(0xae) freturn
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'freturn';
        inc(i);
end;

175 : //(0xaf) dreturn
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'dreturn';
        inc(i);
end;

176 : //(0xb0) areturn
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'areturn';
        inc(i);
end;

177 : //(0xb1) return
begin
        hexaCodeString := format('$%x',[code[codeOffset]]);
        commandString := 'return';
        inc(i);
end;


178 : //(0xb2) getstatic
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['getstatic', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


179 : //(0xb3) putstatic
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['putstatic', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

180 : //(0xb4) getfield
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['getfield', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

181 : //(0xb5) putfield
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['putfield', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

182 : //(0xb6) invokevirtual
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['invokevirtual', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;


183 : //(0xb7) invokespecial
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['invokespecial', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

184 : //(0xb8) invokestatic
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['invokestatic', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

185 : //(0xb9) invokeinterface
begin
        hexaCodeString := format('$%x $%x $%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2],code[codeOffset+3],code[codeOffset+4] ] );
        commandString := format('%s %d 0x0x0x0x0x', ['invokeinterface',
        utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ),
        code[codeOffset+2] ] );
        inc(i);
        inc(i);
        inc(i);
        inc(i);
        inc(i);
end;

186 : ; //(0xba) xxxunusedxxx1

187 : //(0xbb) new
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['new', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

188 : //(0xbc) newarray
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'newarray';
        inc(i);
end;

189 : //(0xbd) anewarray
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['anewarray', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

190 : //(0xbe) arraylength
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'arraylength';
        inc(i);
end;

191 : //(0xbf) athrow
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'athrow';
        inc(i);
end;

192 : //(0xc0) checkcast
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['checkcast', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

193 : //(0xc1) instanceof
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['instanceof', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

194 : //(0xc2) monitorenter
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'monitorenter';
        inc(i);
end;

195 : //(0xc3) monitorexit
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'monitorexit';
        inc(i);
end;

196 : //(0xc4) wide
begin
        raise Exception.Create('wide');
end;

197 : //(0xc5) multianewarray
begin
        raise Exception.Create('multianewarray');
end;

198 : //(0xc6) ifnull
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['ifnull', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

199 : //(0xc7) ifnonnull
begin
        hexaCodeString := format('$%x $%x $%x',[code[codeOffset],code[codeOffset+1],code[codeOffset+2] ] );
        commandString := format('%s %d', ['ifnonnull', utilClass.makeU2withHiByteAndLowByte( code[codeOffset+1], code[codeOffset+2] ) ] );
        inc(i);
        inc(i);
        inc(i);
end;

200 : //(0xc8) goto_w
begin
        raise Exception.Create('wide');
end;

201 : //(0xc9) jsr_w
begin
        raise Exception.Create('wide');
end;

//Reserved opcodes:

202 : // (0xca) breakpoint
begin
        hexaCodeString := format('$%x',[code[codeOffset]] );
        commandString := 'breakpoint';
        inc(i);
end;

254 : //(0xfe) impdep1
begin
        raise Exception.Create('wide');
end;

255 : //(0xff) impdep2
begin
        raise Exception.Create('wide');
end;

end; // case

//commandString := getFixedStringRightOrder( commandString , 20 , ' ' );
//dumpWriteln( format('%s : %s',[commandString,hexaCodeString] ) );


result := i;

end; // function


class function codeAttribute.getClassData( codeAttr : codeAttribute ) : string;
var
        s : string;
begin
        s := utilClass.convertByteToString(codeAttr.code, codeAttr.codeLength );
        result := s;
end;

class function codeAttribute.setClassData( data : string ) : codeAttribute;
var
        codeAttr : codeAttribute;
begin
        codeAttr := codeAttribute.Create;
        utilClass.convertStringToByte(data, codeAttr.code);
        result := codeAttr;
end;


end.

