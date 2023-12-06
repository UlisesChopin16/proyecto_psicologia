import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Components/header.dart';
import 'package:proyecto_psicologia/Services/firebase_services.dart';
import 'package:proyecto_psicologia/Services/generar_pdf_services.dart';
import 'package:proyecto_psicologia/Views/pdf_cita_view.dart';

class CitasSemanaView extends StatefulWidget {
  const CitasSemanaView({ Key? key }) : super(key: key);

  @override
  _CitasSemanaViewState createState() => _CitasSemanaViewState();
}

class _CitasSemanaViewState extends State<CitasSemanaView> {

  final servicios = Get.put(FirebaseServicesS());

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
        width: 800,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    return Obx(
      () => Expanded(
        child: !servicios.verificar.value ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: SizedBox(
                width: 600,
                child: FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Citas de la semana',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const Gap(20),
                      listaCitas()
                    ],
                  ),
                ),
              ),
            ) 
          ],
        ): Center(child: const CircularProgressIndicator()),
      ),
    );
  }

  Widget listaCitas(){
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            listaGenerada()
          ],
        )
      ),
    );
  }

  listaGenerada(){
    return Obx(
      ()=> Expanded(
        child:!servicios.verificar.value  ? ListView(
          children: metodoVerificarLista(),
        ) : const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  List<Widget> metodoVerificarLista(){
    if(servicios.datosCitas.isEmpty){
      return [
        const Text(
          'No hay citas pendientes',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        )
      ];
    }else{
      return servicios.datosCitas.map(
        (e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              hoverColor: Colors.grey[300],
              onTap: ()async{
                servicios.verificar.value = true;

                servicios.fecha.value = e['fechaCita'];
                servicios.hora.value = e['horaCita'];
                servicios.periodo.value = e['cicloEscolarCita'];
                servicios.nombre.value = e['nombreCita'];
                servicios.numeroControl.value = e['numeroControlCita']; 
                servicios.carrera.value = e['carrera'];
                servicios.telefono.value = e['numeroTelCita'];
            
                servicios.vistaPsicologo.value = true;
                      
                await GenerarPdfServices().initPDF();
                servicios.verificar.value = false;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PdfCitaView()
                  )
                ).then((value) => servicios.vistaPsicologo.value = false);
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0, top: 15, left: 15, right: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['fechaCita'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const Gap(10),
                      Text(
                        e['horaCita'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                )
              ),
            ),
          );
        } 
      ).toList();
    }
  }


}