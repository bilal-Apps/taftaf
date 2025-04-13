import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  String? _token;
  int? _userId;

  String? get token => _token;
  int? get userId => _userId;

  Future<String?> _getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(tokenKey);
    _userId = prefs.getInt(userIdKey);
    return _token;
  }

  Future<void> _saveToken(String token, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setInt(userIdKey, userId);
    _token = token;
    _userId = userId;
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    _token = null;
    _userId = null;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token'], data['user_id']);
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur de connexion: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final token = await _getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout/'),
          headers: await _getHeaders(),
        );
      }
    } finally {
      await _removeToken();
    }
  }

  Future<List<Schedule>> getSchedules() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedules/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Schedule.fromJson(json)).toList();
      }
      throw Exception('Échec du chargement des horaires');
    } catch (e) {
      print('Erreur lors de la récupération des horaires: $e');
      return [];
    }
  }

  Future<Schedule> getSchedule(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedules/$id/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Schedule.fromJson(jsonDecode(response.body));
      }
      throw Exception('Échec du chargement de l\'horaire');
    } catch (e) {
      print('Erreur lors de la récupération de l\'horaire: $e');
      rethrow;
    }
  }

  Future<Schedule> createSchedule(Schedule schedule) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedules/'),
        headers: await _getHeaders(),
        body: jsonEncode(schedule.toJson()),
      );

      if (response.statusCode == 201) {
        return Schedule.fromJson(jsonDecode(response.body));
      }
      throw Exception('Échec de la création de l\'horaire');
    } catch (e) {
      print('Erreur lors de la création de l\'horaire: $e');
      rethrow;
    }
  }

  Future<Schedule> updateSchedule(Schedule schedule) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/schedules/${schedule.id}/'),
        headers: await _getHeaders(),
        body: jsonEncode(schedule.toJson()),
      );

      if (response.statusCode == 200) {
        return Schedule.fromJson(jsonDecode(response.body));
      }
      throw Exception('Échec de la mise à jour de l\'horaire');
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'horaire: $e');
      rethrow;
    }
  }

  Future<void> deleteSchedule(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/schedules/$id/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 204) {
        throw Exception('Échec de la suppression de l\'horaire');
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'horaire: $e');
      rethrow;
    }
  }

  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedules/by-date/${date.toIso8601String().split('T')[0]}/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Schedule.fromJson(json)).toList();
      }
      throw Exception('Échec du chargement des horaires pour cette date');
    } catch (e) {
      print('Erreur lors de la récupération des horaires par date: $e');
      return [];
    }
  }

  Future<List<Schedule>> getSchedulesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedules/by-category/$category/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Schedule.fromJson(json)).toList();
      }
      throw Exception('Échec du chargement des horaires pour cette catégorie');
    } catch (e) {
      print('Erreur lors de la récupération des horaires par catégorie: $e');
      return [];
    }
  }

  Future<void> toggleScheduleCompletion(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedules/$id/toggle-completion/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Échec de la modification du statut de l\'horaire');
      }
    } catch (e) {
      print('Erreur lors de la modification du statut de l\'horaire: $e');
      rethrow;
    }
  }
} 