import 'package:flutter/material.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Components/header.dart';
import 'package:proyecto_psicologia/Views/agenda_cita_view.dart';
import 'package:proyecto_psicologia/Views/prioridad_alta_view.dart';

class TestFiltroView extends StatefulWidget {
  const TestFiltroView({ Key? key }) : super(key: key);

  @override
  State<TestFiltroView> createState() => _TestFiltroViewState();
}

class _TestFiltroViewState extends State<TestFiltroView> {

  bool isChanged = false;
  bool isFinished = false;

  IconData idBoton = Icons.arrow_forward_rounded;

  int numPage = 1;
  int taps = 0;

  String textoBoton = 'Siguiente';

  PageController pageController = PageController(
    initialPage: 0,
    viewportFraction: 1,
    keepPage: true
  );

  Map<int,String> preguntas = {
    0: '¿Con qué frecuencia sientes que la vida no tiene sentido?',
    1: '¿Has tenido pensamientos de hacer daño a ti mismo/a o suicidarte?',
    2: '¿Cómo te sientes con respecto a tu desempeño académico?',
    3: '¿Tienes dificultades para concentrarte en tus estudios?',
    4: '¿Sientes que tienes una buena relación con tu familia?',
    5: '¿Te sientes solo/a o aislado/a de los demás?',
    6: '¿Cómo te afecta el estrés en tu vida cotidiana?',
    7: '¿Has perdido interés en actividades que antes disfrutabas?',
    8: '¿Cómo te sientes acerca de tu futuro en este momento?',
    9: '¿Has buscado ayuda psicológica antes?'
  };
  
  Map<int,Map<int,String>> respuestas = {
    0:{
      0: 'Siempre',
      1: 'A veces',
      2: 'Raramente'
    },
    1:{
      0: 'Sí, con frecuencia',
      1: 'Sí, a veces',
      2: 'No, nunca'
    },
    2:{
      0: 'Muy preocupado/a, me siento abrumado/a',
      1: 'Preocupado/a, pero puedo manejarlo',
      2: 'No me preocupo mucho, estoy bien con mis calificaciones'
    },
    3:{
      0: 'Siempre, no puedo concentrarme en absoluto',
      1: 'A veces, me distraigo fácilmente',
      2: 'No tengo problemas para concentrarme'
    },
    4:{
      0: 'No, tengo muchas tensiones familiares',
      1: 'Sí, pero a veces hay conflictos',
      2: 'Sí, tengo una relación sólida con mi familia'
    },
    5:{
      0: 'Siempre, me siento muy solo/a',
      1: 'A veces, me siento solo/a en ocasiones',
      2: 'No, tengo una buena red de apoyo social'
    },
    6:{
      0: 'Mucho, afecta seriamente mi bienestar',
      1: 'Algo, pero puedo manejarlo',
      2: 'No me afecta mucho, puedo lidiar con el estrés'
    },
    7:{
      0: 'Sí, he perdido todo interés',
      1: 'A veces, he perdido interés en algunas cosas',
      2: 'No, todavía disfruto de mis pasatiempos'
    },
    8:{
      0: 'Muy preocupado/a, no veo un futuro positivo',
      1: 'Preocupado/a, pero tengo esperanza',
      2: 'Optimista, creo que mi futuro será bueno'
    },
    9:{
      0: 'Sí, he buscado ayuda profesional previamente',
      1: 'No, nunca he buscado ayuda',
      2: 'No, pero he considerado buscar ayuda'
    },
  };

  Map<int,String> respuestasSeleccionadas = {};

  Map<int,String> abcedario = {
    0: 'A',
    1: 'B',
    2: 'C',
    3: 'D',
    4: 'E',
    5: 'F',
    6: 'G',
  };

  
  verificarCantidadLetras(Map<int, String?> respuestasSelec) {
    final letraFrecuencia = respuestasSelec.values.fold<Map<String, int>>(
      {},
      (frequencies, respuesta) {
        final letra = respuesta!.split('   ')[0];
        return {...frequencies, letra: (frequencies[letra] ?? 0) + 1};
      },
    );

    if (letraFrecuencia.containsKey('A')) {
      final frecuenciaA = letraFrecuencia['A']!;
      if (frecuenciaA >= 6) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PrioridadAltaView(),
          ),
        );
      } else if (frecuenciaA >= 4 && frecuenciaA <= 5) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AgendaCitaView(
              prioridad: 1
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AgendaCitaView(
              prioridad: 3
            ),
          ),
        );
      }
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageController.addListener(() {
        setState(() {
          numPage = pageController.page!.toInt() + 1;
        });
      });
    });
  }

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

  body(){
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          pageBuilder(
            preguntas: preguntas,
            respuestas: respuestas,
          ),
          const SizedBox(height: 20,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(taps > 0)
                botonRetroceso(),
              const SizedBox(width: 20,),
              Text(
                '$numPage de ${preguntas.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(width: 20,),
              botonSiguiente(),
            ],
          ),
        ],
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

  pageBuilder({
    required Map<int,String> preguntas,
    required Map<int,Map<int,String>> respuestas,
  }){
    return SizedBox(
      height: 300,
      width: 500,
      child: PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: preguntas.length,
        itemBuilder: (context,index){
          return Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    preguntas[index]!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Column(
                    children: respuestas[index]!.entries.map(
                      (e) {
                        int pos = respuestas[index]!.values.toList().indexOf(e.value);
                        String opcion = '${abcedario[pos]!}   ${e.value}';
                        return RadioListTile(
                          title: Text(opcion),
                          value: opcion,
                          groupValue: respuestasSeleccionadas[index],
                          onChanged: (value){
                            setState(() {
                              respuestasSeleccionadas[index] = value.toString();
                            });
                          },
                        );
                      }
                    ).toList(),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  botonRetroceso(){
    return BotonPsicologia(
      iconData: Icons.arrow_back_rounded,
      text: 'Retroceder',
      width: 165,
      onTap: (){
        setState(() {
          taps--;
          pageController.previousPage(
            duration: const Duration(milliseconds: 300), 
            curve: Curves.ease
          );
        });
      },
    );
  }

  botonSiguiente(){
    return BotonPsicologia(
      iconData: idBoton,
      text: textoBoton,
      width: 150,
      onTap: (){
        // No se puede avanzar si no se ha seleccionado una respuesta
        if(respuestasSeleccionadas[taps] == null){
          return;
        }
        setState(() {
          if(taps < preguntas.length - 1){
            taps++;
            if(taps == preguntas.length - 1){
              textoBoton = 'Finalizar';
              idBoton = Icons.check_rounded;
            }
          }else{
            isFinished = true;
            Navigator.of(context).pop();
            verificarCantidadLetras(respuestasSeleccionadas);
          }

          pageController.nextPage(
            duration: const Duration(milliseconds: 300), 
            curve: Curves.ease
          );
        });
      },
    );
  }


}