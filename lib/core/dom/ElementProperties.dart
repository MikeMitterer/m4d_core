/*
 * Copyright (c) 2018, Michael Mitterer (office@mikemitterer.at),
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

part of m4d_core;

class ElementProperties {
    static const String DISABLED    = "disabled";
    static const String IS_DISABLED = "id-disabled";

    /// Checks if the [element] has either the class set or if the attribute is available
    static bool hasAttributeOrClass(final dom.Element element,final List<String> classesOrAttributes) {
        Validate.notNull(element);
        Validate.notNull(classesOrAttributes);

        for(final String classOrAttribute in classesOrAttributes) {
            final bool hasClass = element.classes.contains(classOrAttribute);
            if(hasClass) {
                return true;
            }
            final bool isAttributeSet = element.attributes.containsKey(classOrAttribute);
            if(isAttributeSet) {
                return ((new _DataValue(element.attributes[classOrAttribute])).asBool(handleEmptyStringAs: true));
            }
        }
        return false;
    }

    /// Checks if [element] has either the attribute "disabled" set or if it has a 'is-disabled' class
    static bool isDisabled(final dom.Element element) => hasAttributeOrClass(element,[ DISABLED, IS_DISABLED]);
}

