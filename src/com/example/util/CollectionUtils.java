// src/com/example/util/CollectionUtils.java
package com.example.util;

import com.google.common.collect.ImmutableList;

public class CollectionUtils {
  public static <T> ImmutableList<T> createImmutableList(T... elements) {
    return ImmutableList.copyOf(elements);
  }
}