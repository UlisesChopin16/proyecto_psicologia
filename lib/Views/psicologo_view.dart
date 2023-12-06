import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Components/header.dart';
import 'package:proyecto_psicologia/Constants/colors.dart';
import 'package:proyecto_psicologia/Services/firebase_services.dart';
import 'package:proyecto_psicologia/Services/generar_pdf_services.dart';
import 'package:proyecto_psicologia/Views/pdf_cita_view.dart';
import 'package:table_calendar/table_calendar.dart';

class PsicologoView extends StatefulWidget {
  const PsicologoView({ 
    Key? key,
  }) : super(key: key);

  @override
  _PsicologoViewState createState() => _PsicologoViewState();
}

class _PsicologoViewState extends State<PsicologoView> {

  

  final servicios = Get.put(FirebaseServicesS());

  bool active = false;

  DateTime hoy = DateTime.now();
  DateTime selectedDayP = DateTime.now();
  DateTime firstDay = DateTime.now();

  int count = 0;


  @override
  void initState() {
    super.initState();
    // día de hoy + 3 días
    servicios.obtenerCitas();
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
        child: !servicios.verificar.value ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0,),
          child: SizedBox(
            width: 950,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  tableCalendar(),
                  const Gap(20),
                  listaAlumnos(),
                ],
              ),
            ),
          ),
        ) : const Center(
          child: CircularProgressIndicator(),
        )
      ),
    );
  }

  Widget tableCalendar(){
    // dia de hoy mas widget.prioridad
    return FittedBox(
      fit: BoxFit.contain,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: 500, 
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: Colors.grey,
                width: 4
              )
            ),
            child: TableCalendar(
              focusedDay: selectedDayP, 
              firstDay: firstDay,
              lastDay: DateTime(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(selectedDayP, day),
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  // si focusedDay es sabado o domingo entonces no se puede seleccionar
                  if(focusedDay.weekday == DateTime.saturday){
                    selectedDayP = selectedDay.add(const Duration(days: 2));
                  }else if(focusedDay.weekday == DateTime.sunday){
                    selectedDayP = selectedDay.add(const Duration(days: 1));
                  }else{
                    selectedDayP = selectedDay;
                  }
                });
                await servicios.obtenerCita(fecha: selectedDayP);
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              calendarStyle:  CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Palette.colorBlue,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                todayBuilder: (context, date, _) {
                  return Center(
                    child: Text(
                      date.day.toString(),
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  // esta lista contiene las fechas de las citas unicas (sin repetir)
                  final fechaNormalSet = servicios.puntosCitas.map((cita) => cita['fechaNormal']).toSet();

                  if (fechaNormalSet.contains(date.toString().substring(0, 10))) {
                    return Container(
                      height: 10,
                      width: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }

                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  listaAlumnos(){
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 400,
        height: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Citas Pendientes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold
              ),
            ),
            const Gap(20),
            listaGenerada()
          ],
        )
      ),
    );
  }

  listaGenerada(){
    return Obx(
      ()=> Flexible(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: !servicios.verificar.value? servicios.datosCitas.map(
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
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e['nombreCita'],
                              style: const TextStyle(
                                fontSize: 20,
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
                            const Gap(10),
                            Text(e['carrera']),
                            const Gap(10),
                            Text(e['numeroTelCita']),
                            const Gap(10),
                            Text(e['numeroControlCita']),
                          ],
                        ),
                      )
                    ),
                  ),
                );
              } 
            ).toList()
            : const [
              CircularProgressIndicator(),
            ]
          ),
        ),
      ),
    );
  }



}