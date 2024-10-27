enum ComposerStatus { inactive, loading, active }

abstract class ComposerService {
  Stream<ComposerStatus> getStatusStream();
  Stream<String> getErrorStream();
}
