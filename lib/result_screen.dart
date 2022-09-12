import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:receipt_parser/receipt_analyzer.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key, required this.imagePath}) : super(key: key);

  final String imagePath;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {



  @override
  Widget build(BuildContext context) {
    final inputImage = InputImage.fromFilePath(widget.imagePath);

    return Scaffold(
      appBar: AppBar(title: const Text('Results'),),
      body: FutureBuilder<RecognizedText>(
        future: processImage(inputImage),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // If the Future is complete, display the preview.
            return buildResultList(snapshot.data!);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      )
    );
  }

  ListView buildResultList(RecognizedText recognizedText) {
    final resultList = <Widget>[];
    final lines = restructureLines(recognizedText);
    for (TextLine line in lines) {
      // Same getters as TextBlock
      final textView = Text(line.elements.map((e) => e.text).join(" | "));
      resultList.add(textView);
    }
    return ListView(children: resultList);
  }
}
