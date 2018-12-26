import 'client.dart';
import 'dart:core';
import 'abstract_api.dart';

class Index extends AbstractApi {
  final String indexName;
  final Algolia client;

  Index(this.indexName, appId, apiKey, this.client)
      : super(appId, apiKey, client);

  Future<dynamic> search(Map<String, dynamic> query,
      {Map<String, dynamic> options}) async {
    String path = "1/indexes/" + indexName + "/query";

    //Uri uri = client.getUri('read', path);

    return await postRequest(path, query);
  }

  Future<dynamic> searchForFacetValues(String facetName, String text,
      {Map<String, dynamic> query, int maxFacetHits}) async {
    Map<String, dynamic> q = new Map();
    if (query != null) {
      Uri u = Uri(queryParameters: query);
      print(u.query);
      q['params'] = u.query;
    }
    if (maxFacetHits != null) {
      q['maxFacetHits'] = maxFacetHits;
    }
    q["facetQuery"] = text;
    String path = "1/indexes/" + indexName + "/facets/" + facetName + "/query";
    //Uri uri = client.getUri('read', path);
    return await postRequest(path, q);
  }

  Future<dynamic> browse({Map<String, dynamic> query, String cursor}) async {
    Map<String, dynamic> q = new Map();
    if (query != null) {
      Uri u = Uri(queryParameters: query);
      q['params'] = u.query;
    }
    if (cursor != null) {
      q['cursor'] = cursor;
    }
    String path = "1/indexes/" + indexName + "/browse";
    //Uri uri = client.getUri('read', path);
    return await postRequest(path, q);
  }

  Future<dynamic> getObject(String objectId,
      {List<String> attributesToRetrieve}) async {
    String path = "1/indexes/" + indexName + "/" + objectId;
    Map<String, dynamic> queryParameters = Map<String, dynamic>();
    if (attributesToRetrieve != null)
      queryParameters.addAll({"attributesToRetrieve": attributesToRetrieve});
    Uri u = Uri(queryParameters: queryParameters, path: path);
    // Uri uri = client.getUri('read', path, queryParameters: queryParameters);
    print(u.toString());
    return await getRequest(u.toString());
  }

  Future<dynamic> addObject(Map<String, dynamic> object,
      {String objectId}) async {
    String path = "1/indexes/" + indexName;
    if (objectId != null) {
      path += "/" + objectId;
      //Uri uri = client.getUri('write', path);
      return await putRequest(path, object);
    }
    // Uri uri = client.getUri('write', path);
    return await postRequest(path, object);
  }

  Future<dynamic> addObjects(List<Map<String, dynamic>> objects,
      {String objectId}) async {
    List<Map<String, dynamic>> array = List();
    for (Map<String, dynamic> obj in objects) {
      Map<String, dynamic> action = Map<String, dynamic>();
      action.addAll({"action": "addObject", "body": obj});
      //action['action'] = "addObject";
      //action['body'] = obj;
      print(action);
      array.add(action);
    }
    return await _batch(array);
  }

  Future<dynamic> deleteObject(String objectId) async {
    String path = "1/indexes/" + indexName + "/" + objectId;
    //Uri uri = client.getUri('write', path);
    return await deleteRequest(path);
  }

  Future<dynamic> deleteBy(Map<String, dynamic> query) async {
    Map<String, dynamic> q = Map();

    Uri u = Uri(queryParameters: query);
    q['params'] = u.query;

    String path = "1/indexes/" + indexName + "/deleteByQuery";
    // Uri uri = client.getUri('write', path);
    return await postRequest(path, q);
  }

  Future<dynamic> clearIndex() async {
    String path = "1/indexes/" + indexName + "/clear";
    //Uri uri = client.getUri('write', path);
    return await postRequest(path, null);
  }

  Future<dynamic> partialUpdateObject(
      Map<String, dynamic> partialObject, String objectId,
      {bool createIfNotExists: false}) async {
    String path = "1/indexes/" + indexName + "/" + objectId + "/partial";
    // Uri uri = client.getUri('write', path);
    return await postRequest(path, partialObject);
  }

  Future<dynamic> _batch(List<Map<String, dynamic>> actions) async {
    String path = "/1/indexes/" + indexName + "/batch";
    //Uri uri = client.getUri('write', path);
    Map<String, dynamic> requests = {"requests": actions};
    return await postRequest(path, requests);
  }

  Future<dynamic> getSettings() async {
    String path = "1/indexes" + indexName + "/services";
    // Uri uri = client.getUri('read', path);

    return await getRequest(path);
  }

  Future<dynamic> setSettings(Map<String, dynamic> settings,
      {bool forwardToReplicas}) async {
    String path = "1/indexes" + indexName + "/services";
    Map<String, dynamic> queryParameters =
        forwardToReplicas ? {'forwardToReplicas': true} : null;
    Uri uri = client.getUri('write', path, queryParameters: queryParameters);
    print(uri);
    return await putRequest(uri.path, settings);
  }
}
