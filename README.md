# Stoppable

A library for working with stoppables. Stoppables are similar to promises or futures. In addition, they can be stopped.
This library can save add-on developers some work.

## Things included

* **Stoppable.Stoppable**: the class for the stoppable construct.
* **Stoppable.Stoppable.new**: the constructor for the Stoppable class.
* **Stoppable.all**: returns a new stoppable that when stopped also stops all given stoppables.

**Methods:**

* **hasBeenRequestedToStop**: returns if the stoppable has been requested to stop.
* **isRunning**: returns if the stoppable is running.
* **hasStopped**: returns if the stoppable has stopped.
* **stop**: requests that the stoppable stops.
* **alsoStop**: registers another stoppable to also stop.
* **onStop**: registers a callback that is run after "stop" has been called.
* **afterStop**: registers a callback that is run after the stoppable has stopped.

**Private methods (are returned as the second return value of the constructor):**

* **resolve**: resolves the stoppable with the given values and marks it as stopped.
