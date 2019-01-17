// @TestOn("browser")
// unit
library test.unit.mdlcomponenthandler;

import 'package:test/test.dart';
import 'package:m4d_core/m4d_core.dart';
import 'package:m4d_core/services.dart' as service;

// import 'package:logging/logging.dart';

//@ioc.application
class MySpecialApplication extends MaterialApplication {
    String get id => "MySpecialApplication";    
}

main() async {
    // final Logger _logger = new Logger("test.unit.mdlcomponenthandler");

    group('MdlComponentHandler', () {
        setUp(() {
            componentHandler().bind(service.Application).to(MySpecialApplication());
        });
        
        test('> Register Application', () async {
            final app = await componentHandler().upgrade<MySpecialApplication>();
            expect(app, isNotNull);
            expect(app is MySpecialApplication, isTrue);
            expect(app.id, "MySpecialApplication");

        }); // end of 'Register Application' test
                
    });
    // End of 'MdlComponentHandler' group
}

// - Helper --------------------------------------------------------------------------------------
