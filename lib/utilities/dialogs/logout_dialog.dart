import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  // Because showGenericDialog returns T?, we need a safeguard return
  return showGenericDialog(
    context: context,
    title: 'Logout',
    content: 'Are you sure you want to log out?',
    optionsBuilder: () => {
      'Cancel': false,
      'Log out': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
