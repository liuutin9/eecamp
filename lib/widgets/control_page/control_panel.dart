import 'package:eecamp/services/navigation_service.dart';
import 'package:eecamp/widgets/animated_hints/animated_hint_backward.dart';
import 'package:eecamp/widgets/animated_hints/animated_hint_forward.dart';
import 'package:eecamp/widgets/animated_hints/animated_hint_left.dart';
import 'package:eecamp/widgets/animated_hints/animated_hint_right.dart';
import 'package:eecamp/widgets/control_page/control_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eecamp/providers/bluetooth_provider.dart';

enum MoveStates {forward, backward, left, right, stop}
enum ControlButtonTypes {forward, backward, left, right}

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  MoveStates state = MoveStates.stop;

  Future<void> sendMessage(String message) async {
    BluetoothProvider bluetooth = Provider.of<BluetoothProvider>(context, listen: false);
    if (!bluetooth.isDisconnected()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text("Disconnected"),
            icon: const Icon(Icons.bluetooth_disabled),
            actions: [
              TextButton(
                onPressed: () {
                  Provider.of<NavigationService>(context, listen: false).goHome();
                },
                child: const Text("Confirm"),
              ),
            ],
          );
        }
      );
    }
    else if (bluetooth.characteristic != null) {
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
                ControlButton(
                  type: ControlButtonTypes.forward,
                  state: state,
                  setMoveState: setMoveStates,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ControlButton(
                      type: ControlButtonTypes.left,
                      state: state,
                      setMoveState: setMoveStates,
                    ),
                    const SizedBox(
                      width: 100,
                      height: 100,
                      child: Icon(Icons.local_taxi),
                    ),
                    ControlButton(
                      type: ControlButtonTypes.right,
                      state: state,
                      setMoveState: setMoveStates,
                    ),
                  ],
                ),
                ControlButton(
                  type: ControlButtonTypes.backward,
                  state: state,
                  setMoveState: setMoveStates,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}