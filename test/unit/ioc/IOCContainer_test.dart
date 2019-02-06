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
    static int instanceCounter = 0;

    final String firstname;
    final String lastname;

    _TestClass(this.firstname, this.lastname) { instanceCounter++; }

    @override
    Map<String, dynamic> toJson() =>
        <String, dynamic>{ "firstname": firstname, "lastname": lastname};
}

final TestService            = Service<_TestClass>("test.unit.ioccontainer.TestService", ServiceType.Instance);
final TestProvider           = Service<ServiceProvider<_TestClass>>("test.unit.ioccontainer.TestProvider", ServiceType.Provider);
final TestProvider2          = Service<ServiceProvider<_TestClass>>("test.unit.ioccontainer.TestProvider2", ServiceType.Provider);
final TestServiceForFunction = Service<Function>("test.unit.ioccontainer.Function", ServiceType.Function);
final TestServiceFirstName   = Service<AsString>("test.unit.ioccontainer.FirstName", ServiceType.Function);
final TestServiceLastName    = Service<AsString>("test.unit.ioccontainer.LastName", ServiceType.Function);
final TestServiceForToJson   = Service<ToJson>("test.unit.ioccontainer.ToJson", ServiceType.Json);

class TestModule extends Module {
    @override
    configure() {
        TestService.bind.to(_TestClass("Gerda", "Riemann"));
        //bind(TestService).to(_TestClass("Gerda", "Riemann"));
    }
}

class TestModuleWithDependency extends Module {
    @override
    configure() {
        TestServiceForFunction.bind.to(() => 99);
        //bind(TestServiceForFunction).toFunction(() => 99);
    }

    @override
    List<Module> get dependsOn => [ TestModule() ];
}

class TestServiceProvider implements ServiceProvider<_TestClass> {

    @override
    _TestClass get() => _TestClass(_firstname, _lastname);

    String get _firstname => TestServiceFirstName.toString();
    String get _lastname => TestServiceLastName.toString();
}

main() async {
    // final Logger _logger = new Logger("test.unit.ioccontainer.dat");

    //configLogging();

    //await saveDefaultCredentials();

    final container = Container();

    group('Container', () {
        setUp(() {
            _TestClass.instanceCounter = 0;
        });
        tearDown(() {
            container.clear();
        });

        test('> Unregister', () {
            TestService.bind.to(_TestClass("Mike", "Mitterer"));

            var object = TestService.resolve();
            expect(object, isNotNull);

            print(object.runtimeType);
            expect(object is _TestClass, isTrue);

            container.unregister(TestService);
            object = TestService.resolve();
            expect(object, isNull);

        }); // end of 'Unregister' test

        test('> Resolve via Service', () {
            TestService.bind.to(_TestClass("James", "Bond"));

            final object = TestService.resolve(); //.asInstance();

            expect(object, isNotNull);
            expect(object.firstname, "James");
            expect(object.lastname, "Bond");

        }); // end of 'Resolve via Service' test

        test('> Bind the same Service', () {
            TestService.bind.to(_TestClass("Mike", "Mitterer"));
            TestService.bind.to(_TestClass("Sarah", "Riedmann"));
            expect(container.nrOfServices, 1);

            final object = TestService.resolve();
            expect(object.firstname, "Sarah");

            final object2 = TestService.resolve();
            expect(object2.firstname, "Sarah");
        }); // end of '' test

        test('> Register a function', () {
            num counter = 0;
            TestServiceForFunction.bind.to(() {
                return "abc${counter++}";
            });

            final object = TestServiceForFunction.resolve();

            expect(object is Function, isTrue);
            expect(object(), "abc0");
            expect(object(), "abc1");
        }); // end of 'Register a function' test

        test('> Register toJson-callback directly to service', () {
            TestServiceForToJson.bind.to(() {
                return <String, dynamic>{ 'name': "Mike"};
            });

            var object = TestServiceForToJson.resolve();
            expect(object, isNotNull);
            expect(object is ToJson, isTrue);
            expect(object().containsKey("name"), isTrue);
            expect(object()["name"], "Mike");

            expect(TestServiceForToJson.toString(), '{"name":"Mike"}');
        });

        test('> Serializer', () {
            TestService.bind.to(_TestClass("Mike", "Mitterer"));

            // var object = container.resolve(TestService).as<JsonSerializer>();
            var object = TestService.as.subclass<JsonSerializer>();
            expect(object.toJson()["lastname"], "Mitterer");
        }); // end of 'Serializer' test

        test('> Provider I', () {
            TestProvider.bind.to(TestServiceProvider());

            final tc1 = TestProvider.resolve().get();

            expect(tc1, isNotNull);
            expect(tc1.firstname, "test.unit.ioccontainer.FirstName:ServiceType.Function:<undefined>");
            expect(tc1.lastname, "test.unit.ioccontainer.LastName:ServiceType.Function:<undefined>");

            TestServiceFirstName.bind.to(() => "Mike");
            TestServiceLastName.bind.to(() => "Mitterer");

            final tc2 = TestProvider.resolve().get();;
            expect(tc2.firstname, "Mike");
            expect(tc2.lastname, "Mitterer");

        }); // end of 'Provider I' test

        test('> ServiceProvider with Factory-CTOR should produce only one instance', () {
            expect(_TestClass.instanceCounter, 0);

            TestProvider2.bind.to(ServiceProvider<_TestClass>(()
                => _TestClass("Gerda", "Riedmann")));

            // Factory function was not called because we did not execute "get"
            expect(_TestClass.instanceCounter, 0);

            final tc = TestProvider2.resolve().get();
            expect(tc.firstname, "Gerda");
            expect(tc.lastname, "Riedmann");
            expect(_TestClass.instanceCounter, 1);

            [1,2,3,4,5].forEach((_) {
                final tc = TestProvider2.resolve().get();
                expect(tc.firstname, "Gerda");
                expect(tc.lastname, "Riedmann");
                expect(_TestClass.instanceCounter, 1);
            });

        });

        test('> Service mapper', () {
            TestProvider.bind.to(TestServiceProvider());

            TestServiceFirstName.bind.to(() => "Mike");
            TestServiceLastName.bind.to(() => "Mitterer");

            final tc = TestProvider.as.map((ServiceProvider<_TestClass> sp)
                => "${sp.get().firstname} ${sp.get().lastname}");

            expect(tc, "Mike Mitterer");
            
        }); // end of 'Service mapper' test

        test('> Provider with wrong Type', () {

            // Wird vom Analyzer erkannt!
            // TestProvider.bind.to(_TestClass("Mike", "Mitterer");

            expect(() => container.bind(TestProvider).to(_TestClass("Mike", "Mitterer")),
                throwsA(TypeMatcher<TypeError>()));

        }); // end of 'Provider I' test

        test('> Bind directly to Service', () {
            TestProvider.bind.to(TestServiceProvider());

            final obj = TestProvider.resolve().get();
            expect(obj, TypeMatcher<_TestClass>());

            final obj2 = container.resolve(TestProvider).as<TestServiceProvider>().get();
            expect(obj2, TypeMatcher<_TestClass>());
        });

    });
    // End of 'Container.dat' group

    group('Modules', () {
        setUp(() {});
        tearDown(() {
            container.clear();
        });

        test('> Register via Module', () {
            Container.bindModules([
                TestModule()
            ]);

            var object = TestService.as.subclass<_TestClass>();
            expect(object.firstname, "Gerda");
        }); // end of 'Register via Module' test

        test('> Module with depenency', () {
            // After clear in TearDown
            expect(container.nrOfServices, 0);

            Container.bindModules([
                TestModuleWithDependency()
            ]);

            expect(container.nrOfServices, 2);

            final testclass = TestService.as.subclass<_TestClass>();
            expect(testclass.firstname, "Gerda");

            final function = TestServiceForFunction.resolve();
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
            final MyFancyURL = Service<AsString>("test.unit.ioccontainer",ServiceType.Function);

            MyFancyURL.bind.to(() => url);

            expect(serviceAsString(MyFancyURL), url);
            expect(MyFancyURL.toString(), url);
        });

    });
}

