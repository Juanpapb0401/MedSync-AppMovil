import '../../domain/repo/get_linking_code_repo.dart';
import '../sources/get_linking_code_data_source.dart';

class GetLinkingCodeRepoImpl implements GetLinkingCodeRepo {
  final _dataSource = GetLinkingCodeDataSource();

  @override
  Future<String> execute() => _dataSource.execute();
}