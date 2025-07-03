package com.example.util;

public class StringUtils {
  public static String capitalize(String input) {
    if (input == null || input.isEmpty()) {
      return input;
    }
    return Character.toUpperCase(input.charAt(0)) + input.substring(1);
  }
}