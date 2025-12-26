import 'package:flutter/material.dart';
import 'package:lan_mouse_mobile/app/services/lan_mouse_server.dart';
import 'package:virtual_keyboard_custom_layout/virtual_keyboard_custom_layout.dart';
import 'package:lan_mouse_mobile/app/models/keyboard_event.dart' as ke;

class KeyboardHandler extends StatefulWidget {
  const KeyboardHandler({super.key});

  @override
  State<KeyboardHandler> createState() => _KeyboardHandlerState();
}

class _KeyboardHandlerState extends State<KeyboardHandler> {
  final LanMouseServer lanMouseServer = LanMouseServer.instance;

  final Map<String, int> charKeyMap = {
    "a": 30,
    "b": 48,
    "c": 46,
    "d": 32,
    "e": 18,
    "f": 33,
    "g": 34,
    "h": 35,
    "i": 23,
    "j": 36,
    "k": 37,
    "l": 38,
    "m": 50,
    "n": 49,
    "o": 24,
    "p": 25,
    "q": 16,
    "r": 19,
    "s": 31,
    "t": 20,
    "u": 22,
    "v": 47,
    "w": 17,
    "x": 45,
    "y": 21,
    "z": 44,

    "1": 2,
    "2": 3,
    "3": 4,
    "4": 5,
    "5": 6,
    "6": 7,
    "7": 8,
    "8": 9,
    "9": 10,
    "0": 11,

    "`": 41,
    "-": 12,
    "=": 13,
    "[": 26,
    "]": 27,
    "\\": 43,
    ";": 39,
    "'": 40,
    ",": 51,
    ".": 52,
    "/": 53,
    " ": 57,
  };

  final Map<VirtualKeyboardKeyAction, int> actionKeyMap = {
    VirtualKeyboardKeyAction.Backspace: 14,
    VirtualKeyboardKeyAction.Return: 28,
    VirtualKeyboardKeyAction.Shift: 42,
    // VirtualKeyboardKeyAction.Control: 29,
    // VirtualKeyboardKeyAction.Alt: 56,
    VirtualKeyboardKeyAction.Space: 57,
    // VirtualKeyboardKeyAction.Tab: 15,
    // VirtualKeyboardKeyAction.Escape: 1,
  };
  bool shiftPressed = false; // Track Shift state globally

  void onKeyPress(VirtualKeyboardKey key) async {
    debugPrint(
      "Key pressed: text: ${key.text} caps: ${key.capsText} action: ${key.action}, type: ${key.keyType}",
    );
    int? keyCode;

    if (key.keyType == VirtualKeyboardKeyType.Action) {
      if (key.action == VirtualKeyboardKeyAction.Shift) {
        shiftPressed = !shiftPressed;
        final shiftKeyCode = actionKeyMap[VirtualKeyboardKeyAction.Shift]!;
        lanMouseServer.sendInputEvent(
          ke.KeyEvent(key: shiftKeyCode, down: shiftPressed),
        );
      } else {
        keyCode = actionKeyMap[key.action];
        if (keyCode != null) {
          lanMouseServer.sendInputEvent(ke.KeyEvent(key: keyCode, down: true));
          await Future.delayed(const Duration(milliseconds: 30));
          lanMouseServer.sendInputEvent(ke.KeyEvent(key: keyCode, down: false));
        }
      }
    } else if (key.keyType == VirtualKeyboardKeyType.String) {
      final text = key.text?.toLowerCase();
      keyCode = charKeyMap[text];
      if (keyCode == null) return;

      lanMouseServer.sendInputEvent(ke.KeyEvent(key: keyCode, down: true));
      await Future.delayed(const Duration(milliseconds: 30));
      lanMouseServer.sendInputEvent(ke.KeyEvent(key: keyCode, down: false));

      if (shiftPressed) {
        final shiftKeyCode = actionKeyMap[VirtualKeyboardKeyAction.Shift]!;
        lanMouseServer.sendInputEvent(
          ke.KeyEvent(key: shiftKeyCode, down: false),
        );
        shiftPressed = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: VirtualKeyboard(
        defaultLayouts: const [VirtualKeyboardDefaultLayouts.English],
        type: VirtualKeyboardType.Alphanumeric,
        onKeyPress: onKeyPress,
      ),
    );
  }
}
