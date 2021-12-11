unit readme;

interface

implementation
{
implement

**********************************bytecode
long,int 저장 명령
ldc, ldcw ldc_w : integer, String, long
iload?? lload?? 명령
integet, long 사칙연산
integer 변환( short 제외)
비교 분기
integer, long , instance return
static 및 field value의 long
char,byte,int,long 배열
int,char,boolean,char 사용가능

********************************* append
dvm,dvms설정 파일 추가
dfs 할당 처리
StringBuffer class 추가 -> System.out.println("" + "" )사용가능
다른 쓰레드가 종료될때까지 대기하는 것 추가



classlib
******************** java.lang.*
java.lang.Object
  public Object()
  public String toString()

java.lang.System
  public static PrintStream out = new PrintStream();
  public System()
  public static void arraycopy( char[] s , int soffset , char[] d , int doffset , int len )

java.lang.String
  public char[] b;
  public String( StringBuffer s )
  public String(char[] b)
  public String( String b )
  public  String(int offset, int count, char value[])
  public String(char value[], int offset, int count)
  public int length() {

java.lang.StringBuffer
    public native char[] inttostr( int i );
    public native char[] longtostr( long l );
    public StringBuffer() { this(100);
    public StringBuffer(int length)
    public StringBuffer(String str)
    public StringBuffer append(int i)
    public StringBuffer append(long l)
    public synchronized StringBuffer append(String str)
    public synchronized StringBuffer append(char str[])
    public StringBuffer append(boolean b)
    public synchronized StringBuffer append(char c)
    public String toString()

java.lang.Thread
  public Thread()
  public native void start()
  public void run()
  public native static int activeCount();

********************* java.io.*;
java.io.FileInputStream
    private native int readBytes(byte b[], int off, int len);
    private native int open(String name);
    public native int read();
    //public native long skip(long n); 버그가 있가 2003-7-3
    public native int available();
    public native void close();
    public FileInputStream(String name);
    public int read(byte b[]);
    public int read(byte b[], int off, int len);

java.io.FileOutputStream
  private native int open(String name);
  private native int openAppend(String name);
  private native void writeBytes(byte b[], int off, int len);
  public native void write(int b);
  public native void close();
  public FileOutputStream(String name)
  public FileOutputStream(String name, boolean append)
  public void write(byte b[])
  public void write(byte b[], int off, int len)

java.io.PrintStream 
  public PrintStream()
  public native void print( char c );
  public native void println( char c );
  public native void print( int v );
  public native void println( int v );
  public native void print( long v );
  public native void println( long v );
  public native void print( String s );
  public native void println( String s )


fix
. static 및 fieldValue 에서 long 처리
        namdAndValue클래스에 두개를 등록

. 상속받은 메서드가 해당클래스와 같이 호홏되지 않으면 암됨....(jdk 1.2 1.3 이상)
        해당 클래스에 start메소드를 만들고 상위 start를 호출

. cinit 에러
        xx --? excpetion 때문..

. new 배열에 더미 할당 문제
        2003-7-2
        static 객체에 널을 할당하지 않고 new을 함으로써 해결했다.
        따라서 더이상 0번째 객체를 사용하지 않는 코드가 필요 없다.

. 인터프리터에서 각각 덤프하는 문제
        2003-7-24
        runtimeEnvnronment에서 변수들 클래스로 변경
        인터프리터가 서비스 모드에서 디버깅 모드로 실행되면 이 값들이 필요 하기 대문에
        이것을 다시 메서드로 변경한다.

. dvms에서 hext to int64 버그....
        strtoint64 and format('%d' 로 해결..

. dvms에서 String출력 에러
        잘못된 데이타를 가지고 작업을 하고 있었다..

. long 비교 에러
        lcmp 에서 value1과 value2가 뒤바뀌었다.

. static field 문제 -> 클래스가 로드된후 라면 clinit 를 실행하지 않느다.
        k := i or j; // if문에서 다중 비교를 지원하지 않아서 이렇게 한다....
        k := k and -1;
        if k = -1 then
        로 처리..

. dvms에서 ':'이 들어간 문자열 사용시 에러.
        utilClass.getToken(msg,':',s1) 으로 해결.. 토큰의 나머지가 잘려서 발생되는 문제..

. long 연산시 에러
        비트 조합문제..

. DFS writeBytes readBytes 에러
        setlength을 사용하지 않고 고정 배열을 사용

. TCPGetMessage에 임계구역 설정 코드 삽입(2003-9-14)                

****************************************************************************
****************************************************************************
****************************************************************************

bug

gabage colloction

dfs 삭제시 해당 dfs listener 없으면 에러

allowdfsSize는 Integer값만 된다..



}

end.
