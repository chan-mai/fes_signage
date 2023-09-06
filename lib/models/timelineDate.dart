String getTimeText(DateTime time) {
  String hour = time.hour.toString();
  String minute = time.minute.toString();
  if (time.hour < 10) {
    hour = "0" + time.hour.toString();
  }
  if (time.minute < 10) {
    minute = "0" + time.minute.toString();
  }
  String TimeText = hour + ":" + minute;
  return TimeText;
}
