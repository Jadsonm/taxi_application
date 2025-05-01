import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SearchGooglePlaces extends StatefulWidget {
  const SearchGooglePlaces({super.key});

  @override
  State<SearchGooglePlaces> createState() => _SearchGooglePlacesState();
}

class _SearchGooglePlacesState extends State<SearchGooglePlaces> {
  final TextEditingController _searchController = TextEditingController();
  Uuid uuid = const Uuid();
  String sessiontoken = "";
  List<dynamic> placeList = [];
  void getSuggestions(String input) async {
    String googleApiKey = "AIzaSyByq2MCuDdwN-TmVrLKiAnNbEYQVqhsZyU";
    String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String request =
        "$baseUrl?input=$input&key=$googleApiKey&sessiontoken=$sessiontoken";

    var response = await http.get(Uri.parse(request));
    print(response.body.toString());

    if (response.statusCode == 200) {
      setState(() {
        placeList = jsonDecode(response.body.toString())["predictions"];
      });
    } else {
      throw Exception("Failed to load data");
    }
  }

  void onChange() {
    if (sessiontoken.isEmpty) {
      sessiontoken = uuid.v4();
    } else {
      getSuggestions(_searchController.text);
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () {
        onChange();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escolha seu destino"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                  hintText: "Exemplo: Facens", border: OutlineInputBorder()),
            ),
            Expanded(
                child: ListView.builder(
              itemCount: placeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    List<Location> locations = await locationFromAddress(
                        placeList[index]["description"]);
                        double latitude = locations.last.latitude;
                        double longitude = locations.last.longitude;
                        print(locations.last.latitude);
                        print(locations.last.longitude);
                        Navigator.pop(context, {'latitude': latitude, 'longitude': longitude});
                  },
                  title: Text(placeList[index]["description"]),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
