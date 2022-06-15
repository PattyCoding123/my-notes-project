import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occured',
    content: text,
    // Function returns a mapping of options for users to choose in dialog.
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
