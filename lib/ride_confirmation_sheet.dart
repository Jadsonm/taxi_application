import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:taxi_application/models/driver.dart';

class RideConfirmationSheet extends StatefulWidget {
  final Driver driver; // Recebe um motorista

  const RideConfirmationSheet({super.key, required this.driver, required double fareAmount});

  @override
  _RideConfirmationSheetState createState() => _RideConfirmationSheetState();
}

class _RideConfirmationSheetState extends State<RideConfirmationSheet> {
  late int _waitTime;
  bool _rideStarted = false;

  @override
  void initState() {
    super.initState();
    _waitTime = _generateRandomWaitTime();
    _startCountdown();
  }

  int _generateRandomWaitTime(){
    final Random random = Random();
    return random.nextInt(1) + 5;
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_waitTime > 1) {
        setState(() {
          _waitTime--;
        });
      } else {
        timer.cancel();
        _startRide();
      }
    });
  }

  void _startRide() {
    setState(() {
      _rideStarted = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _rideStarted ? "Corrida iniciada!" : "Aguardando motorista...",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _rideStarted ? "Boa viagem!" : "Tempo de espera: $_waitTime segundos",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (!_rideStarted) // Exibe as informações do motorista antes de iniciar a corrida
              Column(
                children: [
                  Text("Nome do motorista: ${widget.driver.name}"), // Usando as informações do motorista
                  Text("Placa do carro: ${widget.driver.plate}"),
                  Text("Modelo do carro: ${widget.driver.carModel}"),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
