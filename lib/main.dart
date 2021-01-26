import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_caching/constants.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: kImageUrls.length,
        itemBuilder: (_, index) => ListImage(index),
      ),
    );
  }
}

class ListImage extends StatelessWidget {
  const ListImage(this.index);

  final int index;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: width,
      child: FutureBuilder(
        future: _getCachedImage(index, width.toInt()),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );

          if (snapshot.hasError)
            return Center(
              child: Text('Error while loading image with index $index'),
            );

          return FittedBox(
            child: Image.file(snapshot.data),
            fit: BoxFit.fill,
          );
        },
      ),
    );
  }

  Future<File> _getCachedImage(int index, int minSize) async {
    final temp = await getTemporaryDirectory();
    final imageFile = File('${temp.path}/images/$index');
    if (imageFile.existsSync()) return imageFile; // return if exists

    final response = await http.get(kImageUrls[index]);
    if (response.statusCode == 200) {
      final compressedImageBytes = await FlutterImageCompress.compressWithList(
        response.bodyBytes,
        minHeight: minSize,
        minWidth: minSize,
        quality: 70,
      );
      await imageFile.create(recursive: true);
      await imageFile.writeAsBytes(compressedImageBytes);
      return imageFile;
    } else {
      throw Exception();
    }
  }
}
