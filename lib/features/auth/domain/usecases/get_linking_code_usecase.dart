import '../repo/get_linking_code_repo.dart';
import '../../data/repo/get_linking_code_repo_impl.dart';

class GetLinkingCodeUsecase {
  final GetLinkingCodeRepo _repo;

  GetLinkingCodeUsecase() : _repo = GetLinkingCodeRepoImpl();

  Future<String> execute() => _repo.execute();
}