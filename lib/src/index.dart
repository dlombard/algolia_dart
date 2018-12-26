import 'client.dart';
import 'dart:core';
import 'abstract_api.dart';
import 'package:dio/dio.dart';

class Index extends AbstractApi {
  final String indexName;
  final Algolia client;

  Index(this.indexName, appId, apiKey, this.client)
      : super(appId, apiKey, client);

  Future<Map<String, dynamic>> search(Map<String, dynamic> query,
      {Map<String, dynamic> options}) async {
    String path = "1/indexes/" + indexName + "/query";

    //Uri uri = client.getUri('read', path);

    Response r = await postRequest(path, query);
    return r.data;
  }

  Future<Map<String, dynamic>> searchForFacetValues(
      String facetName, String text,
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
    Response r = await postRequest(path, q);
    return r.data;
  }

  Future<Map<String, dynamic>> browse(
      {Map<String, dynamic> query, String cursor}) async {
    Map<String, dynamic> q = new Map();
    if (query != null) {
      Uri u = Uri(queryParameters: query);
      q['params'] = u.query;
    }
    if (cursor != null) {
      q['cursor'] = cursor;
    }
    String path = "1/indexes/" + indexName + "/browse";
    Response r = await postRequest(path, q);
    return r.data;
  }

  Future<Map<String, dynamic>> getObject(String objectId,
      {List<String> attributesToRetrieve}) async {
    String path = "1/indexes/" + indexName + "/" + objectId;
    Map<String, dynamic> queryParameters = Map<String, dynamic>();
    if (attributesToRetrieve != null)
      queryParameters.addAll({"attributesToRetrieve": attributesToRetrieve});
    Uri u = Uri(queryParameters: queryParameters, path: path);

    Response r = await getRequest(u.toString());
    return r.data;
  }

  Future<Map<String, dynamic>> addObject(Map<String, dynamic> object,
      {String objectId}) async {
    Response r;
    String path = "1/indexes/" + indexName;
    if (objectId != null) {
      path += "/" + objectId;
      r = await putRequest(path, object);
      return r.data;
    }
    r = await postRequest(path, object);
    return r.data;
  }

  Future<Map<String, dynamic>> addObjects(List<Map<String, dynamic>> objects,
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
    Response r = await _batch(array);
    return r.data;
  }

  Future<Map<String, dynamic>> deleteObject(String objectId) async {
    String path = "1/indexes/" + indexName + "/" + objectId;
    Response r = await deleteRequest(path);
    return r.data;
  }

  Future<Map<String, dynamic>> deleteBy(Map<String, dynamic> query) async {
    Map<String, dynamic> q = Map();

    Uri u = Uri(queryParameters: query);
    q['params'] = u.query;

    String path = "1/indexes/" + indexName + "/deleteByQuery";
    Response r = await postRequest(path, q);
    return r.data;
  }

  Future<Map<String, dynamic>> clearIndex() async {
    String path = "1/indexes/" + indexName + "/clear";
    Response r = await postRequest(path, null);
    return r.data;
  }

  Future<Map<String, dynamic>> partialUpdateObject(
      Map<String, dynamic> partialObject, String objectId,
      {bool createIfNotExists: false}) async {
    String path = "1/indexes/" + indexName + "/" + objectId + "/partial";

    Response r = await postRequest(path, partialObject);
    return r.data;
  }

  Future<dynamic> _batch(List<Map<String, dynamic>> actions) async {
    String path = "/1/indexes/" + indexName + "/batch";
    //Uri uri = client.getUri('write', path);
    Map<String, dynamic> requests = {"requests": actions};
    return await postRequest(path, requests);
  }

  Future<Map<String, dynamic>> getSettings() async {
    String path = "1/indexes" + indexName + "/services";
    Response r = await getRequest(path);
    return r.data;
  }

  Future<Map<String, dynamic>> setSettings(Map<String, dynamic> settings,
      {bool forwardToReplicas}) async {
    String path = "1/indexes" + indexName + "/services";
    Map<String, dynamic> queryParameters =
        forwardToReplicas ? {'forwardToReplicas': true} : null;
    Uri uri = client.getUri('write', path, queryParameters: queryParameters);
    Response r = await putRequest(uri.path, settings);
    return r.data;
  }
}
