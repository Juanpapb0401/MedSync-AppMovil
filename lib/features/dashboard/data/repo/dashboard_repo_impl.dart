import '../../domain/model/daily_summary_model.dart';
import '../../domain/repo/dashboard_repo.dart';
import '../sources/dashboard_data_source.dart';

class DashboardRepoImpl implements DashboardRepo {
  final _source = DashboardDataSource();

  @override
  Future<DailySummaryModel> getDailySummary(DateTime date) =>
      _source.getDailySummary(date);
}
