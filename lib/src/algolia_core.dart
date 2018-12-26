import 'dart:core';

class AlgoliaCore {
  String appId;
  final String _apiKey;
  Map<String, List<Uri>> hosts = {"read": [], "write": []};

  AlgoliaCore(this.appId, this._apiKey) {
    List<Uri> defaultHosts = _shuffleHosts();
    String dsn = appId + "-dsn.algolia.net";
    String base = appId + ".algolia.net";
    hosts['read'] = [Uri(scheme: 'https', host: dsn)]..addAll(defaultHosts);
    hosts['write'] = [Uri(scheme: 'https', host: base)]..addAll(defaultHosts);
  }

  List<Uri> _shuffleHosts() {
    var num = [1, 2, 3];
    List<Uri> defaultHosts = [];
    num.shuffle();

    num.forEach((n) {
      String host = appId + "-${n.toString()}.algolianet.com";
      defaultHosts.add(Uri(scheme: "https", host: host));
    });

    return defaultHosts;
  }

  Uri getReadHost({int n}) {
    if (n == null) return hosts['read'].first;
    return hosts['read'].elementAt(n);
  }

  Uri getWriteHost({int n}) {
    if (n == null) return hosts['write'].first;
    return hosts['write'].elementAt(n);
  }

  Uri getUri(String type, urlPath, {Map<String, dynamic> queryParameters}) {
    var _uri = hosts[type].first;

    Uri uri = Uri(
        scheme: _uri.scheme,
        host: _uri.host,
        path: urlPath,
        queryParameters: queryParameters);
    return uri;
  }
}
