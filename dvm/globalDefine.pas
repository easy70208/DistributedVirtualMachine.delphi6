unit globalDefine;

interface

const
        // 전역 사용 상수 선언 - 각 모듈에서만 사용되는 상수는 각 모듈에서 정의한다.
        // dvm version
        DVM_VERSION = 'Distributed Virtual Machine beta 0.3.1';

        //
        // port define
        //
        // message udp port define
        SERVICE_MODE_MESSAGE_LISTENER_PORT = 9000; // udp는 하나의 컴퓨터에서 service와 normal이 실행될수 있기 때문에 포트를
        NORMAL_MODE_MESSAGE_LISTENER_PORT = 9090; // 다르게 한다.

        // process tcp port define
        PROCESS_LISTENER_PORT = 9000; // tcp message server

        // dfs tcp port define
        DISTRIBUTED_FILE_SYSTEM_LISTENER_PORT = 10000;



        //
        // path define
        //
        // system core dump
//        DVM_DUMP_PATH = './coredump/dvm/';
//        DVMS_DUMP_PATH = './coredump/dvms/';
        DVM_DUMP_PATH = './';
        DVMS_DUMP_PATH = './';

//        DFS_REQUEST_PATH = './dfs/request/';
//        DFS_LISTENER_PATH = './dfs/listener/';
//        DFS_LOCAL_PATH = './dfs/local/';
        DFS_REQUEST_PATH = './';
        DFS_LISTENER_PATH = './';
        DFS_LOCAL_PATH = './';

        DVM_INI_PATH = './dvm.ini';
        DVMS_INI_PATH = './dvms.ini';
        
type
        // udp Message ID
        UDP_MESSAGE_ID = (
        GET_CPUPOWER_MESSAGE, // 다른 service mode의 cpupower 를 얻기 위해 브로드 캐스팅 할때
        START_PROCESS_MESSAGE, // 프로세스를 service mode에서 처음 시작할때
        GET_DISKPOWER_MESSAGE // distributed file system module
        );

        // TCP Message ID
        //
        // * : 인터프리터에서 호출이 없다( 아에 그런 메소드를 호출하지 않는다
        // ** : 인터프리터에서 nomal로 직접호출하지 않느다. -> 호출은 하되 내부적으로 사용된다.
        TCP_PROCESS_MESSAGE_ID = (
PROCESS_MESSAGE_DUMY_0,
PROCESS_MESSAGE_DUMY_1,//*       PROCESS_MESSAGE_ID_getfileIOStream,                 // 1

        PROCESS_MESSAGE_ID_appendArray,                                              // 2
PROCESS_MESSAGE_DUMY_11,//*     PROCESS_MESSAGE_ID_getArray,                                                 // 3

        PROCESS_MESSAGE_ID_getArrayInstanceStructByIndexarrayType,                   // 4
        PROCESS_MESSAGE_ID_getArrayByIndexintArrayInstanceClassDataByIndex ,         // 5
        PROCESS_MESSAGE_ID_getArrayByIndexlongArrayInstanceClassDataByIndex ,        // 6
        PROCESS_MESSAGE_ID_getArrayByIndexbyteArrayInstanceClassDataByIndex ,        // 7
        PROCESS_MESSAGE_ID_getArrayByIndexcharArrayInstanceClassDataByIndex ,        // 8

        PROCESS_MESSAGE_ID_setArrayByIndexintArrayInstanceClassDataByIndex ,         // 9
        PROCESS_MESSAGE_ID_setArrayByIndexlongArrayInstanceClassDataByIndex ,        // 10
        PROCESS_MESSAGE_ID_setArrayByIndexbyteArrayInstanceClassDataByIndex ,        // 11
        PROCESS_MESSAGE_ID_setArrayByIndexcharArrayInstanceClassDataByIndex ,        // 12

        PROCESS_MESSAGE_ID_getArraySizeByIndexintArrayInstanceClassDataByIndex ,     // 13
        PROCESS_MESSAGE_ID_getArraySizeByIndexlongArrayInstanceClassDataByIndex ,    // 14
        PROCESS_MESSAGE_ID_getArraySizeByIndexbyteArrayInstanceClassDataByIndex ,    // 15
        PROCESS_MESSAGE_ID_getArraySizeByIndexcharArrayInstanceClassDataByIndex ,    // 16

        PROCESS_MESSAGE_ID_appendClassHecheri ,                                      // 17
        PROCESS_MESSAGE_ID_getNewInstance ,                                          // 18
        PROCESS_MESSAGE_ID_appendField ,                                             // 19
        PROCESS_MESSAGE_ID_getFieldIndex ,                                           // 20
        PROCESS_MESSAGE_ID_getFieldValue ,                                           // 21
        PROCESS_MESSAGE_ID_setFieldValue ,                                           // 22
        PROCESS_MESSAGE_ID_getOverridingMethodClassName ,                            // 23

        PROCESS_MESSAGE_ID_getNewInstanceClassByIndexclassHecheriIndex ,             // 24
        PROCESS_MESSAGE_ID_getNewInstanceClassByIndexclassHecheriIndexByLoadedClassIndexByIndex , // 25
        PROCESS_MESSAGE_ID_getNewInstanceClassByIndexIndex ,                         // 26
        PROCESS_MESSAGE_ID_getNewInstanceClassByIndexnameByIndex ,                   // 27
        PROCESS_MESSAGE_ID_getNewInstanceClassByIndexvalueByIndex ,                  // 28

        PROCESS_MESSAGE_ID_appendClass ,                                             // 29
        PROCESS_MESSAGE_ID_getLoadedClassIndex ,                                     // 30
        PROCESS_MESSAGE_ID_getLoadedClassName ,                                      // 31

        PROCESS_MESSAGE_ID_incInterpreterThreadCounter ,                             // 32
        PROCESS_MESSAGE_ID_decInterpreterThreadCounter ,                             // 33

PROCESS_MESSAGE_DUMY_111,//**    PROCESS_MESSAGE_ID_callInvokeSpecial ,                                       // 34
PROCESS_MESSAGE_DUMY_12,//**    PROCESS_MESSAGE_ID_callInvokeVirtual ,                                       // 35
PROCESS_MESSAGE_DUMY_13,//**    PROCESS_MESSAGE_ID_callInvokeStatic ,                                        // 36
PROCESS_MESSAGE_DUMY_14,//*    PROCESS_MESSAGE_ID_callMethodType1 ,                                          //  37
PROCESS_MESSAGE_DUMY_15,//**    PROCESS_MESSAGE_ID_callMethodType2 ,                                         //  38
PROCESS_MESSAGE_DUMY_16,//*       PROCESS_MESSAGE_ID_callMethodType3 ,                                       //  39
PROCESS_MESSAGE_DUMY_17,//*       PROCESS_MESSAGE_ID_callMethodType4 ,                                       //  40

PROCESS_MESSAGE_DUMY_18,//**        PROCESS_MESSAGE_ID_returnMethod ,                                         // 41
PROCESS_MESSAGE_DUMY_19,                                                              // 42
        PROCESS_MESSAGE_ID_callNativeMethod ,                                         // 43

        PROCESS_MESSAGE_ID_appendStaticField ,                                        // 44
        PROCESS_MESSAGE_ID_getStaticFieldIndexByFieldName ,                           // 45
        PROCESS_MESSAGE_ID_getStaticFieldValue ,                                      // 46
        PROCESS_MESSAGE_ID_setStaticFieldValue ,                                      // 47

        PROCESS_MESSAGE_ID_getStaticFieldIndex ,                                      // 48
        PROCESS_MESSAGE_ID_getStaticFieldnameByIndex ,                                // 49
        PROCESS_MESSAGE_ID_getStaticFieldvalueByIndex ,                               // 50
PROCESS_MESSAGE_DUMY_20,//*        PROCESS_MESSAGE_ID_getStringByStringInstance ,                             // 51
PROCESS_MESSAGE_DUMY_21,//*       PROCESS_MESSAGE_ID_getUTF8Name ,                                           // 52
PROCESS_MESSAGE_DUMY_22,//*      PROCESS_MESSAGE_ID_getClassInfoName ,                                       // 53
PROCESS_MESSAGE_DUMY_23,//*       PROCESS_MESSAGE_ID_getNameAndTypeName ,                                    // 54
        PROCESS_MESSAGE_ID_getMethodRefInfoName ,                                    // 55
        PROCESS_MESSAGE_ID_getFieldRefInfoName ,                                     // 56
        PROCESS_MESSAGE_ID_getConstantPoolTagByIndex ,                               // 57
        PROCESS_MESSAGE_ID_getConstantPoolconstantIntegerBytesByIndex ,              // 58
        PROCESS_MESSAGE_ID_getConstantPoolconstantStringstringIndexByIndex ,        //  59
        PROCESS_MESSAGE_ID_getConstantPoolconstantUTF8InfolengthByIndex ,           //  60
        PROCESS_MESSAGE_ID_getConstantPoolconstantUTF8InfoBytesByIndex ,            //  61
        PROCESS_MESSAGE_ID_getConstantPoolconstantLongbytesByIndex ,                //  62
        PROCESS_MESSAGE_ID_getAccessFlagLoadedClassByIndexMethodsByIndex,           //  63

PROCESS_MESSAGE_DUMY_24,//*       PROCESS_MESSAGE_ID_getMethodsIndexWithAccessFlag ,                        //  64
        PROCESS_MESSAGE_ID_getMethodsIndex ,                                        //  65
        PROCESS_MESSAGE_ID_getTotalLocalVariableNumber ,                            //  66
        PROCESS_MESSAGE_ID_getMethodLocalVariableNumber ,                           //  67
        PROCESS_MESSAGE_ID_getMethodArgsVariableNumber ,                            //  68
        PROCESS_MESSAGE_ID_getMethodname ,                                          //  69
        PROCESS_MESSAGE_ID_getCodeAttribute ,                                      //   70

        PROCESS_MESSAGE_ID_getInterpreterThreadCounter ,                           //   71
        PROCESS_MESSAGE_ID_getLoaderClassIndex ,                                   //   72
        PROCESS_MESSAGE_ID_getNewInstanceIndex ,                                   //   73
        PROCESS_MESSAGE_ID_getArrayInstanceStructIndex                             //   74
        );
        
implementation

end.
