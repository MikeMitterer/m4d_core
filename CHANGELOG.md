# Change Log for m4d_core
Material Design 4 Dart

## [Unreleased](http://github.com/mikemitterer/m4d_core/compare/v0.2...HEAD)

### Feature
* ServiceProvider acts as Singleton-Factory [2a5432a](https://github.com/mikemitterer/m4d_core/commit/2a5432a0744b5eaada71f66e34926f5bffb907ae)
* Bind directly to Service - makes the whole thing typesafe [99296d3](https://github.com/mikemitterer/m4d_core/commit/99296d3a2b280b96fa05e8a69ef97d5b46c08468)
* Added helper function to convert a service to a string (serviceAsString) [2f2715a](https://github.com/mikemitterer/m4d_core/commit/2f2715afc7d684fca7b208b365a0785314496af8)

### Bugs
* ServiceProvider as Singleton for all registered types lead to TypeErrors [7bbac31](https://github.com/mikemitterer/m4d_core/commit/7bbac31155840ec650f3c5d0ef747bf12f72e903)
* Servic-CTOR was not const [93db395](https://github.com/mikemitterer/m4d_core/commit/93db3951e7294ce2c01d6c05385c92b7fc887d0c)

### Refactor
* Removed global _container variable [f57afce](https://github.com/mikemitterer/m4d_core/commit/f57afcedfd66ef3a643635479d7d7d1246c13b42)
* Changed 'componentHandler().run to ...uprgrade() [7cdfdca](https://github.com/mikemitterer/m4d_core/commit/7cdfdca574bac1e142ca1ae4429d69fa98b74789)

## [v0.2](http://github.com/mikemitterer/m4d_core/compare/v0.1...v0.2) - 2018-12-19

### Feature
* ioc-Container is more typesafe [a653946](https://github.com/mikemitterer/m4d_core/commit/a653946edd8df74340f47fc5a5ba925d666f8347)
* IOC-Container can register Events [1b090bf](https://github.com/mikemitterer/m4d_core/commit/1b090bf46bf60ac351ea5d2cbd5612cce11b9a6d)
* Added some DOM-Helper functions [bfac090](https://github.com/mikemitterer/m4d_core/commit/bfac09091374eed4a6b13f78e885c6c348b9bcd0)
* Added ObservableProperty and ObservableList [7e0120a](https://github.com/mikemitterer/m4d_core/commit/7e0120ac086b20f9560c52f8843ba4cbc96517e4)
* ObservableProperty added [6e0f459](https://github.com/mikemitterer/m4d_core/commit/6e0f4597f47f78ad19a6a1e38f306cb721950e25)

### Docs
* Link to m4d_components [0ffb567](https://github.com/mikemitterer/m4d_core/commit/0ffb567503a318043ef730463e99fb270543e7dd)
* Basic version for README [1c940ca](https://github.com/mikemitterer/m4d_core/commit/1c940caba5a1f5fe151bb960209daf4184955e87)


This CHANGELOG.md was generated with [**Changelog for Dart**](https://pub.dartlang.org/packages/changelog)
