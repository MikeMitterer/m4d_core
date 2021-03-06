@TestOn("chrome")
library test.unit.core.mdlcomponent;

import 'dart:async';
import 'dart:html' as dom;
import 'package:test/test.dart';

import 'package:m4d_core/m4d_core.dart';
import 'package:m4d_core/m4d_ioc.dart' as ioc;
//import 'package:m4d_core/m4d_mock.dart' as mdlmock;
//import 'package:mdl/mdlmock.dart' as mdlmock;

import "package:console_log_handler/console_log_handler.dart";

//import 'MdlComponent_test.reflectable.dart';

part 'lib/SlowComponent.dart';

main() async {
    // final Logger _logger = new Logger("test.MdlComponent");

    //initializeReflectable();
    configLogging();

    final DomRenderer renderer = new DomRenderer();
    final dom.DivElement parent = new dom.DivElement();

    final String html = '''
        <div class="mdl-panel">
            <button id="first" class="mdl-button mdl-ripple-effect">First button</button>            
            <button id="second" class="mdl-button mdl-ripple-effect">Second button</button>
            <canvas width="100" height="100">Loading</canvas>            
            <slow-component></slow-component>
        </div>    
    '''.trim().replaceAll(new RegExp(r"\s+")," ");

    group('MdlComponent', () {
        setUp(() async {
            await registerSlowComponent();
            await componentHandler().upgrade();

//            mdlmock.setUpInjector();
//
//            mdlmock.mockComponentHandler(mdlmock.injector(), mdlmock.componentFactory());
//            await prepareMdlTest( () async {
//                await registerMaterialButton();
//                await registerSlowComponent();
//                await registerMdlTemplateComponents();
//            });
        });

//        test('> Registration', () async {
//            final dom.HtmlElement element = await renderer.render(parent,html);
//
//            await componentHandler().upgradeElement(element);
////            final MaterialButton button = MaterialButton.widget(element.querySelector("#second"));
//
//            expect(button,isNotNull);
//            button.downgrade();
//
//        }); // end of 'Registration' test

        test('> SlowComponent', () async {
            final dom.HtmlElement element = await renderer.render(parent,html);

            await componentHandler().upgradeElement(element);
            final SlowComponent component = SlowComponent.widget(element.querySelector("slow-component"));

            // It takes a while until DOM is rendered for SlowComponent
            // (requestAnimationFrame is used for rendering)
            expect(component.element.innerHtml,isEmpty);

            // wait for 500ms to give requestAnimationFrame a chance to do its work
            // insertElement + removes mdl-content__loading flag from element
            await new Future.delayed(new Duration(milliseconds: 500), expectAsync0( () {
                final SlowComponent component = SlowComponent.widget(element.querySelector("slow-component"));
                //_logger.info(component.element.innerHtml);
                expect(component,isNotNull);
            }));

            component.downgrade();

            await componentHandler().downgradeElement(element);

            bool foundException = false;
            try {
                // Throws exception because element was downgraded
                SlowComponent.widget(element.querySelector("slow-component"));
            } catch(_) {
                foundException = true;
            }
            expect(foundException,isTrue);

        }); // end of 'SlowComponent' test

        test('> waitForChild', () async {
            final dom.HtmlElement element = await renderer.render(parent,html);

            await componentHandler().upgradeElement(element);
            final SlowComponent component = SlowComponent.widget(element.querySelector("slow-component"));

            // simple-div is a child within <slow-component>
            final dom.DivElement div = await component.waitForChild(".simple-div");
            expect(div,isNotNull);
            expect(div is dom.DivElement,isTrue);

        }); // end of 'waitForChild' test

        test('> Timeout', () async {
            final dom.HtmlElement element = await renderer.render(parent,html);

            await componentHandler().upgradeElement(element);
            final SlowComponent component = SlowComponent.widget(element.querySelector("slow-component"));

            // simple-div is a child within <slow-component>
            // Remember: Rendering takes ~400ms!
            bool foundException = false;
            try {
                // Wait only 50ms (default wait-time (50ms) times maxIterations)
                await component.waitForChild(".simple-div", maxIterations: 1);
            } on TimeoutException catch(_) {
                foundException = true;
            }
            expect(foundException,isTrue);

        }); // end of 'Timeout' test

    });
    // End of 'MdlComponent' group
}

// - Helper --------------------------------------------------------------------------------------
