import 'algolia_core.dart';
import 'index.dart';

class Algolia extends AlgoliaCore {
  String appId;
  final String _apiKey;
  String version = "0.0.1";
  Map<String, Index> indices = Map();
  AlgoliaCore _core;

  /// Creates an Algolia Client
  Algolia(this.appId, this._apiKey) : super(appId, _apiKey) {
    _core = new AlgoliaCore(appId, _apiKey);
  }

  Map<String, List<Uri>> getHosts() {
    return _core.hosts;
  }

  /// Initializes an index object
  Index initIndex(String name) {
    return new Index(name, appId, _apiKey, this);
  }

  /// Returns a cached index
  /// If the index does not exist, it will create a new one
  Index getIndex(String name) {
    if (indices.containsKey(name)) {
      return indices[name];
    } else {
      Index index = initIndex(name);
      indices[name] = index;
      return index;
    }
  }
}
