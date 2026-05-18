import '../model/daily_summary_model.dart';

abstract class DashboardRepo {
  Future<DailySummaryModel> getDailySummary(DateTime date);
}
