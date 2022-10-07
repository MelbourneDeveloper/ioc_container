## 0.1.0
- Initial version.
## 0.2.0
- Add a container parameter to singleton factories
## 0.3.0
- Remove fluent style returns
## 0.4.0
- Refactor (breaking changes) to fix singleton issues
## 0.5.0
- Drop a dependency version down
## 0.6.0
- Add more documentation and fix some code analysis issues
## 0.7.0
- Give the name of a missing service in the exception. 
## 0.8.0
- Adds scoping with the `scoped()` and `getScoped()` extensions
- Adds ability to dispose of scoped services with the `dispose` extension
## 0.9.0
- Documentation
## 0.10.0
- Documentation
## 0.11.0
- Add the `init()` extension for async initialization
## 0.12.0
- Documentation
## 0.13.0
- Documentation
## 0.14.0
- Documentation
## 0.15.0
- Documentation
## 1.0.0
- Breaking change: `toContainer()` no longer initializes all singletons and the isLazy parameter was removed. All initialization is lazy now. If you want to intialize all singletons call the `initializeSingletons()` extension