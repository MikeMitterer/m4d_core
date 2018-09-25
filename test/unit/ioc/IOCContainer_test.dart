// @TestOn("browser")
// unit
library test.unit.ioccontainer;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:m4d_core/m4d_ioc.dart';

import 'package:logging/logging.dart';

abstract class _BaseTestClass {}

abstract class JsonSerializer {
    Map<String,dynamic> toJson();
}

class _TestClass extends _BaseTestClass implements JsonSerializer {
    final String firstname;
    final String lastname;

    _TestClass(this.firstname, this.lastname);

  @override
  Map<String,dynamic> toJson() => <String,dynamic>{ "firstname" : firstname, "lastname" : lastname };
}

final TestService =  Service("test.unit.ioccontainer.TestService",ServiceType.Instance);
final TestServiceForFunction =  Service("test.unit.ioccontainer.Function",ServiceType.Function);
final TestServiceForToJson =  Service("test.unit.ioccontainer.ToJson",ServiceType.Json);


class TestModule  extends IOCModule {
  @override
  configure() {
    bind(TestService).to(_TestClass("Gerda","Riemann"));
  }
}

class TestModuleWithDependency extends IOCModule {
  @override
  configure() {
      bind(TestServiceForFunction).toFunction(() => 99);
  }

  @override
  List<IOCModule> get dependsOn => [ TestModule() ];
}

main() async {
    // final Logger _logger = new Logger("test.unit.ioccontainer.dat");

    //configLogging();

    //await saveDefaultCredentials();

    final container = IOCContainer();

    group('IOCContainer', () {
        setUp(() {});
        tearDown(() {
            container.clear();
        });

        test('> Unregister', () {
            container.bind(TestService).to(_TestClass("Mike", "Mitterer"));

            var object = container.resolve(TestService).as<_TestClass>();
            expect(object, isNotNull);

            print(object.runtimeType);
            expect(object is _TestClass, isTrue);

            container.unregister(TestService);
            object = container.resolve(TestService).untyped;
            expect(object, isNull);
        }); // end of 'Unregister' test

        test('> Bind the same Service', () {
            container.bind(TestService).to(_TestClass("Mike", "Mitterer"));
            container.bind(TestService).to(_TestClass("Sarah", "Riedmann"));
            expect(container.nrOfServices, 1);

            var object = container.resolve(TestService).as<_TestClass>();
            expect(object.firstname, "Sarah");

        }); // end of '' test
                
        test('> Register a function', () {
            num counter = 0;
            container.bind(TestServiceForFunction).toFunction<String>(() {
                return "abc${counter++}";
            });
            var object = container.resolve(TestServiceForFunction).as<Function>();
            expect(object is Function, isTrue);
            expect(object(), "abc0");
            expect(object(), "abc1");
        }); // end of 'Register a function' test

        test('> Regist toJson-callback', () {
            container.bind(TestServiceForToJson).toJson(() {
                return <String,dynamic>{ 'name' : "Mike" };
            });

            var object = container.resolve(TestServiceForToJson).as<ToJson>();
            expect(object is ToJson, isTrue);
            expect(object().containsKey("name"), isTrue);
            expect(object()["name"], "Mike");

        }); // end of 'Regist toJson-callback' test

        test('> Serializer', () {
            container.bind(TestService).to(_TestClass("Mike", "Mitterer"));

            var object = container.resolve(TestService).as<JsonSerializer>();
            expect(object.toJson()["lastname"],"Mitterer");
        }); // end of 'Serializer' test

    });
    // End of 'IOCContainer.dat' group

    group('Modules', () {
        setUp(() {});
        tearDown(() {
            container.clear();
        });

        test('> Register via Module', () {
            final container = IOCContainer.bindModules([ TestModule() ]);

            var object = container.resolve(TestService).as<_TestClass>();
            expect(object.firstname, "Gerda");

        }); // end of 'Register via Module' test

        test('> Module with depenency', () {
            // After clear in TearDown
            expect(container.nrOfServices, 0);

            IOCContainer.bindModules([ TestModuleWithDependency() ]);

            expect(container.nrOfServices, 2);

            final testclass = container.resolve(TestService).as<_TestClass>();
            expect(testclass.firstname, "Gerda");

            final function = container.resolve(TestServiceForFunction).as<Function>();
            expect(function(), 99);
            //final testclass = con

        }); // end of 'Module with depenency' test

    }); // End of '' group
}

// - Helper --------------------------------------------------------------------------------------
