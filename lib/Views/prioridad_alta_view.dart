import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Components/header.dart';
import 'package:proyecto_psicologia/Services/firebase_services.dart';

class PrioridadAltaView extends StatefulWidget {
  const PrioridadAltaView({ Key? key }) : super(key: key);

  @override
  _PrioridadAltaViewState createState() => _PrioridadAltaViewState();
}

class _PrioridadAltaViewState extends State<PrioridadAltaView> {

  final servicios = Get.put(FirebaseServicesS());

  DateTime verificarFecha = DateTime.now();

  bool verificarDiaE = true;

  Map<String,List<String>> horarios = {
    'Lunes': [
      '7:00am - 8:00am',
      '8:00am - 9:00am',
      '9:00am - 10:00am',
      '1:00pm - 2:00pm',
    ],
    'Martes': [
      '7:00am - 8:00am',
      '8:00am - 9:00am',
      '9:00am - 10:00am',
      '1:00pm - 2:00pm',
    ],
    'Miercoles': [
      '7:00am - 8:00am',
      '8:00am - 9:00am',
      '9:00am - 10:00am',
    ],
    'Jueves': [
      '7:00am - 8:00am',
      '8:00am - 9:00am',
      '9:00am - 10:00am',
      '1:00pm - 2:00pm',
    ],
    'Viernes': [
      '7:00am - 8:00am',
      '8:00am - 9:00am',
      '9:00am - 10:00am',
      '10:00am - 11:00am'
    ],
  };

  @override
  void initState() {
    super.initState();
    // día de hoy + 3 días
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      // Tu código aquí se ejecutará después de que se haya construido el árbol de widgets.
      // await servicios.obtenerAlumno(
      //   collection: 'estudiantes',
      //   id: servicios.numeroControl.value,
      //   context: context
      // );
      await servicios.obtenerAlumno(
        collection: 'estudiantes',
        id: 'c18090562',
        context: context
      );
    });
  }

  // metodo para checar días y verificar si hay horario disponible 
  Future<void> verificarDia() async {
    print('verificarDia');
    // Si el dia seleccionado es lunes entonces mostrar los horarios de lunes
    while(verificarDiaE){
      if(verificarFecha.weekday == DateTime.monday){
        for(int i = 0; i < horarios['Lunes']!.length; i++){
          await servicios.verificarCita(
            collection: 'Citas',
            id: '${verificarFecha.toString().split(' ')[0]} ${horarios['Lunes']![i]}',
            context: context
          );
          if(!servicios.verificarCitaExistente.value){
            print('${verificarFecha.toString().split(' ')[0]} ${horarios['Lunes']![i]}');
            verificarDiaE = false;
            return;
          }
        }
      } else if(verificarFecha.weekday == DateTime.tuesday){
        for(int i = 0; i < horarios['Martes']!.length; i++){
          await servicios.verificarCita(
            collection: 'Citas',
            id: '${verificarFecha.toString().split(' ')[0]} ${horarios['Martes']![i]}',
            context: context
          );
          if(!servicios.verificarCitaExistente.value){
            print('${verificarFecha.toString().split(' ')[0]} ${horarios['Martes']![i]}');
            verificarDiaE = false;
            return;
          }
        }
        // return listaGenerada('Martes');
      } else if(verificarFecha.weekday == DateTime.wednesday){
        for(int i = 0; i < horarios['Miercoles']!.length; i++){
          await servicios.verificarCita(
            collection: 'Citas',
            id: '${verificarFecha.toString().split(' ')[0]} ${horarios['Miercoles']![i]}',
            context: context
          );
          if(!servicios.verificarCitaExistente.value){
            print('${verificarFecha.toString().split(' ')[0]} ${horarios['Miercoles']![i]}');
            verificarDiaE = false;
            return;
          }
        }
        // return listaGenerada('Miercoles');
      } else if(verificarFecha.weekday == DateTime.thursday){
        for(int i = 0; i < horarios['Jueves']!.length; i++){
          await servicios.verificarCita(
            collection: 'Citas',
            id: '${verificarFecha.toString().split(' ')[0]} ${horarios['Jueves']![i]}',
            context: context
          );
          if(!servicios.verificarCitaExistente.value){
            print('${verificarFecha.toString().split(' ')[0]} ${horarios['Jueves']![i]}');
            verificarDiaE = false;
            return;
          }
        }
        // return listaGenerada('Jueves');
      } else if(verificarFecha.weekday == DateTime.friday){
        for(int i = 0; i < horarios['Viernes']!.length; i++){
          await servicios.verificarCita(
            collection: 'Citas',
            id: '${verificarFecha.toString().split(' ')[0]} ${horarios['Viernes']![i]}',
            context: context
          );
          if(!servicios.verificarCitaExistente.value){
            print('${verificarFecha.toString().split(' ')[0]} ${horarios['Viernes']![i]}');
            verificarDiaE = false;
            return;
          }
        }
        // return listaGenerada('Viernes');
      }
      verificarFecha = verificarFecha.add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: Center(
          child: Column(
            children: [
              const Header(),
              if(!servicios.verificar.value)
              filaBotones(),

              body(),
            ],
          )
        )
      ),
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
      child: !servicios.verificar.value ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ingresarTelefono(),
        ],
      ) : const Center(
        child: CircularProgressIndicator()
      ),
    );
  }



  ingresarTelefono(){
    return SizedBox(
      height: 400,
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
              const SizedBox(height: 20,),
              BotonPsicologia(
                iconData: Icons.check,
                text: 'Enviar',
                onTap: ()async{
                  await verificarDia();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}