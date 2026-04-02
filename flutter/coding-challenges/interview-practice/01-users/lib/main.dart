import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ❌ Everything in one file. No separation. This is what you must refactor.

void main() => runApp(const MaterialApp(home: UsersScreen()));

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String companyName;
  final String city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      companyName: json['company']['name'],
      city: json['address']['city'],
    );
  }
}

// ❌ Algorithm stub — implement this
Map<String, List<User>> groupByCompany(List<User> users) {
  return {};
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // ❌ Network logic inside the widget — should be in a repository
  Future<void> _fetchUsers() async {
    setState(() { isLoading = true; error = null; });
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          users = data.map((json) => User.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() { error = 'Status ${response.statusCode}'; isLoading = false; });
      }
    } catch (e) {
      setState(() { error = e.toString(); isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUsers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchUsers,
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(user.name[0])),
                        title: Text(user.name),
                        subtitle: Text('${user.email}\n${user.companyName} · ${user.city}'),
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
    );
  }
}
