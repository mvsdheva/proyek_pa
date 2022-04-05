import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiServices {
  int timeout = 10;
  String baseUrl = dotenv.env['API_URL'] ?? 'notfound';

  Future<dynamic> forgetPassword(
    String email,
  ) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/guest/password/reset-request'), body: {
        "email": email,
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> postLogin(String email, String password) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/authentication/login'), body: {
        "email": email,
        "password": password,
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        var res = jsonDecode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<String> postLoginWithGoole(String email, String name) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/authentication/login/google'), body: {
        "name": name,
        "email": email,
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        var res = jsonDecode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<String> logoutLogin(String token) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/authentication/logout'), headers: {
        'Authorization': 'Bearer $token'
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<String?> registerPublicUser(String name, String email, String password,
      String passwordConfimation, String noTelp, String address) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/register'), body: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfimation,
        "no_telephone": noTelp,
        "address": address,
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        var res = jsonDecode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> getItems(String token, String find) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/administrator/items?filter[name]=' +
              find +
              '&include=dataApotek'),
          headers: {
            'Authorization': 'Bearer $token'
          }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> getUnits(
    String token,
  ) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/guest/item/unit'),
          headers: {
            'Authorization': 'Bearer $token'
          }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> createItems(
      String token,
      String name,
      String price,
      String stock,
      String unit,
      String description,
      String image,
      String idApotek) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/administrator/items'), body: {
        "name": name,
        "price": price,
        "stock": stock,
        "unit": unit,
        "description": description,
        "image": image,
        "apotek_id": idApotek,
      }, headers: {
        'Authorization': 'Bearer $token'
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> updateItems(
      String token,
      String id,
      String name,
      String price,
      String stock,
      String unit,
      String description,
      String image,
      String idApotek) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/administrator/items/update'), body: {
        "id": id,
        "name": name,
        "price": price,
        "stock": stock,
        "unit": unit,
        "description": description,
        "image": image,
        "apotek_id": idApotek,
      }, headers: {
        'Authorization': 'Bearer $token'
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> deleteItems(
    String token,
    String id,
  ) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/administrator/items/delete'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token'
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> getItemsPublic(String token, String id, String find) async {
    try {
      if (token != "") {
        final response = await http.get(
            Uri.parse('$baseUrl/users/item/group?filter[id]=' +
                id +
                '&include=likers,units,createdBy,dataApotek&filter[name]=' +
                find),
            headers: {
              'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: timeout));
        //
        if (response.statusCode == 200) {
          var res = json.decode(response.body);
          return res;
        } else {
          var res = json.decode(response.body);
          return Future.error(res['message']);
        }
      } else {
        final response = await http
            .get(
              Uri.parse('$baseUrl/guest/item/group?filter[id]=' +
                  id +
                  'filter[name]=' +
                  find),
            )
            .timeout(Duration(seconds: timeout));
        if (response.statusCode == 200) {
          var res = json.decode(response.body);
          return res;
        } else {
          var res = json.decode(response.body);
          return Future.error(res['message']);
        }
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> getCart(String token) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/users/cart'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> setCart(String token, data) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/users/cart'), body: {
        "data": data,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> getAddress(
    String token,
  ) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/users/address'), headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> createAddress(String token, String postalCode, String address,
      String description) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/address'), body: {
        "address": address,
        "postal_code": postalCode,
        "description": description,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> updateAddress(String token, String id, String postalCode,
      String address, String description) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/address/update'), body: {
        "id": id,
        "address": address,
        "postal_code": postalCode,
        "description": description,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> deleteAddress(
    String token,
    String id,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/address/delete'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> createTransaction(String token, String cartId, String method,
      String deliveryAddressId) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/transaction'), body: {
        "cart_id": cartId,
        "method": method,
        "delivery_address_id": deliveryAddressId,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> getTransaction(
    String token,
  ) async {
    try {
      final response = await http.get(
          Uri.parse(
              '$baseUrl/users/transaction?include=dataCart&sort=-created_at'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json;charset=UTF-8',
              'Charset': 'utf-8'
          }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> getTransactionAdmin(
    String token,
  ) async {
    try {
      final response = await http.get(
          Uri.parse(
              '$baseUrl/administrator/transaction?include=dataUser,dataCart&sort=-created_at'),
          headers: {
            'Authorization': 'Bearer $token',
          }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> uploadTransaction(
    String token,
    String idTransaction,
    String image,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/transaction/proof'), body: {
        "id": idTransaction,
        "image": image,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> switchStatusTransaction(
    String token,
    String id,
    String idStatus,
  ) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/administrator/transaction/status'), body: {
        "id": id,
        "status": idStatus,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> getProfileUser(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json;charset=UTF-8',
              'Charset': 'utf-8'
          }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> addImageProfileUser(
    String token,
    String image,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/profile/image'), body: {
        "image": image,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> updateProfileUser(
    String token,
    String id,
    String name,
    String email,
    String noTelephone,
    String address,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/profile/update'), body: {
        "id": id,
        "name": name,
        "email": email,
        "no_telephone": noTelephone,
        "address": address,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> getRadioAdmin(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/administrator/radio'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json;charset=UTF-8',
              'Charset': 'utf-8'
          }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> addRadio(
    String token,
    String name,
    String linkRadio,
    String channel,
    String image,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/administrator/radio'), body: {
        "name": name,
        "link_stream": linkRadio,
        "channel": channel,
        "image": image,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> updateRadio(
    String token,
    String id,
    String name,
    String linkRadio,
    String channel,
    String image,
  ) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/administrator/radio/update'), body: {
        "id": id,
        "name": name,
        "link_stream": linkRadio,
        "channel": channel,
        "image": image,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> deleteRadio(
    String token,
    String id,
  ) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/administrator/radio/delete'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> getRadioUser(String token) async {
    try {
      if (token != "") {
        final response = await http.get(Uri.parse("$baseUrl/users/radio"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json;charset=UTF-8',
              'Charset': 'utf-8'
            }).timeout(Duration(seconds: timeout));
        if (response.statusCode == 200) {
          var res = json.decode(response.body);
          return res;
        } else {
          var res = json.decode(response.body);
          return Future.error(res['message']);
        }
      } else {
        final response = await http
            .get(
              Uri.parse("$baseUrl/guest/radio"),
            )
            .timeout(Duration(seconds: timeout));
        if (response.statusCode == 200) {
          var res = json.decode(response.body);
          return res;
        } else {
          var res = json.decode(response.body);
          return Future.error(res['message']);
        }
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> addLikeItem(
    String token,
    String id,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/like/item'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> removeLikeItem(
    String token,
    String id,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/unlike/item'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> addLikeNews(
    String token,
    String id,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/like/news'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> removeLikeNews(
    String token,
    String id,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/unlike/news'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> addLikeRadio(
    String token,
    String id,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/like/radio'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> removeLikeRadio(
    String token,
    String id,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/users/unlike/radio'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> getWish(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/like/wish'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json;charset=UTF-8',
              'Charset': 'utf-8'
          }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> getNewsAdmin(String token) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/administrator/news?sort=-created_at'),
          headers: {
            'Authorization': 'Bearer $token',
          }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> addNews(
    String token,
    String title,
    String author,
    String description,
    String image,
    String category,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/administrator/news'), body: {
        "title": title,
        "author": author,
        "description": description,
        "image": image,
        "category": category,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> updateNews(
    String token,
    String id,
    String title,
    String author,
    String description,
    String image,
    String category,
  ) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/administrator/news/update'), body: {
        "id": id,
        "title": title,
        "author": author,
        "description": description,
        "image": image,
        "category": category,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> deleteNews(
    String token,
    String id,
  ) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/administrator/news/delete'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> getNewsUser(String token, String category) async {
    try {
      if (token != "") {
        final response = await http.get(
            Uri.parse("$baseUrl/users/news?sort=-created_at&filter[category]=" +
                category),
            headers: {
              'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: timeout));
        if (response.statusCode == 200) {
          var res = json.decode(response.body);
          return res;
        } else {
          var res = json.decode(response.body);
          return Future.error(res['message']);
        }
      } else {
        final response = await http
            .get(
              Uri.parse(
                  '$baseUrl/guest/news?sort=-created_at&filter[category]=' +
                      category),
            )
            .timeout(Duration(seconds: timeout));
        if (response.statusCode == 200) {
          var res = json.decode(response.body);
          return res;
        } else {
          var res = json.decode(response.body);
          return Future.error(res['message']);
        }
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> getApotekAdmin(String token) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/administrator/apotek'), headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }

  Future<dynamic> addApotek(
    String token,
    String name,
    String city,
    String linkAddress,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/administrator/apotek'), body: {
        "name": name,
        "city": city,
        "link_address": linkAddress,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> updateApotek(
    String token,
    String id,
    String name,
    String city,
    String linkAddress,
  ) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/administrator/apotek/update'), body: {
        "id": id,
        "name": name,
        "city": city,
        "link_address": linkAddress,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> deleteApotek(
    String token,
    String id,
  ) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/administrator/apotek/delete'), body: {
        "id": id,
      }, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi:${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout:${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error:${e.toString()}');
    }
  }

  Future<dynamic> getGeneralData() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/users/general-settings"),
          )
          .timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res;
      } else {
        var res = json.decode(response.body);
        return Future.error(res['message']);
      }
    } on SocketException catch (e) {
      return Future.error('Tidak ada koneksi: ${e.toString()}');
    } on TimeoutException catch (e) {
      return Future.error('Request Timeout: ${e.toString()}');
    } on Error catch (e) {
      return Future.error('General Error: ${e.toString()}');
    }
  }
}
