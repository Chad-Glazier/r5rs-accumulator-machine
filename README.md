# Virtual Machine in R5RS

This program demonstrates the `/objects` library by implementing a simulated accumulator machine. I would recommend reading the library's separate documentation, in `/objects/README.md`. This documentation only explains the implementation of the machine.

In order to start the machine, run the following.

```bash
$ racket main.rkt
```

## Memory

### Memory Element

```ts
MemoryElement :=
  private value:  number
  public  read:   () => number
  public  write:  (newValue: number) => newValue
```

This object is meant to represent a memory element that can be read and written to.

### Memory

The component meant to represent the main memory is composed of a vector of one-hundred memory elements, and a couple public methods to read and write to its elements.

```java
Memory :=
  private elements: MemoryElement[100]
  public  read:     (index: number) => number
  public  write:    (index: number, newValue: number) => newValue
  public  dump:     () => string
```

## IO

Input/Output devices have one method each, `read` and `write`, respectively.

```ts
InputDevice :=
  public read:  () => number

OutputDevice :=
  public write: (output: number) => void
```

## CPU

The CPU is where most of the logic of the program is performed. It's represented by the following members (note that `Register` is just an alias for `MemoryElement`):

```Java
CPU :=
  // registers
  private instruction-register: Register
  private program-counter:      Register
  private accumulator:          Register
  private mar:                  Register
  private mdr:                  Register

  // flags, for the bus refresh
  private store?:   boolean
  private load?:    boolean
  private input?:   boolean
  private output?:  boolean
  private halt?:    boolean

  // connected components
  private main-memory:    Memory
  private input-device:   InputDevice
  private output-device:  OutputDevice

  // methods for execution
  private bus-refresh:  () => void
  private fetch:        () => void
  private decode:       () => void
  private execute:      () => void
  
  // public methods
  public  load:   (lst: List) => void
  public  run:    () => 0
```

- **Registers**:
  - `instruction-register`: Holds the current instruction being executed.
  - `program-counter`: Keeps track of the address of the next instruction.
  - `accumulator`: Stores intermediate results of calculations.
  - `mar`: Memory Address Register, holds the address of the memory location to be accessed.
  - `mdr`: Memory Data Register, holds the data read from or written to memory.

- **Flags**:
  - `store?`: Indicates if a store operation is in progress.
  - `load?`: Indicates if a load operation is in progress.
  - `input?`: Indicates if an input operation is in progress.
  - `output?`: Indicates if an output operation is in progress.
  - `halt?`: Indicates if the CPU should halt execution.

- **Connected components**:
  - `main-memory`: Represents the system memory.
  - `input-device`: Represents an input device connected to the CPU.
  - `output-device`: Represents an output device connected to the CPU.

- **Methods for execution**:
  - `bus-refresh`: Handles data transfer between the CPU, memory, input, and output components.
  - `fetch`: Fetches the next instruction from memory.
  - `decode`: Decodes the fetched instruction.
  - `execute`: Executes the decoded instruction.

- **Public methods**:
  - `load`: Accepts a list of instructions represented by 3-4 digit decimal numbers and loads them into the main memory.
  - `run`: Starts the fetch-decode-execute cycle, executing the loaded program until the `halt?` flag is raised.
