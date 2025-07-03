package com.example;

import org.junit.Test;
import static org.junit.Assert.*;

public class HelloWorldTest {
  @Test
  public void testMessage() {
    String greeting = "Hello from Bazel + Java + MODULE.bazel!";
    assertTrue(greeting.contains("Bazel"));
  }
}
