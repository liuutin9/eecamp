import 'package:eecamp/services/navigation_service.dart';
import 'package:eecamp/widgets/animated_hints/animated_hint_backward.dart';
import 'package:eecamp/widgets/animated_hints/animated_hint_forward.dart';
import 'package:eecamp/widgets/animated_hints/animated_hint_left.dart';
import 'package:eecamp/widgets/animated_hints/animated_hint_right.dart';
import 'package:flutter/material.dart';
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
            canPop: false,
            onPopInvoked: (bool didPop) async {
              await bluetooth.disconnectFromDevice();
              if (context.mounted) {
                Provider.of<NavigationService>(context, listen: false).goHome();
              }
            },
            child: Scaffold(
              body: Center(
                child: Text('Failed to connect: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          return PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) async {
              await bluetooth.disconnectFromDevice();
              if (context.mounted) {
                Provider.of<NavigationService>(context, listen: false).goHome();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    await bluetooth.disconnectFromDevice();
                    if (context.mounted) {
                      Provider.of<NavigationService>(context, listen: false).goHome();
                    }
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

class _ControlInterfaceState extends State<ControlInterface> {
  MoveStates state = MoveStates.stop;

  void sendMessage(String message) {
    BluetoothProvider bluetooth = Provider.of<BluetoothProvider>(context, listen: false);
    if (bluetooth.characteristic != null) {
      try {
        bluetooth.characteristic!.write(message.codeUnits, withoutResponse: true);
      } catch (e) {
        debugPrint('Error sending message: $e');
      }
    }
  }

  void setMoveStates(MoveStates newState) {
    setState(() {
      state = newState;
    });
    switch (state) {
      case MoveStates.forward:
        sendMessage('w');
        break;
      case MoveStates.backward:
        sendMessage('s');
        break;
      case MoveStates.left:
        sendMessage('a');
        break;
      case MoveStates.right:
        sendMessage('d');
        break;
      default:
        sendMessage('0');
    }
  }

  Widget getAnimatedHint(MoveStates state) {
    switch (state) {
      case MoveStates.forward:
        return const AnimatedHintForward();
      case MoveStates.backward:
        return const AnimatedHintBackward();
      case MoveStates.left:
        return const AnimatedHintLeft();
      case MoveStates.right:
        return const AnimatedHintRight();
      default:
        return const Icon(
          Icons.navigation,
          size: 100,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: getAnimatedHint(state),
        ),
        Expanded(
          flex: 3,
          child: Card(
            margin: const EdgeInsets.all(0),
            color: Theme.of(context).colorScheme.surface,
            elevation: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onLongPressDown: state == MoveStates.stop
                      ? (details) => setMoveStates(MoveStates.forward) : null,
                  onLongPressCancel: state == MoveStates.forward
                      ? () => setMoveStates(MoveStates.stop) : null,
                  onLongPressEnd: state == MoveStates.forward
                      ? (details) => setMoveStates(MoveStates.stop) : null,
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
                      onLongPressDown: state == MoveStates.stop
                          ? (details) => setMoveStates(MoveStates.left) : null,
                      onLongPressCancel: state == MoveStates.left
                          ? () => setMoveStates(MoveStates.stop) : null,
                      onLongPressEnd: state == MoveStates.left
                          ? (details) => setMoveStates(MoveStates.stop) : null,
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
                      onLongPressDown: state == MoveStates.stop
                          ? (details) => setMoveStates(MoveStates.right) : null,
                      onLongPressCancel: state == MoveStates.right
                          ? () => setMoveStates(MoveStates.stop) : null,
                      onLongPressEnd: state == MoveStates.right
                          ? (details) => setMoveStates(MoveStates.stop) : null,
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
                  onLongPressDown: state == MoveStates.stop
                      ? (details) => setMoveStates(MoveStates.backward) : null,
                  onLongPressCancel: state == MoveStates.backward
                      ? () => setMoveStates(MoveStates.stop) : null,
                  onLongPressEnd: state == MoveStates.backward
                      ? (details) => setMoveStates(MoveStates.stop) : null,
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
        ),
      ],
    );
  }
}