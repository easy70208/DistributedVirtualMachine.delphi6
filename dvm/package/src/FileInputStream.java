package java.io;

public class FileInputStream {

  private int fileHandler;

    private native int readBytes(byte b[], int off, int len);
    private native int open(String name);

    public native int read();
    //public native long skip(long n); 버그가 있가 2003-7-3
    public native int available();
    public native void close();


    public FileInputStream(String name) {
      fileHandler = open( name );
    }

    public int read(byte b[]) {
        return readBytes(b, 0, b.length);
    }

    public int read(byte b[], int off, int len) {
        return readBytes(b, off, len);
    }

}