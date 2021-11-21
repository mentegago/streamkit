abstract class StreamKitModule {
  Stream<ModuleState> get state;

  void dispose() {}
}

enum ModuleState { active, inactive, loading }
