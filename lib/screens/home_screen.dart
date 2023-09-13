import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

import '../models/wallpapers_model.dart';
import '../secrets/secrets.dart';
import 'full_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  String search = "nature";

  Future<WallpapersData> getData() async {
    final responce = await http.get(Uri.parse(
        "https://pixabay.com/api/?key=$apiKey&q=$search&image_type=photo&orientation=vertical&per_page=200"));

    if (responce.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(responce.body);
      final WallpapersData wallpapersData = WallpapersData.fromJson(jsonData);
      return wallpapersData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        actions: [
          Expanded(
              child: Container(
            margin: const EdgeInsets.all(4),
            child: TextField(
              controller: searchController,
              onSubmitted: (value) async {
                setState(() {
                  search = value;
                });
                await getData();
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade400,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                hintText: " Search images",
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: IconButton(
                  onPressed: () async {
                    setState(() {
                      search = searchController.text;
                    });
                    await getData();
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: FutureBuilder<WallpapersData>(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error.toString()}',
                ),
              );
            } else if (snapshot.hasData) {
              final WallpapersData user = snapshot.data!;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: user.hits.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenWallpaper(
                              hits: user.hits,
                              index: index,
                            ),
                          ));
                    },
                    child: Hero(
                      tag: 'tag_${user.hits[index].id}',
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 8,
                          bottom: 8,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: user.hits[index].previewUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text(
                  'No data available',
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
