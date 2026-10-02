// File Name : main.dart
// Description : The Main dart file of the android platform
// Date Of Last Modification : 01/10/2026
// Author : Tarek Sayah



import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';

const Color keycolor = Color.fromRGBO(238, 239, 32,1);
const Color sidecolor = Color.fromRGBO(191, 210, 0, 1);


bool editing = false;
List<(String, String,IconData,bool,DateTime?)> tasks = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init(); 
  await Permission.notification.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyPage(),
    );
  }

}

class MyPage extends StatefulWidget  {
  @override
  State<MyPage> createState() => MyPageState();  
  
}

class MyPageState extends State<MyPage>{
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To->Do"),
      backgroundColor: keycolor,
      actions: [
        IconButton(onPressed: (){ setState(() {
          editing=!editing;}); }, icon: const Icon(Icons.edit)),
        if (editing) 
           IconButton(onPressed: deletItems, icon: const Icon(Icons.delete)),  
        
        IconButton(onPressed: (){}, icon: const Icon(Icons.settings)),
        
      ],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: keycolor,foregroundColor: Colors.black, onPressed: () => _showAddTaskDialog(context),
      
      child: const Icon(Icons.add)),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(task.$1),
              subtitle: Text("${task.$2} \n ${task.$5}"),
              
              leading: Icon(task.$3) ,
              trailing: editing ? Checkbox(
                value:task.$4,
                activeColor: keycolor,
                checkColor: Colors.black,
                onChanged: (bool? newValue) {
                  setState(() {
                    tasks[index] = (task.$1, task.$2, task.$3, newValue?? false,task.$5);
                  });
                    
                }
              ):null,  
            ),
          );
        },
      ),
    );
}
void deletItems() {
  for (final task in tasks) {
    if (task.$4 == true) {
      setState(() {
        tasks.remove(task);
      });
     
    }
  }
}

Future<void> setAlarm(DateTime dateTime,String ntitle , String nbody) async {
  final alarmSettings = AlarmSettings(
    id: tasks.length,
    dateTime: dateTime,
    assetAudioPath: 'assets/audios/Alarm.mp3', // add your own sound file
    loopAudio: true,
    
    vibrate: true,
    volumeSettings: VolumeSettings.fade(
      fadeDuration: const Duration(seconds: 5),

    ),
    notificationSettings: NotificationSettings(
      title: ntitle,
      body: nbody,
      stopButton: 'Stop', 

    ),
  );

  final result = await Alarm.set(alarmSettings: alarmSettings);
  print('Alarm.set() result: $result');
}

void _showAddTaskDialog(BuildContext context) {

  final titleController = TextEditingController();
  final descController = TextEditingController();
  DateTime? selectedDateTime;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: Icon(Icons.edit),
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // important: shrink to fit content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title'),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'e.g. Feed Luna',
                filled:true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Description'),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: 'e.g. Remember to feed Luna at noon',
                filled:true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Time And Date :'),
          TextButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:sidecolor,
              foregroundColor: Colors.black,
              
            ),
            icon: const Icon(Icons.timer_rounded),
            label:Text('Pick Time'),
            onPressed: () async {
              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              
              if (date == null) return;
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time==null) return;

              final DateTime fullDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
              setState(() {
              selectedDateTime = fullDateTime;
              print('Picker set selectedDateTime to: $selectedDateTime');
            });
            },

          ),
        ]),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom( 
                foregroundColor: Colors.black,  
            ),
            onPressed: () => Navigator.pop(context), // cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: keycolor,      
                foregroundColor: Colors.black,  
            ),
            onPressed: () async {
              // use titleController.text and descController.text here
              if (selectedDateTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please assign correct date and time!'),
                ),
              );
              return;}
              setState (() {
                  tasks.add((titleController.text,descController.text,Icons.timelapse_rounded,false,selectedDateTime));
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task added sucessfully'),
                  ));
              });

              await setAlarm(selectedDateTime!,titleController.text,descController.text);

              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: const Text('Add'),
          ),
        ],
      );
    },
  );
}
}