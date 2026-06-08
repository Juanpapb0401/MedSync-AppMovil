import '../model/daily_summary_model.dart';
import '../repo/dashboard_repo.dart';

class GetDailySummaryUsecase {
  final DashboardRepo _repo;

  GetDailySummaryUsecase(this._repo);

  Future<DailySummaryModel> execute(DateTime date) =>
      _repo.getDailySummary(date);
}
