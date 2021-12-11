package java.io;

public class FileOutputStream {

private int fileHandler;

  private native int open(String name);
  private native int openAppend(String name);
  private native void writeBytes(byte b[], int off, int len);

  public native void write(int b);
  public native void close();

  public FileOutputStream(String name) {

      this(name, false);

  }

  public FileOutputStream(String name, boolean append){
//    if( append == false )           System.out.println(name);
    if( append == true )
      fileHandler = openAppend( name );
    else
      fileHandler = open( name );
  }

  public void write(byte b[]) {
      writeBytes(b, 0, b.length);
  }

  public void write(byte b[], int off, int len) {
      writeBytes(b, off, len);
  }



}