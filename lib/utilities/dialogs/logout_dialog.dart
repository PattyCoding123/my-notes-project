import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  // Because showGenericDialog returns T?, we need a safeguard return
  return showGenericDialog(
    context: context,
    title: context.loc.logout_button,
    content: context.loc.logout_dialog_prompt,
    // Function returns a mapping of options for user to choose in dialog
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.logout_button: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
