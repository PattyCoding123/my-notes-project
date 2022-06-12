import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArgument on BuildContext {
  T? getArgument<T>() {
    // ModalRoute is a route that blocks interactions between previous routes,
    // and it covers the entire Navigator. It is utilized when
    // a new BuildContext is created when pushing to a new route.
    final modalRoute = ModalRoute.of(this);
    if (modalRoute != null) {
      final args = modalRoute.settings.arguments;
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}
