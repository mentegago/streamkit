import 'package:fluent_ui/fluent_ui.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: const PageHeader(title: Text("Home")),
        content: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text("Welcome to Mentega StreamKit"),
              Text(
                  "You're looking at an early preview of StreamKit, please use with caution!")
            ],
          ),
        ));
  }
}
