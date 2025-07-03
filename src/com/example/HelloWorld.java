package com.example;

import com.example.util.StringUtils;

public class HelloWorld {
  public static void main(String[] args) {
    String message = "hello from Bazel + Java + MODULE.bazel!";
    System.out.println(StringUtils.capitalize(message));
  }
}