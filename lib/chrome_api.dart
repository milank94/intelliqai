@JS('chrome')
library chrome;

import 'package:js/js.dart';

@JS('tabs.query')
external Future<List<Tab>> query(ParameterQueryTabs parameterQueryTabs);

@JS()
@anonymous
class Tab {
  external String get url;
  external factory Tab({String url});
}

@JS()
@anonymous
class ParameterQueryTabs {
  external bool get active;
  external bool get lastFocusedWindow;

  external factory ParameterQueryTabs({
    bool active,
    bool lastFocusedWindow,
  });
}
