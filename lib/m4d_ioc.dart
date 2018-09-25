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

library m4d_ioc;

import 'package:validate/validate.dart';

typedef Map<String, dynamic> ToJson();

enum ServiceType {
    Instance,
    Function,
    Json
}

abstract class IOCModule {
    BindingSyntax bind(final Service service) => IOCContainer().bind(service);

    configure();

    List<IOCModule> get dependsOn => <IOCModule>[];

    void _resolveDependencies() {
        dependsOn.forEach((final IOCModule module) {
            module?._resolveDependencies();
        });
        configure();
    }
}

class Service {
    final String name;
    final ServiceType type;

    Service(this.name, this.type);

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
            other is Service &&
                runtimeType == other.runtimeType &&
                name == other.name &&
                type == other.type;

    @override
    int get hashCode =>
        name.hashCode ^
        type.hashCode;
}

/// [IOCContainer] is a singleton
class IOCContainer {
    static IOCContainer _singleton;

    final _services = Map<Service, dynamic>();

    factory IOCContainer.bindModules(final List<IOCModule> modules) {
        Validate.notNull(modules);

        if (_singleton == null) {
            _singleton = IOCContainer._private();
        }

        modules.forEach((final IOCModule module) => module?._resolveDependencies());

        return _singleton;
    }

    factory IOCContainer() => IOCContainer.bindModules(<IOCModule>[]);

    BindingSyntax bind(final Service service) {
        Validate.notNull(service);

        return BindingSyntax._private(service, this);
    }

    ResolveSyntax resolve(final Service service) => ResolveSyntax(_services[service]);

    IOCContainer._private();

    void _bindInstance(final Service service, final Object implementation) {
        Validate.notNull(service);
        Validate.notNull(implementation);
        Validate.isTrue(service.type == ServiceType.Instance);
        Validate.isTrue(implementation is! Type,
            "You must bind a concrete class to '${service.name}', "
                "not a type! ($implementation)");

        _services[service] = implementation;
    }

    void _bindFunction<R>(final Service service, R callback()) {
        Validate.notNull(service);
        Validate.notNull(callback);
        Validate.isTrue(service.type == ServiceType.Function);
        Validate.isTrue(callback is Function);
        //Validate.isInstance(instanceCheck<Function>(),function);

        _services[service] = callback;
    }

    void _bindToJson(final Service service, final ToJson callback) {
        Validate.notNull(service);
        Validate.notNull(callback);
        Validate.isTrue(service.type == ServiceType.Json);
        Validate.isTrue(callback is ToJson);
        //Validate.isInstance(instanceCheck<Function>(),function);

        _services[service] = callback;
    }

    void unregister(final Service service) => _services.remove(service);

    void clear() => _services.clear();

    int get nrOfServices => _services.length;
}

class BindingSyntax {
    Service _service;
    IOCContainer _container;

    void to(final Object implementation) => _container._bindInstance(_service, implementation);

    void toFunction<R>(R callback()) => _container._bindFunction<R>(_service, callback);

    void toJson(ToJson callback) => _container._bindToJson(_service, callback);

    BindingSyntax._private(this._service, this._container);
}

class ResolveSyntax {
    final _data;

    ResolveSyntax(this._data) { Validate.notNull(_data); }

    T as<T>([ T converter(final data) ]) => converter == null ? _data as T : converter(_data);

    dynamic get untyped => _data;
}
