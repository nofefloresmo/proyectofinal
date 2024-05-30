import 'package:flutter/material.dart';
import '../models/log_model.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({Key? key}) : super(key: key);

  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late Future<List<Log>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = Log.getLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Logs de Transacciones')),
      body: FutureBuilder<List<Log>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar logs'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay logs disponibles'));
          }

          final logs = snapshot.data!;
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                title: Text('${log.action} - ${log.movieName}'),
                subtitle: Text('${log.timestamp}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Log.deleteLogs();
          setState(() {
            _logsFuture = Log.getLogs();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logs eliminados exitosamente.')),
          );
        },
        child: Icon(Icons.delete),
        backgroundColor: Colors.red,
      ),
    );
  }
}
