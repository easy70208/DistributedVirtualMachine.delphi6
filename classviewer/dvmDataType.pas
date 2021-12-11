unit dvmDataType;

interface

uses
        sysutils;

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
        ACC_PUBLIC = #0001;             // F M C
        ACC_PRIVATE = #0002;            // F M
        ACC_PROTECTED = #0004;          // F M
        ACC_STATIC = #0008;             // F M
        ACC_FINAL = #0010;              // F M C
        ACC_SUPER = #0020;              //     C
        ACC_SYNCHRONIZED = #0020;       //   M
        ACC_VOLATILE = #0040;           // F
        ACC_TRANSIENT = #0080;          // F
        ACC_NATIVE = #0100;             //   M
        ACC_INTERFACE = #0200;          //     C
        ACC_ABSTRACT = #0400;           //   M C
        ACC_STRICT = #0800;             //   M

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
                bytes : longint;
        end;

        constantFloat = class
        public
                bytes : longint;
        end;

        constantLong = class
        public
                highBytes : longint;
                lowBytes : longint;
        end;

        constantDouble = class
        public
                highBytes : longint;
                lowBytes : longint;
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
                attributeLength : longint;
                sourceFileIndex : word;
        end;

        codeAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : longint;
                maxStack : word;
                maxLocals : word;
                codeLength : longint;

                code : array[0..100] of byte;
                //code : array of byte;


                exceptionTableLength : word;

                startPc : array[0..10] of word;
                endPc : array[0..10] of word;
                handlerPc : array[0..10] of word;
                catchType : array[0..10] of word;

                attributesCount : word;
                attributes : array of attributeInfo;
        end;

        lineNumberTableAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : longint;
                lineNumberTableLength : word;

                startPc : array[0..10] of word;
                lineNumber : array[0..10] of word;
        end;

        localVariableTableAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : longint;
                localVariableTableLength : word;

                startPc : array[0..10] of word;
                length : array[0..10] of word;
                nameIndex : array[0..10] of word;
                descriptorIndex : array[0..10] of word;
                index : array[0..10] of word;
        end;

        constantValueAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : longint;
                constantValueIndex : word;
        end;

        exceptionAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : longint;
                numberOfExceptions : word;
                exceptionIndexTable : array[0..10] of word;
        end;

        innerClassesAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : longint;
                numberOfClasses : word;
                innerClassInfoIndex : array[0..10] of word;
                outerClassInfoIndex : array[0..10] of word;
                innerNameIndex : array[0..10] of word;
                innerClassAccessFlags : array[0..10] of word;
        end;

        syntheticAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : longint;
        end;

        deprecatedAttribute = class
        public
                attributeNameIndex : word;
                attributeLength : longint;
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



var
        a : array[0..0] of integer =( CONSTANT_NameAndType );

implementation
end.
