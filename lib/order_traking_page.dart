import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:taxi_application/constants.dart';
import 'package:taxi_application/search_google_places.dart';
import 'ride_confirmation_sheet.dart';
import 'package:taxi_application/models/driver.dart';

List<Driver> drivers = [
  Driver(name: "João", plate: "HQ7-1478", carModel: "Gol"),
  Driver(name: "Maria", plate: "XYZ-5678", carModel: "Civic"),
  Driver(name: "Carlos", plate: "QWE-4321", carModel: "Palio"),
  Driver(name: "José", plate: "GUH-1354", carModel: "Kicks"),
  Driver(name: "Eduardo", plate: "XYZ-5678", carModel: "Pegeout 207"),
  Driver(name: "Emerson", plate: "LAH-9865", carModel: "Taos"),
  Driver(name: "Cleber", plate: "CZA-1357", carModel: "UP"),
  Driver(name: "Lucia", plate: "REZ-9821", carModel: "Onix"),
  Driver(name: "Maria Eduarda", plate: "HJU-6578", carModel: "Fiesta"),
  Driver(name: "Paulo", plate: "JHA-8798", carModel: "Tracker"),
  Driver(name: "Jadson", plate: "HJK-3H20", carModel: "Golf"),
  Driver(name: "Daniela", plate: "DNA-6532", carModel: "Prisma"),
];

class OrderTrakingPage extends StatefulWidget {
  const OrderTrakingPage({super.key});

  @override
  State<OrderTrakingPage> createState() => _OrderTrakingPageState();
}

class _OrderTrakingPageState extends State<OrderTrakingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  double fareAmount = 0.0;
  double destinatonRadius = 30.0;
  bool _hasArrived = false;
  static const LatLng sourceLocation = LatLng(-23.294484, -47.663186);
  LatLng destination = LatLng(-23.261222, -47.674735);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  BitmapDescriptor currentLocationIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  BitmapDescriptor currentLocationIconTeste = BitmapDescriptor.defaultMarker;
  BitmapDescriptor carIcon = BitmapDescriptor.defaultMarker;

  String _buttonText = "Escolha seu destino";
  bool _isDestinationSelected = false;

  void setMarkerCar() async {
    carIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), 'assets/taxi.png');
  }

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
      (location) {
        currentLocation = location;
        setState(() {});
      },
    );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 17,
              target: LatLng(newLoc.latitude!, newLoc.longitude!),
            ),
          ),
        );
        _checkArrival(newLoc);
        setState(() {});
      },
    );
  }

  void _checkArrival(LocationData newLoc) {
    double distance = _calculateDistance(newLoc.latitude!, newLoc.longitude!,
        destination.latitude, destination.longitude);

    if (distance < destinatonRadius && !_hasArrived) {
      _hasArrived = true;
      _showArrivalPage();
    }
  }

  void _showArrivalPage() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ArrivalPage(fareAmount: fareAmount),
    ),
  );
}

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371000;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; 
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  void getPolypoint() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult polylineResult =
        await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: google_api_key,
      request: PolylineRequest(
          origin:
              PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving),
    );
    if (polylineResult.points.isNotEmpty) {
      polylineResult.points.forEach(
        (PointLatLng points) => polylineCoordinates.add(
          LatLng(points.latitude, points.longitude),
        ),
      );
      setState(() {});
    }
  }

  void _selectDestination() async {
    if (!_isDestinationSelected) {
      
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SearchGooglePlaces(),
        ),
      );

      if (result != null) {
        double latitude = result['latitude'];
        double longitude = result['longitude'];
        setState(() {
          destination = LatLng(latitude, longitude);
          polylineCoordinates.clear();
          _isDestinationSelected = true; 
          _buttonText = "Chamar Taxista"; 
        });
        getPolypoint();
      }
    } else {
      // Ação "Iniciar corrida"
      _startRide();
    }
  }

  void _startRide() {
  final randomDriver = (drivers..shuffle()).first;

  setState(() {
    currentLocationIconTeste = carIcon;
  });

  double distance = _calculateDistance(
    currentLocation!.latitude!,
    currentLocation!.longitude!,
    destination.latitude,
    destination.longitude,
  );

  fareAmount = distance * 0.02;

  showModalBottomSheet(
    context: context,
    isDismissible: false,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 1.0,
        child: RideConfirmationSheet(driver: randomDriver, fareAmount: fareAmount),
      );
    },
  );
}


  void setCustomMarker() async {
    currentLocationIconTeste = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), 'assets/localizacao.png');
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    setCustomMarker();
    setMarkerCar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 125, 87),
        title: const Text(
          "Taxi Drivers",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: currentLocation == null
          ? const Center(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.deepOrangeAccent),
                ),
                SizedBox(height: 16),
                Text("Carregando...")
              ],
            ))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                zoom: 14.5,
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
              ),
              polylines: {
                Polyline(
                    polylineId: PolylineId("route"),
                    points: polylineCoordinates,
                    color: const Color.fromARGB(255, 30, 51, 236),
                    width: 6)
              },
              markers: {
                Marker(
                    markerId: MarkerId("currentLocation"),
                    position: LatLng(
                      currentLocation!.latitude!,
                      currentLocation!.longitude!,
                    ),
                    icon: currentLocationIconTeste),
                // const Marker(
                // markerId: MarkerId("source"),
                //position: (sourceLocation),
                // ),
                Marker(
                    markerId: const MarkerId("destination"),
                    position: destination),
              },
              onMapCreated: (controller) {
                _controller.complete(controller);
              },
            ),

      //###### aqui faz a opção dos 3 pontinhos do lado esquerdo ########//
      // drawer: Drawer(
      //   child: Padding(
      //     padding: const EdgeInsets.only(top: 100),
      //     child: ListTile(
      //         onTap: _selectDestination,
      //         title: const Text("Selecione seu destino"),
      //         leading: const Icon(Icons.add_location_alt)),
      //   ),
      // ),

      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent.withOpacity(0.8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: _selectDestination,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.navigation_outlined,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  _buttonText,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ArrivalPage extends StatelessWidget {
  final double fareAmount;

  const ArrivalPage({super.key, required this.fareAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chegou no destino"),
        backgroundColor: const Color.fromARGB(255, 248, 125, 87),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Você chegou ao destino!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Valor da corrida: R\$ ${fareAmount.toStringAsFixed(2)}", // Formata o valor da corrida
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Obrigado por usar nosso serviço!",
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderTrakingPage(),
                    ),
                  );
                },
                child: const Text("Voltar para o início"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
