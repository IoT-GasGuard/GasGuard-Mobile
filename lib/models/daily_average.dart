class DailyAverage {
  final DateTime date;
  final double average;
  
  DailyAverage({
    required this.date,
    required this.average,
  });
  
  String getFormattedDate() {
    return '${date.day}-${date.month}-${date.year}';
  }
}