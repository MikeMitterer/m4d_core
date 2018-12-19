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
typedef Map<String, Function> ToEvents();
typedef String AsString();

Container _container = Container();

abstract class Binder {
    void bind();
}

enum ServiceType {
    Instance,
    Function,
    Json,
    Provider
}

abstract class Module {
    BindingSyntax bind(final Service service) => _container.bind(service);

    configure();

    List<Module> get dependsOn => <Module>[];

    void _resolveDependencies() {
        dependsOn.forEach((final Module module) {
            module?._resolveDependencies();
        });
        configure();
    }
}

class Service<R> {
    /// Service name e.g. 'm4d_formatter.Formatters'
    final String name;

    /// Very basic type-check (Instance, Function, Json)
    final ServiceType type;

    const Service(this.name, this.type);

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

    R resolve() => ServiceResolveSyntax<R>(_container.raw(this))._as();
    ServiceResolveSyntax<R> get to => ServiceResolveSyntax<R>(_container.raw(this));
}

class ServiceResolveSyntax<R> {
    final R _data;

    // Data can be null!
    ServiceResolveSyntax(this._data);

    /// To convert R to one of it's subclasses
    ///
    ///     class TestClass implements JsonSerializer {
    ///         ...
    ///     }
    ///
    ///     var object = TestService.resolveTo().subclass<JsonSerializer>();
    ///
    S subclass<S>() => _data as S;

    /// Map from one type into another
    ///
    ///     final tc = TestProvider.map((ServiceProvider<_TestClass> sp)
    ///         => "${sp.get().firstname} ${sp.get().lastname}");
    ///
    M map<M>(M mapper(R value)) => mapper(_as());

    R _as() => _data;
}

class InstanceService extends Service {
  InstanceService(final String name) : super(name, ServiceType.Instance);
}

class ServiceProvider<T> {
    final T _instance;
    ServiceProvider(this._instance);

    T get() => _instance;
}

/// [Container] is a singleton
class Container {
    static Container _singleton;

    final _services = Map<Service, dynamic>();

    factory Container.bindModules(final List<Module> modules) {
        Validate.notNull(modules);

        if (_singleton == null) {
            _singleton = Container._private();
        }

        modules.forEach((final Module module) => module?._resolveDependencies());

        return _singleton;
    }

    factory Container() => Container.bindModules(<Module>[]);

    Container._private();

    /// Binds a Service-ID ([service]) to its implementation
    BindingSyntax bind(final Service service) {
        Validate.notNull(service);
        return BindingSyntax._private(service);
    }

    ContainerResolveSyntax resolve(final Service service) => ContainerResolveSyntax(raw(service));

    dynamic raw(final Service service) => _services[service];

    void unregister(final Service service) => _services.remove(service);

    void clear() => _services.clear();

    int get nrOfServices => _services.length;
}

class BindingSyntax<T> {
    Service _service;

    void to(final Object implementation) {
//        if(_service.rtType != null) {
//            Validate.isTrue(_service.rtType is implementation.runtimeType)
//        }
        if(_service.type == ServiceType.Instance) {
            _InstanceBinder(_service, implementation).bind();
        } else {
            _ProviderBinder(_service, implementation).bind();
        }
    }

    void toFunction<R>(R callback()) => _FunctionBinder<R>(_service, callback).bind();

    void toJson(ToJson callback) => _JsonBinder(_service, callback).bind();

    void toEvents(ToEvents callback) => _EventsBinder(_service, callback).bind();

    BindingSyntax._private(this._service);
}

class ContainerResolveSyntax {
    final _data;

    // Data can be null!
    ContainerResolveSyntax(this._data);

    R as<R>() {
        if(_data is ServiceProvider<R>) {
            return (_data as ServiceProvider<R>).get();
        } else {
            return _data;
        }
    }

    ServiceProvider<R> asProvider<R>() {
        if(_data is ServiceProvider<R>) {
            return _data as ServiceProvider<R>;
        } else {
            return ServiceProvider<R>(_data);
        }
    }

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
        Validate.isTrue(_service.type == ServiceType.Instance,
            "You can bind ${_service.name} only to ${_service.type}");

        Validate.isTrue(_implementation is! Type,
            "You must bind a concrete class to '${_service.name}', "
                "not a type! ($_implementation)");

        _container._services[_service] = _implementation;
    }
}

class _ProviderBinder extends Binder {
    final Service _service;
    final ServiceProvider _implementation;

    _ProviderBinder(this._service, this._implementation);

    @override
    void bind() {
        Validate.notNull(_service);
        Validate.notNull(_implementation);
        Validate.isTrue(_service.type == ServiceType.Provider,
            "You can bind ${_service.name} only to ${_service.type}");

        Validate.isTrue(_implementation is ServiceProvider,
            "${_service.name} must be of type ${_service.type}");

        Validate.isTrue(_implementation is! Type,
            "You must bind a concrete class to '${_service.name}', "
                "not a type! ($_implementation)");

        _container._services[_service] = _implementation;
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
        Validate.isTrue(_service.type == ServiceType.Function,
            "${_service.name} must be a '${_service.type}' but was '${ServiceType.Function}'!");
        
        Validate.isTrue(_callback is R Function());

        _container._services[_service] = _callback;
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

        _container._services[_service] = _callback;
    }
}

class _EventsBinder extends Binder {
    final Service _service;
    final ToEvents _callback;

    _EventsBinder(this._service,this._callback);

    @override
    void bind() {
        Validate.notNull(_service);
        Validate.notNull(_callback);
        Validate.isTrue(_service.type == ServiceType.Function);
        Validate.isTrue(_callback is ToEvents);

        _container._services[_service] = _callback;
    }
}

