unit readme;

interface

implementation
{
implement

**********************************bytecode
long,int ���� ���
ldc, ldcw ldc_w : integer, String, long
iload?? lload?? ���
integet, long ��Ģ����
integer ��ȯ( short ����)
�� �б�
integer, long , instance return
static �� field value�� long
char,byte,int,long �迭
int,char,boolean,char ��밡��

********************************* append
dvm,dvms���� ���� �߰�
dfs �Ҵ� ó��
StringBuffer class �߰� -> System.out.println("" + "" )��밡��
�ٸ� �����尡 ����ɶ����� ����ϴ� �� �߰�



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
    //public native long skip(long n); ���װ� �ְ� 2003-7-3
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
. static �� fieldValue ���� long ó��
        namdAndValueŬ������ �ΰ��� ���

. ��ӹ��� �޼��尡 �ش�Ŭ������ ���� ȣ�M���� ������ �ϵ�....(jdk 1.2 1.3 �̻�)
        �ش� Ŭ������ start�޼ҵ带 ����� ���� start�� ȣ��

. cinit ����
        xx --? excpetion ����..

. new �迭�� ���� �Ҵ� ����
        2003-7-2
        static ��ü�� ���� �Ҵ����� �ʰ� new�� �����ν� �ذ��ߴ�.
        ���� ���̻� 0��° ��ü�� ������� �ʴ� �ڵ尡 �ʿ� ����.

. ���������Ϳ��� ���� �����ϴ� ����
        2003-7-24
        runtimeEnvnronment���� ������ Ŭ������ ����
        ���������Ͱ� ���� ��忡�� ����� ���� ����Ǹ� �� ������ �ʿ� �ϱ� �빮��
        �̰��� �ٽ� �޼���� �����Ѵ�.

. dvms���� hext to int64 ����....
        strtoint64 and format('%d' �� �ذ�..

. dvms���� String��� ����
        �߸��� ����Ÿ�� ������ �۾��� �ϰ� �־���..

. long �� ����
        lcmp ���� value1�� value2�� �ڹٲ����.

. static field ���� -> Ŭ������ �ε���� ��� clinit �� �������� �ʴ���.
        k := i or j; // if������ ���� �񱳸� �������� �ʾƼ� �̷��� �Ѵ�....
        k := k and -1;
        if k = -1 then
        �� ó��..

. dvms���� ':'�� �� ���ڿ� ���� ����.
        utilClass.getToken(msg,':',s1) ���� �ذ�.. ��ū�� �������� �߷��� �߻��Ǵ� ����..

. long ����� ����
        ��Ʈ ���չ���..

. DFS writeBytes readBytes ����
        setlength�� ������� �ʰ� ���� �迭�� ���

. TCPGetMessage�� �Ӱ豸�� ���� �ڵ� ����(2003-9-14)                

****************************************************************************
****************************************************************************
****************************************************************************

bug

gabage colloction

dfs ������ �ش� dfs listener ������ ����

allowdfsSize�� Integer���� �ȴ�..



}

end.
