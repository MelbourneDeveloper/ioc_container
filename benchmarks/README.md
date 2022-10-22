## Performance Comparison Benchmarks
This folder contains a project that does benchmark comparisons with some other libraries. The benchmarks attempt to perform the same task across libraries, but you should note that the libraries are not identical not all libraries have a focus on DI. You should choose the library that best fits your needs. The only aim here is point out that ioc_container performs well. 

_*Disclaimer: there is no claim that the methodology in these benchmarks is correct. It's possible that my benchmarks don't compare the same thing across libraries. I invite you and the library authors to check these and let me know if there are any mistakes*_


Times in microseconds (μs)

macOS - Mac Mini - 3.2 Ghz 6 Core Intel Core i7

|                  	| ioc_container         	| get_it                	| flutter_simple_DI     	| Riverpod             	|
|------------------	|-----------------------	|-----------------------	|-----------------------	|----------------------	|
| Get              	| 1.152956           	    | 1.6829909085045458 	    | 23.56929286888922  	    |                      	|
| Get Async        	| 14.607701157643634 	    | 8.161859669070166  	    |                       	|                      	|
| Get Scoped       	| 2.718096281903718  	    |                       	|                       	| 7.804826666666667 	  |
| Register and Get 	| 3.6589533333333333 	    | 13.37688998488012  	    | 26.387617939769935 	    |                      	|


Windows 10 - AMD Ryzen 9 3900X 12-Core Processor, 3793 Mhz, 12 Core(s), 24 Logical Processor(s)

|                  	| ioc_container         	| get_it                	| flutter_simple_DI     	| Riverpod             	|
|------------------	|-----------------------	|-----------------------	|-----------------------	|----------------------	|
| Get              	| 1.1175335           	  | 1.5489277255361373 	    | 28.234064595612427  	  |                      	|
| Get Async        	| 16.87476954663538 	    | 8.672696413651794  	    |                       	|                      	|
| Get Scoped       	| 2.630455  	            |                         |                       	| 8.149182729222566 	  |
| Get Scoped Async  | 20.81655432998111  	    |                       	|                       	| 89.69145771355716 	  |
| Register and Get 	| 3.7713381714963714 	    | 15.033727718935676  	  | 30.542997285013573 	    |                      	|


Ubuntu - Intel(R) Core(TM) i7-3632QM CPU @ 2.20GHz

|                  	| ioc_container         	| get_it                	| flutter_simple_DI     	| Riverpod             	|
|------------------	|-----------------------	|-----------------------	|-----------------------	|----------------------	|
| Get              	| 2.0994816666666667        | 2.8123708518937804 	    | 41.567595517715226  	    |                      	|
| Get Async        	| 26.285215218278253 	    | 31.578965594698815  	    |                       	|                      	|
| Get Scoped       	| 5.125594686013285  	    |                           |                       	| 12.82226536263222 	  |
| Get Scoped Async  | 35.78010124873439  	    |                       	|                       	| 305.58831194867685 	  |
| Register and Get 	| 6.431420937658489  	    | 24.428734855181737  	    | 45.431126018207955 	    |                      	|

- ioc_container: 1.0.0
- get_it: 7.2.0
- ioc_container: 1.0.0
- Riverpod: 2.0.2
- flutter_simple_dependency_injection: 2.0.0