import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Components/header.dart';
import 'package:proyecto_psicologia/Services/firebase_services.dart';
import 'package:proyecto_psicologia/Views/citas_semana_view.dart';
import 'package:proyecto_psicologia/Views/test_filtro_view.dart';

class InicioView extends StatefulWidget {
  const InicioView({ Key? key }) : super(key: key);

  @override
  _InicioViewState createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {

  final servicios = Get.put(FirebaseServicesS());

  double height = 0;
  double width = 0;

  // metodo para obtener el tamaño de la pantalla
  void _getScreenSize(){
    setState(() {
      height = MediaQuery.of(context).size.height;
      width = MediaQuery.of(context).size.width;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getScreenSize();
    return Obx(
      ()=> Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Header(),
            if(!servicios.verificar.value)
              filaBotones(),
            body(),
          ],
        ),
      ),
    );
  }


  body(){
    return Obx(
      ()=> Expanded(
        child: !servicios.verificar.value ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              filaImportancia(),
              const SizedBox(height: 40,),
              filaNota(),
              const SizedBox(height: 80,),
            ]
          ),
        ): const Center(
          child: CircularProgressIndicator()
        ),
      ),
    );
  }

  filaBotones(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          botonSalir(),
          SizedBox(
            child: Row(
              children: [
                botonAgendarCita(),
                botonConsultarCita(),
              ],
            ),
          )
        ],
      ),
    );
  }

  botonSalir(){
    // boton para salir
    return BotonPsicologia(
      iconData: Icons.logout,
      text: 'Salir',
      onTap: (){},
    );
  }

  botonAgendarCita(){
    // boton agendar cita
    return BotonPsicologia(
      iconData: Icons.calendar_today_rounded,
      text: 'Agendar cita',
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TestFiltroView()));
      },
      width: 150,
    );
  }

  botonConsultarCita(){
    // boton para consultar citas
    return BotonPsicologia(
      iconData: Icons.alarm_rounded,
      text: 'Consultar cita',
      onTap: () async {
        await servicios.obtenerCitasAlumno(id: servicios.numeroControl.value);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CitasSemanaView()));
      },
      width: 150,
    );
  }


  filaImportancia(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0),
      child: SizedBox(
        width: 800,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              importancia(),
              SizedBox(width: 40,),
              imagenDoctor(),
            ],
          ),
        ),
      ),
    );
  }

  importancia(){
    return SizedBox(
      height: 288,
      width: 600,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F3D6D),
                borderRadius: BorderRadius.circular(20)
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Ir a terapia nos ayuda a reducir el sufrimiento mental, aliviando la depresión, la ansiedad, las adicciones, los trastornos alimenticios, los problemas para dormir y mucho más, lo que a su vez mejora nuestra calidad de vida y nos permite estar más felices, sanos y auténticos.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 50,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20)
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Importancia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }

  imagenDoctor(){
    return Image.network(
      'assets/images/doctor.png',
      fit: BoxFit.contain,
    );
  }


  filaNota(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0),
      child: SizedBox(
        width: 800,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              imagenSemaforo(),
              const SizedBox(width: 40,),
              nota(),
            ],
          ),
        ),
      ),
    );
  }

  nota(){
    return SizedBox(
      height: 358,
      width: 800,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F3D6D),
                borderRadius: BorderRadius.circular(20)
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Al agendar una cita deberás responder un cuestionario, el cual será evaluado para determinar si tu consulta es urgente, medianamente urgente y no tan unrgente, en la cual se priorizará dependiendo si tienes problemas relacionados con el suicidio, problemas familiares o personales y escolares, en el caso que sea urgende podrás agendar inmediatamente a partir del siguiente día, si es medio podrás agendar a partir del tercer día, y si no es tan urgente podrás agendar después de una semana.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 50,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20)
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Nota',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }

  imagenSemaforo(){
    return Image.network(
      'assets/images/semaforo.png',
      width: 207,
      height: 335,
      fit: BoxFit.contain,
    );
  }

}