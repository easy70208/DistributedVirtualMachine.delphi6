unit dvmClassLoader;

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
                procedure loadAttributes( count : integer ; atr : array of attributeInfo );
        public
                procedure load( classfile : string );
                procedure coreDump();
        end;


implementation

procedure classLoader.loadMethodsCount();
begin
        FileRead(fileHandler, methodsCount, 2 );
        methodsCount := bitSwitchInteger( methodsCount );
end;

procedure classLoader.loadMethods();
var
        i : integer;
begin
        setLength( self.methods, self.methodsCount );

        for i:=0 to self.methodsCount - 1 do
        begin
                self.methods[i] := methodInfo.Create ;

                FileRead(fileHandler , self.methods[i].accessFlags , 2 );
                self.methods[i].accessFlags := bitSwitchInteger( self.methods[i].accessFlags );

                FileRead(fileHandler , self.methods[i].nameIndex , 2 );
                self.methods[i].nameIndex := bitSwitchInteger( self.methods[i].nameIndex );

                FileRead(fileHandler , self.methods[i].descriptorIndex , 2 );
                self.methods[i].descriptorIndex := bitSwitchInteger( self.methods[i].descriptorIndex );

                FileRead(fileHandler , self.methods[i].attributesCount , 2 );
                self.methods[i].attributesCount := bitSwitchInteger( self.methods[i].attributesCount );

                if self.methods[i].attributesCount <> 0 then
                begin

                end;
        end;

end;

procedure classLoader.loadAttributesCount();
begin
        FileRead(fileHandler, attributesCount, 2 );
        attributesCount := bitSwitchInteger( attributesCount );
end;


procedure classLoader.loadAttributes( count : integer ; atr : array of attributeInfo );
var
        i : integer;
begin
        setLength( self.attributes, self.attributesCount );
{
        for i:=0 to self.attributesCount - 1 do
        begin
                self.attributes[i] := attributeInfo.Create ;

                FileRead(fileHandler , self.attributes[i].attributeNameIndex , 2 );
                self.attributes[i].attributeNameIndex := bitSwitchInteger( self.attributes[i].attributeNameIndex );

                FileRead(fileHandler , self.attributes[i].attributeLength , 4 );
                self.attributes[i].attributeLength := bitSwitchLong( self.attributes[i].attributeLength );

                FileRead(fileHandler , self.attributes[i].info , self.attributes[i].attributeLength );
        end;
}
end;

procedure classLoader.loadFields();
var
        i : integer;
begin
        setLength( self.fields, self.fieldsCount );

        for i:=0 to self.fieldsCount - 1 do
        begin
                self.fields[i] := fieldInfo.Create ;

                FileRead(fileHandler , self.fields[i].accessFlags , 2 );
                self.fields[i].accessFlags := bitSwitchInteger( self.fields[i].accessFlags );

                FileRead(fileHandler , self.fields[i].nameIndex , 2 );
                self.fields[i].nameIndex := bitSwitchInteger( self.fields[i].nameIndex );

                FileRead(fileHandler , self.fields[i].descriptorIndex , 2 );
                self.fields[i].descriptorIndex := bitSwitchInteger( self.fields[i].descriptorIndex );

                FileRead(fileHandler , self.fields[i].attributesCount , 2 );
                self.fields[i].attributesCount := bitSwitchInteger( self.fields[i].attributesCount );

                if self.fields[i].attributesCount <> 0 then
                begin
                end;
        end;

end;

procedure classLoader.loadFieldsCount();
begin
        FileRead(fileHandler, fieldsCount, 2 );
        fieldsCount := bitSwitchInteger( fieldsCount );
end;

procedure classLoader.loadInterfaces();
var
        i : integer;
begin
        setLength ( self.interfaces , interfacesCount );

        for i := 0 to self.interfacesCount - 1 do
        begin
                FileRead( fileHandler, self.interfaces[i] , 2 );
                self.interfaces[i] := bitSwitchInteger( self.interfaces[i] );
        end;
end;

procedure classLoader.loadMagicNumber();
begin
        FileRead(fileHandler, magicNumber, 4 );
end;

procedure classLoader.loadMinorVersion();
begin
        FileRead(fileHandler, minorVersion, 2 );
        minorVersion := bitSwitchInteger( minorVersion );
end;

procedure classLoader.loadMajorVersion();
begin
        FileRead(fileHandler, majorVersion, 2 );
        majorVersion := bitSwitchInteger( majorVersion );
end;

procedure classLoader.loadConstantPool();
var
        i : integer;
        u2 : word;
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
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantClassInfo).nameIndex := u2;
                        end;
                        CONSTANT_Fieldref :
                        begin
                                self.constantPool[i].info := constantFieldref.Create();
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantFieldref).classIndex := u2;
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantFieldref).nameAndTypeIndex := u2;
                        end;
                        CONSTANT_Methodref :
                        begin
                                self.constantPool[i].info := constantMethodref.Create();
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantMethodref).classIndex := u2;
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantMethodref).nameAndTypeIndex := u2;
                        end;
                        CONSTANT_InterfaceMethodref :
                        begin
                                self.constantPool[i].info := constantInterfaceMethodref.Create();
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantInterfaceMethodref).classIndex := u2;
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantInterfaceMethodref).nameAndTypeIndex := u2;
                        end;
                        CONSTANT_String :
                        begin
                                self.constantPool[i].info := constantString.Create();
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantString).stringIndex := u2;
                        end;
                        CONSTANT_Integer : ;
                        CONSTANT_Float : ;
                        CONSTANT_Long : ;
                        CONSTANT_Double : ;
                        CONSTANT_NameAndType :
                        begin
                                self.constantPool[i].info := constantNameAndType.Create();
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantNameAndType).nameIndex := u2;
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantNameAndType).descriptorIndex := u2;
                        end;
                        CONSTANT_Utf8 :
                        begin
                                self.constantPool[i].info := constantUtf8Info.Create();
                                FileRead( self.fileHandler , u2 , 2 );
                                u2 := bitSwitchInteger( u2 );
                                (self.constantPool[i].info as constantUtf8Info).length := u2;

                                // setLength가 않되고 있다.  모르겠다.
                                // 그래서 bytes를 정적 배열로 선언했다.
                                //setLength( (self.constantPool[i].infoClass as constantUtf8Info).bytes , u2 );

                                FileRead( self.fileHandler , (self.constantPool[i].info as constantUtf8Info).bytes , u2 );
                                // 유니코드 처리 .... 않된다.....
                                //(self.constantPool[i].infoClass as constantUtf8Info).name := widecharlentostring( (self.constantPool[i].infoClass as constantUtf8Info).bytes , u2 );
                                SetString( (self.constantPool[i].info as constantUtf8Info).bytesName , (self.constantPool[i].info as constantUtf8Info).bytes , u2 );
                                //writeln( (self.constantPool[i].infoClass as constantUtf8Info).name );
                        end;
                end;


        end;

end;

procedure classLoader.loadConstantPoolCount();
begin
        FileRead(fileHandler, constantPoolCount, 2 );
        constantPoolCount := bitSwitchInteger( constantPoolCount );
end;

procedure classLoader.loadAccessFlags();
begin
        FileRead(fileHandler, accessFlags, 2 );
        accessFlags := bitSwitchInteger( accessFlags );
end;

procedure classLoader.loadThisClass();
begin
        FileRead(fileHandler, thisClass, 2 );
        thisClass := bitSwitchInteger( thisClass );
end;

procedure classLoader.loadSuperClass();
begin
        FileRead(fileHandler, superClass, 2 );
        superClass := bitSwitchInteger( superClass );
end;

procedure classLoader.loadInterfacesCount();
begin
        FileRead(fileHandler, interfacesCount, 2 );
        interfacesCount := bitSwitchInteger( interfacesCount );
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
        self.loadAttributes( self.attributesCount , self.attributes );

        FileClose( fileHandler );

end;

procedure classLoader.coreDump();
var
        i : integer;
        j : integer;
        k : integer;
        s : string;

        sfa : sourceFileAttribute;
begin
        writeln( format('classfile : %s', [classfile]) );


        writeln( format('magicNumber : 0x%x%x%x%x' ,
                [magicNumber[0], magicNumber[1] ,
                magicNumber[2] , magicNumber[3]] ) );


        writeln( format('minorVersion : 0x%x', [minorVersion] ) );


        writeln( format('majorVersion : 0x%x' , [majorVersion]) );


        writeln( format('constantPoolCount : %d' , [constantPoolCount]) );


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
                                write( format( 'CONSTANT_Integer(%d) ' , [ self.constantPool[i].tag ]) );
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



        writeln( format('accessFlags : 0x%x  ' , [accessFlags]) );


        writeln( format('thisClass : %d' , [thisClass]) );


        writeln( format('superClass : %d' , [superClass]) );


        writeln( format('interfacesCount : %d' , [interfacesCount]) );


        for i:=0 to self.interfacesCount - 1 do
        begin
                writeln( format( 'interface : %d' , [ self.interfaces[i] ] ) );
        end;


        writeln( format('fieldsCount : %d' , [fieldsCount]) );


        for i:=0 to self.fieldsCount - 1 do
        begin
                write( format('field[%d] : ' , [i] ) );
                writeln( format('accessFlags : 0x%x  nameIndex : %d  descriptorIndex : %d  attributesCount : %d',
                [self.fields[i].accessFlags , self.fields[i].nameIndex , self.fields[i].descriptorIndex , self.fields[i].attributesCount ] ) );

                if self.fields[i].attributesCount <> 0 then
                begin
                        for j :=0 to self.fields[i].attributesCount - 1 do
                        begin
                        end;
                end;
        end;



        writeln( format('methodsCount : %d' , [methodsCount]) );


        for i:=0 to self.methodsCount - 1 do
        begin
                write( format('method[%d] : ' , [i] ) );
                writeln( format('accessFlags : 0x%x  nameIndex : %d  descriptorIndex : %d  attributesCount : %d',
                [self.methods[i].accessFlags , self.methods[i].nameIndex , self.methods[i].descriptorIndex , self.methods[i].attributesCount ] ) );


                if self.methods[i].attributesCount <> 0 then
                begin
                {
                        for j :=0 to self.methods[i].attributesCount - 1 do
                        begin
                                write( format('attribute[%d] : ' , [j] ) );
                                writeln( format( 'attributeNameIndex : %d  attributeLength : %d' , [self.methods[i].attributes[j].attributeNameIndex,
                                        self.methods[i].attributes[j].attributeLength ] ) );

                                for k:=0 to self.methods[i].attributes[j].attributeLength - 1 do
                                begin
                                        write( format('%x ' , [ (byte(self.methods[i].attributes[j].info[k])) ] ) );
                                end;

                                writeln( '' );
                        end;
                }
                end;
        end;


        writeln( format('attributesCount : %d' , [attributesCount]) );


        for i:=0 to self.attributesCount - 1 do
        begin {
                write( format('attribute[%d] : ' , [i] ) );
                writeln( format('attributeNameIndex : %d  attributeLength : %d',
                [self.attributes[i].attributeNameIndex , self.attributes[i].attributeLength ] ) );

                for j:=0 to self.attributes[i].attributeLength - 1 do
                begin
                        write( format('%x ' , [ (byte(self.attributes[i].info[j])) ] ) );
                end;

                writeln( '' );}
        end;



end;



end.
