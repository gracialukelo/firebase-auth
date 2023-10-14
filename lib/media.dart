import 'package:anmeldung/firestore_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MediePage extends StatefulWidget {
  const MediePage({Key? key});

  @override
  State<MediePage> createState() => _MediePageState();
}

class _MediePageState extends State<MediePage> {
  List<Post>? posts;
  bool isLoaded = false;
  String imageFile = "";

  @override
  void initState() {
    super.initState();
    getData();
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Post>?> fetchPosts() async {
    try {
      final QuerySnapshot response = await firestore.collection("Post").get();
      final List<Map<String, dynamic>> rawData = response.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      final List<Post> loadedPosts =
          rawData.map((data) => Post.fromJson(data)).toList();
      return loadedPosts;
    } catch (error) {
      debugPrint("Fehler beim Datenabruf: $error");
      return null;
    }
  }

  Future<void> getData() async {
    final loadedPosts = await fetchPosts();
    final imageFiley = await getDownloadURL("omba app-icon.png"); // Ändere den Dateinamen hier entsprechend

    if (loadedPosts != null) {
      setState(() {
        posts = loadedPosts;
        isLoaded = true;
        imageFile = imageFiley;
      });
    }
  }

  Future<String> getDownloadURL(String fileName) async {
    try {
      return await FirebaseStorage.instance.ref().child(fileName).getDownloadURL();
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello World!"),
      ),
      body: Visibility(
        visible: isLoaded,
        replacement: const Center(
          child: CircularProgressIndicator(),
        ),
        child: ListView.builder(
          itemCount: posts?.length ?? 0,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(imageFile), // Verwende NetworkImage
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          posts![index].title ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          posts![index].body ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
