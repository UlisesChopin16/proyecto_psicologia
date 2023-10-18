import 'package:flutter/material.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Components/header.dart';

class PrioridadAltaView extends StatefulWidget {
  const PrioridadAltaView({ Key? key }) : super(key: key);

  @override
  _PrioridadAltaViewState createState() => _PrioridadAltaViewState();
}

class _PrioridadAltaViewState extends State<PrioridadAltaView> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Header(),
            filaBotones(),
            body(),
          ],
        )
      )
    );
  }

  filaBotones(){
    return Center(
      child: SizedBox(
        width: 500,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BotonPsicologia(
              iconData: Icons.arrow_back_rounded,
              text: 'Volver',
              onTap: (){
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }


  body(){
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ingresarTelefono(),
        ],
      ),
    );
  }



  ingresarTelefono(){
    return SizedBox(
      height: 300,
      width: 500,
      child: Card(
        color: const Color(0xFFD9D9D9),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
              const Text(
                'Tu prioridad es ALTA',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20,),
              const Text(
                'Por favor, ingresa tu número de teléfono para que un psicólogo se comunique contigo',
                style: TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20,),
              TextField(
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 2
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF030D67),
                      width: 2
                    ),
                  ),
                  labelText: 'Número de teléfono',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}