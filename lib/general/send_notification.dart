import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

Future<bool> sendNotification(
    {required String title,
    required String body,
    String? image,
    required String token,
    required String requestType}) async {
  developer.log('Sending notification');
  var url =
      'https://us-central1-autoshare-2023a.cloudfunctions.net/sendNotificationToToken';
  var response = await http.post(Uri.parse(url), body: <String, dynamic>{
    "title": title,
    "body": body,
    "image": image ?? '',
    "tokens": token,
    "request_type": requestType,
  });
  developer.log(response.body.toString());
  return (response.body == 'success');
}
