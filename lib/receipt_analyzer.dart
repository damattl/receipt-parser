import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:developer' as dev;

Future<RecognizedText> processImage(InputImage inputImage) async {
  final textRecognizer = TextRecognizer();
  final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);



  String fullText = recognizedText.text;
  dev.log(fullText);
  dev.log(recognizedText.blocks.toString());

  textRecognizer.close();

  return recognizedText;
}


List<TextLine> restructureLines(RecognizedText recognizedText) {
  final blockLines = <TextLine>[];

  for (TextBlock block in recognizedText.blocks) {
    dev.log("Block: ${block.cornerPoints.toString()}");
    for (TextLine line in block.lines) {
      dev.log("Line: ${line.cornerPoints.toString()}");
      blockLines.add(line);
    }
  }

  blockLines.sort((a, b) => a.cornerPoints[0].y.compareTo(b.cornerPoints[0].y));
  dev.log(blockLines.map((e) => e.cornerPoints[0]).toString());

  final restructuredLines = <TextLine>[];

  TextLine? prevLine;
  TextLine? fullLine;
  for (TextLine line in blockLines) {
    if (prevLine == null) {
      fullLine = line;
      prevLine = line;
      continue;
    }
    fullLine ??= line;
    if (yDifference(prevLine, line) < 15) {
      fullLine.elements.addAll(line.elements);
      prevLine = line;
    } else {
      restructureLineElements(fullLine);
      restructuredLines.add(fullLine);
      fullLine = line;
      prevLine = line;
    }
  }

  return restructuredLines;
}

void restructureLineElements(TextLine line) {
  line.elements.sort((a, b) => a.cornerPoints[0].x.compareTo(b.cornerPoints[0].x));
}

num yDifference(TextLine prevLine, TextLine currentLine) {
  final topDiff = (prevLine.cornerPoints[0].y - currentLine.cornerPoints[0].y).abs();
  //final botDiff = (prevLine.cornerPoints[3].y - currentLine.cornerPoints[3].y).abs();

  return topDiff;
}

// TODO: Find out better threshold
// TOOD: Linear Transformation on the TextBoxes
