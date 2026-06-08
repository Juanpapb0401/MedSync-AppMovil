import '../repo/get_linking_code_repo.dart';

class GetLinkingCodeUsecase {
  final GetLinkingCodeRepo _repo;

  GetLinkingCodeUsecase(this._repo);

  Future<String> execute() => _repo.execute();
}