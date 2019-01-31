// @TestOn("browser")
// unit
library test.unit.ioccontainer;

import 'package:test/test.dart';
import 'package:m4d_core/m4d_ioc.dart';

abstract class _BaseTestClass {}

abstract class JsonSerializer {
    Map<String, dynamic> toJson();
}

class _TestClass extends _BaseTestClass implements JsonSerializer {
    final String firstname;
    final String lastname;

    _TestClass(this.firstname, this.lastname);

    @override
    Map<String, dynamic> toJson() =>
        <String, dynamic>{ "firstname": firstname, "lastname": lastname};
}

final TestService            = Service<_TestClass>("test.unit.ioccontainer.TestService", ServiceType.Instance);
final TestProvider           = Service<ServiceProvider<_TestClass>>("test.unit.ioccontainer.TestProvider", ServiceType.Provider);
final TestServiceForFunction = Service<Function>("test.unit.ioccontainer.Function", ServiceType.Function);
final TestServiceFirstName   = Service<AsString>("test.unit.ioccontainer.FirstName", ServiceType.Function);
final TestServiceLastName    = Service<AsString>("test.unit.ioccontainer.LastName", ServiceType.Function);
final TestServiceForToJson   = Service<ToJson>("test.unit.ioccontainer.ToJson", ServiceType.Json);

class TestModule extends Module {
    @override
    configure() {
        bind(TestService).to(_TestClass("Gerda", "Riemann"));
    }
}

class TestModuleWithDependency extends Module {
    @override
    configure() {
        bind(TestServiceForFunction).toFunction(() => 99);
    }

    @override
    List<Module> get dependsOn => [ TestModule() ];
}

class TestServiceProvider implements ServiceProvider<_TestClass> {

    final _ioc = Container();

    @override
    _TestClass get() => _TestClass(_firstname, _lastname);

    String get _firstname => _service(TestServiceFirstName);
    String get _lastname => _service(TestServiceLastName);

    /// Checks for unregistered services!
    String _service(final Service service) {
        final function = _ioc.resolve(service).as<AsString>();
        if(function == null) {
            return "${service.name}:undefined";
        }
        return function();
    }
}

main() async {
    // final Logger _logger = new Logger("test.unit.ioccontainer.dat");

    //configLogging();

    //await saveDefaultCredentials();

    final container = Container();

    group('Container', () {
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
            object = container
                .resolve(TestService)
                .untyped;
            expect(object, isNull);
        }); // end of 'Unregister' test

        test('> Resolve via Service', () {
            container.bind(TestService).to(_TestClass("James", "Bond"));

            final object = TestService.resolve(); //.asInstance();

            expect(object, isNotNull);
            expect(object.firstname, "James");
            expect(object.lastname, "Bond");

        }); // end of 'Resolve via Service' test

        test('> Bind the same Service', () {
            container.bind(TestService).to(_TestClass("Mike", "Mitterer"));
            container.bind(TestService).to(_TestClass("Sarah", "Riedmann"));
            expect(container.nrOfServices, 1);

            final object = container.resolve(TestService).as<_TestClass>();
            expect(object.firstname, "Sarah");

            final object2 = TestService.resolve();
            expect(object2.firstname, "Sarah");
        }); // end of '' test

        test('> Register a function', () {
            num counter = 0;
            container.bind(TestServiceForFunction).toFunction<String>(() {
                return "abc${counter++}";
            });

            final object = container.resolve(TestServiceForFunction).as<Function>();

            expect(object is Function, isTrue);
            expect(object(), "abc0");
            expect(object(), "abc1");
        }); // end of 'Register a function' test

        test('> Resolve function via Service-Object', () {
            num counter = 0;
            container.bind(TestServiceForFunction).toFunction<String>(() {
                return "abc${counter++}";
            });

            final object = TestServiceForFunction.resolve();

            expect(object is Function, isTrue);
            expect(object(), "abc0");
            expect(object(), "abc1");
        }); // end of 'Resolve function via Service-Object' test

        test('> Register toJson-callback', () {
            container.bind(TestServiceForToJson).toJson(() {
                return <String, dynamic>{ 'name': "Mike"};
            });

            var object = container.resolve(TestServiceForToJson).as<ToJson>();
            expect(object is ToJson, isTrue);
            expect(object().containsKey("name"), isTrue);
            expect(object()["name"], "Mike");
        }); // end of 'Register toJson-callback' test

        test('> toJson-callback via Service-Object', () {
            container.bind(TestServiceForToJson).toJson(() {
                return <String, dynamic>{ 'name': "Mike"};
            });

            var object = TestServiceForToJson.resolve();
            expect(object is ToJson, isTrue);
            expect(object().containsKey("name"), isTrue);
            expect(object()["name"], "Mike");
        }); // end of 'toJson-callback via Service-Object' test

        test('> Serializer', () {
            container.bind(TestService).to(_TestClass("Mike", "Mitterer"));

            var object = container.resolve(TestService).as<JsonSerializer>();
            expect(object.toJson()["lastname"], "Mitterer");
        }); // end of 'Serializer' test

        test('> Serializer via Service-Object', () {
            container.bind(TestService).to(_TestClass("Mike", "Mitterer"));

            var object = TestService.to.subclass<JsonSerializer>();
            expect(object.toJson()["lastname"], "Mitterer");
        }); // end of 'Serializer via Service-Object' test

        test('> Provider I', () {
            container.bind(TestProvider).to(TestServiceProvider());

            final tc1 = container.resolve(TestProvider).asProvider<_TestClass>().get();

            expect(tc1, isNotNull);
            expect(tc1.firstname, "test.unit.ioccontainer.FirstName:undefined");
            expect(tc1.lastname, "test.unit.ioccontainer.LastName:undefined");

            container.bind(TestServiceFirstName).toFunction<String>(() => "Mike");
            container.bind(TestServiceLastName).toFunction<String>(() => "Mitterer");

            final tc2 = container.resolve(TestProvider).asProvider<_TestClass>().get();
            expect(tc2.firstname, "Mike");
            expect(tc2.lastname, "Mitterer");

        }); // end of 'Provider I' test

        test('> Provider via Service-Object', () {
            container.bind(TestProvider).to(TestServiceProvider());

            final tc1 = TestProvider.resolve().get();

            expect(tc1, isNotNull);
            expect(tc1.firstname, "test.unit.ioccontainer.FirstName:undefined");
            expect(tc1.lastname, "test.unit.ioccontainer.LastName:undefined");

            container.bind(TestServiceFirstName).toFunction<String>(() => "Mike");
            container.bind(TestServiceLastName).toFunction<String>(() => "Mitterer");

            final tc2 = TestProvider.resolve().get();
            expect(tc2.firstname, "Mike");
            expect(tc2.lastname, "Mitterer");
        }); // end of 'Provider via Service-Object' test

        test('> Service mapper', () {
            container.bind(TestProvider).to(TestServiceProvider());

            container.bind(TestServiceFirstName).toFunction<String>(() => "Mike");
            container.bind(TestServiceLastName).toFunction<String>(() => "Mitterer");

            final tc = TestProvider.to.map((ServiceProvider<_TestClass> sp)
                => "${sp.get().firstname} ${sp.get().lastname}");

            expect(tc, "Mike Mitterer");
            
        }); // end of 'Service mapper' test

        test('> Provider with wrong Type', () {
            expect(() => container.bind(TestProvider).to(_TestClass("Mike", "Mitterer")),
                throwsA(TypeMatcher<TypeError>()));

        }); // end of 'Provider I' test

    });
    // End of 'Container.dat' group

    group('Modules', () {
        setUp(() {});
        tearDown(() {
            container.clear();
        });

        test('> Register via Module', () {
            final container = Container.bindModules([ TestModule()]);

            var object = container.resolve(TestService).as<_TestClass>();
            expect(object.firstname, "Gerda");
        }); // end of 'Register via Module' test

        test('> Module with depenency', () {
            // After clear in TearDown
            expect(container.nrOfServices, 0);

            Container.bindModules([ TestModuleWithDependency()]);

            expect(container.nrOfServices, 2);

            final testclass = container.resolve(TestService).as<_TestClass>();
            expect(testclass.firstname, "Gerda");

            final function = container.resolve(TestServiceForFunction).as<Function>();
            expect(function(), 99);
            //final testclass = con

        }); // end of 'Module with depenency' test
    }); // End of '' group

    group("Tools", () {
        setUp(() {});
        tearDown(() {
            container.clear();
        });

        test('> Resolve Service as String', () {
            const url = "http://www.myhost.at/api/v1/jobs";
            const MyFancyURL  = Service<AsString>("test.unit.ioccontainer",ServiceType.Function);

            container.bind(MyFancyURL).toFunction<String>(() => url);

            expect(serviceAsString(MyFancyURL), url);
        });

    });
}

