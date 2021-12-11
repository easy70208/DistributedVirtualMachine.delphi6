package java.lang;

public class Thread {

  public Thread() {
  }

  public native void start();

  public void run() {
  }
  
  public native static int activeCount();
}
