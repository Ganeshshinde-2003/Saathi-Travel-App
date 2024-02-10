import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Page'),
        backgroundColor: const Color(0xFFFFFDF4),
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFFFFDF4),
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 20,
        ),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Users',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFFDFBD43),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFDFBD43),
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFDFBD43),
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFDFBD43),
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: searchResults.isNotEmpty
                  ? ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFDFBD43),
                                width: 2.0,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(
                                  searchResults[index]['profilePicUrl']),
                            ),
                          ),
                          title: Text(searchResults[index]['displayName']),
                          subtitle: Text(searchResults[index]['email']),
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/search.png',
                      width: 400,
                      fit: BoxFit.contain,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) async {
    if (query.isNotEmpty) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> allUsers = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return doc.data();
      }).toList();

      List<Map<String, dynamic>> results = allUsers
          .where((user) => user['displayName']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      setState(() {
        searchResults = results;
      });
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }
}
