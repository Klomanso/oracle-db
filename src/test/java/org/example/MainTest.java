package org.example;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.ArgumentsProvider;
import org.junit.jupiter.params.provider.ArgumentsSource;

class MainTest {

  @Test
  void testLeftPad_whenGivenNullSource_returnNull() {

    // Given
    String source = null;
    int length = 0;
    char paddingChar = 'l';

    // When
    String result = Main.leftPad(source, length, paddingChar);

    // Then
    assertNull(result);
  }

  @Test
  void testLeftPad_whenGivenLengthLessOrEqualSourceLength_thenReturnSource() {

    // Given
    String source = "testString";
    int length = 4;
    char paddingChar = 'l';

    // When
    String result = Main.leftPad(source, length, paddingChar);

    // Then
    assertEquals(source, result);
  }

  @ParameterizedTest
  @ArgumentsSource(leftPadArgumentsProvider.class)
  void testLeftPad_whenGivenCorrectInput_thenReturnLeftPaddedString(leftPadDTO input) {

    // Given && When
    String result = Main.leftPad(input.source(), input.length(), input.paddingChar());

    // Then
    assertEquals(input.expected(), result);
  }

  private static class leftPadArgumentsProvider implements ArgumentsProvider {

    @Override
    public Stream<? extends Arguments> provideArguments(ExtensionContext context) {
      return Stream.of(
          Arguments.of(new leftPadDTO("test", 5, '6', "6test")),
          Arguments.of(new leftPadDTO("", 5, '6', "66666")),
          Arguments.of(new leftPadDTO("1234567890", 20, ' ', "          1234567890")),
          Arguments.of(new leftPadDTO("test", 5, '6', "6test")));
    }
  }

  private record leftPadDTO(String source, int length, char paddingChar, String expected) {}
}
