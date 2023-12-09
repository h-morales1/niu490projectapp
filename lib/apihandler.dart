import 'package:dio/dio.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ApiHandler {
  String? baseUrl; // server ip: http://xxx.xxx.x.xx:PORT
  final dio = Dio();

  //setters
  void setBaseUrl(String url) {
    baseUrl = url;
  }

  /*
    GET: just a test GET request to /train/app
   */
  void getHttp() async {
    //final response = await dio.get('http://192.168.4.27:4567/train/app');
    final response = await dio.get('$baseUrl/train/app'); // combine baseUrl with specified path
    print(response);
  }

  /*
    POST: posts vector_size, epochs, ai_training(zip), human_training(zip)
   */
  void trainModel(int vectorSize, int epochs, File aiTraining, File humanTraining) async {
    String aiName = aiTraining.path.split('/').last; // file name for ai zip file
    String huName = humanTraining.path.split('/').last; // file name for human zip file

    // piece together formdata to post vector_size, epochs, ai_training zip, human_training zip
    final formData = FormData.fromMap({
      'vector_size': vectorSize,
      'epochs': epochs,
      'ai_training': await MultipartFile.fromFile(aiTraining.path, filename: aiName, contentType: MediaType("application/zip", "application/octet-stream")),
      'human_training': await MultipartFile.fromFile(humanTraining.path, filename: huName ,contentType: MediaType("application/zip", "application/octet-stream"))
    });

    final response = await dio.post('$baseUrl/train/app', data: formData); // post request to baseurl+specified path
    print(response);
  }

  /*
    POST: posts test file for testing against model
   */
  void testModel(File testFile) async {
    String fileName = testFile.path.split('/').last; // get file name for test doc

    // piece together formdata to post test file to server for testing
    final formData = FormData.fromMap({
      'test_file': await MultipartFile.fromFile(testFile.path, filename: fileName, contentType: MediaType("application/zip", "application/octet-stream"))
    });

    final response = await dio.post('$baseUrl/test/app', data: formData); // post request
    print(response);
  }
}