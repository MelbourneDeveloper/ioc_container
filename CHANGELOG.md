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
## Async Focus
This version focuses on async initalization. New methods `addAsync()` and `addSingletonAsync()` make it easy to add async factories, and you can now perform async disposals. Call `getAsync()` or `getAsyncSafe()` to get async services. 
## Performance enhancement
There is a big improvement on the `get()` method. This version brings a set of benchmarks that measure performance against similar libraries. Check the benchmarks folder.
## Breaking Changes 
- `init()` renamed to `getAsync()`. The feedback was that init was a bad name
- The `dispose()` method now returns a future. If you need to dispose services and wait for the result, you must `await` this call
- `toContainer()` no longer initializes all singletons and the isLazy parameter was removed. All initialization is lazy now. If you want to intialize all singletons call the `initializeSingletons()` extension
## Other Changes
- This version drops the `meta` dependency. This means that the container no
longer has the @immutable annotation. See the documentation about immutability.
- Containers now have an `isScoped` flag. If this is true, all factories act like singletons. Use the `scoped()` method to create a scoped version of the container
- The `merge()` method allows you to copy the singletons/scope from one container to another
## 1.0.1
- Fix Dart formatting
## 1.0.2
- Firebase doco