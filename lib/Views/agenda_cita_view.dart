import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Components/header.dart';
import 'package:proyecto_psicologia/Constants/colors.dart';
import 'package:proyecto_psicologia/Services/firebase_services.dart';
import 'package:proyecto_psicologia/Views/pdf_cita_view.dart';
import 'package:table_calendar/table_calendar.dart';

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

  MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    // ponemos la mascara que queremos que tenga la fecha de nacimiento
    // en este caso es la fecha de nacimiento de  4 digitos, un guion, 2 digitos, otro guion y 2 digitos
    // y seguira este formato al momento de escribirlo
    mask: 'xxxxxxxxxx', 

    // con este parametro le decimos que el texto se escribira de manera automatica al momento de escribir el texto  
    type: MaskAutoCompletionType.eager,
    // con este filtro le decimos que solo acepte numeros
    // y que cambie los 8x por el numero que escribamos
    filter: { "x": RegExp(r'[0-9]') },
  );

  final servicios = Get.put(FirebaseServicesS());

  bool active = false;

  DateTime hoy = DateTime.now();
  DateTime selectedDayP = DateTime.now();
  DateTime firstDay = DateTime.now();

  String horario = '';

  List<String> meses = [
    'Enero', 
    'Febrero', 
    'Marzo', 
    'Abril', 
    'Mayo', 
    'Junio', 
    'Julio', 
    'Agosto', 
    'Septiembre', 
    'Octubre', 
    'Noviembre', 
    'Diciembre'
  ];

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
    servicios.obtenerAlumno(collection: 'estudiantes', id: 'c18090562');
    if(hoy.add(Duration(days: widget.prioridad)).weekday == DateTime.saturday){
      selectedDayP = DateTime.now().add(Duration(days: widget.prioridad + 2));
      firstDay = DateTime.now().add(Duration(days: widget.prioridad + 2));
    }else if(hoy.add( Duration(days: widget.prioridad)).weekday == DateTime.sunday){
      selectedDayP = DateTime.now().add(Duration(days: widget.prioridad + 1));
      firstDay = DateTime.now().add(Duration(days: widget.prioridad + 1));
    }else{
      selectedDayP = DateTime.now().add(Duration(days: widget.prioridad));
      firstDay = DateTime.now().add(Duration(days: widget.prioridad));
    }
  }

  // metodo para obtener la fecha compuesta por ejemplo si tengo 2021-10-10 este metodo me devuelve 10/Octubre/2021 o 01/Enero/2021
  String obtenerFecha(DateTime fecha){
    // obtenemos el día con formato de 2 digitos
    String dia = fecha.day.toString().padLeft(2, '0');
    String mes = meses[fecha.month - 1];
    String year = fecha.year.toString();
    return '$dia/$mes/$year';
  }

  void onChangedTelefono(String value){
    setState(() {
      servicios.telefono.value = value;
      if(servicios.telefono.value.length == 10 && horario != ''){
        active = true;
        servicios.datosCita['celular'] = servicios.telefono.value;
      }else{
        active = false;
      }
    });
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
            BotonPsicologia(
              iconData: Icons.save_rounded,
              text: 'Guardar',
              width: 140,
              onTap: active ? () async {
                servicios.verificar.value = true;
                if(servicios.verificarTelefono.value){
                  await servicios.actualizarCita(collection: 'estudiantes', id: servicios.numeroControl.value, data: servicios.datosCita);
                }

                servicios.fecha.value = obtenerFecha(selectedDayP);
                servicios.hora.value = horario;
                servicios.verificar.value = false;

                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PdfCitaView()
                  )
                );
              } : null,
            ),
          ],
        ),
      ),
    );
  }


  body(){
    return Obx(
      () => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !servicios.verificar.value ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: SizedBox(
                width: 950,
                child: FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      tableCalendar(),
                      const Gap(20),
                      listaHorarios(),
                    ],
                  ),
                ),
              ),
            ) : const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }

  tableCalendar(){
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
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(selectedDayP, day),
              onDaySelected: (selectedDay, focusedDay){
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
            ),
          ),
        ),
      ),
    );
  }

  listaHorarios(){
    return Obx(
      () => FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Horarios',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold
                ),
              ),
              Expanded(
                child: checkList(),
              ),
              if(servicios.verificarTelefono.value)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(20),
                  const Text(
                    'Telefono',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  TextFormField(
                    onChanged: onChangedTelefono,
                    inputFormatters: [maskFormatter],
                    decoration: InputDecoration(
                      hintText: 'Ingrese su numero de telefono por favor',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    ),
                  )
                ],
              )
            ],
          )
        ),
      ),
    );
  }

  checkList(){
    // Si el dia seleccionado es lunes entonces mostrar los horarios de lunes
    if(selectedDayP.weekday == DateTime.monday){
      return listaGenerada('Lunes');
    } else if(selectedDayP.weekday == DateTime.tuesday){
      return listaGenerada('Martes');
    } else if(selectedDayP.weekday == DateTime.wednesday){
      return listaGenerada('Miercoles');
    } else if(selectedDayP.weekday == DateTime.thursday){
      return listaGenerada('Jueves');
    } else if(selectedDayP.weekday == DateTime.friday){
      return listaGenerada('Viernes');
    }
  }

  listaGenerada(String dia){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: horarios[dia]!.map(
        (e) => Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: RadioListTile(
            title: Text(
             e.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
            value:e.toString(), 
            groupValue: horario, 
            onChanged: (opcion) {
              setState(() {
                if (servicios.telefono.value.length == 10) {
                  active = true;
                }
                horario = opcion.toString();
              });
            },
          ),
        )
      ).toList(),
    );
  }

  

}