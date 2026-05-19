import '../model/daily_summary_model.dart';
import '../repo/dashboard_repo.dart';
import '../../data/repo/dashboard_repo_impl.dart';

class GetDailySummaryUsecase {
  final DashboardRepo _repo = DashboardRepoImpl();

  Future<DailySummaryModel> execute(DateTime date) =>
      _repo.getDailySummary(date);
}
