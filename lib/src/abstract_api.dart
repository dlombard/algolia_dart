//import 'package:http/http.dart';
import 'dart:convert';
import 'algolia_exception.dart';
import 'package:dio/dio.dart';
import 'client.dart';

abstract class AbstractApi {
  Dio _client;
  final Algolia algoliaClient;
  final String _apiKey;
  final String appId;
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "charset": "UTF-8"
  };

  AbstractApi(this.appId, this._apiKey, this.algoliaClient) {
    headers.addAll({
      "Accept-Encoding": "gzip",
      "X-Algolia-Application-Id": appId,
      "X-Algolia-API-Key": _apiKey
    });

    Options options =
        Options(headers: headers, connectTimeout: 2000, receiveTimeout: 30000);

    _client = Dio(options);
    _client.interceptor.request.onSend = (Options options) {
      print('send request：path:${options.path}，baseURL:${options.baseUrl}');
      // Do something before request is sent

      return options; //continue
      // If you want to resolve the request with some custom data，
      // you can return a `Response` object or return `dio.resolve(data)`.
      // If you want to reject the request with a error message,
      // you can return a `DioError` object or return `dio.reject(errMsg)`
    };
  }

  Future<dynamic> getRequest(String path, {Map<String, dynamic> json}) =>
      send('GET', path, json: json);
  Future<dynamic> deleteRequest(String path) => send('DELETE', path);
  Future<dynamic> postRequest(String path, dynamic data) =>
      send('POST', path, json: data);
  Future<dynamic> putRequest(String path, dynamic data) =>
      send('PUT', path, json: data);

  /*Future<Response> send(String method, Uri uri, {dynamic json}) async {
    Request request = Request(method, uri);
    request.headers["X-Algolia-Application-Id"] = appId;
    request.headers["X-Algolia-API-Key"] = _apiKey;

    if (json != null) {
      request.body = jsonEncode(json);
    }
    StreamedResponse streamedResponse = await _client.send(request);
    Response response = await Response.fromStream(streamedResponse);

    Object body = jsonDecode(response.body);
    if (response.statusCode / 100 == 4) {
      if (body is Map)
        throw AlgoliaException(body['message'].toString(), response.statusCode);
      throw AlgoliaException(body.toString(), response.statusCode);
    }
    return response;
  }*/

  Future<Response> send(String method, String path,
      {Map<String, dynamic> json}) async {
    List<String> errors = List<String>();

    List<Uri> hosts = algoliaClient.hosts['write'];
    if (method == 'GET') hosts = algoliaClient.hosts['read'];
    for (Uri host in hosts) {
      Response response;
      String baseUrl;
      Options o;

      if (!path.startsWith("/")) path = "/" + path;
      baseUrl = host.toString();
      o = new Options(baseUrl: baseUrl, method: method);

      try {
        response =
            await _client.request(path, data: jsonEncode(json), options: o);
        return response;
      } on DioError catch (dioError) {
        if (dioError.response != null) {
          errors.add(
              AlgoliaNetworkException(dioError.message, data: dioError.response.data)
                  .toString());
          continue;
        }
        throw AlgoliaNetworkException(dioError.message.toString());
      }
    }
    String errorMessage = "All hosts failed: " + errors.toString();
    throw AlgoliaNetworkException(errorMessage);
  }
}
