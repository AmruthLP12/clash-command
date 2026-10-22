export 'openers/unsupported.dart'
    if (dart.library.io) 'openers/native.dart'
    if (dart.library.js_interop) 'openers/web.dart';
