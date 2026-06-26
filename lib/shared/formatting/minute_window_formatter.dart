abstract final class MinuteWindowFormatter {
  static String clockRange(int startMinute, int endMinute) {
    return '${_clockFace(startMinute)}-${_clockFace(endMinute)}';
  }

  static String _clockFace(int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    final period = hour >= 12 ? 'PM' : 'AM';
    final twelveHour = hour % 12 == 0 ? 12 : hour % 12;
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$twelveHour:$paddedMinute $period';
  }
}
