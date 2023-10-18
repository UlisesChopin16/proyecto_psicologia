import 'package:flutter/material.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Components/header.dart';

class AgendaCitaView extends StatefulWidget {
  final int prioridad;
  const AgendaCitaView({ 
    Key? key,
    required this.prioridad
  }) : super(key: key);

  @override
  _AgendaCitaViewState createState() => _AgendaCitaViewState();
}

class _AgendaCitaViewState extends State<AgendaCitaView> {

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
          Text(
            'Días despues de hoy para agendar ${widget.prioridad}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold
            ),
          )
        ],
      ),
    );
  }



  

}