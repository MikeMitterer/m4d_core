/*
 * Copyright (c) 2015, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 *
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * The core - handles the initialisation process and
 * defines the base-class for all components
 */
library m4d_core;

import 'dart:html' as dom;

import 'dart:collection';
import 'dart:async';
import 'dart:js';

import 'package:logging/logging.dart';
import 'package:validate/validate.dart';

import 'core/interfaces.dart';
import 'services.dart' as service;
import 'm4d_ioc.dart' as ioc;

export 'core/annotations.dart';
export 'core/interfaces.dart';

part "core/utils.dart";

part "core/MdlEventListener.dart";

part "core/MdlComponent.dart";
part "core/MdlComponentHandler.dart";
part "core/MdlConfig.dart";
part 'core/DomRenderer.dart';

abstract class MdlDataConsumer {
    void consume(final data);
}

final MdlComponentHandler _componenthandler = new MdlComponentHandler();

MdlComponentHandler componentFactory() => componentHandler();

MdlComponentHandler componentHandler() {
    return _componenthandler;
}







