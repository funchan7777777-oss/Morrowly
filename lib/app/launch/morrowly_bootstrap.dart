import 'package:flutter/widgets.dart';
import 'package:morrowly/app/morrowly_app.dart';

void bootstrapMorrowly() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MorrowlyApp());
}
