import 'package:flutter/material.dart';

/// Temporary feedback for actions that are not connected to the API yet.
void showPreviewNotice(BuildContext context, String action) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$action will work once the API is connected.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
