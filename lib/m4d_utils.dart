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
library m4d_utils;

import 'dart:async';

// import 'package:logging/logging.dart';
import 'package:validate/validate.dart';

part 'utils/StringToFunction.dart';
part "utils/ConvertValue.dart";

/// Waits until [test] returns true
///
/// Can be used to test if an element is already in the DOM
Future<int> waitUntil(bool test(),{
    final int maxIterations: 100,
    final Duration step: const Duration(milliseconds: 10) }) async {

    int iterations = 0;
    for(;iterations < maxIterations;iterations++) {
        await Future.delayed(step);
        if(test()) {
            break;
        }
    }
    if(iterations >= maxIterations) {
        throw TimeoutException(
            "Condition not reached within ${iterations * step.inMilliseconds}ms");
    }
    return iterations;
}


