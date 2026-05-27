import '../../domain/repo/get_linking_code_repo.dart';
import '../sources/get_linking_code_data_source.dart';

class GetLinkingCodeRepoImpl implements GetLinkingCodeRepo {
  final GetLinkingCodeDataSource _dataSource;

  GetLinkingCodeRepoImpl(this._dataSource);

  @override
  Future<String> execute() => _dataSource.execute();
}