/*
  * rd_Bench.ahk
  * Class for benchmarking methods/functions
  * Outputs to debug console
  * Copyright(c) 2021 Reinhard Liess
  * MIT Licensed
*/

class rd_Bench {

  iterations := 100

    /**
      * Constructor
      * @param {object} [options] - options object
      * @param {string} options.iterations - number of iterations
    */
  __New(options:="") {

    for key, value in options {
      this[key] := value
    }

    DllCall("QueryPerformanceFrequency", "Int64*", freq)
    this.qpcFreq := freq

  }


  /**
    * Benches boundfunc this.iteration times
    * Outputs results to debug console
    * @param {string} name - Name of benchmark
    * @param {string} boundFunc - Function to test, optionally with bound variables
    * @returns {void}
  */
  benchFunc(name, boundFunc) {

    DllCall("QueryPerformanceCounter", "Int64*", counterBefore)
    Loop, % this.iterations {
      ret := boundFunc.Call()
    }

    DllCall("QueryPerformanceCounter", "Int64*", counterAfter)
    msElapsed := (CounterAfter - CounterBefore) / this.qpcFreq * 1000

    this.outputResult(name, msElapsed)

  }

  /**
  * Outputs results to debug console
  * @param {string} name - name of benchmark
  * @param {string} msElapsed - milliseconds elapsed
  * @returns {void}
  */
  outputResult(name, msElapsed) {

    OutputDebug, % format("Bench: {1} - {2}ms({3}ms for {4} iterations)"
      , name, msElapsed / this.iterations, msElapsed, this.iterations )

  }

}
