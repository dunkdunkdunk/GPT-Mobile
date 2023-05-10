import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}

class FirstRoute extends StatefulWidget {
  const FirstRoute();

  _FirstRoute createState() => _FirstRoute();
}

class _FirstRoute extends State<FirstRoute> {
  String _text;

  final SpeechToText _speech = SpeechToText();
  Future<void> _listen() async {
    if (!_speech.isAvailable) {
      print('Speech recognition is not available');
      return;
    }

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Row(children: [
              Text(
                "GPT-Mobile Clone (demo)",
              ),
              Spacer(),
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SecondRoute()));
                  }),
            ]),
            backgroundColor: Colors.green[700],
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(8))),
            toolbarHeight: 50,
          ),
          backgroundColor: Colors.grey[900],
          body: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Ask anything!",
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: _listen,
                  icon: Icon(Icons.mic),
                  label: Text(''),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24.0),
                      ),
                    ),
                    side: BorderSide(width: 2.0, color: Colors.white),
                    primary: Colors.green[700],
                    onPrimary: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 120, vertical: 8.0),
                    elevation: 4.0,
                  ),
                ),
              ]))),
    );
  }
}

class SecondRoute extends StatefulWidget {
  const SecondRoute();

  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  String _apiKey = '';
  bool _loading = false;
  bool _valid = false;

  Future<void> _submitApiKey(String apiKey) async {
    setState(() {
      _loading = true;
    });

    final url = Uri.parse('https://api.openai.com/v1/models');
    final headers = {'Authorization': 'Bearer $apiKey'};
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < Duration(seconds: 10)) {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          _valid = true;
        });
        print('API key is valid!');
        return;
      }
      await Future.delayed(Duration(seconds: 1));
    }

    setState(() {
      _loading = false;
      _valid = false;
    });
    print('API key is invalid or the server is not responding.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GPT-Mobile Clone (demo)"),
        backgroundColor: Colors.green[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        toolbarHeight: 50,
      ),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "OpenAI API Key",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: _valid
                      ? BorderSide(color: Colors.green[700])
                      : BorderSide(color: Colors.red[600]),
                ),
                suffixIcon: Icon(
                  _valid ? Icons.check : Icons.clear,
                  color: _valid ? Colors.green[700] : Colors.red[600],
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) => _onApiKeyChanged(value),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _submitApiKey(_apiKey),
              child: Text(
                "Submit",
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green[700],
                onPrimary: Colors.white,
              ),
            ),
            if (_loading)
              SizedBox(
                  height: 100.0,
                  width: 100.0,
                  child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  void _onApiKeyChanged(String value) {
    setState(() {
      _apiKey = value;
    });
  }
}
