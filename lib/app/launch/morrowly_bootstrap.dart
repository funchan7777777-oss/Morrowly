import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:morrowly/app/morrowly_app.dart';

void bootstrapMorrowly() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: const Color(0x00000000),
      systemNavigationBarColor: const Color(0x00000000),
      systemNavigationBarDividerColor: const Color(0x00000000),
    ),
  );
  runApp(const MorrowlyApp());
}
