import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wakelock_platform_interface/messages.dart';
import 'package:wakelock_platform_interface/method_channel_wakelock.dart';
import 'package:wakelock_platform_interface/wakelock_platform_interface.dart';

class _ApiLogger implements TestWakelockApi {
  final List<String> log = [];
  ToggleMessage toggleMessage;

  @override
  IsEnabledMessage isEnabled() {
    log.add('isEnabled');
    return IsEnabledMessage()..enabled = true;
  }

  @override
  void toggle(ToggleMessage message) {
    log.add('toggle');
    toggleMessage = message;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$WakelockPlatformInterface', () {
    test('$MethodChannelWakelock() is the default instance', () {
      expect(WakelockPlatformInterface.instance,
          isInstanceOf<MethodChannelWakelock>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        WakelockPlatformInterface.instance =
            ImplementsWakelockPlatformInterface();
      }, throwsA(isInstanceOf<AssertionError>()));
    });

    test('Can be mocked with `implements`', () {
      final mock = ImplementsWakelockPlatformInterface();
      when(mock.isMock).thenReturn(true);
      WakelockPlatformInterface.instance = mock;
    });

    test('Can be extended', () {
      WakelockPlatformInterface.instance = ExtendsVideoPlayerPlatform();
    });
  });

  group('$MethodChannelWakelock', () {
    final wakelock = MethodChannelWakelock();
    _ApiLogger logger;

    setUp(() {
      logger = _ApiLogger();
      TestWakelockApi.setup(logger);
    });

    test('toggle', () async {
      await wakelock.toggle(enable: true);

      expect(logger.log.last, 'toggle');
      expect(logger.toggleMessage.enable, isTrue);

      await wakelock.toggle(enable: false);

      expect(logger.log.last, 'toggle');
      expect(logger.log, hasLength(2));
      expect(logger.toggleMessage.enable, isFalse);
    });

    test('enabled', () async {
      final enabled = await wakelock.enabled;

      expect(logger.log.last, 'isEnabled');
      expect(enabled, isTrue);
    });
  });
}

class ImplementsWakelockPlatformInterface extends Mock
    implements WakelockPlatformInterface {}

class ExtendsVideoPlayerPlatform extends WakelockPlatformInterface {}
