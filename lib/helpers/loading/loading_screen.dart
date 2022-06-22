import 'package:flutter/material.dart';
import 'package:mynotes/helpers/loading/loading_screen_controller.dart';
import 'dart:async';

class LoadingScreen {
  // Singleton Constructor
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  LoadingScreenController? controller;

  // Method to show the loading screen overlay
  void show({
    required BuildContext context,
    required String text,
  }) {
    if (controller?.update(text) ?? false) {
      return;
    } else {
      controller = showOverlay(context: context, text: text);
    }
  }

  // Method to hide the loading screen overlay
  void hide() {
    controller?.close();
    controller = null;
  }

  // Method that displays a loading screen as an overlay and returns
  // a LoadingScreenController.
  LoadingScreenController showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final loadingText = StreamController<String>();
    loadingText.add(text);

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // OverlayEntry will create the overlay that will be displayed in front of
    // the views whenever a loading screen is needed.
    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      StreamBuilder(
                        // Insert text argument stream into
                        // the stream builder to display on loading screen.
                        stream: loadingText.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Display overlay
    state?.insert(overlay);

    // Return a LoadingScreenController with the typedef function parameters
    // defined. These will be called by the loading screen controller
    // member whenever it needs to close the overlay or update it (since
    // the loading screen controller has access to these function members).
    return LoadingScreenController(
      close: () {
        loadingText.close;
        overlay.remove();
        return true;
      },
      update: (text) {
        loadingText.add(text);
        return true;
      },
    );
  }
}
