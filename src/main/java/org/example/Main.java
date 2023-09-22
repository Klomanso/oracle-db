package org.example;

public class Main {
  public static void main(String[] args) {
    System.out.println("Hello world!");
  }

  public static String leftPad(String source, int length, char paddingChar) {
    if (source == null) {
      return null;
    }
    if (length <= source.length()) {
      return source;
    }
    StringBuilder result = new StringBuilder(source);
    for (int i = length - source.length(); i > 0; i--) {
      result.insert(0, paddingChar);
    }
    return result.toString();
  }
}
