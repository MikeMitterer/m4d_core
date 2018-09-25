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

abstract class Binder {
    void bind();
}

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
    /// Service name e.g. 'm4d_formatter.Formatters'
    final String name;

    /// Very basic type-check (Instance, Function, Json)
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

    /// Binds a Service-ID ([service]) to its implementation
    BindingSyntax bind(final Service service) {
        Validate.notNull(service);

        return BindingSyntax._private(service);
    }

    ResolveSyntax resolve(final Service service) => ResolveSyntax(_services[service]);

    IOCContainer._private();

    void unregister(final Service service) => _services.remove(service);

    void clear() => _services.clear();

    int get nrOfServices => _services.length;
}

class BindingSyntax {
    Service _service;

    void to(final Object implementation) => _InstanceBinder(_service, implementation).bind();

    void toFunction<R>(R callback()) => _FunctionBinder<R>(_service, callback).bind();

    void toJson(ToJson callback) => _JsonBinder(_service, callback).bind();

    BindingSyntax._private(this._service);
}

class ResolveSyntax {
    final _data;

    // Data can be null!
    ResolveSyntax(this._data);

    T as<T>([ T converter(final data) ]) => converter == null ? _data as T : converter(_data);

    dynamic get untyped => _data;
}

class _InstanceBinder extends Binder {
    final Service _service;
    final Object _implementation;

    _InstanceBinder(this._service, this._implementation);

    @override
    void bind() {
        Validate.notNull(_service);
        Validate.notNull(_implementation);
        Validate.isTrue(_service.type == ServiceType.Instance);
        Validate.isTrue(_implementation is! Type,
            "You must bind a concrete class to '${_service.name}', "
                "not a type! ($_implementation)");

        IOCContainer()._services[_service] = _implementation;
    }
}

class _FunctionBinder<R> extends Binder {
    final Service _service;
    final R Function() _callback;

    _FunctionBinder(this._service, this._callback);

    @override
    void bind() {
        Validate.notNull(_service);
        Validate.notNull(_callback);
        Validate.isTrue(_service.type == ServiceType.Function);
        Validate.isTrue(_callback is R Function());

        IOCContainer()._services[_service] = _callback;
    }
}

class _JsonBinder extends Binder {
    final Service _service;
    final ToJson _callback;

    _JsonBinder(this._service,this._callback);

    @override
    void bind() {
        Validate.notNull(_service);
        Validate.notNull(_callback);
        Validate.isTrue(_service.type == ServiceType.Json);
        Validate.isTrue(_callback is ToJson);

        IOCContainer()._services[_service] = _callback;
    }
}

