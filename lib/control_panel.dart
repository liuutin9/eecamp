import 'package:eecamp/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:eecamp/services/bluetooth_service.dart';

enum MoveStates {forward, backward, left, right, stop}

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  // TextEditingController messageController = TextEditingController();

  // Future<void> sendMessage(String message, BluetoothProvider bluetooth) async {
  //   if (bluetooth.connectedDevice!.isConnected) debugPrint("Yes");
  //   if (bluetooth.characteristic!.properties.write) debugPrint("true");
  //   if (bluetooth.characteristic != null) {
  //     try {
  //       await bluetooth.characteristic!.write(message.codeUnits, withoutResponse: true);
  //     } catch (e) {
  //       debugPrint('Error sending message: $e');
  //     }
  //   }
  // }

  // void receiveMessage(BluetoothProvider bluetooth) async {
  //   if (bluetooth.characteristic != null) {
  //     try {
  //       var value = await bluetooth.characteristic!.read();
  //       String receivedMessage = String.fromCharCodes(value);
  //       debugPrint('Received: $receivedMessage');
  //       if (!mounted) return;
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text('Received Message'),
  //           content: Text(receivedMessage),
  //           actions: <Widget>[
  //             TextButton(
  //               child: const Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     } catch (e) {
  //       debugPrint('Error receiving message: $e');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    BluetoothProvider bluetooth = Provider.of<BluetoothProvider>(context, listen: false);
    return FutureBuilder(
      future: bluetooth.connectToDevice(bluetooth.selectedDevice!, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text('Connecting to ${bluetooth.selectedDevice?.platformName}'),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          return PopScope(
            canPop: true,
            onPopInvoked: (bool didPop) {
              bluetooth.disconnectFromDevice();
              Provider.of<NavigationService>(context, listen: false).goHome();
            },
            child: Scaffold(
              body: Center(
                child: Text('Failed to connect: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          return PopScope(
            canPop: true,
            onPopInvoked: (bool didPop) {
              bluetooth.disconnectFromDevice();
              Provider.of<NavigationService>(context, listen: false).goHome();
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    bluetooth.disconnectFromDevice();
                    Provider.of<NavigationService>(context, listen: false).goHome();
                  },
                ),
                title: Text(bluetooth.selectedDevice?.platformName ?? 'Device'),
              ),
              body: const ControlInterface(),
            ),
          );
        }
      },
    );
  }
}

class ControlInterface extends StatefulWidget {
  const ControlInterface({super.key});

  @override
  State<ControlInterface> createState() => _ControlInterfaceState();
}

class _ControlInterfaceState extends State<ControlInterface> with SingleTickerProviderStateMixin {
  MoveStates state = MoveStates.stop;
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _rotateAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart,
    ));
    _slideAnimation = Tween(begin: Offset.zero, end: const Offset(0, 1)).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setMoveStates(MoveStates newState) {
    BluetoothProvider bluetooth = Provider.of<BluetoothProvider>(context, listen: false);
    setState(() {
      state = newState;
    });
    switch (state) {
      case MoveStates.forward:
        if (bluetooth.characteristic != null) {
          try {
            bluetooth.characteristic!.write('w'.codeUnits, withoutResponse: true);
          } catch (e) {
            debugPrint('Error sending message: $e');
          }
        }
        break;
      case MoveStates.backward:
        if (bluetooth.characteristic != null) {
          try {
            bluetooth.characteristic!.write('s'.codeUnits, withoutResponse: true);
          } catch (e) {
            debugPrint('Error sending message: $e');
          }
        }
        break;
      case MoveStates.left:
        if (bluetooth.characteristic != null) {
          try {
            bluetooth.characteristic!.write('a'.codeUnits, withoutResponse: true);
          } catch (e) {
            debugPrint('Error sending message: $e');
          }
        }
        break;
      case MoveStates.right:
        if (bluetooth.characteristic != null) {
          try {
            bluetooth.characteristic!.write('d'.codeUnits, withoutResponse: true);
          } catch (e) {
            debugPrint('Error sending message: $e');
          }
        }
        break;
      default:
        if (bluetooth.characteristic != null) {
          try {
            bluetooth.characteristic!.write('0'.codeUnits, withoutResponse: true);
          } catch (e) {
            debugPrint('Error sending message: $e');
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: AnimatedContainer(
            duration: const Duration(seconds: 1),
            child: const Icon(
              Icons.navigation,
              size: 100,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTapDown: state == MoveStates.stop
                    ? (details) {
                      debugPrint('TapDown');
                      setMoveStates(MoveStates.forward);
                    } : null,
                onTapUp: state == MoveStates.forward
                    ? (details) {
                      debugPrint('TapUp');
                      setMoveStates(MoveStates.stop);
                    } : null,
                child: Opacity(
                  opacity: state == MoveStates.stop || state == MoveStates.forward ? 1 : 0.3,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: state == MoveStates.forward
                          ? Theme.of(context).colorScheme.surfaceContainerLowest
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.rectangle,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const Icon(Icons.arrow_upward)
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTapDown: state == MoveStates.stop
                        ? (details) {
                          debugPrint('TapDown');
                          setMoveStates(MoveStates.left);
                        } : null,
                    onTapUp: state == MoveStates.left
                        ? (details) {
                          debugPrint('TapUp');
                          setMoveStates(MoveStates.stop);
                        } : null,
                    child: Opacity(
                      opacity: state == MoveStates.stop || state == MoveStates.left ? 1 : 0.3,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: state == MoveStates.left
                              ? Theme.of(context).colorScheme.surfaceContainerLowest
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: BoxShape.rectangle,
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: const Icon(Icons.rotate_left)
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 100,
                    height: 100,
                    child: Icon(Icons.local_taxi),
                  ),
                  GestureDetector(
                    onTapDown: state == MoveStates.stop
                        ? (details) {
                          debugPrint('TapDown');
                          setMoveStates(MoveStates.right);
                        } : null,
                    onTapUp: state == MoveStates.right
                        ? (details) {
                          debugPrint('TapUp');
                          setMoveStates(MoveStates.stop);
                        } : null,
                    child: Opacity(
                      opacity: state == MoveStates.stop || state == MoveStates.right ? 1 : 0.3,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: state == MoveStates.right
                              ? Theme.of(context).colorScheme.surfaceContainerLowest
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: BoxShape.rectangle,
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: const Icon(Icons.rotate_right)
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTapDown: state == MoveStates.stop
                    ? (details) {
                      debugPrint('TapDown');
                      setMoveStates(MoveStates.backward);
                    } : null,
                onTapUp: state == MoveStates.backward
                    ? (details) {
                      debugPrint('TapUp');
                      setMoveStates(MoveStates.stop);
                    } : null,
                child: Opacity(
                  opacity: state == MoveStates.stop || state == MoveStates.backward ? 1 : 0.3,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: state == MoveStates.backward
                          ? Theme.of(context).colorScheme.surfaceContainerLowest
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.rectangle,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const Icon(Icons.arrow_downward)
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
