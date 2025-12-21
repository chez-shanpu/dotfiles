# Cilium - Api

**Pages:** 18

---

## Protocol Documentation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/_api/v1/relay/README/

**Contents:**
- Protocol Documentation
- Table of Contents
- relay/relay.proto
  - NodeStatusEvent
  - NodeState
- Scalar Value Types

NodeStatusEvent is a message sent by hubble-relay to inform clients about the state of a particular node.

state_change contains the new node state

node_names is the list of nodes for which the above state changes applies

message is an optional message attached to the state change (e.g. an error message). The message applies to all nodes in node_names.

UNKNOWN_NODE_STATE indicates that the state of this node is unknown.

NODE_CONNECTED indicates that we have established a connection to this node. The client can expect to observe flows from this node.

NODE_UNAVAILABLE indicates that the connection to this node is currently unavailable. The client can expect to not see any flows from this node until either the connection is re-established or the node is gone.

NODE_GONE indicates that a node has been removed from the cluster. No reconnection attempts will be made.

NODE_ERROR indicates that a node has reported an error while processing the request. No reconnection attempts will be made.

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead.

Bignum or Fixnum (as required)

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead.

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s.

Always four bytes. More efficient than uint32 if values are often greater than 2^28.

Bignum or Fixnum (as required)

Always eight bytes. More efficient than uint64 if values are often greater than 2^56.

Bignum or Fixnum (as required)

A string must always contain UTF-8 encoded or 7-bit ASCII text.

May contain any arbitrary sequence of bytes.

---

## API Rate Limiting — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/configuration/api-rate-limiting/

**Contents:**
- API Rate Limiting
- Default Rate Limits
- Configuration
  - API call to Configuration mapping
  - Configuration Parameters
  - Valid duration values
- Automatic Adjustment
- Metrics
- Understanding the log output

The per node Cilium agent is essentially event-driven. For example, the CNI plugin is invoked when a new workload is scheduled onto the node which in turn makes an API call to the Cilium agent to allocate an IP address and create the Cilium endpoint. Another example is loading of network policy or service definitions where changes of these definitions will create an event which will notify the Cilium agent that a modification is required.

Due to being event-driven, the amount of work performed by the Cilium agent highly depends on the rate of external events it receives. In order to constrain the resources that the Cilium agent consumes, it can be helpful to restrict the rate and allowed parallel executions of API calls.

The following API calls are currently subject to rate limiting:

Estimated Processing Duration

DELETE /endpoint/{id}

PATCH /endpoint/{id}*

The api-rate-limit option can be used to overwrite individual settings of the default configuration:

DELETE /endpoint/{id}

PATCH /endpoint/{id}*

Allowed requests per time unit in the format <number>/<duration>.

Burst of API requests allowed by rate limiter.

Minimum wait duration each API call has to wait before being processed.

Maximum duration an API call is allowed to wait before it fails.

estimated-processing-duration

Estimated processing duration of an average API call. Used for automatic adjustment.

Enable automatic adjustment of rate-limit, rate-burst and parallel-requests.

Number of parallel API calls allowed.

min-parallel-requests

Lower limit of parallel requests when auto-adjusting.

max-parallel-requests

Upper limit of parallel requests when auto-adjusting.

Number of API calls to calculate mean processing duration for auto adjustment.

Log an Info message for each API call processed.

delayed-adjustment-factor

Factor for slower adjustment of rate-burst and parallel-requests.

max-adjustment-factor

Maximum factor the auto-adjusted values can deviate from the initial base values configured.

The rate-limit option expects a value in the form <number>/<duration> where <duration> is a value that can be parsed with ParseDuration(). The supported units are: ns, us, ms, s, m, h.

Static values are relatively useless as the Cilium agent will run on different machine types. Deriving rate limits based on number of available CPU cores or available memory can be misleading as well as the Cilium agent may be subject to CPU and memory constraints.

For this reason, all API call rate limiting is done with automatic adjustment of the limits with the goal to stay as close as possible to the configured estimated processing duration. This processing duration is specified for each group of API call and is constantly monitored.

On completion of every API call, new limits are calculated. For this purpose, an adjustment factor is calculated:

This adjustment factor is then applied to rate-limit, rate-burst and parallel-requests and will steer the mean processing duration to get closer to the estimated processing duration.

If delayed-adjustment-factor is specified, then this additional factor is used to slow the growth of the rate-burst and parallel-requests as both values should typically adjust slower than rate-limit:

All API calls subject to rate limiting will expose API Rate Limiting. Example:

The API rate limiter logs under the rate subsystem. An example message can be seen below:

The following is an explanation for all the API rate limiting messages:

The request was admitted into the rate limiter. The associated HTTP context (caller’s request) has not yet timed out. The request will now be rate-limited according to the configuration of the rate limiter. It will enter the waiting stage according to the computed waiting duration.

The request has finished waiting its computed duration to achieve rate-limiting. The underlying HTTP API action will now take place. This means that this request was not thrown back at the caller with a 429 HTTP status code.

This is a common message when the requests are being processed within the configured bounds of the rate limiter.

The API rate limiter has processed this request and the underlying HTTP API action has finished. This means the request is no longer actively waiting or in other words, no longer being rate-limited. This does not mean the underlying HTTP action has succeeded; only that this request has been dealt with.

The underlying HTTP context (request) was cancelled. In other words, the caller has given up on the request. This most likely means that the HTTP request timed out. A 429 HTTP response status code is returned to the caller, which may or may not receive it anyway.

The request has been denied by the rate limiter because too many parallel requests are already in flight. The caller will receive a 429 HTTP status response.

This is a common message when the rate limiter is doing its job of preventing too many parallel requests at once.

The request has been denied by the rate limiter because the request’s waiting duration would exceed the maximum configured waiting duration. For example, if the maximum waiting duration was 5s and due to the backlog of the rate limiter, this request would need to wait 10s, then this request would be thrown out. A 429 HTTP response status code would be returned to the caller.

This is the most common message when the rate limiter is doing its job of pacing the incoming requests into Cilium.

The request has been denied by the rate limiter because after the request has waited its calculated waiting duration, the context associated with the request has been cancelled. In the most likely scenario, this means that there was an HTTP timeout while the request was actively being rate-limited or in other words, actively being delayed by the rate limiter. A 429 HTTP response status code is returned to the caller.

---

## SDP gRPC API Reference — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/sdpapi/

**Contents:**
- SDP gRPC API Reference

gRPC API contract between Standalone DNS Proxy and Cilium Agent.

---

## BPF Architecture — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/reference-guides/bpf/architecture/

**Contents:**
- BPF Architecture
- Instruction Set
- Helper Functions
- Maps
- Object Pinning
- Tail Calls
- BPF to BPF Calls
- JIT
- Hardening
- Offloads

BPF does not define itself by only providing its instruction set, but also by offering further infrastructure around it such as maps which act as efficient key / value stores, helper functions to interact with and leverage kernel functionality, tail calls for calling into other BPF programs, security hardening primitives, a pseudo file system for pinning objects (maps, programs), and infrastructure for allowing BPF to be offloaded, for example, to a network card.

LLVM provides a BPF back end, so that tools like clang can be used to compile C into a BPF object file, which can then be loaded into the kernel. BPF is deeply tied to the Linux kernel and allows for full programmability without sacrificing native kernel performance.

Last but not least, also the kernel subsystems making use of BPF are part of BPF’s infrastructure. The two main subsystems discussed throughout this document are tc and XDP where BPF programs can be attached to. XDP BPF programs are attached at the earliest networking driver stage and trigger a run of the BPF program upon packet reception. By definition, this achieves the best possible packet processing performance since packets cannot get processed at an even earlier point in software. However, since this processing occurs so early in the networking stack, the stack has not yet extracted metadata out of the packet. On the other hand, tc BPF programs are executed later in the kernel stack, so they have access to more metadata and core kernel functionality. Apart from tc and XDP programs, various other kernel subsystems use BPF, such as tracing (via kprobes, uprobes, tracepoints, for example).

The following subsections provide further details on individual aspects of the BPF architecture.

BPF is a general purpose RISC instruction set and was originally designed for the purpose of writing programs in a subset of C which can be compiled into BPF instructions through a compiler back end (e.g. LLVM), so that the kernel can later on map them through an in-kernel JIT compiler into native opcodes for optimal execution performance inside the kernel.

The advantages for pushing these instructions into the kernel include:

Making the kernel programmable without having to cross kernel / user space boundaries. For example, BPF programs related to networking, as in the case of Cilium, can implement flexible container policies, load balancing and other means without having to move packets to user space and back into the kernel. State between BPF programs and kernel / user space can still be shared through maps whenever needed.

Given the flexibility of a programmable data path, programs can be heavily optimized for performance also by compiling out features that are not required for the use cases the program solves. For example, if a container does not require IPv4, then the BPF program can be built to only deal with IPv6 in order to save resources in the fast-path.

In case of networking (e.g. tc and XDP), BPF programs can be updated atomically without having to restart the kernel, system services or containers, and without traffic interruptions. Furthermore, any program state can also be maintained throughout updates via BPF maps.

BPF provides a stable ABI towards user space, and does not require any third party kernel modules. BPF is a core part of the Linux kernel that is shipped everywhere, and guarantees that existing BPF programs keep running with newer kernel versions. This guarantee is the same guarantee that the kernel provides for system calls with regard to user space applications. Moreover, BPF programs are portable across different architectures.

BPF programs work in concert with the kernel, they make use of existing kernel infrastructure (e.g. drivers, netdevices, tunnels, protocol stack, sockets) and tooling (e.g. iproute2) as well as the safety guarantees which the kernel provides. Unlike kernel modules, BPF programs are verified through an in-kernel verifier in order to ensure that they cannot crash the kernel, always terminate, etc. XDP programs, for example, reuse the existing in-kernel drivers and operate on the provided DMA buffers containing the packet frames without exposing them or an entire driver to user space as in other models. Moreover, XDP programs reuse the existing stack instead of bypassing it. BPF can be considered a generic “glue code” between kernel facilities for crafting programs to solve specific use cases.

The execution of a BPF program inside the kernel is always event-driven! Examples:

A networking device which has a BPF program attached on its ingress path will trigger the execution of the program once a packet is received.

A kernel address which has a kprobe with a BPF program attached will trap once the code at that address gets executed, which will then invoke the kprobe’s callback function for instrumentation, subsequently triggering the execution of the attached BPF program.

BPF consists of eleven 64 bit registers with 32 bit subregisters, a program counter and a 512 byte large BPF stack space. Registers are named r0 - r10. The operating mode is 64 bit by default, the 32 bit subregisters can only be accessed through special ALU (arithmetic logic unit) operations. The 32 bit lower subregisters zero-extend into 64 bit when they are being written to.

Register r10 is the only register which is read-only and contains the frame pointer address in order to access the BPF stack space. The remaining r0 - r9 registers are general purpose and of read/write nature.

A BPF program can call into a predefined helper function, which is defined by the core kernel (never by modules). The BPF calling convention is defined as follows:

r0 contains the return value of a helper function call.

r1 - r5 hold arguments from the BPF program to the kernel helper function.

r6 - r9 are callee saved registers that will be preserved on helper function call.

The BPF calling convention is generic enough to map directly to x86_64, arm64 and other ABIs, thus all BPF registers map one to one to HW CPU registers, so that a JIT only needs to issue a call instruction, but no additional extra moves for placing function arguments. This calling convention was modeled to cover common call situations without having a performance penalty. Calls with 6 or more arguments are currently not supported. The helper functions in the kernel which are dedicated to BPF (BPF_CALL_0() to BPF_CALL_5() functions) are specifically designed with this convention in mind.

Register r0 is also the register containing the exit value for the BPF program. The semantics of the exit value are defined by the type of program. Furthermore, when handing execution back to the kernel, the exit value is passed as a 32 bit value.

Registers r1 - r5 are scratch registers, meaning the BPF program needs to either spill them to the BPF stack or move them to callee saved registers if these arguments are to be reused across multiple helper function calls. Spilling means that the variable in the register is moved to the BPF stack. The reverse operation of moving the variable from the BPF stack to the register is called filling. The reason for spilling/filling is due to the limited number of registers.

Upon entering execution of a BPF program, register r1 initially contains the context for the program. The context is the input argument for the program (similar to argc/argv pair for a typical C program). BPF is restricted to work on a single context. The context is defined by the program type, for example, a networking program can have a kernel representation of the network packet (skb) as the input argument.

The general operation of BPF is 64 bit to follow the natural model of 64 bit architectures in order to perform pointer arithmetics, pass pointers but also pass 64 bit values into helper functions, and to allow for 64 bit atomic operations.

The maximum instruction limit per program is restricted to 4096 BPF instructions, which, by design, means that any program will terminate quickly. For kernel newer than 5.1 this limit was lifted to 1 million BPF instructions. Although the instruction set contains forward as well as backward jumps, the in-kernel BPF verifier will forbid loops so that termination is always guaranteed. Since BPF programs run inside the kernel, the verifier’s job is to make sure that these are safe to run, not affecting the system’s stability. This means that from an instruction set point of view, loops can be implemented, but the verifier will restrict that. However, there is also a concept of tail calls that allows for one BPF program to jump into another one. This, too, comes with an upper nesting limit of 33 calls, and is usually used to decouple parts of the program logic, for example, into stages.

The instruction format is modeled as two operand instructions, which helps mapping BPF instructions to native instructions during JIT phase. The instruction set is of fixed size, meaning every instruction has 64 bit encoding. Currently, 87 instructions have been implemented and the encoding also allows to extend the set with further instructions when needed. The instruction encoding of a single 64 bit instruction on a big-endian machine is defined as a bit sequence from most significant bit (MSB) to least significant bit (LSB) of op:8, dst_reg:4, src_reg:4, off:16, imm:32. off and imm is of signed type. The encodings are part of the kernel headers and defined in linux/bpf.h header, which also includes linux/bpf_common.h.

op defines the actual operation to be performed. Most of the encoding for op has been reused from cBPF. The operation can be based on register or immediate operands. The encoding of op itself provides information on which mode to use (BPF_X for denoting register-based operations, and BPF_K for immediate-based operations respectively). In the latter case, the destination operand is always a register. Both dst_reg and src_reg provide additional information about the register operands to be used (e.g. r0 - r9) for the operation. off is used in some instructions to provide a relative offset, for example, for addressing the stack or other buffers available to BPF (e.g. map values, packet data, etc), or jump targets in jump instructions. imm contains a constant / immediate value.

The available op instructions can be categorized into various instruction classes. These classes are also encoded inside the op field. The op field is divided into (from MSB to LSB) code:4, source:1 and class:3. class is the more generic instruction class, code denotes a specific operational code inside that class, and source tells whether the source operand is a register or an immediate value. Possible instruction classes include:

BPF_LD, BPF_LDX: Both classes are for load operations. BPF_LD is used for loading a double word as a special instruction spanning two instructions due to the imm:32 split, and for byte / half-word / word loads of packet data. The latter was carried over from cBPF mainly in order to keep cBPF to BPF translations efficient, since they have optimized JIT code. For native BPF these packet load instructions are less relevant nowadays. BPF_LDX class holds instructions for byte / half-word / word / double-word loads out of memory. Memory in this context is generic and could be stack memory, map value data, packet data, etc.

BPF_ST, BPF_STX: Both classes are for store operations. Similar to BPF_LDX the BPF_STX is the store counterpart and is used to store the data from a register into memory, which, again, can be stack memory, map value, packet data, etc. BPF_STX also holds special instructions for performing word and double-word based atomic add operations, which can be used for counters, for example. The BPF_ST class is similar to BPF_STX by providing instructions for storing data into memory only that the source operand is an immediate value.

BPF_ALU, BPF_ALU64: Both classes contain ALU operations. Generally, BPF_ALU operations are in 32 bit mode and BPF_ALU64 in 64 bit mode. Both ALU classes have basic operations with source operand which is register-based and an immediate-based counterpart. Supported by both are add (+), sub (-), and (&), or (|), left shift (<<), right shift (>>), xor (^), mul (*), div (/), mod (%), neg (~) operations. Also mov (<X> := <Y>) was added as a special ALU operation for both classes in both operand modes. BPF_ALU64 also contains a signed right shift. BPF_ALU additionally contains endianness conversion instructions for half-word / word / double-word on a given source register.

BPF_JMP: This class is dedicated to jump operations. Jumps can be unconditional and conditional. Unconditional jumps simply move the program counter forward, so that the next instruction to be executed relative to the current instruction is off + 1, where off is the constant offset encoded in the instruction. Since off is signed, the jump can also be performed backwards as long as it does not create a loop and is within program bounds. Conditional jumps operate on both, register-based and immediate-based source operands. If the condition in the jump operations results in true, then a relative jump to off + 1 is performed, otherwise the next instruction (0 + 1) is performed. This fall-through jump logic differs compared to cBPF and allows for better branch prediction as it fits the CPU branch predictor logic more naturally. Available conditions are jeq (==), jne (!=), jgt (>), jge (>=), jsgt (signed >), jsge (signed >=), jlt (<), jle (<=), jslt (signed <), jsle (signed <=) and jset (jump if DST & SRC). Apart from that, there are three special jump operations within this class: the exit instruction which will leave the BPF program and return the current value in r0 as a return code, the call instruction, which will issue a function call into one of the available BPF helper functions, and a hidden tail call instruction, which will jump into a different BPF program.

The Linux kernel is shipped with a BPF interpreter which executes programs assembled in BPF instructions. Even cBPF programs are translated into eBPF programs transparently in the kernel, except for architectures that still ship with a cBPF JIT and have not yet migrated to an eBPF JIT.

Currently x86_64, arm64, ppc64, s390x, mips64, sparc64 and arm architectures come with an in-kernel eBPF JIT compiler.

All BPF handling such as loading of programs into the kernel or creation of BPF maps is managed through a central bpf() system call. It is also used for managing map entries (lookup / update / delete), and making programs as well as maps persistent in the BPF file system through pinning.

Helper functions are a concept which enables BPF programs to consult a core kernel defined set of function calls in order to retrieve / push data from / to the kernel. Available helper functions may differ for each BPF program type, for example, BPF programs attached to sockets are only allowed to call into a subset of helpers compared to BPF programs attached to the tc layer. Encapsulation and decapsulation helpers for lightweight tunneling constitute an example of functions which are only available to lower tc layers, whereas event output helpers for pushing notifications to user space are available to tc and XDP programs.

Each helper function is implemented with a commonly shared function signature similar to system calls. The signature is defined as:

The calling convention as described in the previous section applies to all BPF helper functions.

The kernel abstracts helper functions into macros BPF_CALL_0() to BPF_CALL_5() which are similar to those of system calls. The following example is an extract from a helper function which updates map elements by calling into the corresponding map implementation callbacks:

There are various advantages of this approach: while cBPF overloaded its load instructions in order to fetch data at an impossible packet offset to invoke auxiliary helper functions, each cBPF JIT needed to implement support for such a cBPF extension. In case of eBPF, each newly added helper function will be JIT compiled in a transparent and efficient way, meaning that the JIT compiler only needs to emit a call instruction since the register mapping is made in such a way that BPF register assignments already match the underlying architecture’s calling convention. This allows for easily extending the core kernel with new helper functionality. All BPF helper functions are part of the core kernel and cannot be extended or added through kernel modules.

The aforementioned function signature also allows the verifier to perform type checks. The above struct bpf_func_proto is used to hand all the necessary information that needs to be known about the helper to the verifier, so that the verifier can make sure that the expected types from the helper match the current contents of the BPF program’s analyzed registers.

Argument types can range from passing in any kind of value up to restricted contents such as a pointer / size pair for the BPF stack buffer, which the helper should read from or write to. In the latter case, the verifier can also perform additional checks, for example, whether the buffer was previously initialized.

The list of available BPF helper functions is rather long and constantly growing, for example, at the time of this writing, tc BPF programs can choose from 38 different BPF helpers. The kernel’s struct bpf_verifier_ops contains a get_func_proto callback function that provides the mapping of a specific enum bpf_func_id to one of the available helpers for a given BPF program type.

Maps are efficient key / value stores that reside in kernel space. They can be accessed from a BPF program in order to keep state among multiple BPF program invocations. They can also be accessed through file descriptors from user space and can be arbitrarily shared with other BPF programs or user space applications.

BPF programs which share maps with each other are not required to be of the same program type, for example, tracing programs can share maps with networking programs. A single BPF program can currently access up to 64 different maps directly.

Map implementations are provided by the core kernel. There are generic maps with per-CPU and non-per-CPU flavor that can read / write arbitrary data, but there are also a few non-generic maps that are used along with helper functions.

Generic maps currently available are BPF_MAP_TYPE_HASH, BPF_MAP_TYPE_ARRAY, BPF_MAP_TYPE_PERCPU_HASH, BPF_MAP_TYPE_PERCPU_ARRAY, BPF_MAP_TYPE_LRU_HASH, BPF_MAP_TYPE_LRU_PERCPU_HASH and BPF_MAP_TYPE_LPM_TRIE. They all use the same common set of BPF helper functions in order to perform lookup, update or delete operations while implementing a different backend with differing semantics and performance characteristics.

Non-generic maps that are currently in the kernel are BPF_MAP_TYPE_PROG_ARRAY, BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_MAP_TYPE_CGROUP_ARRAY, BPF_MAP_TYPE_STACK_TRACE, BPF_MAP_TYPE_ARRAY_OF_MAPS, BPF_MAP_TYPE_HASH_OF_MAPS. For example, BPF_MAP_TYPE_PROG_ARRAY is an array map which holds other BPF programs, BPF_MAP_TYPE_ARRAY_OF_MAPS and BPF_MAP_TYPE_HASH_OF_MAPS both hold pointers to other maps such that entire BPF maps can be atomically replaced at runtime. These types of maps tackle a specific issue which was unsuitable to be implemented solely through a BPF helper function since additional (non-data) state is required to be held across BPF program invocations.

BPF maps and programs act as a kernel resource and can only be accessed through file descriptors, backed by anonymous inodes in the kernel. Advantages, but also a number of disadvantages come along with them:

User space applications can make use of most file descriptor related APIs, file descriptor passing for Unix domain sockets work transparently, etc, but at the same time, file descriptors are limited to a processes’ lifetime, which makes options like map sharing rather cumbersome to carry out.

Thus, it brings a number of complications for certain use cases such as iproute2, where tc or XDP sets up and loads the program into the kernel and terminates itself eventually. With that, also access to maps is unavailable from user space side, where it could otherwise be useful, for example, when maps are shared between ingress and egress locations of the data path. Also, third party applications may wish to monitor or update map contents during BPF program runtime.

To overcome this limitation, a minimal kernel space BPF file system has been implemented, where BPF map and programs can be pinned to, a process called object pinning. The BPF system call has therefore been extended with two new commands which can pin (BPF_OBJ_PIN) or retrieve (BPF_OBJ_GET) a previously pinned object.

For instance, tools such as tc make use of this infrastructure for sharing maps on ingress and egress. The BPF related file system is not a singleton, it does support multiple mount instances, hard and soft links, etc.

Another concept that can be used with BPF is called tail calls. Tail calls can be seen as a mechanism that allows one BPF program to call another, without returning back to the old program. Such a call has minimal overhead as unlike function calls, it is implemented as a long jump, reusing the same stack frame.

Such programs are verified independently of each other, thus for transferring state, either per-CPU maps as scratch buffers or in case of tc programs, skb fields such as the cb[] area must be used.

Only programs of the same type can be tail called, and they also need to match in terms of JIT compilation, thus either JIT compiled or only interpreted programs can be invoked, but not mixed together.

There are two components involved for carrying out tail calls: the first part needs to setup a specialized map called program array (BPF_MAP_TYPE_PROG_ARRAY) that can be populated by user space with key / values, where values are the file descriptors of the tail called BPF programs, the second part is a bpf_tail_call() helper where the context, a reference to the program array and the lookup key is passed to. Then the kernel inlines this helper call directly into a specialized BPF instruction. Such a program array is currently write-only from user space side.

The kernel looks up the related BPF program from the passed file descriptor and atomically replaces program pointers at the given map slot. When no map entry has been found at the provided key, the kernel will just “fall through” and continue execution of the old program with the instructions following after the bpf_tail_call(). Tail calls are a powerful utility, for example, parsing network headers could be structured through tail calls. During runtime, functionality can be added or replaced atomically, and thus altering the BPF program’s execution behavior.

Aside from BPF helper calls and BPF tail calls, a more recent feature that has been added to the BPF core infrastructure is BPF to BPF calls. Before this feature was introduced into the kernel, a typical BPF C program had to declare any reusable code that, for example, resides in headers as always_inline such that when LLVM compiles and generates the BPF object file all these functions were inlined and therefore duplicated many times in the resulting object file, artificially inflating its code size:

The main reason why this was necessary was due to lack of function call support in the BPF program loader as well as verifier, interpreter and JITs. Starting with Linux kernel 4.16 and LLVM 6.0 this restriction got lifted and BPF programs no longer need to use always_inline everywhere. Thus, the prior shown BPF example code can then be rewritten more naturally as:

Mainstream BPF JIT compilers like x86_64 and arm64 support BPF to BPF calls today with others following in near future. BPF to BPF call is an important performance optimization since it heavily reduces the generated BPF code size and therefore becomes friendlier to a CPU’s instruction cache.

The calling convention known from BPF helper function applies to BPF to BPF calls just as well, meaning r1 up to r5 are for passing arguments to the callee and the result is returned in r0. r1 to r5 are scratch registers whereas r6 to r9 preserved across calls the usual way. The maximum number of nesting calls respectively allowed call frames is 8. A caller can pass pointers (e.g. to the caller’s stack frame) down to the callee, but never vice versa.

BPF JIT compilers emit separate images for each function body and later fix up the function call addresses in the image in a final JIT pass. This has proven to require minimal changes to the JITs in that they can treat BPF to BPF calls as conventional BPF helper calls.

Up to kernel 5.9, BPF tail calls and BPF subprograms excluded each other. BPF programs that utilized tail calls couldn’t take the benefit of reducing program image size and faster load times. Linux kernel 5.10 finally allows users to bring the best of two worlds and adds the ability to combine the BPF subprograms with tail calls.

This improvement comes with some restrictions, though. Mixing these two features can cause a kernel stack overflow. To get an idea of what might happen, see the picture below that illustrates the mix of bpf2bpf calls and tail calls:

Tail calls, before the actual jump to the target program, will unwind only its current stack frame. As we can see in the example above, if a tail call occurs from within the sub-function, the function’s (func1) stack frame will be present on the stack when a program execution is at func2. Once the final function (func3) function terminates, all the previous stack frames will be unwinded and control will get back to the caller of BPF program caller.

The kernel introduced additional logic for detecting this feature combination. There is a limit on the stack size throughout the whole call chain down to 256 bytes per subprogram (note that if the verifier detects the bpf2bpf call, then the main function is treated as a sub-function as well). In total, with this restriction, the BPF program’s call chain can consume at most 8KB of stack space. This limit comes from the 256 bytes per stack frame multiplied by the tail call count limit (33). Without this, the BPF programs will operate on 512-byte stack size, yielding the 16KB size in total for the maximum count of tail calls that would overflow the stack on some architectures.

One more thing to mention is that this feature combination is currently supported only on the x86-64 architecture.

The 64 bit x86_64, arm64, ppc64, s390x, mips64, sparc64 and 32 bit arm, x86_32 architectures are all shipped with an in-kernel eBPF JIT compiler, also all of them are feature equivalent and can be enabled through:

The 32 bit mips, ppc and sparc architectures currently have a cBPF JIT compiler. The mentioned architectures still having a cBPF JIT as well as all remaining architectures supported by the Linux kernel which do not have a BPF JIT compiler at all need to run eBPF programs through the in-kernel interpreter.

In the kernel’s source tree, eBPF JIT support can be easily determined through issuing a grep for HAVE_EBPF_JIT:

JIT compilers speed up execution of the BPF program significantly since they reduce the per instruction cost compared to the interpreter. Often instructions can be mapped 1:1 with native instructions of the underlying architecture. This also reduces the resulting executable image size and is therefore more instruction cache friendly to the CPU. In particular in case of CISC instruction sets such as x86, the JITs are optimized for emitting the shortest possible opcodes for a given instruction to shrink the total necessary size for the program translation.

BPF locks the entire BPF interpreter image (struct bpf_prog) as well as the JIT compiled image (struct bpf_binary_header) in the kernel as read-only during the program’s lifetime in order to prevent the code from potential corruptions. Any corruption happening at that point, for example, due to some kernel bugs will result in a general protection fault and thus crash the kernel instead of allowing the corruption to happen silently.

Architectures that support setting the image memory as read-only can be determined through:

The option CONFIG_ARCH_HAS_SET_MEMORY is not configurable, thanks to which this protection is always built in. Other architectures might follow in the future.

In case of the x86_64 JIT compiler, the JITing of the indirect jump from the use of tail calls is realized through a retpoline in case CONFIG_RETPOLINE has been set which is the default at the time of writing in most modern Linux distributions.

In case of /proc/sys/net/core/bpf_jit_harden set to 1 additional hardening steps for the JIT compilation take effect for unprivileged users. This effectively trades off their performance slightly by decreasing a (potential) attack surface in case of untrusted users operating on the system. The decrease in program execution still results in better performance compared to switching to interpreter entirely.

Currently, enabling hardening will blind all user provided 32 bit and 64 bit constants from the BPF program when it gets JIT compiled in order to prevent JIT spraying attacks which inject native opcodes as immediate values. This is problematic as these immediate values reside in executable kernel memory, therefore, a jump that could be triggered from some kernel bug would jump to the start of the immediate value and then execute these as native instructions.

JIT constant blinding prevents this due to randomizing the actual instruction, which means the operation is transformed from an immediate based source operand to a register based one through rewriting the instruction by splitting the actual load of the value into two steps: 1) load of a blinded immediate value rnd ^ imm into a register, 2) xoring that register with rnd such that the original imm immediate then resides in the register and can be used for the actual operation. The example was provided for a load operation, but really all generic operations are blinded.

Example of JITing a program with hardening disabled:

The same program gets constant blinded when loaded through BPF as an unprivileged user in the case hardening is enabled:

Both programs are semantically the same, only that none of the original immediate values are visible anymore in the disassembly of the second program.

At the same time, hardening also disables any JIT kallsyms exposure for privileged users, preventing that JIT image addresses are not exposed to /proc/kallsyms anymore.

Moreover, the Linux kernel provides the option CONFIG_BPF_JIT_ALWAYS_ON which removes the entire BPF interpreter from the kernel and permanently enables the JIT compiler. This has been developed as part of a mitigation in the context of Spectre v2 such that when used in a VM-based setting, the guest kernel is not going to reuse the host kernel’s BPF interpreter when mounting an attack anymore. For container-based environments, the CONFIG_BPF_JIT_ALWAYS_ON configuration option is optional, but in case JITs are enabled there anyway, the interpreter may as well be compiled out to reduce the kernel’s complexity. Thus, it is also generally recommended for widely used JITs in case of mainstream architectures such as x86_64 and arm64.

Last but not least, the kernel offers an option to disable the use of the bpf(2) system call for unprivileged users through the /proc/sys/kernel/unprivileged_bpf_disabled sysctl knob. This is on purpose a one-time kill switch, meaning once set to 1, there is no option to reset it back to 0 until a new kernel reboot. When set only CAP_SYS_ADMIN privileged processes out of the initial namespace are allowed to use the bpf(2) system call from that point onwards. Upon start, Cilium sets this knob to 1 as well.

Networking programs in BPF, in particular for tc and XDP do have an offload-interface to hardware in the kernel in order to execute BPF code directly on the NIC.

Currently, the nfp driver from Netronome has support for offloading BPF through a JIT compiler which translates BPF instructions to an instruction set implemented against the NIC. This includes offloading of BPF maps to the NIC as well, thus the offloaded BPF program can perform map lookups, updates and deletions.

The Linux kernel provides few sysctls that are BPF related and covered in this section.

/proc/sys/net/core/bpf_jit_enable: Enables or disables the BPF JIT compiler.

Disable the JIT and use only interpreter (kernel’s default value)

Enable the JIT compiler

Enable the JIT and emit debugging traces to the kernel log

As described in subsequent sections, bpf_jit_disasm tool can be used to process debugging traces when the JIT compiler is set to debugging mode (option 2).

/proc/sys/net/core/bpf_jit_harden: Enables or disables BPF JIT hardening. Note that enabling hardening trades off performance, but can mitigate JIT spraying by blinding out the BPF program’s immediate values. For programs processed through the interpreter, blinding of immediate values is not needed / performed.

Disable JIT hardening (kernel’s default value)

Enable JIT hardening for unprivileged users only

Enable JIT hardening for all users

/proc/sys/net/core/bpf_jit_kallsyms: Enables or disables export of JITed programs as kernel symbols to /proc/kallsyms so that they can be used together with perf tooling as well as making these addresses aware to the kernel for stack unwinding, for example, used in dumping stack traces. The symbol names contain the BPF program tag (bpf_prog_<tag>). If bpf_jit_harden is enabled, then this feature is disabled.

Disable JIT kallsyms export (kernel’s default value)

Enable JIT kallsyms export for privileged users only

/proc/sys/kernel/unprivileged_bpf_disabled: Enables or disable unprivileged use of the bpf(2) system call. The Linux kernel has unprivileged use of bpf(2) enabled by default.

Once the value is set to 1, unprivileged use will be permanently disabled until the next reboot, neither an application nor an admin can reset the value anymore.

The value can also be set to 2, which means it can be changed at runtime to 0 or 1 later while disabling the unprivileged used for now. This value was added in Linux 5.13. If BPF_UNPRIV_DEFAULT_OFF is enabled in the kernel config, then this knob will default to 2 instead of 0.

This knob does not affect any cBPF programs such as seccomp or traditional socket filters that do not use the bpf(2) system call for loading the program into the kernel.

Unprivileged use of bpf syscall enabled (kernel’s default value)

Unprivileged use of bpf syscall disabled (until reboot)

Unprivileged use of bpf syscall disabled (default if BPF_UNPRIV_DEFAULT_OFF is enabled in kernel config)

---

## gRPC API Reference — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/grpcapi/

**Contents:**
- gRPC API Reference

Hubble’s gRPC API is stable as of version 1.0, backward compatibility will be upheld for whole lifecycle of Cilium 1.x.

---

## Debugging and Testing — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/reference-guides/bpf/debug_and_test/

**Contents:**
- Debugging and Testing
- bpftool
- Kernel Testing
- JIT Debugging
- Introspection
- Tracing pipe
- Miscellaneous

bpftool is the main introspection and debugging tool around BPF and developed and shipped along with the Linux kernel tree under tools/bpf/bpftool/.

The tool can dump all BPF programs and maps that are currently loaded in the system, or list and correlate all BPF maps used by a specific program. Furthermore, it allows to dump the entire map’s key / value pairs, or lookup, update, delete individual ones as well as retrieve a key’s neighbor key in the map. Such operations can be performed based on BPF program or map IDs or by specifying the location of a BPF file system pinned program or map. The tool additionally also offers an option to pin maps or programs into the BPF file system.

For a quick overview of all BPF programs currently loaded on the host invoke the following command:

Similarly, to get an overview of all active maps:

Note that for each command, bpftool also supports json based output by appending --json at the end of the command line. An additional --pretty improves the output to be more human readable.

For dumping the post-verifier BPF instruction image of a specific BPF program, one starting point could be to inspect a specific program, e.g. attached to the tc ingress hook:

The program from the object file bpf_host.o, section from-netdev has a BPF program ID of 406 as denoted in id 406. Based on this information bpftool can provide some high-level metadata specific to the program:

The program of ID 406 is of type sched_cls (BPF_PROG_TYPE_SCHED_CLS), has a tag of e0362f5bd9163a0a (SHA sum over the instruction sequence), it was loaded by root uid 0 on Apr 09/16:24. The BPF instruction sequence is 11,144 bytes long and the JITed image 7,721 bytes. The program itself (excluding maps) consumes 12,288 bytes that are accounted / charged against user uid 0. And the BPF program uses the BPF maps with IDs 18, 20, 8, 5, 6 and 14. The latter IDs can further be used to get information or dump the map themselves.

Additionally, bpftool can issue a dump request of the BPF instructions the program runs:

bpftool correlates BPF map IDs into the instruction stream as shown above as well as calls to BPF helpers or other BPF programs.

The instruction dump reuses the same ‘pretty-printer’ as the kernel’s BPF verifier. Since the program was JITed and therefore the actual JIT image that was generated out of above xlated instructions is executed, it can be dumped as well through bpftool:

Mainly for BPF JIT developers, the option also exists to interleave the disassembly with the actual native opcodes:

The same interleaving can be done for the normal BPF instructions which can sometimes be useful for debugging in the kernel:

The basic blocks of a program can also be visualized with the help of graphviz. For this purpose, bpftool has a visual dump mode that generates a dot file instead of the plain BPF xlated instruction dump that can later be converted to a png file:

Another option would be to pass the dot file to dotty as a viewer, that is dotty output.dot, where the result for the bpf_host.o program looks as follows (small extract):

Note that the xlated instruction dump provides the post-verifier BPF instruction image which means that it dumps the instructions as if they were to be run through the BPF interpreter. In the kernel, the verifier performs various rewrites of the original instructions provided by the BPF loader.

One example of rewrites is the inlining of helper functions in order to improve runtime performance, here in the case of a map lookup for hash tables:

bpftool correlates calls to helper functions or BPF to BPF calls through kallsyms. Therefore, make sure that JITed BPF programs are exposed to kallsyms (bpf_jit_kallsyms) and that kallsyms addresses are not obfuscated (calls are otherwise shown as call bpf_unspec#0):

BPF to BPF calls are correlated as well for both, interpreter as well as JIT case. In the latter, the tag of the subprogram is shown as call target. In each case, the pc+2 is the pc-relative offset of the call target, which denotes the subprogram.

JITed variant of the dump:

In the case of tail calls, the kernel maps them into a single instruction internally, bpftool will still correlate them as a helper call for ease of debugging:

Dumping an entire map is possible through the map dump subcommand which iterates through all present map elements and dumps the key / value pairs.

If no BTF (BPF Type Format) data is available for a given map, then the key / value pairs are dumped as hex:

However, with BTF, the map also holds debugging information about the key and value structures. For example, BTF in combination with BPF maps and the BPF_ANNOTATE_KV_PAIR() macro from iproute2 will result in the following dump (test_xdp_noinline.o from kernel selftests):

The BPF_ANNOTATE_KV_PAIR() macro forces a map-specific ELF section containing an empty key and value, this enables the iproute2 BPF loader to correlate BTF data with that section and thus allows to choose the corresponding types out of the BTF for loading the map.

Compiling through LLVM and generating BTF through debugging information by pahole:

Now loading into kernel and dumping the map via bpftool:

Lookup, update, delete, and ‘get next key’ operations on the map for specific keys can be performed through bpftool as well.

If the BPF program has been successfully loaded with BTF debugging information, the BTF ID will be shown in prog show command result denoted in btf_id.

This can also be confirmed with btf show command which dumps all BTF objects loaded on a system.

And the subcommand btf dump can be used to check which debugging information is included in the BTF. With this command, BTF dump can be formatted either ‘raw’ or ‘c’, the one that is used in C code.

To learn more about bpftool, check out eCHO episode 11: Exploring bpftool with Quentin Monnet, maintainer of bpftool.

The Linux kernel ships a BPF selftest suite, which can be found in the kernel source tree under tools/testing/selftests/bpf/.

The test suite contains test cases against the BPF verifier, program tags, various tests against the BPF map interface and map types. It contains various runtime tests from C code for checking LLVM back end, and eBPF as well as cBPF asm code that is run in the kernel for testing the interpreter and JITs.

For JIT developers performing audits or writing extensions, each compile run can output the generated JIT image into the kernel log through:

Whenever a new BPF program is loaded, the JIT compiler will dump the output, which can then be inspected with dmesg, for example:

flen is the length of the BPF program (here, 6 BPF instructions), and proglen tells the number of bytes generated by the JIT for the opcode image (here, 70 bytes in size). pass means that the image was generated in 3 compiler passes, for example, x86_64 can have various optimization passes to further reduce the image size when possible. image contains the address of the generated JIT image, from and pid the user space application name and PID respectively, which triggered the compilation process. The dump output for eBPF and cBPF JITs is the same format.

In the kernel tree under tools/bpf/, there is a tool called bpf_jit_disasm. It reads out the latest dump and prints the disassembly for further inspection:

Alternatively, the tool can also dump related opcodes along with the disassembly.

More recently, bpftool adapted the same feature of dumping the BPF JIT image based on a given BPF program ID already loaded in the system (see bpftool section).

For performance analysis of JITed BPF programs, perf can be used as usual. As a prerequisite, JITed programs need to be exported through kallsyms infrastructure.

Enabling or disabling bpf_jit_kallsyms does not require a reload of the related BPF programs. Next, a small workflow example is provided for profiling BPF programs. A crafted tc BPF program is used for demonstration purposes, where perf records a failed allocation inside bpf_clone_redirect() helper. Due to the use of direct write, bpf_try_make_head_writable() failed, which would then release the cloned skb again and return with an error message. perf thus records all kfree_skb events.

The stack trace recorded by perf will then show the bpf_prog_8227addf251b7543() symbol as part of the call trace, meaning that the BPF program with the tag 8227addf251b7543 was related to the kfree_skb event, and such program was attached to netdevice em1 on the ingress hook as shown by tc.

The Linux kernel provides various tracepoints around BPF and XDP which can be used for additional introspection, for example, to trace interactions of user space programs with the bpf system call.

Example usage with perf (alternatively to sleep example used here, a specific application like tc could be used here instead, of course):

For the BPF programs, their individual program tag is displayed.

For debugging, XDP also has a tracepoint that is triggered when exceptions are raised:

Exceptions are triggered in the following scenarios:

The BPF program returned an invalid / unknown XDP action code.

The BPF program returned with XDP_ABORTED indicating a non-graceful exit.

The BPF program returned with XDP_TX, but there was an error on transmit, for example, due to the port not being up, due to the transmit ring being full, due to allocation failures, etc.

Both tracepoint classes can also be inspected with a BPF program itself attached to one or more tracepoints, collecting further information in a map or punting such events to a user space collector through the bpf_perf_event_output() helper, for example.

When a BPF program makes a call to bpf_trace_printk(), the output is sent to the kernel tracing pipe. Users may read from this file to consume events that are traced to this buffer:

BPF programs and maps are memory accounted against RLIMIT_MEMLOCK similar to perf. The currently available size in unit of system pages which may be locked into memory can be inspected through ulimit -l. The setrlimit system call man page provides further details.

The default limit is usually insufficient to load more complex programs or larger BPF maps, so that the BPF system call will return with errno of EPERM. In such situations a workaround with ulimit -l unlimited or with a sufficiently large limit could be performed. The RLIMIT_MEMLOCK is mainly enforcing limits for unprivileged users. Depending on the setup, setting a higher limit for privileged users is often acceptable.

---

## Protocol Documentation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/_api/v1/flow/README/

**Contents:**
- Protocol Documentation
- Table of Contents
- flow/flow.proto
  - AgentEvent
  - AgentEventUnknown
  - CiliumEventType
  - DNS
  - DebugEvent
  - Endpoint
  - EndpointRegenNotification

EndpointRegenNotification

EndpointUpdateNotification

FlowFilter.Experimental

PolicyUpdateNotification

ServiceDeleteNotification

ServiceUpsertNotification

ServiceUpsertNotificationAddr

SocketTranslationPoint

TraceObservationPoint

PolicyUpdateNotification

used for POLICY_UPDATED and POLICY_DELETED

EndpointRegenNotification

used for ENDPOINT_REGENERATE_SUCCESS and ENDPOINT_REGENERATE_FAILURE

EndpointUpdateNotification

used for ENDPOINT_CREATED and ENDPOINT_DELETED

used for IPCACHE_UPSERTED and IPCACHE_DELETED

ServiceUpsertNotification

ServiceDeleteNotification

CiliumEventType from which the flow originated.

type of event the flow originated from, i.e. github.com/cilium/cilium/pkg/monitor/api.MessageType*

sub_type may indicate more details depending on type, e.g. - github.com/cilium/cilium/pkg/monitor/api.Trace* - github.com/cilium/cilium/pkg/monitor/api.Drop* - github.com/cilium/cilium/pkg/monitor/api.DbgCapture*

DNS flow. This is basically directly mapped from Cilium’s LogRecordDNS:

DNS name that’s being looked up: e.g. “isovalent.com.”

List of IP addresses in the DNS response.

TTL in the DNS response.

List of CNames in the DNS response.

Corresponds to DNSDataSource defined in: https://github.com/cilium/cilium/blob/04f3889d627774f79e56d14ddbc165b3169e2d01/pkg/proxy/accesslog/record.go#L253

Return code of the DNS request defined in: https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml#dns-parameters-6

String representation of qtypes defined in: https://tools.ietf.org/html/rfc1035#section-3.2.3

String representation of rrtypes defined in: https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml#dns-parameters-4

google.protobuf.UInt32Value

google.protobuf.UInt32Value

google.protobuf.UInt32Value

google.protobuf.UInt32Value

google.protobuf.Int32Value

labels in foo=bar format.

EventTypeFilter is a filter describing a particular event type.

type is the primary flow type as defined by: github.com/cilium/cilium/pkg/monitor/api.MessageType*

match_sub_type is set to true when matching on the sub_type should be done. This flag is required as 0 is a valid sub_type.

sub_type is the secondary type, e.g. - github.com/cilium/cilium/pkg/monitor/api.Trace*

google.protobuf.Timestamp

uuid is a universally unique identifier for this flow.

Deprecated. only applicable to Verdict = DROPPED. deprecated in favor of drop_reason_desc.

auth_type is the authentication type specified for the flow in Cilium Network Policy. Only set on policy verdict events.

NodeName is the name of the node from which this Flow was captured.

node labels in foo=bar format.

all names the source IP can have.

all names the destination IP can have.

L7 information. This field is set if and only if FlowType is L7.

Deprecated. Deprecated. This suffers from false negatives due to protobuf not being able to distinguish between the value being false or it being absent. Please use is_reply instead.

EventType of the originating Cilium event

source_service contains the service name of the source

destination_service contains the service name of the destination

traffic_direction of the connection, e.g. ingress or egress

policy_match_type is only applicable to the cilium event type PolicyVerdict https://github.com/cilium/cilium/blob/e831859b5cc336c6d964a6d35bbd34d1840e21b9/pkg/monitor/datapath_policy.go#L50

trace_observation_point

TraceObservationPoint

Only applicable to cilium trace notifications, blank for other types.

Cilium datapath trace reason info.

Cilium datapath filename and line number. Currently only applicable when Verdict = DROPPED.

only applicable to Verdict = DROPPED.

google.protobuf.BoolValue

is_reply indicates that this was a packet (L4) or message (L7) in the reply direction. May be absent (in which case it is unknown whether it is a reply or not).

Only applicable to cilium debug capture events, blank for other types

interface is the network interface on which this flow was observed

proxy_port indicates the port of the proxy to which the flow was forwarded

trace_context contains information about a trace related to the flow, if any.

SocketTranslationPoint

sock_xlate_point is the socket translation point. Only applicable to TraceSock notifications, blank for other types

socket_cookie is the Linux kernel socket cookie for this flow. Only applicable to TraceSock notifications, zero for other types

cgroup_id of the process which emitted this event. Only applicable to TraceSock notifications, zero for other types

Deprecated. This is a temporary workaround to support summary field for pb.Flow without duplicating logic from the old parser. This field will be removed once we fully migrate to the new parser.

extensions can be used to add arbitrary additional metadata to flows. This can be used to extend functionality for other Hubble compatible APIs, or experiment with new functionality without needing to change the public API.

The CiliumNetworkPolicies allowing the egress of the flow.

The CiliumNetworkPolicies allowing the ingress of the flow.

The CiliumNetworkPolicies denying the egress of the flow.

The CiliumNetworkPolicies denying the ingress of the flow.

The set of Log values for policies that matched this flow. If no matched policies have an explicit log value configured, this list is empty. Duplicate values are elided; each entry is unique.

FlowFilter represent an individual flow filter. All fields are optional. If multiple fields are set, then all fields must match for the filter to match.

uuid filters by a list of flow uuids.

source_ip filters by a list of source ips. Each of the source ips can be specified as an exact match (e.g. “1.1.1.1”) or as a CIDR range (e.g. “1.1.1.0/24”).

source_ip_xlated filters by a list IPs. Each of the IPs can be specified as an exact match (e.g. “1.1.1.1”) or as a CIDR range (e.g. “1.1.1.0/24”).

source_pod filters by a list of source pod name prefixes, optionally within a given namespace (e.g. “xwing”, “kube-system/coredns-“). The pod name can be omitted to only filter by namespace (e.g. “kube-system/”) or the namespace can be omitted to filter for pods in any namespace (e.g. “/xwing”)

source_fqdn filters by a list of source fully qualified domain names

source_labels filters on a list of source label selectors. Selectors support the full Kubernetes label selector syntax.

source_service filters on a list of source service names. This field supports the same syntax as the source_pod field.

source_workload filters by a list of source workload.

source_cluster_name filters by a list of source cluster names.

destination_ip filters by a list of destination ips. Each of the destination ips can be specified as an exact match (e.g. “1.1.1.1”) or as a CIDR range (e.g. “1.1.1.0/24”).

destination_pod filters by a list of destination pod names

destination_fqdn filters by a list of destination fully qualified domain names

destination_label filters on a list of destination label selectors

destination_service filters on a list of destination service names

destination_workload filters by a list of destination workload.

destination_cluster_name

destination_cluster_name filters by a list of destination cluster names.

traffic_direction filters flow by direction of the connection, e.g. ingress or egress.

only return Flows that were classified with a particular verdict.

only applicable to Verdict = DROPPED (e.g. “POLICY_DENIED”, “UNSUPPORTED_L3_PROTOCOL”)

interface is the network interface on which this flow was observed.

event_type is the list of event types to filter on

http_status_code is a list of string prefixes (e.g. “4+”, “404”, “5+”) to filter on the HTTP status code

protocol filters flows by L4 or L7 protocol, e.g. (e.g. “tcp”, “http”)

source_port filters flows by L4 source port

destination_port filters flows by L4 destination port

reply filters flows based on the direction of the flow.

dns_query filters L7 DNS flows by query patterns (RE2 regex), e.g. ‘kube.*local’.

source_identity filters by the security identity of the source endpoint.

destination_identity filters by the security identity of the destination endpoint.

GET, POST, PUT, etc. methods. This type of field is well suited for an enum but every single existing place is using a string already.

http_path is a list of regular expressions to filter on the HTTP path.

http_url is a list of regular expressions to filter on the HTTP URL.

http_header is a list of key:value pairs to filter on the HTTP headers.

tcp_flags filters flows based on TCP header flags

node_name is a list of patterns to filter on the node name, e.g. “k8s*”, “test-cluster/*.domain.com”, “cluster-name/” etc.

node_labels filters on a list of node label selectors. Selectors support the full Kubernetes label selector syntax.

filter based on IP version (ipv4 or ipv6)

trace_id filters flows by trace ID

FlowFilter.Experimental

experimental contains filters that are not stable yet. Support for experimental features is always optional and subject to change.

Experimental contains filters that are not stable yet. Support for experimental features is always optional and subject to change.

cel_expression takes a common expression language (CEL) expression returning a boolean to determine if the filter matched or not. You can use the _flow variable to access fields on the flow using the flow.Flow protobuf field names. See https://github.com/google/cel-spec/blob/v0.14.0/doc/intro.md#introduction for more details on CEL and accessing the protobuf fields in CEL. Using CEL has performance cost compared to other filters, so prefer using non-CEL filters when possible, and try to specify CEL filters last in the list of FlowFilters.

L7 information for HTTP flows. It corresponds to Cilium’s accesslog.LogRecordHTTP type.

source_xlated is the post-translation source IP when the flow was SNATed. When “source_xlated” is set, the “source” field is populated with the pre-translation source IP address.

This field indicates whether the TraceReasonEncryptMask is set or not. https://github.com/cilium/cilium/blob/ba0ed147bd5bb342f67b1794c2ad13c6e99d5236/pkg/monitor/datapath_trace.go#L27

google.protobuf.UInt32Value

L7 information for Kafka flows. It corresponds to Cilium’s accesslog.LogRecordKafka type.

ICMP is technically not L4, but mutually exclusive with the above

Message for L7 flow, which roughly corresponds to Cilium’s accesslog LogRecord:

Latency of the response

LostEvent is a message which notifies consumers about a loss of events that happened before the events were captured by Hubble.

source is the location where events got lost.

num_events_lost is the number of events that haven been lost at source.

google.protobuf.Int32Value

cpu on which the event was lost if the source of lost events is PERF_EVENT_RING_BUFFER.

ServiceUpsertNotificationAddr

ServiceUpsertNotificationAddr

google.protobuf.Timestamp

TraceContext contains trace context propagation data, i.e. information about a distributed trace. For more information about trace context, check the W3C Trace Context specification.

parent identifies the incoming request in a tracing system.

TraceParent identifies the incoming request in a tracing system.

trace_id is a unique value that identifies a trace. It is a byte array represented as a hex string.

AgentEventType is the type of agent event. These values are shared with type AgentNotification in pkg/monitor/api/types.go.

ENDPOINT_REGENERATE_SUCCESS

ENDPOINT_REGENERATE_FAILURE

These types correspond to definitions in pkg/policy/l4.go.

These values are shared with pkg/monitor/api/datapath_debug.go and bpf/lib/dbg.h.

DBG_CAPTURE_POINT_UNKNOWN

DBG_CAPTURE_AFTER_V46

DBG_CAPTURE_AFTER_V64

DBG_CAPTURE_PROXY_PRE

DBG_CAPTURE_PROXY_POST

DBG_CAPTURE_SNAT_POST

These values are shared with pkg/monitor/api/datapath_debug.go and bpf/lib/dbg.h.

DBG_ICMP6_TIME_EXCEEDED

DBG_LB6_LOOKUP_FRONTEND

DBG_LB6_LOOKUP_FRONTEND_FAIL

DBG_LB6_LOOKUP_BACKEND_SLOT

DBG_LB6_LOOKUP_BACKEND_SLOT_SUCCESS

DBG_LB6_LOOKUP_BACKEND_SLOT_V2_FAIL

DBG_LB6_LOOKUP_BACKEND_FAIL

DBG_LB6_REVERSE_NAT_LOOKUP

DBG_LB4_LOOKUP_FRONTEND

DBG_LB4_LOOKUP_FRONTEND_FAIL

DBG_LB4_LOOKUP_BACKEND_SLOT

DBG_LB4_LOOKUP_BACKEND_SLOT_SUCCESS

DBG_LB4_LOOKUP_BACKEND_SLOT_V2_FAIL

DBG_LB4_LOOKUP_BACKEND_FAIL

DBG_LB4_REVERSE_NAT_LOOKUP

DBG_LB4_LOOPBACK_SNAT

DBG_LB4_LOOPBACK_SNAT_REV

DBG_RR_BACKEND_SLOT_SEL

DBG_NETDEV_IN_CLUSTER

DBG_IP_ID_MAP_FAILED4

DBG_IP_ID_MAP_FAILED6

DBG_IP_ID_MAP_SUCCEED4

DBG_IP_ID_MAP_SUCCEED6

These values are shared with pkg/monitor/api/drop.go and bpf/lib/common.h. Note that non-drop reasons (i.e. values less than api.DropMin) are not used here.

INVALID_DESTINATION_MAC

INVALID_PACKET_DROPPED

CT_TRUNCATED_OR_INVALID_HEADER

CT_MISSING_TCP_ACK_FLAG

CT_UNKNOWN_L4_PROTOCOL

CT_CANNOT_CREATE_ENTRY_FROM_PACKET

UNSUPPORTED_L3_PROTOCOL

ERROR_WRITING_TO_PACKET

ERROR_RETRIEVING_TUNNEL_KEY

ERROR_RETRIEVING_TUNNEL_OPTIONS

INVALID_GENEVE_OPTION

UNKNOWN_L3_TARGET_ADDRESS

STALE_OR_UNROUTABLE_IP

NO_MATCHING_LOCAL_CONTAINER_FOUND

ERROR_WHILE_CORRECTING_L3_CHECKSUM

ERROR_WHILE_CORRECTING_L4_CHECKSUM

CT_MAP_INSERTION_FAILED

INVALID_IPV6_EXTENSION_HEADER

IP_FRAGMENTATION_NOT_SUPPORTED

SERVICE_BACKEND_NOT_FOUND

NO_TUNNEL_OR_ENCAPSULATION_ENDPOINT

FAILED_TO_INSERT_INTO_PROXYMAP

REACHED_EDT_RATE_LIMITING_DROP_HORIZON

UNKNOWN_CONNECTION_TRACKING_STATE

LOCAL_HOST_IS_UNREACHABLE

NO_CONFIGURATION_AVAILABLE_TO_PERFORM_POLICY_DECISION

UNSUPPORTED_L2_PROTOCOL

NO_MAPPING_FOR_NAT_MASQUERADE

UNSUPPORTED_PROTOCOL_FOR_NAT_MASQUERADE

ENCAPSULATION_TRAFFIC_IS_PROHIBITED

FIRST_LOGICAL_DATAGRAM_FRAGMENT_NOT_FOUND

FORBIDDEN_ICMPV6_MESSAGE

DENIED_BY_LB_SRC_RANGE_CHECK

PROXY_REDIRECTION_NOT_SUPPORTED_FOR_PROTOCOL

UNSUPPORTED_PROTOCOL_FOR_DSR_ENCAP

A BPF program wants to tail call into bpf_host, but the host datapath hasn’t been loaded yet.

A BPF program wants to tail call some endpoint’s policy program in cilium_call_policy, but the program is not available.

An Egress Gateway node matched a packet against an Egress Gateway policy that didn’t select a valid Egress IP.

Punt packet to a user space proxy.

EventType are constants are based on the ones from <linux/perf_event.h>.

EventSample is equivalent to PERF_RECORD_SAMPLE.

RecordLost is equivalent to PERF_RECORD_LOST.

not sure about the underscore here, but L34 also reads strange

This enum corresponds to Cilium’s L7 accesslog FlowType:

UNKNOWN_LOST_EVENT_SOURCE

PERF_EVENT_RING_BUFFER

PERF_EVENT_RING_BUFFER indicates that events were dropped in the BPF perf event ring buffer, indicating that userspace agent did not keep up with the events produced by the datapath.

OBSERVER_EVENTS_QUEUE

OBSERVER_EVENTS_QUEUE indicates that events were dropped because the Hubble events queue was full, indicating that the Hubble observer did not keep up.

HUBBLE_RING_BUFFER indicates that the event was dropped because it could not be read from Hubble’s ring buffer in time before being overwritten.

This mirrors enum xlate_point in bpf/lib/trace_sock.h

SOCK_XLATE_POINT_UNKNOWN

SOCK_XLATE_POINT_PRE_DIRECTION_FWD

Pre service translation

SOCK_XLATE_POINT_POST_DIRECTION_FWD

Post service translation

SOCK_XLATE_POINT_PRE_DIRECTION_REV

Pre reverse service translation

SOCK_XLATE_POINT_POST_DIRECTION_REV

Post reverse service translation

Cilium treats 0 as TO_LXC, but its’s something we should work to remove. This is intentionally set as unknown, so proto API can guarantee the observation point is always going to be present on trace events.

TO_PROXY indicates network packets are transmitted towards the l7 proxy.

TO_HOST indicates network packets are transmitted towards the host namespace.

TO_STACK indicates network packets are transmitted towards the Linux kernel network stack on host machine.

TO_OVERLAY indicates network packets are transmitted towards the tunnel device.

TO_ENDPOINT indicates network packets are transmitted towards endpoints (containers).

FROM_ENDPOINT indicates network packets were received from endpoints (containers).

FROM_PROXY indicates network packets were received from the l7 proxy.

FROM_HOST indicates network packets were received from the host namespace.

FROM_STACK indicates network packets were received from the Linux kernel network stack on host machine.

FROM_OVERLAY indicates network packets were received from the tunnel device.

FROM_NETWORK indicates network packets were received from native devices.

TO_NETWORK indicates network packets are transmitted towards native devices.

FROM_CRYPTO indicates network packets were received from the crypto process for decryption.

TO_CRYPTO indicates network packets are transmitted towards the crypto process for encryption.

TRAFFIC_DIRECTION_UNKNOWN

UNKNOWN is used if there is no verdict for this flow event

FORWARDED is used for flow events where the trace point has forwarded this packet or connection to the next processing entity.

DROPPED is used for flow events where the connection or packet has been dropped (e.g. due to a malformed packet, it being rejected by a network policy etc). The exact drop reason may be found in drop_reason_desc.

ERROR is used for flow events where an error occurred during processing

AUDIT is used on policy verdict events in policy audit mode, to denominate flows that would have been dropped by policy if audit mode was turned off

REDIRECTED is used for flow events which have been redirected to the proxy

TRACED is used for flow events which have been observed at a trace point, but no particular verdict has been reached yet

TRANSLATED is used for flow events where an address has been translated

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead.

Bignum or Fixnum (as required)

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead.

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s.

Always four bytes. More efficient than uint32 if values are often greater than 2^28.

Bignum or Fixnum (as required)

Always eight bytes. More efficient than uint64 if values are often greater than 2^56.

Bignum or Fixnum (as required)

A string must always contain UTF-8 encoded or 7-bit ASCII text.

May contain any arbitrary sequence of bytes.

---

## Protocol Documentation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/_api/v1/observer/README/

**Contents:**
- Protocol Documentation
- Table of Contents
- observer/observer.proto
  - ExportEvent
  - GetAgentEventsRequest
  - GetAgentEventsResponse
  - GetDebugEventsRequest
  - GetDebugEventsResponse
  - GetFlowsRequest
  - GetFlowsRequest.Experimental

observer/observer.proto

GetAgentEventsRequest

GetAgentEventsResponse

GetDebugEventsRequest

GetDebugEventsResponse

GetFlowsRequest.Experimental

GetNamespacesResponse

ExportEvent contains an event to be exported. Not to be used outside of the exporter feature.

relay.NodeStatusEvent

node_status informs clients about the state of the nodes participating in this particular GetFlows request.

lost_events informs clients about events which got dropped due to a Hubble component being unavailable

agent_event informs clients about an event received from the Cilium agent.

debug_event contains Cilium datapath debug events

Name of the node where this event was observed.

google.protobuf.Timestamp

Timestamp at which this event was observed.

Number of flows that should be returned. Incompatible with since/until. Defaults to the most recent (last) number events, unless first is true, then it will return the earliest number events.

first specifies if we should look at the first number events or the last number of events. Incompatible with follow.

follow sets when the server should continue to stream agent events after printing the last N agent events.

google.protobuf.Timestamp

Since this time for returned agent events. Incompatible with number.

google.protobuf.Timestamp

Until this time for returned agent events. Incompatible with number.

GetAgentEventsResponse contains an event received from the Cilium agent.

Name of the node where this event was observed.

google.protobuf.Timestamp

Timestamp at which this event was observed.

Number of events that should be returned. Incompatible with since/until. Defaults to the most recent (last) number events, unless first is true, then it will return the earliest number events.

first specifies if we should look at the first number events or the last number of events. Incompatible with follow.

follow sets when the server should continue to stream debug events after printing the last N debug events.

google.protobuf.Timestamp

Since this time for returned debug events. Incompatible with number.

google.protobuf.Timestamp

Until this time for returned debug events. Incompatible with number.

GetDebugEventsResponse contains a Cilium datapath debug events.

Name of the node where this event was observed.

google.protobuf.Timestamp

Timestamp at which this event was observed.

Number of flows that should be returned. Incompatible with since/until. Defaults to the most recent (last) number flows, unless first is true, then it will return the earliest number flows.

first specifies if we should look at the first number flows or the last number of flows. Incompatible with follow.

follow sets when the server should continue to stream flows after printing the last N flows.

blacklist defines a list of filters which have to match for a flow to be excluded from the result. If multiple blacklist filters are specified, only one of them has to match for a flow to be excluded.

whitelist defines a list of filters which have to match for a flow to be included in the result. If multiple whitelist filters are specified, only one of them has to match for a flow to be included. The whitelist and blacklist can both be specified. In such cases, the set of the returned flows is the set difference whitelist - blacklist. In other words, the result will contain all flows matched by the whitelist that are not also simultaneously matched by the blacklist.

google.protobuf.Timestamp

Since this time for returned flows. Incompatible with number.

google.protobuf.Timestamp

Until this time for returned flows. Incompatible with number.

google.protobuf.FieldMask

FieldMask allows clients to limit flow’s fields that will be returned. For example, {paths: [“source.id”, “destination.id”]} will return flows with only these two fields set.

GetFlowsRequest.Experimental

extensions can be used to add arbitrary additional metadata to GetFlowsRequest. This can be used to extend functionality for other Hubble compatible APIs, or experiment with new functionality without needing to change the public API.

Experimental contains fields that are not stable yet. Support for experimental features is always optional and subject to change.

google.protobuf.FieldMask

Deprecated. FieldMask allows clients to limit flow’s fields that will be returned. For example, {paths: [“source.id”, “destination.id”]} will return flows with only these two fields set. Deprecated in favor of top-level field_mask. This field will be removed in v1.17.

GetFlowsResponse contains either a flow or a protocol message.

relay.NodeStatusEvent

node_status informs clients about the state of the nodes participating in this particular GetFlows request.

lost_events informs clients about events which got dropped due to a Hubble component being unavailable

Name of the node where this event was observed.

google.protobuf.Timestamp

Timestamp at which this event was observed.

GetNamespacesResponse contains the list of namespaces.

Namespaces is a list of namespaces with flows

GetNodesResponse contains the list of nodes.

Nodes is an exhaustive list of nodes.

Node represents a cluster node.

Name is the name of the node.

Version is the version of Cilium/Hubble as reported by the node.

Address is the network address of the API endpoint.

State represents the known state of the node.

TLS reports TLS related information.

UptimeNS is the uptime of this instance in nanoseconds

number of currently captured flows

maximum capacity of the ring buffer

total amount of flows observed since the observer was started

number of currently captured flows In a multi-node context, this is the cumulative count of all captured flows.

maximum capacity of the ring buffer In a multi-node context, this is the aggregation of all ring buffers capacities.

total amount of flows observed since the observer was started In a multi-node context, this is the aggregation of all flows that have been seen.

uptime of this observer instance in nanoseconds In a multi-node context, this field corresponds to the uptime of the longest living instance.

google.protobuf.UInt32Value

number of nodes for which a connection is established

num_unavailable_nodes

google.protobuf.UInt32Value

number of nodes for which a connection cannot be established

list of nodes that are unavailable This list may not be exhaustive.

Version is the version of Cilium/Hubble.

Approximate rate of flows seen by Hubble per second over the last minute. In a multi-node context, this is the sum of all flows rates.

TLS represents TLS information.

Enabled reports whether TLS is enabled or not.

ServerName is the TLS server name that can be used as part of the TLS cert validation process.

Observer returns a stream of Flows depending on which filter the user want to observe.

GetFlowsResponse stream

GetFlows returning structured data, meant to eventually obsolete GetLastNFlows.

GetAgentEventsRequest

GetAgentEventsResponse stream

GetAgentEvents returns Cilium agent events.

GetDebugEventsRequest

GetDebugEventsResponse stream

GetDebugEvents returns Cilium datapath debug events.

GetNodes returns information about nodes in a cluster.

GetNamespacesResponse

GetNamespaces returns information about namespaces in a cluster. The namespaces returned are namespaces which have had network flows in the last hour. The namespaces are returned sorted by cluster name and namespace in ascending order.

ServerStatus returns some details about the running hubble server.

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead.

Bignum or Fixnum (as required)

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead.

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s.

Always four bytes. More efficient than uint32 if values are often greater than 2^28.

Bignum or Fixnum (as required)

Always eight bytes. More efficient than uint64 if values are often greater than 2^56.

Bignum or Fixnum (as required)

A string must always contain UTF-8 encoded or 7-bit ASCII text.

May contain any arbitrary sequence of bytes.

---

## API Reference — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/api/

**Contents:**
- API Reference
- Introduction
- How to access the API
  - CLI Client
    - Example
  - Golang Package
    - Example
- Compatibility Guarantees
- API Reference

The Cilium API is JSON based and provided by the cilium-agent. The purpose of the API is to provide visibility and control over an individual agent instance. In general, all API calls affect only the resources managed by the individual cilium-agent serving the API. A few selected API calls such as the security identity resolution provides cluster wide visibility. Such API calls are marked specifically. Unless noted otherwise, API calls will only affect local agent resources.

The easiest way to access the API is via the cilium CLI client. cilium will automatically locate the API of the agent running on the same node and access it. However, using the -H or --host flag, the cilium client can be pointed to an arbitrary API address.

The following Go packages can be used to access the API:

Main client API abstraction

API resource data type models

The full example can be found in the cilium/client-example repository.

Cilium API is stable as of version 1.0, backward compatibility will be upheld for whole lifecycle of Cilium 1.x.

Get nodes information stored in the cilium-agent

client-id – Client UUID should be used when the client wants to request a diff of nodes added and / or removed since the last time that client has made a request.

Get health of Cilium daemon

Returns health and status information of the Cilium daemon and related components such as the local container runtime, connected datastore, Kubernetes integration and Hubble.

brief – Brief will return a brief representation of the Cilium status.

require-k8s-connectivity – If set to true, failure of the agent to connect to the Kubernetes control plane will cause the agent’s health status to also fail.

attach-mode (string) – Core datapath attachment mode

auth-certificate-provider.msg (string) – Human readable status/error/warning message

auth-certificate-provider.state (string) – State the component is in

bandwidth-manager.congestionControl (string) –

bandwidth-manager.devices[] (string) –

bandwidth-manager.enabled (boolean) – Is bandwidth manager enabled

bpf-maps.dynamic-size-ratio (number) – Ratio of total system memory to use for dynamic sizing of BPF maps

bpf-maps.maps[].name (string) – Name of the BPF map

bpf-maps.maps[].size (integer) – Size of the BPF map

cilium.msg (string) – Human readable status/error/warning message

cilium.state (string) – State the component is in

client-id (integer) – When supported by the API, this client ID should be used by the client when making another request to the server. See for example “/cluster/nodes”.

clock-source.hertz (integer) – Kernel Hz

clock-source.mode (string) – Datapath clock source

cluster (any) – Status of cluster +k8s:deepcopy-gen=true

cluster-mesh (any) – Status of ClusterMesh +k8s:deepcopy-gen=true

cni-chaining (any) – Status of CNI chaining

cni-file.msg (string) – Human readable status/error/warning message

cni-file.state (string) – State the component is in

container-runtime.msg (string) – Human readable status/error/warning message

container-runtime.state (string) – State the component is in

controllers[].configuration.error-retry (boolean) – Retry on error

controllers[].configuration.error-retry-base (string) – Base error retry back-off time

controllers[].configuration.interval (string) – Regular synchronization interval

controllers[].name (string) – Name of controller

controllers[].status.consecutive-failure-count (integer) – Number of consecutive errors since last success

controllers[].status.failure-count (integer) – Total number of failed runs

controllers[].status.last-failure-msg (string) – Error message of last failed run

controllers[].status.last-failure-timestamp (string) – Timestamp of last error

controllers[].status.last-success-timestamp (string) – Timestamp of last success

controllers[].status.success-count (integer) – Total number of successful runs

controllers[].uuid (string) – UUID of controller

datapath-mode (string) – Datapath mode

encryption (any) – Status of transparent encryption +k8s:deepcopy-gen=true

host-firewall.devices[] (string) –

host-firewall.mode (string) –

hubble-metrics.msg (string) – Human readable status/error/warning message

hubble-metrics.state (string) – State the component is in

hubble.msg (string) – Human readable status/error/warning message

hubble.observer.current-flows (integer) – Current number of flows this Hubble observer stores

hubble.observer.max-flows (integer) – Maximum number of flows this Hubble observer is able to store

hubble.observer.seen-flows (integer) – Total number of flows this Hubble observer has seen

hubble.observer.uptime (string) – Uptime of this Hubble observer instance

hubble.state (string) – State the component is in

identity-range (any) – Status of identity range of the cluster

ipam (any) – Status of IP address management +k8s:deepcopy-gen=true

ipv4-big-tcp.enabled (boolean) – Is IPv4 BIG TCP enabled

ipv4-big-tcp.maxGRO (integer) – Maximum IPv4 GRO size

ipv4-big-tcp.maxGSO (integer) – Maximum IPv4 GSO size

ipv6-big-tcp.enabled (boolean) – Is IPv6 BIG TCP enabled

ipv6-big-tcp.maxGRO (integer) – Maximum IPv6 GRO size

ipv6-big-tcp.maxGSO (integer) – Maximum IPv6 GSO size

kube-proxy-replacement.deviceList[].ip[] (string) –

kube-proxy-replacement.deviceList[].name (string) –

kube-proxy-replacement.devices[] (string) –

kube-proxy-replacement.directRoutingDevice (string) –

kube-proxy-replacement.features.annotations[] (string) –

kube-proxy-replacement.features.bpfSocketLBHostnsOnly (boolean) – flag bpf-lb-sock-hostns-only

kube-proxy-replacement.features.externalIPs.enabled (boolean) –

kube-proxy-replacement.features.gracefulTermination.enabled (boolean) –

kube-proxy-replacement.features.hostPort.enabled (boolean) –

kube-proxy-replacement.features.hostReachableServices.enabled (boolean) –

kube-proxy-replacement.features.hostReachableServices.protocols[] (string) –

kube-proxy-replacement.features.nat46X64.enabled (boolean) –

kube-proxy-replacement.features.nat46X64.gateway.enabled (boolean) –

kube-proxy-replacement.features.nat46X64.gateway.prefixes[] (string) –

kube-proxy-replacement.features.nat46X64.service.enabled (boolean) –

kube-proxy-replacement.features.nodePort.acceleration (string) –

kube-proxy-replacement.features.nodePort.algorithm (string) –

kube-proxy-replacement.features.nodePort.dsrMode (string) –

kube-proxy-replacement.features.nodePort.enabled (boolean) –

kube-proxy-replacement.features.nodePort.lutSize (integer) –

kube-proxy-replacement.features.nodePort.mode (string) –

kube-proxy-replacement.features.nodePort.portMax (integer) –

kube-proxy-replacement.features.nodePort.portMin (integer) –

kube-proxy-replacement.features.sessionAffinity.enabled (boolean) –

kube-proxy-replacement.features.socketLB.enabled (boolean) –

kube-proxy-replacement.features.socketLBTracing.enabled (boolean) –

kube-proxy-replacement.mode (string) –

kubernetes.k8s-api-versions[] (string) –

kubernetes.msg (string) – Human readable status/error/warning message

kubernetes.state (string) – State the component is in

kvstore.msg (string) – Human readable status/error/warning message

kvstore.state (string) – State the component is in

masquerading.enabled (boolean) –

masquerading.enabledProtocols.ipv4 (boolean) – Is masquerading enabled for IPv4 traffic

masquerading.enabledProtocols.ipv6 (boolean) – Is masquerading enabled for IPv6 traffic

masquerading.ip-masq-agent (boolean) – Is BPF ip-masq-agent enabled

masquerading.mode (string) –

masquerading.snat-exclusion-cidr (string) – This field is obsolete, please use snat-exclusion-cidr-v4 or snat-exclusion-cidr-v6.

masquerading.snat-exclusion-cidr-v4 (string) – SnatExclusionCIDRv4 exempts SNAT from being performed on any packet sent to an IPv4 address that belongs to this CIDR.

masquerading.snat-exclusion-cidr-v6 (string) – SnatExclusionCIDRv6 exempts SNAT from being performed on any packet sent to an IPv6 address that belongs to this CIDR. For IPv6 we only do masquerading in iptables mode.

nodeMonitor (any) – Status of the node monitor

proxy.envoy-deployment-mode (string) – Deployment mode of Envoy L7 proxy

proxy.ip (string) – IP address that the proxy listens on

proxy.port-range (string) – Port range used for proxying

proxy.redirects[].name (string) – Name of the proxy redirect

proxy.redirects[].proxy (string) – Name of the proxy this redirect points to

proxy.redirects[].proxy-port (integer) – Host port that this redirect points to

proxy.total-ports (integer) – Total number of listening proxy ports

proxy.total-redirects (integer) – Total number of ports configured to redirect to proxies

routing.inter-host-routing-mode (string) – Datapath routing mode for cross-cluster connectivity

routing.intra-host-routing-mode (string) – Datapath routing mode for connectivity within the host

routing.tunnel-protocol (string) – Tunnel protocol in use for cross-cluster connectivity

srv6.enabled (boolean) –

srv6.srv6EncapMode (string) –

stale (object) – List of stale information in the status

Get configuration of Cilium daemon

Returns the configuration of the Cilium daemon.

spec.options (object) – Map of configuration key/value pairs.

spec.policy-enforcement (string) – The policy-enforcement mode

status.GROIPv4MaxSize (integer) – Maximum IPv4 GRO size on workload facing devices

status.GROMaxSize (integer) – Maximum IPv6 GRO size on workload facing devices

status.GSOIPv4MaxSize (integer) – Maximum IPv4 GSO size on workload facing devices

status.GSOMaxSize (integer) – Maximum IPv6 GSO size on workload facing devices

status.addressing.ipv4.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

status.addressing.ipv4.alloc-range (string) – Address pool to be used for local endpoints

status.addressing.ipv4.enabled (boolean) – True if address family is enabled

status.addressing.ipv4.ip (string) – IP address of node

status.addressing.ipv6.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

status.addressing.ipv6.alloc-range (string) – Address pool to be used for local endpoints

status.addressing.ipv6.enabled (boolean) – True if address family is enabled

status.addressing.ipv6.ip (string) – IP address of node

status.daemonConfigurationMap (any) – Config map which contains all the active daemon configurations

status.datapathMode (string) – Datapath mode

status.deviceMTU (integer) – MTU on workload facing devices

status.egress-multi-home-ip-rule-compat (boolean) – Configured compatibility mode for –egress-multi-home-ip-rule-compat

status.enableBBRHostNamespaceOnly (boolean) – True if BBR is enabled only in the host network namespace

status.enableRouteMTUForCNIChaining (boolean) – Enable route MTU for pod netns when CNI chaining is used

status.immutable (object) – Map of configuration key/value pairs.

status.installUplinkRoutesForDelegatedIPAM (boolean) – Install ingress/egress routes through uplink on host for Pods when working with delegated IPAM plugin.

status.ipLocalReservedPorts (string) – Comma-separated list of IP ports should be reserved in the workload network namespace

status.ipam-mode (string) – Configured IPAM mode

status.k8s-configuration (string) –

status.k8s-endpoint (string) –

status.kvstoreConfiguration (any) – Configuration used for the kvstore

status.masquerade (boolean) –

status.masqueradeProtocols.ipv4 (boolean) – Status of masquerading for IPv4 traffic

status.masqueradeProtocols.ipv6 (boolean) – Status of masquerading for IPv6 traffic

status.nodeMonitor (any) – Status of the node monitor

status.realized.options (object) – Map of configuration key/value pairs.

status.realized.policy-enforcement (string) – The policy-enforcement mode

status.routeMTU (integer) – MTU for network facing routes

Modify daemon configuration

Updates the daemon configuration by applying the provided ConfigurationMap and regenerates & recompiles all required datapath components.

options (object) – Map of configuration key/value pairs.

policy-enforcement (string) – The policy-enforcement mode

400 Bad Request – Bad configuration parameters

403 Forbidden – Forbidden

500 Internal Server Error – Recompilation failed

Get endpoint by endpoint ID

Returns endpoint information

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

400 Bad Request – Invalid endpoint ID format for specified type

404 Not Found – Endpoint not found

429 Too Many Requests – Rate-limiting too many requests in the given time frame

id (integer) – The cilium-agent-local ID of the endpoint

spec.label-configuration.user[] (string) –

spec.options (object) – Map of configuration key/value pairs.

status.controllers[].configuration.error-retry (boolean) – Retry on error

status.controllers[].configuration.error-retry-base (string) – Base error retry back-off time

status.controllers[].configuration.interval (string) – Regular synchronization interval

status.controllers[].name (string) – Name of controller

status.controllers[].status.consecutive-failure-count (integer) – Number of consecutive errors since last success

status.controllers[].status.failure-count (integer) – Total number of failed runs

status.controllers[].status.last-failure-msg (string) – Error message of last failed run

status.controllers[].status.last-failure-timestamp (string) – Timestamp of last error

status.controllers[].status.last-success-timestamp (string) – Timestamp of last success

status.controllers[].status.success-count (integer) – Total number of successful runs

status.controllers[].uuid (string) – UUID of controller

status.external-identifiers.cni-attachment-id (string) – ID assigned to this attachment by container runtime

status.external-identifiers.container-id (string) – ID assigned by container runtime (deprecated, may not be unique)

status.external-identifiers.container-name (string) – Name assigned to container (deprecated, may not be unique)

status.external-identifiers.docker-endpoint-id (string) – Docker endpoint ID

status.external-identifiers.docker-network-id (string) – Docker network ID

status.external-identifiers.k8s-namespace (string) – K8s namespace for this endpoint (deprecated, may not be unique)

status.external-identifiers.k8s-pod-name (string) – K8s pod name for this endpoint (deprecated, may not be unique)

status.external-identifiers.pod-name (string) – K8s pod for this endpoint (deprecated, may not be unique)

status.health.bpf (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

status.health.connected (boolean) – Is this endpoint reachable

status.health.overallHealth (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

status.health.policy (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

status.identity.id (integer) – Unique identifier

status.identity.labelsSHA256 (string) – SHA256 of labels

status.identity.labels[] (string) –

status.labels.derived[] (string) –

status.labels.disabled[] (string) –

status.labels.realized.user[] (string) –

status.labels.security-relevant[] (string) –

status.log[].code (string) – Code indicate type of status change

status.log[].message (string) – Status message

status.log[].state (string) – State of endpoint

status.log[].timestamp (string) – Timestamp when status change occurred

status.namedPorts[].name (string) – Optional layer 4 port name

status.namedPorts[].port (integer) – Layer 4 port number

status.namedPorts[].protocol (string) – Layer 4 protocol

status.networking.addressing[].ipv4 (string) – IPv4 address

status.networking.addressing[].ipv4-expiration-uuid (string) – UUID of IPv4 expiration timer

status.networking.addressing[].ipv4-pool-name (string) – IPAM pool from which this IPv4 address was allocated

status.networking.addressing[].ipv6 (string) – IPv6 address

status.networking.addressing[].ipv6-expiration-uuid (string) – UUID of IPv6 expiration timer

status.networking.addressing[].ipv6-pool-name (string) – IPAM pool from which this IPv6 address was allocated

status.networking.container-interface-name (string) – Name of network device in container netns

status.networking.host-addressing.ipv4.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

status.networking.host-addressing.ipv4.alloc-range (string) – Address pool to be used for local endpoints

status.networking.host-addressing.ipv4.enabled (boolean) – True if address family is enabled

status.networking.host-addressing.ipv4.ip (string) – IP address of node

status.networking.host-addressing.ipv6.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

status.networking.host-addressing.ipv6.alloc-range (string) – Address pool to be used for local endpoints

status.networking.host-addressing.ipv6.enabled (boolean) – True if address family is enabled

status.networking.host-addressing.ipv6.ip (string) – IP address of node

status.networking.host-mac (string) – MAC address

status.networking.interface-index (integer) – Index of network device in host netns

status.networking.interface-name (string) – Name of network device in host netns

status.networking.mac (string) – MAC address

status.policy.proxy-policy-revision (integer) – The policy revision currently enforced in the proxy for this endpoint

status.policy.proxy-statistics[].allocated-proxy-port (integer) – The port the proxy is listening on

status.policy.proxy-statistics[].location (string) – Location of where the redirect is installed

status.policy.proxy-statistics[].port (integer) – The port subject to the redirect

status.policy.proxy-statistics[].protocol (string) – Name of the L7 protocol

status.policy.proxy-statistics[].statistics.requests.denied (integer) – Number of messages denied

status.policy.proxy-statistics[].statistics.requests.error (integer) – Number of errors while parsing messages

status.policy.proxy-statistics[].statistics.requests.forwarded (integer) – Number of messages forwarded

status.policy.proxy-statistics[].statistics.requests.received (integer) – Number of messages received

status.policy.proxy-statistics[].statistics.responses.denied (integer) – Number of messages denied

status.policy.proxy-statistics[].statistics.responses.error (integer) – Number of errors while parsing messages

status.policy.proxy-statistics[].statistics.responses.forwarded (integer) – Number of messages forwarded

status.policy.proxy-statistics[].statistics.responses.received (integer) – Number of messages received

status.policy.realized.allowed-egress-identities[] (integer) –

status.policy.realized.allowed-ingress-identities[] (integer) –

status.policy.realized.build (integer) – Build number of calculated policy in use

status.policy.realized.cidr-policy.egress[] (any) – A policy rule including the rule labels it derives from

status.policy.realized.cidr-policy.ingress[] (any) – A policy rule including the rule labels it derives from

status.policy.realized.denied-egress-identities[] (integer) –

status.policy.realized.denied-ingress-identities[] (integer) –

status.policy.realized.id (integer) – Own identity of endpoint

status.policy.realized.l4.egress[] (any) – A policy rule including the rule labels it derives from

status.policy.realized.l4.ingress[] (any) – A policy rule including the rule labels it derives from

status.policy.realized.policy-enabled (string) – Whether policy enforcement is enabled (ingress, egress, both or none)

status.policy.realized.policy-revision (integer) – The agent-local policy revision

status.policy.spec.allowed-egress-identities[] (integer) –

status.policy.spec.allowed-ingress-identities[] (integer) –

status.policy.spec.build (integer) – Build number of calculated policy in use

status.policy.spec.cidr-policy.egress[] (any) – A policy rule including the rule labels it derives from

status.policy.spec.cidr-policy.ingress[] (any) – A policy rule including the rule labels it derives from

status.policy.spec.denied-egress-identities[] (integer) –

status.policy.spec.denied-ingress-identities[] (integer) –

status.policy.spec.id (integer) – Own identity of endpoint

status.policy.spec.l4.egress[] (any) – A policy rule including the rule labels it derives from

status.policy.spec.l4.ingress[] (any) – A policy rule including the rule labels it derives from

status.policy.spec.policy-enabled (string) – Whether policy enforcement is enabled (ingress, egress, both or none)

status.policy.spec.policy-revision (integer) – The agent-local policy revision

status.realized.label-configuration.user[] (string) –

status.realized.options (object) – Map of configuration key/value pairs.

status.state (string) – State of endpoint (required)

Creates a new endpoint

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

addressing.ipv4 (string) – IPv4 address

addressing.ipv4-expiration-uuid (string) – UUID of IPv4 expiration timer

addressing.ipv4-pool-name (string) – IPAM pool from which this IPv4 address was allocated

addressing.ipv6 (string) – IPv6 address

addressing.ipv6-expiration-uuid (string) – UUID of IPv6 expiration timer

addressing.ipv6-pool-name (string) – IPAM pool from which this IPv6 address was allocated

container-id (string) – ID assigned by container runtime

container-interface-name (string) – Name of network device in container netns

container-name (string) – Name assigned to container

datapath-configuration.disable-sip-verification (boolean) – Disable source IP verification for the endpoint.

datapath-configuration.external-ipam (boolean) – Indicates that IPAM is done external to Cilium. This will prevent the IP from being released and re-allocation of the IP address is skipped on restore.

datapath-configuration.install-endpoint-route (boolean) – Installs a route in the Linux routing table pointing to the device of the endpoint’s interface.

datapath-configuration.require-arp-passthrough (boolean) – Enable ARP passthrough mode

datapath-configuration.require-egress-prog (boolean) – Endpoint requires a host-facing egress program to be attached to implement ingress policy and reverse NAT.

datapath-configuration.require-routing (boolean) – Endpoint requires BPF routing to be enabled, when disabled, routing is delegated to Linux routing.

datapath-map-id (integer) – ID of datapath tail call map

disable-legacy-identifiers (boolean) – Disables lookup using legacy endpoint identifiers (container name, container id, pod name) for this endpoint

docker-endpoint-id (string) – Docker endpoint ID

docker-network-id (string) – Docker network ID

host-mac (string) – MAC address

id (integer) – Local endpoint ID

interface-index (integer) – Index of network device in host netns

interface-name (string) – Name of network device in host netns

k8s-namespace (string) – Kubernetes namespace name

k8s-pod-name (string) – Kubernetes pod name

k8s-uid (string) – Kubernetes pod UID

mac (string) – MAC address

netns-cookie (string) – Network namespace cookie

parent-interface-index (integer) – Index of network device from which an IP was used as endpoint IP. Only relevant for ENI environments.

pid (integer) – Process ID of the workload belonging to this endpoint

policy-enabled (boolean) – Whether policy enforcement is enabled or not

properties (any) – Properties is used to store information about the endpoint at creation. Useful for tests.

state (string) – State of endpoint (required)

sync-build-endpoint (boolean) – Whether to build an endpoint synchronously

201 Created – Created

400 Bad Request – Invalid endpoint in request

403 Forbidden – Forbidden

409 Conflict – Endpoint already exists

429 Too Many Requests – Rate-limiting too many requests in the given time frame

500 Internal Server Error – Endpoint creation failed

503 Service Unavailable – Service Unavailable

id (integer) – The cilium-agent-local ID of the endpoint

spec.label-configuration.user[] (string) –

spec.options (object) – Map of configuration key/value pairs.

status.controllers[].configuration.error-retry (boolean) – Retry on error

status.controllers[].configuration.error-retry-base (string) – Base error retry back-off time

status.controllers[].configuration.interval (string) – Regular synchronization interval

status.controllers[].name (string) – Name of controller

status.controllers[].status.consecutive-failure-count (integer) – Number of consecutive errors since last success

status.controllers[].status.failure-count (integer) – Total number of failed runs

status.controllers[].status.last-failure-msg (string) – Error message of last failed run

status.controllers[].status.last-failure-timestamp (string) – Timestamp of last error

status.controllers[].status.last-success-timestamp (string) – Timestamp of last success

status.controllers[].status.success-count (integer) – Total number of successful runs

status.controllers[].uuid (string) – UUID of controller

status.external-identifiers.cni-attachment-id (string) – ID assigned to this attachment by container runtime

status.external-identifiers.container-id (string) – ID assigned by container runtime (deprecated, may not be unique)

status.external-identifiers.container-name (string) – Name assigned to container (deprecated, may not be unique)

status.external-identifiers.docker-endpoint-id (string) – Docker endpoint ID

status.external-identifiers.docker-network-id (string) – Docker network ID

status.external-identifiers.k8s-namespace (string) – K8s namespace for this endpoint (deprecated, may not be unique)

status.external-identifiers.k8s-pod-name (string) – K8s pod name for this endpoint (deprecated, may not be unique)

status.external-identifiers.pod-name (string) – K8s pod for this endpoint (deprecated, may not be unique)

status.health.bpf (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

status.health.connected (boolean) – Is this endpoint reachable

status.health.overallHealth (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

status.health.policy (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

status.identity.id (integer) – Unique identifier

status.identity.labelsSHA256 (string) – SHA256 of labels

status.identity.labels[] (string) –

status.labels.derived[] (string) –

status.labels.disabled[] (string) –

status.labels.realized.user[] (string) –

status.labels.security-relevant[] (string) –

status.log[].code (string) – Code indicate type of status change

status.log[].message (string) – Status message

status.log[].state (string) – State of endpoint

status.log[].timestamp (string) – Timestamp when status change occurred

status.namedPorts[].name (string) – Optional layer 4 port name

status.namedPorts[].port (integer) – Layer 4 port number

status.namedPorts[].protocol (string) – Layer 4 protocol

status.networking.addressing[].ipv4 (string) – IPv4 address

status.networking.addressing[].ipv4-expiration-uuid (string) – UUID of IPv4 expiration timer

status.networking.addressing[].ipv4-pool-name (string) – IPAM pool from which this IPv4 address was allocated

status.networking.addressing[].ipv6 (string) – IPv6 address

status.networking.addressing[].ipv6-expiration-uuid (string) – UUID of IPv6 expiration timer

status.networking.addressing[].ipv6-pool-name (string) – IPAM pool from which this IPv6 address was allocated

status.networking.container-interface-name (string) – Name of network device in container netns

status.networking.host-addressing.ipv4.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

status.networking.host-addressing.ipv4.alloc-range (string) – Address pool to be used for local endpoints

status.networking.host-addressing.ipv4.enabled (boolean) – True if address family is enabled

status.networking.host-addressing.ipv4.ip (string) – IP address of node

status.networking.host-addressing.ipv6.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

status.networking.host-addressing.ipv6.alloc-range (string) – Address pool to be used for local endpoints

status.networking.host-addressing.ipv6.enabled (boolean) – True if address family is enabled

status.networking.host-addressing.ipv6.ip (string) – IP address of node

status.networking.host-mac (string) – MAC address

status.networking.interface-index (integer) – Index of network device in host netns

status.networking.interface-name (string) – Name of network device in host netns

status.networking.mac (string) – MAC address

status.policy.proxy-policy-revision (integer) – The policy revision currently enforced in the proxy for this endpoint

status.policy.proxy-statistics[].allocated-proxy-port (integer) – The port the proxy is listening on

status.policy.proxy-statistics[].location (string) – Location of where the redirect is installed

status.policy.proxy-statistics[].port (integer) – The port subject to the redirect

status.policy.proxy-statistics[].protocol (string) – Name of the L7 protocol

status.policy.proxy-statistics[].statistics.requests.denied (integer) – Number of messages denied

status.policy.proxy-statistics[].statistics.requests.error (integer) – Number of errors while parsing messages

status.policy.proxy-statistics[].statistics.requests.forwarded (integer) – Number of messages forwarded

status.policy.proxy-statistics[].statistics.requests.received (integer) – Number of messages received

status.policy.proxy-statistics[].statistics.responses.denied (integer) – Number of messages denied

status.policy.proxy-statistics[].statistics.responses.error (integer) – Number of errors while parsing messages

status.policy.proxy-statistics[].statistics.responses.forwarded (integer) – Number of messages forwarded

status.policy.proxy-statistics[].statistics.responses.received (integer) – Number of messages received

status.policy.realized.allowed-egress-identities[] (integer) –

status.policy.realized.allowed-ingress-identities[] (integer) –

status.policy.realized.build (integer) – Build number of calculated policy in use

status.policy.realized.cidr-policy.egress[] (any) – A policy rule including the rule labels it derives from

status.policy.realized.cidr-policy.ingress[] (any) – A policy rule including the rule labels it derives from

status.policy.realized.denied-egress-identities[] (integer) –

status.policy.realized.denied-ingress-identities[] (integer) –

status.policy.realized.id (integer) – Own identity of endpoint

status.policy.realized.l4.egress[] (any) – A policy rule including the rule labels it derives from

status.policy.realized.l4.ingress[] (any) – A policy rule including the rule labels it derives from

status.policy.realized.policy-enabled (string) – Whether policy enforcement is enabled (ingress, egress, both or none)

status.policy.realized.policy-revision (integer) – The agent-local policy revision

status.policy.spec.allowed-egress-identities[] (integer) –

status.policy.spec.allowed-ingress-identities[] (integer) –

status.policy.spec.build (integer) – Build number of calculated policy in use

status.policy.spec.cidr-policy.egress[] (any) – A policy rule including the rule labels it derives from

status.policy.spec.cidr-policy.ingress[] (any) – A policy rule including the rule labels it derives from

status.policy.spec.denied-egress-identities[] (integer) –

status.policy.spec.denied-ingress-identities[] (integer) –

status.policy.spec.id (integer) – Own identity of endpoint

status.policy.spec.l4.egress[] (any) – A policy rule including the rule labels it derives from

status.policy.spec.l4.ingress[] (any) – A policy rule including the rule labels it derives from

status.policy.spec.policy-enabled (string) – Whether policy enforcement is enabled (ingress, egress, both or none)

status.policy.spec.policy-revision (integer) – The agent-local policy revision

status.realized.label-configuration.user[] (string) –

status.realized.options (object) – Map of configuration key/value pairs.

status.state (string) – State of endpoint (required)

Modify existing endpoint

Applies the endpoint change request to an existing endpoint

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

addressing.ipv4 (string) – IPv4 address

addressing.ipv4-expiration-uuid (string) – UUID of IPv4 expiration timer

addressing.ipv4-pool-name (string) – IPAM pool from which this IPv4 address was allocated

addressing.ipv6 (string) – IPv6 address

addressing.ipv6-expiration-uuid (string) – UUID of IPv6 expiration timer

addressing.ipv6-pool-name (string) – IPAM pool from which this IPv6 address was allocated

container-id (string) – ID assigned by container runtime

container-interface-name (string) – Name of network device in container netns

container-name (string) – Name assigned to container

datapath-configuration.disable-sip-verification (boolean) – Disable source IP verification for the endpoint.

datapath-configuration.external-ipam (boolean) – Indicates that IPAM is done external to Cilium. This will prevent the IP from being released and re-allocation of the IP address is skipped on restore.

datapath-configuration.install-endpoint-route (boolean) – Installs a route in the Linux routing table pointing to the device of the endpoint’s interface.

datapath-configuration.require-arp-passthrough (boolean) – Enable ARP passthrough mode

datapath-configuration.require-egress-prog (boolean) – Endpoint requires a host-facing egress program to be attached to implement ingress policy and reverse NAT.

datapath-configuration.require-routing (boolean) – Endpoint requires BPF routing to be enabled, when disabled, routing is delegated to Linux routing.

datapath-map-id (integer) – ID of datapath tail call map

disable-legacy-identifiers (boolean) – Disables lookup using legacy endpoint identifiers (container name, container id, pod name) for this endpoint

docker-endpoint-id (string) – Docker endpoint ID

docker-network-id (string) – Docker network ID

host-mac (string) – MAC address

id (integer) – Local endpoint ID

interface-index (integer) – Index of network device in host netns

interface-name (string) – Name of network device in host netns

k8s-namespace (string) – Kubernetes namespace name

k8s-pod-name (string) – Kubernetes pod name

k8s-uid (string) – Kubernetes pod UID

mac (string) – MAC address

netns-cookie (string) – Network namespace cookie

parent-interface-index (integer) – Index of network device from which an IP was used as endpoint IP. Only relevant for ENI environments.

pid (integer) – Process ID of the workload belonging to this endpoint

policy-enabled (boolean) – Whether policy enforcement is enabled or not

properties (any) – Properties is used to store information about the endpoint at creation. Useful for tests.

state (string) – State of endpoint (required)

sync-build-endpoint (boolean) – Whether to build an endpoint synchronously

400 Bad Request – Invalid modify endpoint request

403 Forbidden – Forbidden

404 Not Found – Endpoint does not exist

429 Too Many Requests – Rate-limiting too many requests in the given time frame

500 Internal Server Error – Endpoint update failed

503 Service Unavailable – Service Unavailable

Deletes the endpoint specified by the ID. Deletion is imminent and atomic, if the deletion request is valid and the endpoint exists, deletion will occur even if errors are encountered in the process. If errors have been encountered, the code 202 will be returned, otherwise 200 on success.

All resources associated with the endpoint will be freed and the workload represented by the endpoint will be disconnected.It will no longer be able to initiate or receive communications of any sort.

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

206 Partial Content – Deleted with a number of errors encountered

400 Bad Request – Invalid endpoint ID format for specified type. Details in error message

403 Forbidden – Forbidden

404 Not Found – Endpoint not found

429 Too Many Requests – Rate-limiting too many requests in the given time frame

503 Service Unavailable – Service Unavailable

Retrieves a list of endpoints that have metadata matching the provided parameters.

Retrieves a list of endpoints that have metadata matching the provided parameters, or all endpoints if no parameters provided.

404 Not Found – Endpoints with provided parameters not found

429 Too Many Requests – Rate-limiting too many requests in the given time frame

[].id (integer) – The cilium-agent-local ID of the endpoint

[].spec.label-configuration.user[] (string) –

[].spec.options (object) – Map of configuration key/value pairs.

[].status.controllers[].configuration.error-retry (boolean) – Retry on error

[].status.controllers[].configuration.error-retry-base (string) – Base error retry back-off time

[].status.controllers[].configuration.interval (string) – Regular synchronization interval

[].status.controllers[].name (string) – Name of controller

[].status.controllers[].status.consecutive-failure-count (integer) – Number of consecutive errors since last success

[].status.controllers[].status.failure-count (integer) – Total number of failed runs

[].status.controllers[].status.last-failure-msg (string) – Error message of last failed run

[].status.controllers[].status.last-failure-timestamp (string) – Timestamp of last error

[].status.controllers[].status.last-success-timestamp (string) – Timestamp of last success

[].status.controllers[].status.success-count (integer) – Total number of successful runs

[].status.controllers[].uuid (string) – UUID of controller

[].status.external-identifiers.cni-attachment-id (string) – ID assigned to this attachment by container runtime

[].status.external-identifiers.container-id (string) – ID assigned by container runtime (deprecated, may not be unique)

[].status.external-identifiers.container-name (string) – Name assigned to container (deprecated, may not be unique)

[].status.external-identifiers.docker-endpoint-id (string) – Docker endpoint ID

[].status.external-identifiers.docker-network-id (string) – Docker network ID

[].status.external-identifiers.k8s-namespace (string) – K8s namespace for this endpoint (deprecated, may not be unique)

[].status.external-identifiers.k8s-pod-name (string) – K8s pod name for this endpoint (deprecated, may not be unique)

[].status.external-identifiers.pod-name (string) – K8s pod for this endpoint (deprecated, may not be unique)

[].status.health.bpf (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

[].status.health.connected (boolean) – Is this endpoint reachable

[].status.health.overallHealth (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

[].status.health.policy (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

[].status.identity.id (integer) – Unique identifier

[].status.identity.labelsSHA256 (string) – SHA256 of labels

[].status.identity.labels[] (string) –

[].status.labels.derived[] (string) –

[].status.labels.disabled[] (string) –

[].status.labels.realized.user[] (string) –

[].status.labels.security-relevant[] (string) –

[].status.log[].code (string) – Code indicate type of status change

[].status.log[].message (string) – Status message

[].status.log[].state (string) – State of endpoint

[].status.log[].timestamp (string) – Timestamp when status change occurred

[].status.namedPorts[].name (string) – Optional layer 4 port name

[].status.namedPorts[].port (integer) – Layer 4 port number

[].status.namedPorts[].protocol (string) – Layer 4 protocol

[].status.networking.addressing[].ipv4 (string) – IPv4 address

[].status.networking.addressing[].ipv4-expiration-uuid (string) – UUID of IPv4 expiration timer

[].status.networking.addressing[].ipv4-pool-name (string) – IPAM pool from which this IPv4 address was allocated

[].status.networking.addressing[].ipv6 (string) – IPv6 address

[].status.networking.addressing[].ipv6-expiration-uuid (string) – UUID of IPv6 expiration timer

[].status.networking.addressing[].ipv6-pool-name (string) – IPAM pool from which this IPv6 address was allocated

[].status.networking.container-interface-name (string) – Name of network device in container netns

[].status.networking.host-addressing.ipv4.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

[].status.networking.host-addressing.ipv4.alloc-range (string) – Address pool to be used for local endpoints

[].status.networking.host-addressing.ipv4.enabled (boolean) – True if address family is enabled

[].status.networking.host-addressing.ipv4.ip (string) – IP address of node

[].status.networking.host-addressing.ipv6.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

[].status.networking.host-addressing.ipv6.alloc-range (string) – Address pool to be used for local endpoints

[].status.networking.host-addressing.ipv6.enabled (boolean) – True if address family is enabled

[].status.networking.host-addressing.ipv6.ip (string) – IP address of node

[].status.networking.host-mac (string) – MAC address

[].status.networking.interface-index (integer) – Index of network device in host netns

[].status.networking.interface-name (string) – Name of network device in host netns

[].status.networking.mac (string) – MAC address

[].status.policy.proxy-policy-revision (integer) – The policy revision currently enforced in the proxy for this endpoint

[].status.policy.proxy-statistics[].allocated-proxy-port (integer) – The port the proxy is listening on

[].status.policy.proxy-statistics[].location (string) – Location of where the redirect is installed

[].status.policy.proxy-statistics[].port (integer) – The port subject to the redirect

[].status.policy.proxy-statistics[].protocol (string) – Name of the L7 protocol

[].status.policy.proxy-statistics[].statistics.requests.denied (integer) – Number of messages denied

[].status.policy.proxy-statistics[].statistics.requests.error (integer) – Number of errors while parsing messages

[].status.policy.proxy-statistics[].statistics.requests.forwarded (integer) – Number of messages forwarded

[].status.policy.proxy-statistics[].statistics.requests.received (integer) – Number of messages received

[].status.policy.proxy-statistics[].statistics.responses.denied (integer) – Number of messages denied

[].status.policy.proxy-statistics[].statistics.responses.error (integer) – Number of errors while parsing messages

[].status.policy.proxy-statistics[].statistics.responses.forwarded (integer) – Number of messages forwarded

[].status.policy.proxy-statistics[].statistics.responses.received (integer) – Number of messages received

[].status.policy.realized.allowed-egress-identities[] (integer) –

[].status.policy.realized.allowed-ingress-identities[] (integer) –

[].status.policy.realized.build (integer) – Build number of calculated policy in use

[].status.policy.realized.cidr-policy.egress[] (any) – A policy rule including the rule labels it derives from

[].status.policy.realized.cidr-policy.ingress[] (any) – A policy rule including the rule labels it derives from

[].status.policy.realized.denied-egress-identities[] (integer) –

[].status.policy.realized.denied-ingress-identities[] (integer) –

[].status.policy.realized.id (integer) – Own identity of endpoint

[].status.policy.realized.l4.egress[] (any) – A policy rule including the rule labels it derives from

[].status.policy.realized.l4.ingress[] (any) – A policy rule including the rule labels it derives from

[].status.policy.realized.policy-enabled (string) – Whether policy enforcement is enabled (ingress, egress, both or none)

[].status.policy.realized.policy-revision (integer) – The agent-local policy revision

[].status.policy.spec.allowed-egress-identities[] (integer) –

[].status.policy.spec.allowed-ingress-identities[] (integer) –

[].status.policy.spec.build (integer) – Build number of calculated policy in use

[].status.policy.spec.cidr-policy.egress[] (any) – A policy rule including the rule labels it derives from

[].status.policy.spec.cidr-policy.ingress[] (any) – A policy rule including the rule labels it derives from

[].status.policy.spec.denied-egress-identities[] (integer) –

[].status.policy.spec.denied-ingress-identities[] (integer) –

[].status.policy.spec.id (integer) – Own identity of endpoint

[].status.policy.spec.l4.egress[] (any) – A policy rule including the rule labels it derives from

[].status.policy.spec.l4.ingress[] (any) – A policy rule including the rule labels it derives from

[].status.policy.spec.policy-enabled (string) – Whether policy enforcement is enabled (ingress, egress, both or none)

[].status.policy.spec.policy-revision (integer) – The agent-local policy revision

[].status.realized.label-configuration.user[] (string) –

[].status.realized.options (object) – Map of configuration key/value pairs.

[].status.state (string) – State of endpoint (required)

Deletes a list of endpoints

Deletes a list of endpoints that have endpoints matching the provided properties

container-id (string) – ID assigned by container runtime

206 Partial Content – Deleted with a number of errors encountered

400 Bad Request – Invalid endpoint delete request

404 Not Found – No endpoints with provided parameters found

429 Too Many Requests – Rate-limiting too many requests in the given time frame

503 Service Unavailable – Service Unavailable

Retrieve endpoint configuration

Retrieves the configuration of the specified endpoint.

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

404 Not Found – Endpoint not found

429 Too Many Requests – Rate-limiting too many requests in the given time frame

immutable (object) – Map of configuration key/value pairs.

realized.label-configuration.user[] (string) –

realized.options (object) – Map of configuration key/value pairs.

Modify mutable endpoint configuration

Update the configuration of an existing endpoint and regenerates & recompiles the corresponding programs automatically.

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

label-configuration.user[] (string) –

options (object) – Map of configuration key/value pairs.

400 Bad Request – Invalid configuration request

403 Forbidden – Forbidden

404 Not Found – Endpoint not found

429 Too Many Requests – Rate-limiting too many requests in the given time frame

500 Internal Server Error – Update failed. Details in message.

503 Service Unavailable – Service Unavailable

Retrieves the list of labels associated with an endpoint.

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

404 Not Found – Endpoint not found

429 Too Many Requests – Rate-limiting too many requests in the given time frame

spec.user[] (string) –

status.derived[] (string) –

status.disabled[] (string) –

status.realized.user[] (string) –

status.security-relevant[] (string) –

Set label configuration of endpoint

Sets labels associated with an endpoint. These can be user provided or derived from the orchestration system.

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

403 Forbidden – Forbidden

404 Not Found – Endpoint not found

429 Too Many Requests – Rate-limiting too many requests in the given time frame

500 Internal Server Error – Error while updating labels

503 Service Unavailable – Service Unavailable

Retrieves the status logs associated with this endpoint.

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

400 Bad Request – Invalid identity provided

404 Not Found – Endpoint not found

429 Too Many Requests – Rate-limiting too many requests in the given time frame

[].code (string) – Code indicate type of status change

[].message (string) – Status message

[].state (string) – State of endpoint

[].timestamp (string) – Timestamp when status change occurred

Retrieves the status logs associated with this endpoint.

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

400 Bad Request – Invalid identity provided

404 Not Found – Endpoint not found

429 Too Many Requests – Rate-limiting too many requests in the given time frame

bpf (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

connected (boolean) – Is this endpoint reachable

overallHealth (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

policy (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

Retrieves a list of identities that have metadata matching the provided parameters.

Retrieves a list of identities that have metadata matching the provided parameters, or all identities if no parameters are provided.

404 Not Found – Identities with provided parameters not found

520 – Identity storage unreachable. Likely a network problem.

521 – Invalid identity format in storage

[].id (integer) – Unique identifier

[].labelsSHA256 (string) – SHA256 of labels

[].labels[] (string) –

id (string) – Cluster wide unique identifier of a security identity.

400 Bad Request – Invalid identity provided

404 Not Found – Identity not found

520 – Identity storage unreachable. Likely a network problem.

521 – Invalid identity format in storage

id (integer) – Unique identifier

labelsSHA256 (string) – SHA256 of labels

Retrieve identities which are being used by local endpoints

404 Not Found – Set of identities which are being used by local endpoints could not be found.

[].identity.id (integer) – Unique identifier

[].identity.labelsSHA256 (string) – SHA256 of labels

[].identity.labels[] (string) –

[].refCount (integer) – number of endpoints consuming this identity locally (should always be > 0)

Allocate an IP address

201 Created – Success

403 Forbidden – Forbidden

502 Bad Gateway – Allocation failure

address.ipv4 (string) – IPv4 address

address.ipv4-expiration-uuid (string) – UUID of IPv4 expiration timer

address.ipv4-pool-name (string) – IPAM pool from which this IPv4 address was allocated

address.ipv6 (string) – IPv6 address

address.ipv6-expiration-uuid (string) – UUID of IPv6 expiration timer

address.ipv6-pool-name (string) – IPAM pool from which this IPv6 address was allocated

host-addressing.ipv4.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

host-addressing.ipv4.alloc-range (string) – Address pool to be used for local endpoints

host-addressing.ipv4.enabled (boolean) – True if address family is enabled

host-addressing.ipv4.ip (string) – IP address of node

host-addressing.ipv6.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

host-addressing.ipv6.alloc-range (string) – Address pool to be used for local endpoints

host-addressing.ipv6.enabled (boolean) – True if address family is enabled

host-addressing.ipv6.ip (string) – IP address of node

ipv4.cidrs[] (string) –

ipv4.expiration-uuid (string) – The UUID for the expiration timer. Set when expiration has been enabled while allocating.

ipv4.gateway (string) – IP of gateway

ipv4.interface-number (string) – InterfaceNumber is a field for generically identifying an interface. This is only useful in ENI mode.

ipv4.ip (string) – Allocated IP for endpoint

ipv4.master-mac (string) – MAC of master interface if address is a slave/secondary of a master interface

ipv6.cidrs[] (string) –

ipv6.expiration-uuid (string) – The UUID for the expiration timer. Set when expiration has been enabled while allocating.

ipv6.gateway (string) – IP of gateway

ipv6.interface-number (string) – InterfaceNumber is a field for generically identifying an interface. This is only useful in ENI mode.

ipv6.ip (string) – Allocated IP for endpoint

ipv6.master-mac (string) – MAC of master interface if address is a slave/secondary of a master interface

Allocate an IP address

ip (string) – IP address

400 Bad Request – Invalid IP address

403 Forbidden – Forbidden

409 Conflict – IP already allocated

500 Internal Server Error – IP allocation failure. Details in message.

501 Not Implemented – Allocation for address family disabled

Release an allocated IP address

ip (string) – IP address

400 Bad Request – Invalid IP address

403 Forbidden – Forbidden

404 Not Found – IP address not found

500 Internal Server Error – Address release failure

501 Not Implemented – Allocation for address family disabled

Retrieve entire policy tree

Returns the entire policy tree with all children.

Deprecated: will be removed in v1.19

404 Not Found – No policy rules found

policy (string) – Policy definition as JSON.

revision (integer) – Revision number of the policy. Incremented each time the policy is changed in the agent’s repository

Create or update a policy (sub)tree

Deprecated: will be removed in v1.19

replace (boolean) – If true, indicates that existing rules with identical labels should be replaced.

replace-with-labels (array) – If present, indicates that existing rules with the given labels should be deleted.

400 Bad Request – Invalid policy

403 Forbidden – Forbidden

500 Internal Server Error – Policy import failed

policy (string) – Policy definition as JSON.

revision (integer) – Revision number of the policy. Incremented each time the policy is changed in the agent’s repository

Delete a policy (sub)tree

Deprecated: will be removed in v1.19

400 Bad Request – Invalid request

403 Forbidden – Forbidden

404 Not Found – Policy not found

500 Internal Server Error – Error while deleting policy

policy (string) – Policy definition as JSON.

revision (integer) – Revision number of the policy. Incremented each time the policy is changed in the agent’s repository

See what selectors match which identities

[].identities[] (integer) –

[].labels[].key (string) –

[].labels[].source (string) – Source can be one of the above values (e.g. LabelSourceContainer)

[].labels[].value (string) –

[].selector (string) – string form of selector

[].users (integer) – number of users of this selector in the cache

Retrieve list of all local redirect policies

[].frontend-mappings[].backends[].backend-address.ip (string) – Layer 3 address (required)

[].frontend-mappings[].backends[].backend-address.nodeName (string) – Optional name of the node on which this backend runs

[].frontend-mappings[].backends[].backend-address.port (integer) – Layer 4 port number

[].frontend-mappings[].backends[].backend-address.preferred (boolean) – Indicator if this backend is preferred in the context of clustermesh service affinity. The value is set based on related annotation of global service. Applicable for active state only.

[].frontend-mappings[].backends[].backend-address.protocol (string) – Layer 4 protocol (TCP, UDP, etc)

[].frontend-mappings[].backends[].backend-address.state (string) – State of the backend for load-balancing service traffic

[].frontend-mappings[].backends[].backend-address.weight (integer) – Backend weight

[].frontend-mappings[].backends[].backend-address.zone (string) – Optional name of the zone in which this backend runs

[].frontend-mappings[].backends[].pod-id (string) – Namespace and name of the backend pod

[].frontend-mappings[].frontend-address.ip (string) – Layer 3 address

[].frontend-mappings[].frontend-address.port (integer) – Layer 4 port number

[].frontend-mappings[].frontend-address.protocol (string) – Layer 4 protocol

[].frontend-mappings[].frontend-address.scope (string) – Load balancing scope for frontend address

[].frontend-type (string) – LRP frontend type

[].lrp-type (string) – LRP config type

[].name (string) – LRP service name

[].namespace (string) – LRP service namespace

[].service-id (string) – matching k8s service namespace and name

[].uid (string) – Unique identification

Retrieve list of all services

[].spec.backend-addresses[].ip (string) – Layer 3 address (required)

[].spec.backend-addresses[].nodeName (string) – Optional name of the node on which this backend runs

[].spec.backend-addresses[].port (integer) – Layer 4 port number

[].spec.backend-addresses[].preferred (boolean) – Indicator if this backend is preferred in the context of clustermesh service affinity. The value is set based on related annotation of global service. Applicable for active state only.

[].spec.backend-addresses[].protocol (string) – Layer 4 protocol (TCP, UDP, etc)

[].spec.backend-addresses[].state (string) – State of the backend for load-balancing service traffic

[].spec.backend-addresses[].weight (integer) – Backend weight

[].spec.backend-addresses[].zone (string) – Optional name of the zone in which this backend runs

[].spec.flags.cluster (string) – Service cluster

[].spec.flags.extTrafficPolicy (string) – Service external traffic policy

[].spec.flags.healthCheckNodePort (integer) – Service health check node port

[].spec.flags.intTrafficPolicy (string) – Service internal traffic policy

[].spec.flags.name (string) – Service name (e.g. Kubernetes service name)

[].spec.flags.namespace (string) – Service namespace (e.g. Kubernetes namespace)

[].spec.flags.natPolicy (string) – Service protocol NAT policy

[].spec.flags.trafficPolicy (string) – Service external traffic policy (deprecated in favor of extTrafficPolicy)

[].spec.flags.type (string) – Service type

[].spec.frontend-address.ip (string) – Layer 3 address

[].spec.frontend-address.port (integer) – Layer 4 port number

[].spec.frontend-address.protocol (string) – Layer 4 protocol

[].spec.frontend-address.scope (string) – Load balancing scope for frontend address

[].spec.id (integer) – Unique identification

[].spec.updateServices (boolean) – Update all services selecting the backends with their given states (id and frontend are ignored)

[].status.realized.backend-addresses[].ip (string) – Layer 3 address (required)

[].status.realized.backend-addresses[].nodeName (string) – Optional name of the node on which this backend runs

[].status.realized.backend-addresses[].port (integer) – Layer 4 port number

[].status.realized.backend-addresses[].preferred (boolean) – Indicator if this backend is preferred in the context of clustermesh service affinity. The value is set based on related annotation of global service. Applicable for active state only.

[].status.realized.backend-addresses[].protocol (string) – Layer 4 protocol (TCP, UDP, etc)

[].status.realized.backend-addresses[].state (string) – State of the backend for load-balancing service traffic

[].status.realized.backend-addresses[].weight (integer) – Backend weight

[].status.realized.backend-addresses[].zone (string) – Optional name of the zone in which this backend runs

[].status.realized.flags.cluster (string) – Service cluster

[].status.realized.flags.extTrafficPolicy (string) – Service external traffic policy

[].status.realized.flags.healthCheckNodePort (integer) – Service health check node port

[].status.realized.flags.intTrafficPolicy (string) – Service internal traffic policy

[].status.realized.flags.name (string) – Service name (e.g. Kubernetes service name)

[].status.realized.flags.namespace (string) – Service namespace (e.g. Kubernetes namespace)

[].status.realized.flags.natPolicy (string) – Service protocol NAT policy

[].status.realized.flags.trafficPolicy (string) – Service external traffic policy (deprecated in favor of extTrafficPolicy)

[].status.realized.flags.type (string) – Service type

[].status.realized.frontend-address.ip (string) – Layer 3 address

[].status.realized.frontend-address.port (integer) – Layer 4 port number

[].status.realized.frontend-address.protocol (string) – Layer 4 protocol

[].status.realized.frontend-address.scope (string) – Load balancing scope for frontend address

[].status.realized.id (integer) – Unique identification

[].status.realized.updateServices (boolean) – Update all services selecting the backends with their given states (id and frontend are ignored)

Retrieve list of all recorders

[].spec.capture-length (integer) – Maximum packet length or zero for full packet length

[].spec.filters[].dst-port (string) – Layer 4 destination port, zero (or in future range)

[].spec.filters[].dst-prefix (string) – Layer 3 destination CIDR

[].spec.filters[].protocol (string) – Layer 4 protocol

[].spec.filters[].src-port (string) – Layer 4 source port, zero (or in future range)

[].spec.filters[].src-prefix (string) – Layer 3 source CIDR

[].spec.id (integer) – Unique identification (required)

[].status.realized.capture-length (integer) – Maximum packet length or zero for full packet length

[].status.realized.filters[].dst-port (string) – Layer 4 destination port, zero (or in future range)

[].status.realized.filters[].dst-prefix (string) – Layer 3 destination CIDR

[].status.realized.filters[].protocol (string) – Layer 4 protocol

[].status.realized.filters[].src-port (string) – Layer 4 source port, zero (or in future range)

[].status.realized.filters[].src-prefix (string) – Layer 3 source CIDR

[].status.realized.id (integer) – Unique identification (required)

Retrieve list of all recorder masks

[].status.realized.dst-port-mask (string) – Layer 4 destination port mask

[].status.realized.dst-prefix-mask (string) – Layer 3 destination IP mask

[].status.realized.priority (integer) – Priority of this mask

[].status.realized.protocol-mask (string) – Layer 4 protocol mask

[].status.realized.src-port-mask (string) – Layer 4 source port mask

[].status.realized.src-prefix-mask (string) – Layer 3 source IP mask

[].status.realized.users (integer) – Number of users of this mask

Retrieve configuration of a recorder

id (integer) – ID of recorder

404 Not Found – Recorder not found

spec.capture-length (integer) – Maximum packet length or zero for full packet length

spec.filters[].dst-port (string) – Layer 4 destination port, zero (or in future range)

spec.filters[].dst-prefix (string) – Layer 3 destination CIDR

spec.filters[].protocol (string) – Layer 4 protocol

spec.filters[].src-port (string) – Layer 4 source port, zero (or in future range)

spec.filters[].src-prefix (string) – Layer 3 source CIDR

spec.id (integer) – Unique identification (required)

status.realized.capture-length (integer) – Maximum packet length or zero for full packet length

status.realized.filters[].dst-port (string) – Layer 4 destination port, zero (or in future range)

status.realized.filters[].dst-prefix (string) – Layer 3 destination CIDR

status.realized.filters[].protocol (string) – Layer 4 protocol

status.realized.filters[].src-port (string) – Layer 4 source port, zero (or in future range)

status.realized.filters[].src-prefix (string) – Layer 3 source CIDR

status.realized.id (integer) – Unique identification (required)

Create or update recorder

id (integer) – ID of recorder

capture-length (integer) – Maximum packet length or zero for full packet length

filters[].dst-port (string) – Layer 4 destination port, zero (or in future range)

filters[].dst-prefix (string) – Layer 3 destination CIDR

filters[].protocol (string) – Layer 4 protocol

filters[].src-port (string) – Layer 4 source port, zero (or in future range)

filters[].src-prefix (string) – Layer 3 source CIDR

id (integer) – Unique identification (required)

201 Created – Created

403 Forbidden – Forbidden

500 Internal Server Error – Error while creating recorder

id (integer) – ID of recorder

403 Forbidden – Forbidden

404 Not Found – Recorder not found

500 Internal Server Error – Recorder deletion failed

Retrieve list of CIDRs

500 Internal Server Error – Prefilter get failed

spec.deny[] (string) –

spec.revision (integer) –

status.realized.deny[] (string) –

status.realized.revision (integer) –

403 Forbidden – Forbidden

461 – Invalid CIDR prefix

500 Internal Server Error – Prefilter update failed

spec.deny[] (string) –

spec.revision (integer) –

status.realized.deny[] (string) –

status.realized.revision (integer) –

403 Forbidden – Forbidden

461 – Invalid CIDR prefix

500 Internal Server Error – Prefilter delete failed

spec.deny[] (string) –

spec.revision (integer) –

status.realized.deny[] (string) –

status.realized.revision (integer) –

Retrieve information about the agent and environment for debugging

500 Internal Server Error – DebugInfo get failed

cilium-memory-map (string) –

cilium-nodemonitor-memory-map (string) –

cilium-status.attach-mode (string) – Core datapath attachment mode

cilium-status.auth-certificate-provider.msg (string) – Human readable status/error/warning message

cilium-status.auth-certificate-provider.state (string) – State the component is in

cilium-status.bandwidth-manager.congestionControl (string) –

cilium-status.bandwidth-manager.devices[] (string) –

cilium-status.bandwidth-manager.enabled (boolean) – Is bandwidth manager enabled

cilium-status.bpf-maps.dynamic-size-ratio (number) – Ratio of total system memory to use for dynamic sizing of BPF maps

cilium-status.bpf-maps.maps[].name (string) – Name of the BPF map

cilium-status.bpf-maps.maps[].size (integer) – Size of the BPF map

cilium-status.cilium.msg (string) – Human readable status/error/warning message

cilium-status.cilium.state (string) – State the component is in

cilium-status.client-id (integer) – When supported by the API, this client ID should be used by the client when making another request to the server. See for example “/cluster/nodes”.

cilium-status.clock-source.hertz (integer) – Kernel Hz

cilium-status.clock-source.mode (string) – Datapath clock source

cilium-status.cluster (any) – Status of cluster +k8s:deepcopy-gen=true

cilium-status.cluster-mesh (any) – Status of ClusterMesh +k8s:deepcopy-gen=true

cilium-status.cni-chaining (any) – Status of CNI chaining

cilium-status.cni-file.msg (string) – Human readable status/error/warning message

cilium-status.cni-file.state (string) – State the component is in

cilium-status.container-runtime.msg (string) – Human readable status/error/warning message

cilium-status.container-runtime.state (string) – State the component is in

cilium-status.controllers[].configuration.error-retry (boolean) – Retry on error

cilium-status.controllers[].configuration.error-retry-base (string) – Base error retry back-off time

cilium-status.controllers[].configuration.interval (string) – Regular synchronization interval

cilium-status.controllers[].name (string) – Name of controller

cilium-status.controllers[].status.consecutive-failure-count (integer) – Number of consecutive errors since last success

cilium-status.controllers[].status.failure-count (integer) – Total number of failed runs

cilium-status.controllers[].status.last-failure-msg (string) – Error message of last failed run

cilium-status.controllers[].status.last-failure-timestamp (string) – Timestamp of last error

cilium-status.controllers[].status.last-success-timestamp (string) – Timestamp of last success

cilium-status.controllers[].status.success-count (integer) – Total number of successful runs

cilium-status.controllers[].uuid (string) – UUID of controller

cilium-status.datapath-mode (string) – Datapath mode

cilium-status.encryption (any) – Status of transparent encryption +k8s:deepcopy-gen=true

cilium-status.host-firewall.devices[] (string) –

cilium-status.host-firewall.mode (string) –

cilium-status.hubble-metrics.msg (string) – Human readable status/error/warning message

cilium-status.hubble-metrics.state (string) – State the component is in

cilium-status.hubble.msg (string) – Human readable status/error/warning message

cilium-status.hubble.observer.current-flows (integer) – Current number of flows this Hubble observer stores

cilium-status.hubble.observer.max-flows (integer) – Maximum number of flows this Hubble observer is able to store

cilium-status.hubble.observer.seen-flows (integer) – Total number of flows this Hubble observer has seen

cilium-status.hubble.observer.uptime (string) – Uptime of this Hubble observer instance

cilium-status.hubble.state (string) – State the component is in

cilium-status.identity-range (any) – Status of identity range of the cluster

cilium-status.ipam (any) – Status of IP address management +k8s:deepcopy-gen=true

cilium-status.ipv4-big-tcp.enabled (boolean) – Is IPv4 BIG TCP enabled

cilium-status.ipv4-big-tcp.maxGRO (integer) – Maximum IPv4 GRO size

cilium-status.ipv4-big-tcp.maxGSO (integer) – Maximum IPv4 GSO size

cilium-status.ipv6-big-tcp.enabled (boolean) – Is IPv6 BIG TCP enabled

cilium-status.ipv6-big-tcp.maxGRO (integer) – Maximum IPv6 GRO size

cilium-status.ipv6-big-tcp.maxGSO (integer) – Maximum IPv6 GSO size

cilium-status.kube-proxy-replacement.deviceList[].ip[] (string) –

cilium-status.kube-proxy-replacement.deviceList[].name (string) –

cilium-status.kube-proxy-replacement.devices[] (string) –

cilium-status.kube-proxy-replacement.directRoutingDevice (string) –

cilium-status.kube-proxy-replacement.features.annotations[] (string) –

cilium-status.kube-proxy-replacement.features.bpfSocketLBHostnsOnly (boolean) – flag bpf-lb-sock-hostns-only

cilium-status.kube-proxy-replacement.features.externalIPs.enabled (boolean) –

cilium-status.kube-proxy-replacement.features.gracefulTermination.enabled (boolean) –

cilium-status.kube-proxy-replacement.features.hostPort.enabled (boolean) –

cilium-status.kube-proxy-replacement.features.hostReachableServices.enabled (boolean) –

cilium-status.kube-proxy-replacement.features.hostReachableServices.protocols[] (string) –

cilium-status.kube-proxy-replacement.features.nat46X64.enabled (boolean) –

cilium-status.kube-proxy-replacement.features.nat46X64.gateway.enabled (boolean) –

cilium-status.kube-proxy-replacement.features.nat46X64.gateway.prefixes[] (string) –

cilium-status.kube-proxy-replacement.features.nat46X64.service.enabled (boolean) –

cilium-status.kube-proxy-replacement.features.nodePort.acceleration (string) –

cilium-status.kube-proxy-replacement.features.nodePort.algorithm (string) –

cilium-status.kube-proxy-replacement.features.nodePort.dsrMode (string) –

cilium-status.kube-proxy-replacement.features.nodePort.enabled (boolean) –

cilium-status.kube-proxy-replacement.features.nodePort.lutSize (integer) –

cilium-status.kube-proxy-replacement.features.nodePort.mode (string) –

cilium-status.kube-proxy-replacement.features.nodePort.portMax (integer) –

cilium-status.kube-proxy-replacement.features.nodePort.portMin (integer) –

cilium-status.kube-proxy-replacement.features.sessionAffinity.enabled (boolean) –

cilium-status.kube-proxy-replacement.features.socketLB.enabled (boolean) –

cilium-status.kube-proxy-replacement.features.socketLBTracing.enabled (boolean) –

cilium-status.kube-proxy-replacement.mode (string) –

cilium-status.kubernetes.k8s-api-versions[] (string) –

cilium-status.kubernetes.msg (string) – Human readable status/error/warning message

cilium-status.kubernetes.state (string) – State the component is in

cilium-status.kvstore.msg (string) – Human readable status/error/warning message

cilium-status.kvstore.state (string) – State the component is in

cilium-status.masquerading.enabled (boolean) –

cilium-status.masquerading.enabledProtocols.ipv4 (boolean) – Is masquerading enabled for IPv4 traffic

cilium-status.masquerading.enabledProtocols.ipv6 (boolean) – Is masquerading enabled for IPv6 traffic

cilium-status.masquerading.ip-masq-agent (boolean) – Is BPF ip-masq-agent enabled

cilium-status.masquerading.mode (string) –

cilium-status.masquerading.snat-exclusion-cidr (string) – This field is obsolete, please use snat-exclusion-cidr-v4 or snat-exclusion-cidr-v6.

cilium-status.masquerading.snat-exclusion-cidr-v4 (string) – SnatExclusionCIDRv4 exempts SNAT from being performed on any packet sent to an IPv4 address that belongs to this CIDR.

cilium-status.masquerading.snat-exclusion-cidr-v6 (string) – SnatExclusionCIDRv6 exempts SNAT from being performed on any packet sent to an IPv6 address that belongs to this CIDR. For IPv6 we only do masquerading in iptables mode.

cilium-status.nodeMonitor (any) – Status of the node monitor

cilium-status.proxy.envoy-deployment-mode (string) – Deployment mode of Envoy L7 proxy

cilium-status.proxy.ip (string) – IP address that the proxy listens on

cilium-status.proxy.port-range (string) – Port range used for proxying

cilium-status.proxy.redirects[].name (string) – Name of the proxy redirect

cilium-status.proxy.redirects[].proxy (string) – Name of the proxy this redirect points to

cilium-status.proxy.redirects[].proxy-port (integer) – Host port that this redirect points to

cilium-status.proxy.total-ports (integer) – Total number of listening proxy ports

cilium-status.proxy.total-redirects (integer) – Total number of ports configured to redirect to proxies

cilium-status.routing.inter-host-routing-mode (string) – Datapath routing mode for cross-cluster connectivity

cilium-status.routing.intra-host-routing-mode (string) – Datapath routing mode for connectivity within the host

cilium-status.routing.tunnel-protocol (string) – Tunnel protocol in use for cross-cluster connectivity

cilium-status.srv6.enabled (boolean) –

cilium-status.srv6.srv6EncapMode (string) –

cilium-status.stale (object) – List of stale information in the status

cilium-version (string) –

encryption.wireguard (any) – Status of the WireGuard agent +k8s:deepcopy-gen=true

endpoint-list[].id (integer) – The cilium-agent-local ID of the endpoint

endpoint-list[].spec.label-configuration.user[] (string) –

endpoint-list[].spec.options (object) – Map of configuration key/value pairs.

endpoint-list[].status.controllers[].configuration.error-retry (boolean) – Retry on error

endpoint-list[].status.controllers[].configuration.error-retry-base (string) – Base error retry back-off time

endpoint-list[].status.controllers[].configuration.interval (string) – Regular synchronization interval

endpoint-list[].status.controllers[].name (string) – Name of controller

endpoint-list[].status.controllers[].status.consecutive-failure-count (integer) – Number of consecutive errors since last success

endpoint-list[].status.controllers[].status.failure-count (integer) – Total number of failed runs

endpoint-list[].status.controllers[].status.last-failure-msg (string) – Error message of last failed run

endpoint-list[].status.controllers[].status.last-failure-timestamp (string) – Timestamp of last error

endpoint-list[].status.controllers[].status.last-success-timestamp (string) – Timestamp of last success

endpoint-list[].status.controllers[].status.success-count (integer) – Total number of successful runs

endpoint-list[].status.controllers[].uuid (string) – UUID of controller

endpoint-list[].status.external-identifiers.cni-attachment-id (string) – ID assigned to this attachment by container runtime

endpoint-list[].status.external-identifiers.container-id (string) – ID assigned by container runtime (deprecated, may not be unique)

endpoint-list[].status.external-identifiers.container-name (string) – Name assigned to container (deprecated, may not be unique)

endpoint-list[].status.external-identifiers.docker-endpoint-id (string) – Docker endpoint ID

endpoint-list[].status.external-identifiers.docker-network-id (string) – Docker network ID

endpoint-list[].status.external-identifiers.k8s-namespace (string) – K8s namespace for this endpoint (deprecated, may not be unique)

endpoint-list[].status.external-identifiers.k8s-pod-name (string) – K8s pod name for this endpoint (deprecated, may not be unique)

endpoint-list[].status.external-identifiers.pod-name (string) – K8s pod for this endpoint (deprecated, may not be unique)

endpoint-list[].status.health.bpf (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

endpoint-list[].status.health.connected (boolean) – Is this endpoint reachable

endpoint-list[].status.health.overallHealth (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

endpoint-list[].status.health.policy (string) – A common set of statuses for endpoint health * OK = All components operational * Bootstrap = This component is being created * Pending = A change is being processed to be applied * Warning = This component is not applying up-to-date policies (but is still applying the previous version) * Failure = An error has occurred and no policy is being applied * Disabled = This endpoint is disabled and will not handle traffic

endpoint-list[].status.identity.id (integer) – Unique identifier

endpoint-list[].status.identity.labelsSHA256 (string) – SHA256 of labels

endpoint-list[].status.identity.labels[] (string) –

endpoint-list[].status.labels.derived[] (string) –

endpoint-list[].status.labels.disabled[] (string) –

endpoint-list[].status.labels.realized.user[] (string) –

endpoint-list[].status.labels.security-relevant[] (string) –

endpoint-list[].status.log[].code (string) – Code indicate type of status change

endpoint-list[].status.log[].message (string) – Status message

endpoint-list[].status.log[].state (string) – State of endpoint

endpoint-list[].status.log[].timestamp (string) – Timestamp when status change occurred

endpoint-list[].status.namedPorts[].name (string) – Optional layer 4 port name

endpoint-list[].status.namedPorts[].port (integer) – Layer 4 port number

endpoint-list[].status.namedPorts[].protocol (string) – Layer 4 protocol

endpoint-list[].status.networking.addressing[].ipv4 (string) – IPv4 address

endpoint-list[].status.networking.addressing[].ipv4-expiration-uuid (string) – UUID of IPv4 expiration timer

endpoint-list[].status.networking.addressing[].ipv4-pool-name (string) – IPAM pool from which this IPv4 address was allocated

endpoint-list[].status.networking.addressing[].ipv6 (string) – IPv6 address

endpoint-list[].status.networking.addressing[].ipv6-expiration-uuid (string) – UUID of IPv6 expiration timer

endpoint-list[].status.networking.addressing[].ipv6-pool-name (string) – IPAM pool from which this IPv6 address was allocated

endpoint-list[].status.networking.container-interface-name (string) – Name of network device in container netns

endpoint-list[].status.networking.host-addressing.ipv4.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

endpoint-list[].status.networking.host-addressing.ipv4.alloc-range (string) – Address pool to be used for local endpoints

endpoint-list[].status.networking.host-addressing.ipv4.enabled (boolean) – True if address family is enabled

endpoint-list[].status.networking.host-addressing.ipv4.ip (string) – IP address of node

endpoint-list[].status.networking.host-addressing.ipv6.address-type (string) – Node address type, one of HostName, ExternalIP or InternalIP

endpoint-list[].status.networking.host-addressing.ipv6.alloc-range (string) – Address pool to be used for local endpoints

endpoint-list[].status.networking.host-addressing.ipv6.enabled (boolean) – True if address family is enabled

endpoint-list[].status.networking.host-addressing.ipv6.ip (string) – IP address of node

endpoint-list[].status.networking.host-mac (string) – MAC address

endpoint-list[].status.networking.interface-index (integer) – Index of network device in host netns

endpoint-list[].status.networking.interface-name (string) – Name of network device in host netns

endpoint-list[].status.networking.mac (string) – MAC address

endpoint-list[].status.policy.proxy-policy-revision (integer) – The policy revision currently enforced in the proxy for this endpoint

endpoint-list[].status.policy.proxy-statistics[].allocated-proxy-port (integer) – The port the proxy is listening on

endpoint-list[].status.policy.proxy-statistics[].location (string) – Location of where the redirect is installed

endpoint-list[].status.policy.proxy-statistics[].port (integer) – The port subject to the redirect

endpoint-list[].status.policy.proxy-statistics[].protocol (string) – Name of the L7 protocol

endpoint-list[].status.policy.proxy-statistics[].statistics.requests.denied (integer) – Number of messages denied

endpoint-list[].status.policy.proxy-statistics[].statistics.requests.error (integer) – Number of errors while parsing messages

endpoint-list[].status.policy.proxy-statistics[].statistics.requests.forwarded (integer) – Number of messages forwarded

endpoint-list[].status.policy.proxy-statistics[].statistics.requests.received (integer) – Number of messages received

endpoint-list[].status.policy.proxy-statistics[].statistics.responses.denied (integer) – Number of messages denied

endpoint-list[].status.policy.proxy-statistics[].statistics.responses.error (integer) – Number of errors while parsing messages

endpoint-list[].status.policy.proxy-statistics[].statistics.responses.forwarded (integer) – Number of messages forwarded

endpoint-list[].status.policy.proxy-statistics[].statistics.responses.received (integer) – Number of messages received

endpoint-list[].status.policy.realized.allowed-egress-identities[] (integer) –

endpoint-list[].status.policy.realized.allowed-ingress-identities[] (integer) –

endpoint-list[].status.policy.realized.build (integer) – Build number of calculated policy in use

endpoint-list[].status.policy.realized.cidr-policy.egress[] (any) – A policy rule including the rule labels it derives from

endpoint-list[].status.policy.realized.cidr-policy.ingress[] (any) – A policy rule including the rule labels it derives from

endpoint-list[].status.policy.realized.denied-egress-identities[] (integer) –

endpoint-list[].status.policy.realized.denied-ingress-identities[] (integer) –

endpoint-list[].status.policy.realized.id (integer) – Own identity of endpoint

endpoint-list[].status.policy.realized.l4.egress[] (any) – A policy rule including the rule labels it derives from

endpoint-list[].status.policy.realized.l4.ingress[] (any) – A policy rule including the rule labels it derives from

endpoint-list[].status.policy.realized.policy-enabled (string) – Whether policy enforcement is enabled (ingress, egress, both or none)

endpoint-list[].status.policy.realized.policy-revision (integer) – The agent-local policy revision

endpoint-list[].status.policy.spec.allowed-egress-identities[] (integer) –

endpoint-list[].status.policy.spec.allowed-ingress-identities[] (integer) –

endpoint-list[].status.policy.spec.build (integer) – Build number of calculated policy in use

endpoint-list[].status.policy.spec.cidr-policy.egress[] (any) – A policy rule including the rule labels it derives from

endpoint-list[].status.policy.spec.cidr-policy.ingress[] (any) – A policy rule including the rule labels it derives from

endpoint-list[].status.policy.spec.denied-egress-identities[] (integer) –

endpoint-list[].status.policy.spec.denied-ingress-identities[] (integer) –

endpoint-list[].status.policy.spec.id (integer) – Own identity of endpoint

endpoint-list[].status.policy.spec.l4.egress[] (any) – A policy rule including the rule labels it derives from

endpoint-list[].status.policy.spec.l4.ingress[] (any) – A policy rule including the rule labels it derives from

endpoint-list[].status.policy.spec.policy-enabled (string) – Whether policy enforcement is enabled (ingress, egress, both or none)

endpoint-list[].status.policy.spec.policy-revision (integer) – The agent-local policy revision

endpoint-list[].status.realized.label-configuration.user[] (string) –

endpoint-list[].status.realized.options (object) – Map of configuration key/value pairs.

endpoint-list[].status.state (string) – State of endpoint (required)

environment-variables[] (string) –

kernel-version (string) –

policy.policy (string) – Policy definition as JSON.

policy.revision (integer) – Revision number of the policy. Incremented each time the policy is changed in the agent’s repository

service-list[].spec.backend-addresses[].ip (string) – Layer 3 address (required)

service-list[].spec.backend-addresses[].nodeName (string) – Optional name of the node on which this backend runs

service-list[].spec.backend-addresses[].port (integer) – Layer 4 port number

service-list[].spec.backend-addresses[].preferred (boolean) – Indicator if this backend is preferred in the context of clustermesh service affinity. The value is set based on related annotation of global service. Applicable for active state only.

service-list[].spec.backend-addresses[].protocol (string) – Layer 4 protocol (TCP, UDP, etc)

service-list[].spec.backend-addresses[].state (string) – State of the backend for load-balancing service traffic

service-list[].spec.backend-addresses[].weight (integer) – Backend weight

service-list[].spec.backend-addresses[].zone (string) – Optional name of the zone in which this backend runs

service-list[].spec.flags.cluster (string) – Service cluster

service-list[].spec.flags.extTrafficPolicy (string) – Service external traffic policy

service-list[].spec.flags.healthCheckNodePort (integer) – Service health check node port

service-list[].spec.flags.intTrafficPolicy (string) – Service internal traffic policy

service-list[].spec.flags.name (string) – Service name (e.g. Kubernetes service name)

service-list[].spec.flags.namespace (string) – Service namespace (e.g. Kubernetes namespace)

service-list[].spec.flags.natPolicy (string) – Service protocol NAT policy

service-list[].spec.flags.trafficPolicy (string) – Service external traffic policy (deprecated in favor of extTrafficPolicy)

service-list[].spec.flags.type (string) – Service type

service-list[].spec.frontend-address.ip (string) – Layer 3 address

service-list[].spec.frontend-address.port (integer) – Layer 4 port number

service-list[].spec.frontend-address.protocol (string) – Layer 4 protocol

service-list[].spec.frontend-address.scope (string) – Load balancing scope for frontend address

service-list[].spec.id (integer) – Unique identification

service-list[].spec.updateServices (boolean) – Update all services selecting the backends with their given states (id and frontend are ignored)

service-list[].status.realized.backend-addresses[].ip (string) – Layer 3 address (required)

service-list[].status.realized.backend-addresses[].nodeName (string) – Optional name of the node on which this backend runs

service-list[].status.realized.backend-addresses[].port (integer) – Layer 4 port number

service-list[].status.realized.backend-addresses[].preferred (boolean) – Indicator if this backend is preferred in the context of clustermesh service affinity. The value is set based on related annotation of global service. Applicable for active state only.

service-list[].status.realized.backend-addresses[].protocol (string) – Layer 4 protocol (TCP, UDP, etc)

service-list[].status.realized.backend-addresses[].state (string) – State of the backend for load-balancing service traffic

service-list[].status.realized.backend-addresses[].weight (integer) – Backend weight

service-list[].status.realized.backend-addresses[].zone (string) – Optional name of the zone in which this backend runs

service-list[].status.realized.flags.cluster (string) – Service cluster

service-list[].status.realized.flags.extTrafficPolicy (string) – Service external traffic policy

service-list[].status.realized.flags.healthCheckNodePort (integer) – Service health check node port

service-list[].status.realized.flags.intTrafficPolicy (string) – Service internal traffic policy

service-list[].status.realized.flags.name (string) – Service name (e.g. Kubernetes service name)

service-list[].status.realized.flags.namespace (string) – Service namespace (e.g. Kubernetes namespace)

service-list[].status.realized.flags.natPolicy (string) – Service protocol NAT policy

service-list[].status.realized.flags.trafficPolicy (string) – Service external traffic policy (deprecated in favor of extTrafficPolicy)

service-list[].status.realized.flags.type (string) – Service type

service-list[].status.realized.frontend-address.ip (string) – Layer 3 address

service-list[].status.realized.frontend-address.port (integer) – Layer 4 port number

service-list[].status.realized.frontend-address.protocol (string) – Layer 4 protocol

service-list[].status.realized.frontend-address.scope (string) – Load balancing scope for frontend address

service-list[].status.realized.id (integer) – Unique identification

service-list[].status.realized.updateServices (boolean) – Update all services selecting the backends with their given states (id and frontend are ignored)

Retrieve cgroup metadata for all pods

500 Internal Server Error – CgroupDumpMetadata get failed

pod-metadatas[].containers[].cgroup-id (integer) –

pod-metadatas[].containers[].cgroup-path (string) –

pod-metadatas[].ips[] (string) –

pod-metadatas[].name (string) –

pod-metadatas[].namespace (string) –

maps[].cache[].desired-action (string) – Desired action to be performed

maps[].cache[].key (string) – Key of map entry

maps[].cache[].last-error (string) – Last error seen while performing desired action

maps[].cache[].value (string) – Value of map entry

maps[].path (string) – Path to BPF map

Retrieve contents of BPF map

name (string) – Name of map

404 Not Found – Map not found

cache[].desired-action (string) – Desired action to be performed

cache[].key (string) – Key of map entry

cache[].last-error (string) – Last error seen while performing desired action

cache[].value (string) – Value of map entry

path (string) – Path to BPF map

Retrieves the recent event logs associated with this endpoint.

name (string) – Name of map

follow (boolean) – Whether to follow streamed requests

404 Not Found – Map not found

Retrieves the list of DNS lookups intercepted from all endpoints.

Retrieves the list of DNS lookups intercepted from endpoints, optionally filtered by DNS name, CIDR IP range or source.

matchpattern (string) – A toFQDNs compatible matchPattern expression

cidr (string) – A CIDR range of IPs

source (string) – Source from which FQDN entries come from

400 Bad Request – Invalid request (error parsing parameters)

404 Not Found – No DNS data with provided parameters found

[].endpoint-id (integer) – The endpoint that made this lookup, or 0 for the agent itself.

[].expiration-time (string) – The absolute time when this data will expire in this cache

[].fqdn (string) – DNS name

[].lookup-time (string) – The absolute time when this data was received

[].source (string) – The reason this FQDN IP association exists. Either a DNS lookup or an ongoing connection to an IP that was created by a DNS lookup.

[].ttl (integer) – The TTL in the DNS response

Deletes matching DNS lookups from the policy-generation cache.

Deletes matching DNS lookups from the cache, optionally restricted by DNS name. The removed IP data will no longer be used in generated policies.

matchpattern (string) – A toFQDNs compatible matchPattern expression

400 Bad Request – Invalid request (error parsing parameters)

403 Forbidden – Forbidden

Retrieves the list of DNS lookups intercepted from an endpoint.

Retrieves the list of DNS lookups intercepted from the specific endpoint, optionally filtered by endpoint id, DNS name, CIDR IP range or source.

id (string) – String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints. Supported endpoint id prefixes: cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595 cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343 cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0 container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique) container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique) pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique) cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1 docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

String describing an endpoint with the format [prefix:]id. If no prefix is specified, a prefix of cilium-local: is assumed. Not all endpoints will be addressable by all endpoint ID prefixes with the exception of the local Cilium UUID which is assigned to all endpoints.

cilium-local: Local Cilium endpoint UUID, e.g. cilium-local:3389595

cilium-global: Global Cilium endpoint UUID, e.g. cilium-global:cluster1:nodeX:452343

cni-attachment-id: CNI attachment ID, e.g. cni-attachment-id:22222:eth0

container-id: Container runtime ID, e.g. container-id:22222 (deprecated, may not be unique)

container-name: Container name, e.g. container-name:foobar (deprecated, may not be unique)

pod-name: pod name for this container if K8s is enabled, e.g. pod-name:default:foobar (deprecated, may not be unique)

cep-name: cep name for this container if K8s is enabled, e.g. pod-name:default:foobar-net1

docker-endpoint: Docker libnetwork endpoint ID, e.g. docker-endpoint:4444

matchpattern (string) – A toFQDNs compatible matchPattern expression

cidr (string) – A CIDR range of IPs

source (string) – Source from which FQDN entries come from

400 Bad Request – Invalid request (error parsing parameters)

404 Not Found – No DNS data with provided parameters found

[].endpoint-id (integer) – The endpoint that made this lookup, or 0 for the agent itself.

[].expiration-time (string) – The absolute time when this data will expire in this cache

[].fqdn (string) – DNS name

[].lookup-time (string) – The absolute time when this data was received

[].source (string) – The reason this FQDN IP association exists. Either a DNS lookup or an ongoing connection to an IP that was created by a DNS lookup.

[].ttl (integer) – The TTL in the DNS response

List internal DNS selector representations

Retrieves the list of DNS-related fields (names to poll, selectors and their corresponding regexes).

400 Bad Request – Invalid request (error parsing parameters)

DNSPollNames[] (string) –

FQDNPolicySelectors[].regexString (string) – String representation of regular expression form of FQDNSelector

FQDNPolicySelectors[].selectorString (string) – FQDNSelector in string representation

Lists information about known IP addresses

Retrieves a list of IPs with known associated information such as their identities, host addresses, Kubernetes pod names, etc. The list can optionally filtered by a CIDR IP range.

cidr (string) – A CIDR range of IPs

400 Bad Request – Invalid request (error parsing parameters)

404 Not Found – No IP cache entries with provided parameters found

[].cidr (string) – Key of the entry in the form of a CIDR range (required)

[].encryptKey (integer) – The context ID for the encryption session

[].hostIP (string) – IP address of the host

[].identity (integer) – Numerical identity assigned to the IP (required)

[].metadata.name (string) – Name assigned to the IP (e.g. Kubernetes pod name)

[].metadata.namespace (string) – Namespace of the IP (e.g. Kubernetes namespace)

[].metadata.source (string) – Source of the IP entry and its metadata

List information about known node IDs

Retrieves a list of node IDs allocated by the agent and their associated node IP addresses.

[].id (integer) – ID allocated by the agent for the node (required)

Lists operational state of BGP peers

Retrieves current operational state of BGP peers created by Cilium BGP virtual router. This includes session state, uptime, information per address family, etc.

500 Internal Server Error – Internal Server Error

501 Not Implemented – BGP Control Plane disabled

[] (any) – State of a BGP Peer +k8s:deepcopy-gen=true

Lists BGP routes from BGP Control Plane RIB.

Retrieves routes from BGP Control Plane RIB filtered by parameters you specify

table_type (string) – BGP Routing Information Base (RIB) table type

afi (string) – Address Family Indicator (AFI) of a BGP route

safi (string) – Subsequent Address Family Indicator (SAFI) of a BGP route

router_asn (integer) – Autonomous System Number (ASN) identifying a BGP virtual router instance. If not specified, all virtual router instances are selected.

neighbor (string) – IP address specifying a BGP neighbor. Has to be specified only when table type is adj-rib-in or adj-rib-out.

500 Internal Server Error – Internal Server Error

501 Not Implemented – BGP Control Plane disabled

[] (any) – Single BGP route retrieved from the RIB of underlying router

Lists BGP route policies configured in BGP Control Plane.

Retrieves route policies from BGP Control Plane.

router_asn (integer) – Autonomous System Number (ASN) identifying a BGP virtual router instance. If not specified, all virtual router instances are selected.

500 Internal Server Error – Internal Server Error

501 Not Implemented – BGP Control Plane disabled

[] (any) – Single BGP route policy retrieved from the underlying router

---

## Helm Reference — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/helm-reference/

**Contents:**
- Helm Reference

The table below serves as a reference for the values that can be set on Cilium’s Helm chart.

Configure the underlying network MTU to overwrite auto-detected MTU. This value doesn’t change the host network interface MTU i.e. eth0 or ens0. It changes the MTU for cilium_net@cilium_host, cilium_host@cilium_net, cilium_vxlan and lxc_health interfaces.

Affinity for cilium-agent.

{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"k8s-app":"cilium"}},"topologyKey":"kubernetes.io/hostname"}]}}

Install the cilium agent resources.

agentNotReadyTaintKey

Configure the key of the taint indicating that Cilium is not ready on the node. When set to a value starting with ignore-taint.cluster-autoscaler.kubernetes.io/, the Cluster Autoscaler will ignore the taint on its decisions, allowing the cluster to scale up.

"node.cilium.io/agent-not-ready"

Enable AKS BYOCNI integration. Note that this is incompatible with AKS clusters not created in BYOCNI mode: use Azure integration (azure.enabled) instead.

Enable AlibabaCloud ENI integration

Annotate k8s node upon initialization with Cilium’s metadata.

Annotations to be added to all top-level cilium-agent objects (resources under templates/cilium-agent)

The api-rate-limit option can be used to overwrite individual settings of the default configuration for rate limiting calls to the Cilium Agent API

authentication.enabled

Enable authentication processing and garbage collection. Note that if disabled, policy enforcement will still block requests that require authentication. But the resulting authentication requests for these requests will not be processed, therefore the requests not be allowed.

authentication.gcInterval

Interval for garbage collection of auth map entries.

authentication.mutual.connectTimeout

Timeout for connecting to the remote node TCP socket

authentication.mutual.port

Port on the agent where mutual authentication handshakes between agents will be performed

authentication.mutual.spire.adminSocketPath

SPIRE socket path where the SPIRE delegated api agent is listening

"/run/spire/sockets/admin.sock"

authentication.mutual.spire.agentSocketPath

SPIRE socket path where the SPIRE workload agent is listening. Applies to both the Cilium Agent and Operator

"/run/spire/sockets/agent/agent.sock"

authentication.mutual.spire.annotations

Annotations to be added to all top-level spire objects (resources under templates/spire)

authentication.mutual.spire.connectionTimeout

SPIRE connection timeout

authentication.mutual.spire.enabled

Enable SPIRE integration (beta)

authentication.mutual.spire.install.agent.affinity

SPIRE agent affinity configuration

authentication.mutual.spire.install.agent.annotations

SPIRE agent annotations

authentication.mutual.spire.install.agent.image

{"digest":"sha256:163970884fba18860cac93655dc32b6af85a5dcf2ebb7e3e119a10888eff8fcd","override":null,"pullPolicy":"IfNotPresent","repository":"ghcr.io/spiffe/spire-agent","tag":"1.12.4","useDigest":true}

authentication.mutual.spire.install.agent.labels

authentication.mutual.spire.install.agent.nodeSelector

SPIRE agent nodeSelector configuration ref: ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

authentication.mutual.spire.install.agent.podSecurityContext

Security context to be added to spire agent pods. SecurityContext holds pod-level security attributes and common container settings. ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod

authentication.mutual.spire.install.agent.priorityClassName

The priority class to use for the spire agent

authentication.mutual.spire.install.agent.resources

container resource limits & requests

authentication.mutual.spire.install.agent.securityContext

Security context to be added to spire agent containers. SecurityContext holds pod-level security attributes and common container settings. ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container

authentication.mutual.spire.install.agent.serviceAccount

SPIRE agent service account

{"create":true,"name":"spire-agent"}

authentication.mutual.spire.install.agent.skipKubeletVerification

SPIRE Workload Attestor kubelet verification.

authentication.mutual.spire.install.agent.tolerations

SPIRE agent tolerations configuration By default it follows the same tolerations as the agent itself to allow the Cilium agent on this node to connect to SPIRE. ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

[{"effect":"NoSchedule","key":"node.kubernetes.io/not-ready"},{"effect":"NoSchedule","key":"node-role.kubernetes.io/master"},{"effect":"NoSchedule","key":"node-role.kubernetes.io/control-plane"},{"effect":"NoSchedule","key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true"},{"key":"CriticalAddonsOnly","operator":"Exists"}]

authentication.mutual.spire.install.enabled

Enable SPIRE installation. This will only take effect only if authentication.mutual.spire.enabled is true

authentication.mutual.spire.install.existingNamespace

SPIRE namespace already exists. Set to true if Helm should not create, manage, and import the SPIRE namespace.

authentication.mutual.spire.install.initImage

init container image of SPIRE agent and server

{"digest":"sha256:d80cd694d3e9467884fcb94b8ca1e20437d8a501096cdf367a5a1918a34fc2fd","override":null,"pullPolicy":"IfNotPresent","repository":"docker.io/library/busybox","tag":"1.37.0","useDigest":true}

authentication.mutual.spire.install.namespace

SPIRE namespace to install into

authentication.mutual.spire.install.server.affinity

SPIRE server affinity configuration

authentication.mutual.spire.install.server.annotations

SPIRE server annotations

authentication.mutual.spire.install.server.ca.keyType

SPIRE CA key type AWS requires the use of RSA. EC cryptography is not supported

authentication.mutual.spire.install.server.ca.subject

{"commonName":"Cilium SPIRE CA","country":"US","organization":"SPIRE"}

authentication.mutual.spire.install.server.dataStorage.accessMode

Access mode of the SPIRE server data storage

authentication.mutual.spire.install.server.dataStorage.enabled

Enable SPIRE server data storage

authentication.mutual.spire.install.server.dataStorage.size

Size of the SPIRE server data storage

authentication.mutual.spire.install.server.dataStorage.storageClass

StorageClass of the SPIRE server data storage

authentication.mutual.spire.install.server.image

{"digest":"sha256:34147f27066ab2be5cc10ca1d4bfd361144196467155d46c45f3519f41596e49","override":null,"pullPolicy":"IfNotPresent","repository":"ghcr.io/spiffe/spire-server","tag":"1.12.4","useDigest":true}

authentication.mutual.spire.install.server.initContainers

SPIRE server init containers

authentication.mutual.spire.install.server.labels

authentication.mutual.spire.install.server.nodeSelector

SPIRE server nodeSelector configuration ref: ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

authentication.mutual.spire.install.server.podSecurityContext

Security context to be added to spire server pods. SecurityContext holds pod-level security attributes and common container settings. ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod

authentication.mutual.spire.install.server.priorityClassName

The priority class to use for the spire server

authentication.mutual.spire.install.server.resources

container resource limits & requests

authentication.mutual.spire.install.server.securityContext

Security context to be added to spire server containers. SecurityContext holds pod-level security attributes and common container settings. ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container

authentication.mutual.spire.install.server.service.annotations

Annotations to be added to the SPIRE server service

authentication.mutual.spire.install.server.service.labels

Labels to be added to the SPIRE server service

authentication.mutual.spire.install.server.service.type

Service type for the SPIRE server service

authentication.mutual.spire.install.server.serviceAccount

SPIRE server service account

{"create":true,"name":"spire-server"}

authentication.mutual.spire.install.server.tolerations

SPIRE server tolerations configuration ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

authentication.mutual.spire.serverAddress

SPIRE server address used by Cilium Operator If k8s Service DNS along with port number is used (e.g. ..svc(.*): format), Cilium Operator will resolve its address by looking up the clusterIP from Service resource. Example values: 10.0.0.1:8081, spire-server.cilium-spire.svc:8081

authentication.mutual.spire.trustDomain

SPIFFE trust domain to use for fetching certificates

authentication.queueSize

Buffer size of the channel Cilium uses to receive authentication events from the signal map.

authentication.rotatedIdentitiesQueueSize

Buffer size of the channel Cilium uses to receive certificate expiration events from auth handlers.

Enable installation of PodCIDR routes between worker nodes if worker nodes share a common L2 network segment.

Enable Azure integration. Note that this is incompatible with AKS clusters created in BYOCNI mode: use AKS BYOCNI integration (aksbyocni.enabled) instead.

Enable bandwidth manager to optimize TCP and UDP workloads and allow for rate-limiting traffic from individual Pods with EDT (Earliest Departure Time) through the “kubernetes.io/egress-bandwidth” Pod annotation.

{"bbr":false,"bbrHostNamespaceOnly":false,"enabled":false}

Activate BBR TCP congestion control for Pods

bandwidthManager.bbrHostNamespaceOnly

Activate BBR TCP congestion control for Pods in the host namespace only.

bandwidthManager.enabled

Enable bandwidth manager infrastructure (also prerequirement for BBR)

This feature set enables virtual BGP routers to be created via CiliumBGPPeeringPolicy CRDs.

{"enabled":false,"legacyOriginAttribute":{"enabled":false},"routerIDAllocation":{"ipPool":"","mode":"default"},"secretsNamespace":{"create":false,"name":"kube-system"},"statusReport":{"enabled":true}}

bgpControlPlane.enabled

Enables the BGP control plane.

bgpControlPlane.legacyOriginAttribute

Legacy BGP ORIGIN attribute settings (BGPv2 only)

bgpControlPlane.legacyOriginAttribute.enabled

Enable/Disable advertising LoadBalancerIP routes with the legacy BGP ORIGIN attribute value INCOMPLETE (2) instead of the default IGP (0). Enable for compatibility with the legacy behavior of MetalLB integration.

bgpControlPlane.routerIDAllocation

BGP router-id allocation mode

{"ipPool":"","mode":"default"}

bgpControlPlane.routerIDAllocation.ipPool

IP pool to allocate the BGP router-id from when the mode is ip-pool.

bgpControlPlane.routerIDAllocation.mode

BGP router-id allocation mode. In default mode, the router-id is derived from the IPv4 address if it is available, or else it is determined by the lower 32 bits of the MAC address.

bgpControlPlane.secretsNamespace

SecretsNamespace is the namespace which BGP support will retrieve secrets from.

{"create":false,"name":"kube-system"}

bgpControlPlane.secretsNamespace.create

Create secrets namespace for BGP secrets.

bgpControlPlane.secretsNamespace.name

The name of the secret namespace to which Cilium agents are given read access

bgpControlPlane.statusReport

Status reporting settings (BGPv2 only)

bgpControlPlane.statusReport.enabled

Enable/Disable BGPv2 status reporting It is recommended to enable status reporting in general, but if you have any issue such as high API server load, you can disable it by setting this to false.

Configure the maximum number of entries in auth map.

bpf.autoMount.enabled

Enable automatic mount of BPF filesystem When autoMount is enabled, the BPF filesystem is mounted at bpf.root path on the underlying host and inside the cilium agent pod. If users disable autoMount, it’s expected that users have mounted bpffs filesystem at the specified bpf.root volume, and then the volume will be mounted inside the cilium agent pod at the same path.

Enable CT accounting for packets and bytes

Configure the maximum number of entries for the non-TCP connection tracking table.

Configure the maximum number of entries in the TCP connection tracking table.

Mode for Pod devices for the core datapath (veth, netkit, netkit-l2)

bpf.disableExternalIPMitigation

Disable ExternalIP mitigation (CVE-2020-8554)

Control to use a distributed per-CPU backend memory for the core BPF LRU maps which Cilium uses. This improves performance significantly, but it is also recommended to increase BPF map sizing along with that.

bpf.distributedLRU.enabled

Enable distributed LRU backend memory. For compatibility with existing installations it is off by default.

Attach endpoint programs using tcx instead of legacy tc hooks on supported kernels.

Control events generated by the Cilium datapath exposed to Cilium monitor and Hubble. Helm configuration for BPF events map rate limiting is experimental and might change in upcoming releases.

{"default":{"burstLimit":null,"rateLimit":null},"drop":{"enabled":true},"policyVerdict":{"enabled":true},"trace":{"enabled":true}}

Default settings for all types of events except dbg and pcap.

{"burstLimit":null,"rateLimit":null}

bpf.events.default.burstLimit

Configure the maximum number of messages that can be written to BPF events map in 1 second. If burstLimit is greater than 0, non-zero value for rateLimit must also be provided lest the configuration is considered invalid. Setting both burstLimit and rateLimit to 0 disables BPF events rate limiting.

bpf.events.default.rateLimit

Configure the limit of messages per second that can be written to BPF events map. The number of messages is averaged, meaning that if no messages were written to the map over 5 seconds, it’s possible to write more events in the 6th second. If rateLimit is greater than 0, non-zero value for burstLimit must also be provided lest the configuration is considered invalid. Setting both burstLimit and rateLimit to 0 disables BPF events rate limiting.

bpf.events.drop.enabled

bpf.events.policyVerdict.enabled

Enable policy verdict events.

bpf.events.trace.enabled

bpf.hostLegacyRouting

Configure whether direct routing mode should route traffic via host stack (true) or directly and more efficiently out of BPF (false) if the kernel supports it. The latter has the implication that it will also bypass netfilter in the host namespace.

bpf.lbAlgorithmAnnotation

Enable the option to define the load balancing algorithm on a per-service basis through service.cilium.io/lb-algorithm annotation.

bpf.lbExternalClusterIP

Allow cluster external access to ClusterIP services.

Configure the maximum number of service entries in the load balancer maps.

Enable the option to define the load balancing mode (SNAT or DSR) on a per-service basis through service.cilium.io/forwarding-mode annotation.

bpf.lbSourceRangeAllTypes

Enable loadBalancerSourceRanges CIDR filtering for all service types, not just LoadBalancer services. The corresponding NodePort and ClusterIP (if enabled for cluster-external traffic) will also apply the CIDR filter.

bpf.mapDynamicSizeRatio

Configure auto-sizing for all BPF maps based on available memory. ref: https://docs.cilium.io/en/stable/network/ebpf/maps/

Enable native IP masquerade support in eBPF

bpf.monitorAggregation

Configure the level of aggregation for monitor notifications. Valid options are none, low, medium, maximum.

Configure which TCP flags trigger notifications when seen for the first time in a connection.

Configure the typical time between monitor notifications for active connections.

Configure the maximum number of entries for the NAT table.

Configure the maximum number of entries for the neighbor table.

Configures the maximum number of entries for the node table.

Configure the maximum number of entries in endpoint policy map (per endpoint). @schema type: [null, integer] @schema

bpf.policyStatsMapMax

Configure the maximum number of entries in global policy stats map. @schema type: [null, integer] @schema

Enables pre-allocation of eBPF map values. This increases memory usage but can reduce latency.

Configure the mount point for the BPF filesystem

Configure the eBPF-based TPROXY (beta) to reduce reliance on iptables rules for implementing Layer 7 policy.

Configure explicitly allowed VLAN id’s for bpf logic bypass. [0] will allow all VLAN id’s without any filtering.

Enable BPF clock source probing for more efficient tick retrieval.

Configure certificate generation for Hubble integration. If hubble.tls.auto.method=cronJob, these values are used for the Kubernetes CronJob which will be scheduled regularly to (re)generate any certificates not provided manually.

{"affinity":{},"annotations":{"cronJob":{},"job":{}},"extraVolumeMounts":[],"extraVolumes":[],"generateCA":true,"image":{"digest":"sha256:2825dbfa6f89cbed882fd1d81e46a56c087e35885825139923aa29eb8aec47a9","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/certgen","tag":"v0.3.1","useDigest":true},"nodeSelector":{},"podLabels":{},"priorityClassName":"","resources":{},"tolerations":[],"ttlSecondsAfterFinished":1800}

Annotations to be added to the hubble-certgen initial Job and CronJob

{"cronJob":{},"job":{}}

certgen.extraVolumeMounts

Additional certgen volumeMounts.

Additional certgen volumes.

When set to true the certificate authority secret is created.

Node selector for certgen ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

Labels to be added to hubble-certgen pods

certgen.priorityClassName

Priority class for certgen ref: https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass

Resource limits for certgen ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers

Node tolerations for pod assignment on nodes with taints ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

certgen.ttlSecondsAfterFinished

Seconds after which the completed job pod will be deleted

Configure cgroup related configuration

{"autoMount":{"enabled":true,"resources":{}},"hostRoot":"/run/cilium/cgroupv2"}

cgroup.autoMount.enabled

Enable auto mount of cgroup2 filesystem. When autoMount is enabled, cgroup2 filesystem is mounted at cgroup.hostRoot path on the underlying host and inside the cilium agent pod. If users disable autoMount, it’s expected that users have mounted cgroup2 filesystem at the specified cgroup.hostRoot volume, and then the volume will be mounted inside the cilium agent pod at the same path.

cgroup.autoMount.resources

Init Container Cgroup Automount resource limits & requests

Configure cgroup root where cgroup2 filesystem is mounted on the host (see also: cgroup.autoMount)

"/run/cilium/cgroupv2"

CiliumEndpointSlice configuration options.

{"enabled":false,"rateLimits":[{"burst":20,"limit":10,"nodes":0},{"burst":100,"limit":50,"nodes":100}]}

ciliumEndpointSlice.enabled

Enable Cilium EndpointSlice feature.

ciliumEndpointSlice.rateLimits

List of rate limit options to be used for the CiliumEndpointSlice controller. Each object in the list must have the following fields: nodes: Count of nodes at which to apply the rate limit. limit: The sustained request rate in requests per second. The maximum rate that can be configured is 50. burst: The burst request rate in requests per second. The maximum burst that can be configured is 100.

[{"burst":20,"limit":10,"nodes":0},{"burst":100,"limit":50,"nodes":100}]

Clean all eBPF datapath state from the initContainer of the cilium-agent DaemonSet. WARNING: Use with care!

Clean all local Cilium state from the initContainer of the cilium-agent DaemonSet. Implies cleanBpfState: true. WARNING: Use with care!

Unique ID of the cluster. Must be unique across all connected clusters and in the range of 1 to 255. Only required for Cluster Mesh, may be 0 if Cluster Mesh is not used.

Name of the cluster. Only required for Cluster Mesh and mutual authentication with SPIRE. It must respect the following constraints: * It must contain at most 32 characters; * It must begin and end with a lower case alphanumeric character; * It may contain lower case alphanumeric characters and dashes between. The “default” name cannot be used if the Cluster ID is different from 0.

clustermesh.annotations

Annotations to be added to all top-level clustermesh objects (resources under templates/clustermesh-apiserver and templates/clustermesh-config)

clustermesh.apiserver.affinity

Affinity for clustermesh.apiserver

{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchLabels":{"k8s-app":"clustermesh-apiserver"}},"topologyKey":"kubernetes.io/hostname"},"weight":100}]}}

clustermesh.apiserver.etcd.init.extraArgs

Additional arguments to clustermesh-apiserver etcdinit.

clustermesh.apiserver.etcd.init.extraEnv

Additional environment variables to clustermesh-apiserver etcdinit.

clustermesh.apiserver.etcd.init.resources

Specifies the resources for etcd init container in the apiserver

clustermesh.apiserver.etcd.lifecycle

lifecycle setting for the etcd container

clustermesh.apiserver.etcd.resources

Specifies the resources for etcd container in the apiserver

clustermesh.apiserver.etcd.securityContext

Security context to be added to clustermesh-apiserver etcd containers

{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}

clustermesh.apiserver.etcd.storageMedium

Specifies whether etcd data is stored in a temporary volume backed by the node’s default medium, such as disk, SSD or network storage (Disk), or RAM (Memory). The Memory option enables improved etcd read and write performance at the cost of additional memory usage, which counts against the memory limits of the container.

clustermesh.apiserver.extraArgs

Additional clustermesh-apiserver arguments.

clustermesh.apiserver.extraEnv

Additional clustermesh-apiserver environment variables.

clustermesh.apiserver.extraVolumeMounts

Additional clustermesh-apiserver volumeMounts.

clustermesh.apiserver.extraVolumes

Additional clustermesh-apiserver volumes.

clustermesh.apiserver.healthPort

TCP port for the clustermesh-apiserver health API.

clustermesh.apiserver.image

Clustermesh API server image.

{"digest":"","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/clustermesh-apiserver","tag":"v1.18.5","useDigest":false}

clustermesh.apiserver.kvstoremesh.enabled

Enable KVStoreMesh. KVStoreMesh caches the information retrieved from the remote clusters in the local etcd instance (deprecated - KVStoreMesh will always be enabled once the option is removed).

clustermesh.apiserver.kvstoremesh.extraArgs

Additional KVStoreMesh arguments.

clustermesh.apiserver.kvstoremesh.extraEnv

Additional KVStoreMesh environment variables.

clustermesh.apiserver.kvstoremesh.extraVolumeMounts

Additional KVStoreMesh volumeMounts.

clustermesh.apiserver.kvstoremesh.healthPort

TCP port for the KVStoreMesh health API.

clustermesh.apiserver.kvstoremesh.kvstoreMode

Specify the KVStore mode when running KVStoreMesh Supported values: - “internal”: remote cluster identities are cached in etcd that runs as a sidecar within clustermesh-apiserver pod. - “external”: clustermesh-apiserver will sync remote cluster information to the etcd used as kvstore. This can’t be enabled with crd identity allocation mode.

clustermesh.apiserver.kvstoremesh.lifecycle

lifecycle setting for the KVStoreMesh container

clustermesh.apiserver.kvstoremesh.readinessProbe

Configuration for the KVStoreMesh readiness probe.

clustermesh.apiserver.kvstoremesh.resources

Resource requests and limits for the KVStoreMesh container

clustermesh.apiserver.kvstoremesh.securityContext

KVStoreMesh Security context

{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}

clustermesh.apiserver.lifecycle

lifecycle setting for the apiserver container

clustermesh.apiserver.metrics.enabled

Enables exporting apiserver metrics in OpenMetrics format.

clustermesh.apiserver.metrics.etcd.enabled

Enables exporting etcd metrics in OpenMetrics format.

clustermesh.apiserver.metrics.etcd.mode

Set level of detail for etcd metrics; specify ‘extensive’ to include server side gRPC histogram metrics.

clustermesh.apiserver.metrics.etcd.port

Configure the port the etcd metric server listens on.

clustermesh.apiserver.metrics.kvstoremesh.enabled

Enables exporting KVStoreMesh metrics in OpenMetrics format.

clustermesh.apiserver.metrics.kvstoremesh.port

Configure the port the KVStoreMesh metric server listens on.

clustermesh.apiserver.metrics.port

Configure the port the apiserver metric server listens on.

clustermesh.apiserver.metrics.serviceMonitor.annotations

Annotations to add to ServiceMonitor clustermesh-apiserver

clustermesh.apiserver.metrics.serviceMonitor.enabled

Enable service monitor. This requires the prometheus CRDs to be available (see https://github.com/prometheus-operator/prometheus-operator/blob/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml)

clustermesh.apiserver.metrics.serviceMonitor.etcd.interval

Interval for scrape metrics (etcd metrics)

clustermesh.apiserver.metrics.serviceMonitor.etcd.metricRelabelings

Metrics relabeling configs for the ServiceMonitor clustermesh-apiserver (etcd metrics)

clustermesh.apiserver.metrics.serviceMonitor.etcd.relabelings

Relabeling configs for the ServiceMonitor clustermesh-apiserver (etcd metrics)

clustermesh.apiserver.metrics.serviceMonitor.etcd.scrapeTimeout

Timeout after which scrape is considered to be failed.

clustermesh.apiserver.metrics.serviceMonitor.interval

Interval for scrape metrics (apiserver metrics)

clustermesh.apiserver.metrics.serviceMonitor.kvstoremesh.interval

Interval for scrape metrics (KVStoreMesh metrics)

clustermesh.apiserver.metrics.serviceMonitor.kvstoremesh.metricRelabelings

Metrics relabeling configs for the ServiceMonitor clustermesh-apiserver (KVStoreMesh metrics)

clustermesh.apiserver.metrics.serviceMonitor.kvstoremesh.relabelings

Relabeling configs for the ServiceMonitor clustermesh-apiserver (KVStoreMesh metrics)

clustermesh.apiserver.metrics.serviceMonitor.kvstoremesh.scrapeTimeout

Timeout after which scrape is considered to be failed.

clustermesh.apiserver.metrics.serviceMonitor.labels

Labels to add to ServiceMonitor clustermesh-apiserver

clustermesh.apiserver.metrics.serviceMonitor.metricRelabelings

Metrics relabeling configs for the ServiceMonitor clustermesh-apiserver (apiserver metrics)

clustermesh.apiserver.metrics.serviceMonitor.relabelings

Relabeling configs for the ServiceMonitor clustermesh-apiserver (apiserver metrics)

clustermesh.apiserver.metrics.serviceMonitor.scrapeTimeout

Timeout after which scrape is considered to be failed.

clustermesh.apiserver.nodeSelector

Node labels for pod assignment ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

{"kubernetes.io/os":"linux"}

clustermesh.apiserver.podAnnotations

Annotations to be added to clustermesh-apiserver pods

clustermesh.apiserver.podDisruptionBudget.enabled

enable PodDisruptionBudget ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/

clustermesh.apiserver.podDisruptionBudget.maxUnavailable

Maximum number/percentage of pods that may be made unavailable

clustermesh.apiserver.podDisruptionBudget.minAvailable

Minimum number/percentage of pods that should remain scheduled. When it’s set, maxUnavailable must be disabled by maxUnavailable: null

clustermesh.apiserver.podDisruptionBudget.unhealthyPodEvictionPolicy

How are unhealthy, but running, pods counted for eviction

clustermesh.apiserver.podLabels

Labels to be added to clustermesh-apiserver pods

clustermesh.apiserver.podSecurityContext

Security context to be added to clustermesh-apiserver pods

{"fsGroup":65532,"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532}

clustermesh.apiserver.priorityClassName

The priority class to use for clustermesh-apiserver

clustermesh.apiserver.readinessProbe

Configuration for the clustermesh-apiserver readiness probe.

clustermesh.apiserver.replicas

Number of replicas run for the clustermesh-apiserver deployment.

clustermesh.apiserver.resources

Resource requests and limits for the clustermesh-apiserver

clustermesh.apiserver.securityContext

Security context to be added to clustermesh-apiserver containers

{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}

clustermesh.apiserver.service.annotations

Annotations for the clustermesh-apiserver service. Example annotations to configure an internal load balancer on different cloud providers: * AKS: service.beta.kubernetes.io/azure-load-balancer-internal: “true” * EKS: service.beta.kubernetes.io/aws-load-balancer-scheme: “internal” * GKE: networking.gke.io/load-balancer-type: “Internal”

clustermesh.apiserver.service.enableSessionAffinity

Defines when to enable session affinity. Each replica in a clustermesh-apiserver deployment runs its own discrete etcd cluster. Remote clients connect to one of the replicas through a shared Kubernetes Service. A client reconnecting to a different backend will require a full resync to ensure data integrity. Session affinity can reduce the likelihood of this happening, but may not be supported by all cloud providers. Possible values: - “HAOnly” (default) Only enable session affinity for deployments with more than 1 replica. - “Always” Always enable session affinity. - “Never” Never enable session affinity. Useful in environments where session affinity is not supported, but may lead to slightly degraded performance due to more frequent reconnections.

clustermesh.apiserver.service.externalTrafficPolicy

The externalTrafficPolicy of service used for apiserver access.

clustermesh.apiserver.service.internalTrafficPolicy

The internalTrafficPolicy of service used for apiserver access.

clustermesh.apiserver.service.labels

Labels for the clustermesh-apiserver service.

clustermesh.apiserver.service.loadBalancerClass

Configure a loadBalancerClass. Allows to configure the loadBalancerClass on the clustermesh-apiserver LB service in case the Service type is set to LoadBalancer (requires Kubernetes 1.24+).

clustermesh.apiserver.service.loadBalancerIP

Configure a specific loadBalancerIP. Allows to configure a specific loadBalancerIP on the clustermesh-apiserver LB service in case the Service type is set to LoadBalancer.

clustermesh.apiserver.service.loadBalancerSourceRanges

Configure loadBalancerSourceRanges. Allows to configure the source IP ranges allowed to access the clustermesh-apiserver LB service in case the Service type is set to LoadBalancer.

clustermesh.apiserver.service.nodePort

Optional port to use as the node port for apiserver access. WARNING: make sure to configure a different NodePort in each cluster if kube-proxy replacement is enabled, as Cilium is currently affected by a known bug (#24692) when NodePorts are handled by the KPR implementation. If a service with the same NodePort exists both in the local and the remote cluster, all traffic originating from inside the cluster and targeting the corresponding NodePort will be redirected to a local backend, regardless of whether the destination node belongs to the local or the remote cluster.

clustermesh.apiserver.service.type

The type of service used for apiserver access.

clustermesh.apiserver.terminationGracePeriodSeconds

terminationGracePeriodSeconds for the clustermesh-apiserver deployment

clustermesh.apiserver.tls.admin

base64 encoded PEM values for the clustermesh-apiserver admin certificate and private key. Used if ‘auto’ is not enabled.

clustermesh.apiserver.tls.authMode

Configure the clustermesh authentication mode. Supported values: - legacy: All clusters access remote clustermesh instances with the same username (i.e., remote). The “remote” certificate must be generated with CN=remote if provided manually. - migration: Intermediate mode required to upgrade from legacy to cluster (and vice versa) with no disruption. Specifically, it enables the creation of the per-cluster usernames, while still using the common one for authentication. The “remote” certificate must be generated with CN=remote if provided manually (same as legacy). - cluster: Each cluster accesses remote etcd instances with a username depending on the local cluster name (i.e., remote-). The “remote” certificate must be generated with CN=remote- if provided manually. Cluster mode is meaningful only when the same CA is shared across all clusters part of the mesh.

clustermesh.apiserver.tls.auto

Configure automatic TLS certificates generation. A Kubernetes CronJob is used the generate any certificates not provided by the user at installation time.

{"certManagerIssuerRef":{},"certValidityDuration":1095,"enabled":true,"method":"helm"}

clustermesh.apiserver.tls.auto.certManagerIssuerRef

certmanager issuer used when clustermesh.apiserver.tls.auto.method=certmanager.

clustermesh.apiserver.tls.auto.certValidityDuration

Generated certificates validity duration in days.

clustermesh.apiserver.tls.auto.enabled

When set to true, automatically generate a CA and certificates to enable mTLS between clustermesh-apiserver and external workload instances. If set to false, the certs to be provided by setting appropriate values below.

clustermesh.apiserver.tls.client

base64 encoded PEM values for the clustermesh-apiserver client certificate and private key. Used if ‘auto’ is not enabled.

clustermesh.apiserver.tls.enableSecrets

Allow users to provide their own certificates Users may need to provide their certificates using a mechanism that requires they provide their own secrets. This setting does not apply to any of the auto-generated mechanisms below, it only restricts the creation of secrets via the tls-provided templates.

clustermesh.apiserver.tls.remote

base64 encoded PEM values for the clustermesh-apiserver remote cluster certificate and private key. Used if ‘auto’ is not enabled.

clustermesh.apiserver.tls.server

base64 encoded PEM values for the clustermesh-apiserver server certificate and private key. Used if ‘auto’ is not enabled.

{"cert":"","extraDnsNames":[],"extraIpAddresses":[],"key":""}

clustermesh.apiserver.tls.server.extraDnsNames

Extra DNS names added to certificate when it’s auto generated

clustermesh.apiserver.tls.server.extraIpAddresses

Extra IP addresses added to certificate when it’s auto generated

clustermesh.apiserver.tolerations

Node tolerations for pod assignment on nodes with taints ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

clustermesh.apiserver.topologySpreadConstraints

Pod topology spread constraints for clustermesh-apiserver

clustermesh.apiserver.updateStrategy

clustermesh-apiserver update strategy

{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}

Clustermesh explicit configuration.

{"clusters":[],"domain":"mesh.cilium.io","enabled":false}

clustermesh.config.clusters

List of clusters to be peered in the mesh.

clustermesh.config.domain

Default dns domain for the Clustermesh API servers This is used in the case cluster addresses are not provided and IPs are used.

clustermesh.config.enabled

Enable the Clustermesh explicit configuration.

clustermesh.enableEndpointSliceSynchronization

Enable the synchronization of Kubernetes EndpointSlices corresponding to the remote endpoints of appropriately-annotated global services through ClusterMesh

clustermesh.enableMCSAPISupport

Enable Multi-Cluster Services API support

clustermesh.maxConnectedClusters

The maximum number of clusters to support in a ClusterMesh. This value cannot be changed on running clusters, and all clusters in a ClusterMesh must be configured with the same value. Values > 255 will decrease the maximum allocatable cluster-local identities. Supported values are 255 and 511.

clustermesh.policyDefaultLocalCluster

Control whether policy rules assume by default the local cluster if not explicitly selected

clustermesh.useAPIServer

Deploy clustermesh-apiserver for clustermesh

Configure the path to the CNI binary directory on the host.

Configure chaining on top of other CNI plugins. Possible values: - none - aws-cni - flannel - generic-veth - portmap

A CNI network name in to which the Cilium plugin should be added as a chained plugin. This will cause the agent to watch for a CNI network with this network name. When it is found, this will be used as the basis for Cilium’s CNI configuration file. If this is set, it assumes a chaining mode of generic-veth. As a special case, a chaining mode of aws-cni implies a chainingTarget of aws-cni.

cni.confFileMountPath

Configure the path to where to mount the ConfigMap inside the agent pod.

"/tmp/cni-configuration"

Configure the path to the CNI configuration directory on the host.

When defined, configMap will mount the provided value as ConfigMap and interpret the ‘cni.configMapKey’ value as CNI configuration file and write it when the agent starts up.

Configure the key in the CNI ConfigMap to read the contents of the CNI configuration from. For this to be effective, the ‘cni.configMap’ parameter must be specified too. Note that the ‘cni.configMap’ parameter is the name of the ConfigMap, while ‘cni.configMapKey’ is the name of the key in the ConfigMap data containing the actual configuration.

Skip writing of the CNI configuration. This can be used if writing of the CNI configuration is performed by external automation.

cni.enableRouteMTUForCNIChaining

Enable route MTU for pod netns when CNI chaining is used

Make Cilium take ownership over the /etc/cni/net.d directory on the node, renaming all non-Cilium CNI configurations to *.cilium_bak. This ensures no Pods can be scheduled using other CNI plugins during Cilium agent downtime.

cni.hostConfDirMountPath

Configure the path to where the CNI configuration directory is mounted inside the agent pod.

"/host/etc/cni/net.d"

Install the CNI configuration and binary files into the filesystem.

cni.iptablesRemoveAWSRules

Enable the removal of iptables rules created by the AWS CNI VPC plugin.

Configure the log file for CNI logging with retention policy of 7 days. Disable CNI file logging by setting this field to empty explicitly.

"/var/run/cilium/cilium-cni.log"

Specifies the resources for the cni initContainer

{"requests":{"cpu":"100m","memory":"10Mi"}}

Remove the CNI configuration and binary files on agent shutdown. Enable this if you’re removing Cilium from the cluster. Disable this to prevent the CNI configuration file from being removed during agent upgrade, which can cause nodes to go unmanageable.

commonLabels allows users to add common labels for all Cilium resources.

connectivityProbeFrequencyRatio

Ratio of the connectivity probe frequency vs resource usage, a float in [0, 1]. 0 will give more frequent probing, 1 will give less frequent probing. Probing frequency is dynamically adjusted based on the cluster size.

Configure how frequently garbage collection should occur for the datapath connection tracking table.

conntrackGCMaxInterval

Configure the maximum frequency for the garbage collection of the connection tracking table. Only affects the automatic computation for the frequency and has no effect when ‘conntrackGCInterval’ is set. This can be set to more frequently clean up unused identities created from ToFQDN policies.

Configure timeout in which Cilium will exit if CRDs are not available

Tail call hooks for custom eBPF programs.

Enable tail call hooks for custom eBPF programs.

daemon.allowedConfigOverrides

allowedConfigOverrides is a list of config-map keys that can be overridden. That is to say, if this value is set, config sources (excepting the first one) can only override keys in this list. This takes precedence over blockedConfigOverrides. By default, all keys may be overridden. To disable overrides, set this to “none” or change the configSources variable.

daemon.blockedConfigOverrides

blockedConfigOverrides is a list of config-map keys that may not be overridden. In other words, if any of these keys appear in a configuration source excepting the first one, they will be ignored This is ignored if allowedConfigOverrides is set. By default, all keys may be overridden.

Configure a custom list of possible configuration override sources The default is “config-map:cilium-config,cilium-node-config”. For supported values, see the help text for the build-config subcommand. Note that this value should be a comma-separated string.

daemon.enableSourceIPVerification

enableSourceIPVerification is a boolean flag to enable or disable the Source IP verification of endpoints. This flag is useful when Cilium is chained with other CNIs. By default, this functionality is enabled

Configure where Cilium runtime state should be stored.

Grafana dashboards for cilium-agent grafana can import dashboards based on the label and value ref: https://github.com/grafana/helm-charts/tree/main/charts/grafana#sidecar-for-dashboards

{"annotations":{},"enabled":false,"label":"grafana_dashboard","labelValue":"1","namespace":null}

debug.metricsSamplingInterval

Set the agent-internal metrics sampling frequency. This sets the frequency of the internal sampling of the agent metrics. These are available via the “cilium-dbg shell – metrics -s” command and are part of the metrics HTML page included in the sysdump. @schema type: [null, string] @schema

Configure verbosity levels for debug logging This option is used to enable debug messages for operations related to such sub-system such as (e.g. kvstore, envoy, datapath or policy), and flow is for enabling debug messages emitted per request, message and connection. Multiple values can be set via a space-separated string (e.g. “datapath envoy”). Applicable values: - flow - kvstore - envoy - datapath - policy

defaultLBServiceIPAM indicates the default LoadBalancer Service IPAM when no LoadBalancer class is set. Applicable values: lbipam, nodeipam, none @schema type: [string] @schema

directRoutingSkipUnreachable

Enable skipping of PodCIDR routes between worker nodes if the worker nodes are in a different L2 network segment.

Disable the usage of CiliumEndpoint CRD.

DNS policy for Cilium agent pods. Ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy

dnsProxy.dnsRejectResponseCode

DNS response code for rejecting DNS requests, available options are ‘[nameError refused]’.

dnsProxy.enableDnsCompression

Allow the DNS proxy to compress responses to endpoints that are larger than 512 Bytes or the EDNS0 option, if present.

dnsProxy.endpointMaxIpPerHostname

Maximum number of IPs to maintain per FQDN name for each endpoint.

dnsProxy.idleConnectionGracePeriod

Time during which idle but previously active connections with expired DNS lookups are still considered alive.

dnsProxy.maxDeferredConnectionDeletes

Maximum number of IPs to retain for expired DNS lookups with still-active connections.

The minimum time, in seconds, to use DNS data for toFQDNs policies. If the upstream DNS server returns a DNS record with a shorter TTL, Cilium overwrites the TTL with this value. Setting this value to zero means that Cilium will honor the TTLs returned by the upstream DNS server.

dnsProxy.preAllocateIdentities

Pre-allocate ToFQDN identities. This reduces DNS proxy tail latency, at the potential cost of some unnecessary policymap entries. Disable this if you have a large (200+) number of unique ToFQDN selectors.

DNS cache data at this path is preloaded on agent startup.

Global port on which the in-agent DNS proxy should listen. Default 0 is a OS-assigned port.

dnsProxy.proxyResponseMaxDelay

The maximum time the DNS proxy holds an allowed DNS response before sending it along. Responses are sent as soon as the datapath is updated with the new IP information.

dnsProxy.socketLingerTimeout

Timeout (in seconds) when closing the connection between the DNS proxy and the upstream server. If set to 0, the connection is closed immediately (with TCP RST). If set to -1, the connection is closed asynchronously in the background.

egressGateway.enabled

Enables egress gateway to redirect and SNAT the traffic that leaves the cluster.

egressGateway.reconciliationTriggerInterval

Time between triggers of egress gateway state reconciliations

enableCriticalPriorityClass

Explicitly enable or disable priority class. .Capabilities.KubeVersion is unsettable in helm template calls, it depends on k8s libraries version that Helm was compiled against. This option allows to explicitly disable setting the priority class, which is useful for rendering charts for gke clusters in advance.

Enables IPv4 BIG TCP support which increases maximum IPv4 GSO/GRO limits for nodes and pods

Enables masquerading of IPv4 traffic leaving the node from endpoints.

true unless ipam eni mode is active

Enables IPv6 BIG TCP support which increases maximum IPv6 GSO/GRO limits for nodes and pods

Enables masquerading of IPv6 traffic leaving the node from endpoints.

enableInternalTrafficPolicy

Enable Internal Traffic Policy

Enable LoadBalancer IP Address Management

enableMasqueradeRouteSource

Enables masquerading to the source of the route for traffic leaving the node from endpoints.

enableNonDefaultDenyPolicies

Enable Non-Default-Deny policies

enableXTSocketFallback

Enables the fallback compatibility solution for when the xt_socket kernel module is missing and it is needed for the datapath L7 redirection to work properly. See documentation for details on when this can be disabled: https://docs.cilium.io/en/stable/operations/system_requirements/#linux-kernel.

Enable transparent network encryption.

encryption.ipsec.encryptedOverlay

Enable IPsec encrypted overlay

encryption.ipsec.interface

The interface to use for encrypted traffic.

encryption.ipsec.keyFile

Name of the key file inside the Kubernetes secret configured via secretName.

encryption.ipsec.keyRotationDuration

Maximum duration of the IPsec key rotation. The previous key will be removed after that delay.

encryption.ipsec.keyWatcher

Enable the key watcher. If disabled, a restart of the agent will be necessary on key rotations.

encryption.ipsec.mountPath

Path to mount the secret inside the Cilium pod.

encryption.ipsec.secretName

Name of the Kubernetes secret containing the encryption keys.

encryption.nodeEncryption

Enable encryption for pure node to node traffic. This option is only effective when encryption.type is set to “wireguard”.

encryption.strictMode

Configure the WireGuard Pod2Pod strict mode.

{"allowRemoteNodeIdentities":false,"cidr":"","enabled":false}

encryption.strictMode.allowRemoteNodeIdentities

Allow dynamic lookup of remote node identities. This is required when tunneling is used or direct routing is used and the node CIDR and pod CIDR overlap.

encryption.strictMode.cidr

CIDR for the WireGuard Pod2Pod strict mode.

encryption.strictMode.enabled

Enable WireGuard Pod2Pod strict mode.

Encryption method. Can be either ipsec or wireguard.

encryption.wireguard.persistentKeepalive

Controls WireGuard PersistentKeepalive option. Set 0s to disable.

endpointHealthChecking.enabled

Enable connectivity health checking between virtual endpoints.

endpointLockdownOnMapOverflow

Enable endpoint lockdown on policy map overflow.

endpointRoutes.enabled

Enable use of per endpoint routes instead of routing via the cilium_host interface.

eni.awsEnablePrefixDelegation

Enable ENI prefix delegation

eni.awsReleaseExcessIPs

Release IPs not used from the ENI

EC2 API endpoint to use

Enable Elastic Network Interface (ENI) integration.

Tags to apply to the newly created ENIs

Interval for garbage collection of unattached ENIs. Set to “0s” to disable.

Additional tags attached to ENIs created by Cilium. Dangling ENIs with this tag will be garbage collected

{"io.cilium/cilium-managed":"true,"io.cilium/cluster-name":"<auto-detected>"}

If using IAM role for Service Accounts will not try to inject identity values from cilium-aws kubernetes secret. Adds annotation to service account if managed by Helm. See https://github.com/aws/amazon-eks-pod-identity-webhook

eni.instanceTagsFilter

Filter via AWS EC2 Instance tags (k=v) which will dictate which AWS EC2 Instances are going to be used to create new ENIs

Filter via subnet IDs which will dictate which subnets are going to be used to create new ENIs Important note: This requires that each instance has an ENI with a matching subnet attached when Cilium is deployed. If you only want to control subnets for ENIs attached by Cilium, use the CNI configuration file settings (cni.customConf) instead.

Filter via tags (k=v) which will dictate which subnets are going to be used to create new ENIs Important note: This requires that each instance has an ENI with a matching subnet attached when Cilium is deployed. If you only want to control subnets for ENIs attached by Cilium, use the CNI configuration file settings (cni.customConf) instead.

Affinity for cilium-envoy.

{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"cilium.io/no-schedule","operator":"NotIn","values":["true"]}]}]}},"podAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"k8s-app":"cilium"}},"topologyKey":"kubernetes.io/hostname"}]},"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"k8s-app":"cilium-envoy"}},"topologyKey":"kubernetes.io/hostname"}]}}

Annotations to be added to all top-level cilium-envoy objects (resources under templates/cilium-envoy)

Set Envoy’–base-id’ to use when allocating shared memory regions. Only needs to be changed if multiple Envoy instances will run on the same node and may have conflicts. Supported values: 0 - 4294967295. Defaults to ‘0’

envoy.bootstrapConfigMap

ADVANCED OPTION: Bring your own custom Envoy bootstrap ConfigMap. Provide the name of a ConfigMap with a bootstrap-config.json key. When specified, Envoy will use this ConfigMap instead of the default provided by the chart. WARNING: Use of this setting has the potential to prevent cilium-envoy from starting up, and can cause unexpected behavior (e.g. due to syntax error or semantically incorrect configuration). Before submitting an issue, please ensure you have disabled this feature, as support cannot be provided for custom Envoy bootstrap configs. @schema type: [null, string] @schema

envoy.connectTimeoutSeconds

Time in seconds after which a TCP connection attempt times out

envoy.debug.admin.enabled

Enable admin interface for cilium-envoy. This is useful for debugging and should not be enabled in production.

envoy.debug.admin.port

Port number (bound to loopback interface). kubectl port-forward can be used to access the admin interface.

DNS policy for Cilium envoy pods. Ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy

Enable Envoy Proxy in standalone DaemonSet. This field is enabled by default for new installation.

true for new installation

Additional envoy container arguments.

envoy.extraContainers

Additional containers added to the cilium Envoy DaemonSet.

Additional envoy container environment variables.

envoy.extraHostPathMounts

Additional envoy hostPath mounts.

envoy.extraVolumeMounts

Additional envoy volumeMounts.

Additional envoy volumes.

TCP port for the health API.

Maximum number of retries for each HTTP request

envoy.httpUpstreamLingerTimeout

Time in seconds to block Envoy worker thread while an upstream HTTP connection is closing. If set to 0, the connection is closed immediately (with TCP RST). If set to -1, the connection is closed asynchronously in the background.

envoy.idleTimeoutDurationSeconds

Set Envoy upstream HTTP idle connection timeout seconds. Does not apply to connections with pending requests. Default 60s

Envoy container image.

{"digest":"sha256:3108521821c6922695ff1f6ef24b09026c94b195283f8bfbfc0fa49356a156e1","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/cilium-envoy","tag":"v1.34.12-1765374555-6a93b0bbba8d6dc75b651cbafeedb062b2997716","useDigest":true}

envoy.initialFetchTimeoutSeconds

Time in seconds after which the initial fetch on an xDS stream is considered timed out

envoy.livenessProbe.enabled

Enable liveness probe for cilium-envoy

envoy.livenessProbe.failureThreshold

failure threshold of liveness probe

envoy.livenessProbe.periodSeconds

interval between checks of the liveness probe

envoy.log.accessLogBufferSize

Size of the Envoy access log buffer created within the agent in bytes. Tune this value up if you encounter “Envoy: Discarded truncated access log message” errors. Large request/response header sizes (e.g. 16KiB) will require a larger buffer size.

envoy.log.defaultLevel

Default log level of Envoy application log that is configured if Cilium debug / verbose logging isn’t enabled. This option allows to have a different log level than the Cilium Agent - e.g. lower it to critical. Possible values: trace, debug, info, warning, error, critical, off

Defaults to the default log level of the Cilium Agent - info

The format string to use for laying out the log message metadata of Envoy. If specified, Envoy will use text format output. This setting is mutually exclusive with envoy.log.format_json.

"[%Y-%m-%d %T.%e][%t][%l][%n] [%g:%#] %v"

envoy.log.format_json

The JSON logging format to use for Envoy. This setting is mutually exclusive with envoy.log.format. ref: https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/bootstrap/v3/bootstrap.proto#envoy-v3-api-field-config-bootstrap-v3-bootstrap-applicationlogconfig-logformat-json-format

Path to a separate Envoy log file, if any. Defaults to /dev/stdout.

envoy.maxConcurrentRetries

Maximum number of concurrent retries on Envoy clusters

envoy.maxConnectionDurationSeconds

Set Envoy HTTP option max_connection_duration seconds. Default 0 (disable)

envoy.maxRequestsPerConnection

ProxyMaxRequestsPerConnection specifies the max_requests_per_connection setting for Envoy

Node selector for cilium-envoy.

{"kubernetes.io/os":"linux"}

Annotations to be added to envoy pods

Labels to be added to envoy pods

envoy.podSecurityContext

Security Context for cilium-envoy pods.

{"appArmorProfile":{"type":"Unconfined"}}

envoy.podSecurityContext.appArmorProfile

AppArmorProfile options for the cilium-agent and init containers

{"type":"Unconfined"}

envoy.policyRestoreTimeoutDuration

Max duration to wait for endpoint policies to be restored on restart. Default “3m”.

envoy.priorityClassName

The priority class to use for cilium-envoy.

Configure Cilium Envoy Prometheus options. Note that some of these apply to either cilium-agent or cilium-envoy.

{"enabled":true,"port":"9964","serviceMonitor":{"annotations":{},"enabled":false,"interval":"10s","labels":{},"metricRelabelings":null,"relabelings":[{"action":"replace","replacement":"${1}","sourceLabels":["__meta_kubernetes_pod_node_name"],"targetLabel":"node"}],"scrapeTimeout":null}}

envoy.prometheus.enabled

Enable prometheus metrics for cilium-envoy

envoy.prometheus.port

Serve prometheus metrics for cilium-envoy on the configured port

envoy.prometheus.serviceMonitor.annotations

Annotations to add to ServiceMonitor cilium-envoy

envoy.prometheus.serviceMonitor.enabled

Enable service monitors. This requires the prometheus CRDs to be available (see https://github.com/prometheus-operator/prometheus-operator/blob/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml) Note that this setting applies to both cilium-envoy and cilium-agent with Envoy enabled.

envoy.prometheus.serviceMonitor.interval

Interval for scrape metrics.

envoy.prometheus.serviceMonitor.labels

Labels to add to ServiceMonitor cilium-envoy

envoy.prometheus.serviceMonitor.metricRelabelings

Metrics relabeling configs for the ServiceMonitor cilium-envoy or for cilium-agent with Envoy configured.

envoy.prometheus.serviceMonitor.relabelings

Relabeling configs for the ServiceMonitor cilium-envoy or for cilium-agent with Envoy configured.

[{"action":"replace","replacement":"${1}","sourceLabels":["__meta_kubernetes_pod_node_name"],"targetLabel":"node"}]

envoy.prometheus.serviceMonitor.scrapeTimeout

Timeout after which scrape is considered to be failed.

envoy.readinessProbe.failureThreshold

failure threshold of readiness probe

envoy.readinessProbe.periodSeconds

interval between checks of the readiness probe

Envoy resource limits & requests ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

Roll out cilium envoy pods automatically when configmap is updated.

envoy.securityContext.capabilities.envoy

Capabilities for the cilium-envoy container. Even though granted to the container, the cilium-envoy-starter wrapper drops all capabilities after forking the actual Envoy process. NET_BIND_SERVICE is the only capability that can be passed to the Envoy process by setting envoy.securityContext.capabilities.keepNetBindService=true (in addition to granting the capability to the container). Note: In case of embedded envoy, the capability must be granted to the cilium-agent container.

["NET_ADMIN","SYS_ADMIN"]

envoy.securityContext.capabilities.keepCapNetBindService

Keep capability NET_BIND_SERVICE for Envoy process.

envoy.securityContext.privileged

Run the pod with elevated privileges

envoy.securityContext.seLinuxOptions

SELinux options for the cilium-envoy container

{"level":"s0","type":"spc_t"}

envoy.startupProbe.enabled

Enable startup probe for cilium-envoy

envoy.startupProbe.failureThreshold

failure threshold of startup probe. 105 x 2s translates to the old behaviour of the readiness probe (120s delay + 30 x 3s)

envoy.startupProbe.periodSeconds

interval between checks of the startup probe

envoy.streamIdleTimeoutDurationSeconds

Set Envoy the amount of time that the connection manager will allow a stream to exist with no upstream or downstream activity. default 5 minutes

envoy.terminationGracePeriodSeconds

Configure termination grace period for cilium-envoy DaemonSet.

Node tolerations for envoy scheduling to nodes with taints ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

[{"operator":"Exists"}]

cilium-envoy update strategy ref: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/#updating-a-daemonset

{"rollingUpdate":{"maxUnavailable":2},"type":"RollingUpdate"}

envoy.xffNumTrustedHopsL7PolicyEgress

Number of trusted hops regarding the x-forwarded-for and related HTTP headers for the egress L7 policy enforcement Envoy listeners.

envoy.xffNumTrustedHopsL7PolicyIngress

Number of trusted hops regarding the x-forwarded-for and related HTTP headers for the ingress L7 policy enforcement Envoy listeners.

Enable CiliumEnvoyConfig CRD CiliumEnvoyConfig CRD can also be implicitly enabled by other options.

envoyConfig.retryInterval

Interval in which an attempt is made to reconcile failed EnvoyConfigs. If the duration is zero, the retry is deactivated.

envoyConfig.secretsNamespace

SecretsNamespace is the namespace in which envoy SDS will retrieve secrets from.

{"create":true,"name":"cilium-secrets"}

envoyConfig.secretsNamespace.create

Create secrets namespace for CiliumEnvoyConfig CRDs.

envoyConfig.secretsNamespace.name

The name of the secret namespace to which Cilium agents are given read access.

Enable etcd mode for the agent.

List of etcd endpoints

["https://CHANGE-ME:2379"]

Enable use of TLS/SSL for connectivity to etcd.

Additional agent container arguments.

extraConfig allows you to specify additional configuration parameters to be included in the cilium-config configmap.

Additional containers added to the cilium DaemonSet.

Additional agent container environment variables.

Additional agent hostPath mounts.

Additional initContainers added to the cilium Daemonset.

Additional agent volumeMounts.

Additional agent volumes.

Forces the auto-detection of devices, even if specific devices are explicitly listed

gatewayAPI.enableAlpn

Enable ALPN for all listeners configured with Gateway API. ALPN will attempt HTTP/2, then HTTP 1.1. Note that this will also enable appProtocol support, and services that wish to use HTTP/2 will need to indicate that via their appProtocol.

gatewayAPI.enableAppProtocol

Enable Backend Protocol selection support (GEP-1911) for Gateway API via appProtocol.

gatewayAPI.enableProxyProtocol

Enable proxy protocol for all GatewayAPI listeners. Note that only Proxy protocol traffic will be accepted once this is enabled.

Enable support for Gateway API in cilium This will automatically set enable-envoy-config as well.

gatewayAPI.externalTrafficPolicy

Control how traffic from external sources is routed to the LoadBalancer Kubernetes Service for all Cilium GatewayAPI Gateway instances. Valid values are “Cluster” and “Local”. Note that this value will be ignored when hostNetwork.enabled == true. ref: https://kubernetes.io/docs/reference/networking/virtual-ips/#external-traffic-policy

gatewayAPI.gatewayClass.create

Enable creation of GatewayClass resource The default value is ‘auto’ which decides according to presence of gateway.networking.k8s.io/v1/GatewayClass in the cluster. Other possible values are ‘true’ and ‘false’, which will either always or never create the GatewayClass, respectively.

gatewayAPI.hostNetwork.enabled

Configure whether the Envoy listeners should be exposed on the host network.

gatewayAPI.hostNetwork.nodes.matchLabels

Specify the labels of the nodes where the Ingress listeners should be exposed matchLabels: kubernetes.io/os: linux kubernetes.io/hostname: kind-worker

gatewayAPI.secretsNamespace

SecretsNamespace is the namespace in which envoy SDS will retrieve TLS secrets from.

{"create":true,"name":"cilium-secrets","sync":true}

gatewayAPI.secretsNamespace.create

Create secrets namespace for Gateway API.

gatewayAPI.secretsNamespace.name

Name of Gateway API secret namespace.

gatewayAPI.secretsNamespace.sync

Enable secret sync, which will make sure all TLS secrets used by Ingress are synced to secretsNamespace.name. If disabled, TLS secrets must be maintained externally.

gatewayAPI.xffNumTrustedHops

The number of additional GatewayAPI proxy hops from the right side of the HTTP header to trust when determining the origin client’s IP address.

Enable Google Kubernetes Engine integration

healthCheckICMPFailureThreshold

Number of ICMP requests sent for each health check before marking a node or endpoint unreachable.

Enable connectivity health checking.

TCP port for the agent health API. This is not the port for cilium-health.

Configure the host firewall.

Enables the enforcement of host policies in the eBPF datapath.

Annotations to be added to all top-level hubble objects (resources under templates/hubble)

hubble.dropEventEmitter

Emit v1.Events related to pods on detection of packet drops. This feature is alpha, please provide feedback at https://github.com/cilium/cilium/issues/33975.

{"enabled":false,"interval":"2m","reasons":["auth_required","policy_denied"]}

hubble.dropEventEmitter.interval

Minimum time between emitting same events.

hubble.dropEventEmitter.reasons

Drop reasons to emit events for. ref: https://docs.cilium.io/en/stable/_api/v1/flow/README/#dropreason

["auth_required","policy_denied"]

Enable Hubble (true by default).

{"dynamic":{"config":{"configMapName":"cilium-flowlog-config","content":[{"excludeFilters":[],"fieldMask":[],"fileCompress":false,"fileMaxBackups":5,"fileMaxSizeMb":10,"filePath":"/var/run/cilium/hubble/events.log","includeFilters":[],"name":"all"}],"createConfigMap":true},"enabled":false},"static":{"allowList":[],"denyList":[],"enabled":false,"fieldMask":[],"fileCompress":false,"fileMaxBackups":5,"fileMaxSizeMb":10,"filePath":"/var/run/cilium/hubble/events.log"}}

hubble.export.dynamic

Dynamic exporters configuration. Dynamic exporters may be reconfigured without a need of agent restarts.

{"config":{"configMapName":"cilium-flowlog-config","content":[{"excludeFilters":[],"fieldMask":[],"fileCompress":false,"fileMaxBackups":5,"fileMaxSizeMb":10,"filePath":"/var/run/cilium/hubble/events.log","includeFilters":[],"name":"all"}],"createConfigMap":true},"enabled":false}

hubble.export.dynamic.config.configMapName

– Name of configmap with configuration that may be altered to reconfigure exporters within a running agents.

"cilium-flowlog-config"

hubble.export.dynamic.config.content

– Exporters configuration in YAML format.

[{"excludeFilters":[],"fieldMask":[],"fileCompress":false,"fileMaxBackups":5,"fileMaxSizeMb":10,"filePath":"/var/run/cilium/hubble/events.log","includeFilters":[],"name":"all"}]

hubble.export.dynamic.config.createConfigMap

– True if helm installer should create config map. Switch to false if you want to self maintain the file content.

Static exporter configuration. Static exporter is bound to agent lifecycle.

{"allowList":[],"denyList":[],"enabled":false,"fieldMask":[],"fileCompress":false,"fileMaxBackups":5,"fileMaxSizeMb":10,"filePath":"/var/run/cilium/hubble/events.log"}

hubble.export.static.fileCompress

Enable compression of rotated files.

hubble.export.static.fileMaxBackups

Defines max number of backup/rotated files.

hubble.export.static.fileMaxSizeMb

Defines max file size of output file before it gets rotated.

An additional address for Hubble to listen to. Set this field “:4244” if you are enabling Hubble Relay, as it assumes that Hubble is listening on port 4244.

Hubble metrics configuration. See https://docs.cilium.io/en/stable/observability/metrics/#hubble-metrics for more comprehensive documentation about Hubble metrics.

{"dashboards":{"annotations":{},"enabled":false,"label":"grafana_dashboard","labelValue":"1","namespace":null},"dynamic":{"config":{"configMapName":"cilium-dynamic-metrics-config","content":[],"createConfigMap":true},"enabled":false},"enableOpenMetrics":false,"enabled":null,"port":9965,"serviceAnnotations":{},"serviceMonitor":{"annotations":{},"enabled":false,"interval":"10s","jobLabel":"","labels":{},"metricRelabelings":null,"relabelings":[{"action":"replace","replacement":"${1}","sourceLabels":["__meta_kubernetes_pod_node_name"],"targetLabel":"node"}],"scrapeTimeout":null,"tlsConfig":{}},"tls":{"enabled":false,"server":{"cert":"","existingSecret":"","extraDnsNames":[],"extraIpAddresses":[],"key":"","mtls":{"enabled":false,"key":"ca.crt","name":null,"useSecret":false}}}}

hubble.metrics.dashboards

Grafana dashboards for hubble grafana can import dashboards based on the label and value ref: https://github.com/grafana/helm-charts/tree/main/charts/grafana#sidecar-for-dashboards

{"annotations":{},"enabled":false,"label":"grafana_dashboard","labelValue":"1","namespace":null}

hubble.metrics.dynamic.config.configMapName

– Name of configmap with configuration that may be altered to reconfigure metric handlers within a running agent.

"cilium-dynamic-metrics-config"

hubble.metrics.dynamic.config.content

– Exporters configuration in YAML format.

hubble.metrics.dynamic.config.createConfigMap

– True if helm installer should create config map. Switch to false if you want to self maintain the file content.

hubble.metrics.enableOpenMetrics

Enables exporting hubble metrics in OpenMetrics format.

hubble.metrics.enabled

Configures the list of metrics to collect. If empty or null, metrics are disabled. Example: enabled: - dns:query;ignoreAAAA - drop - tcp - flow - icmp - http You can specify the list of metrics from the helm CLI: –set hubble.metrics.enabled=”{dns:query;ignoreAAAA,drop,tcp,flow,icmp,http}”

Configure the port the hubble metric server listens on.

hubble.metrics.serviceAnnotations

Annotations to be added to hubble-metrics service.

hubble.metrics.serviceMonitor.annotations

Annotations to add to ServiceMonitor hubble

hubble.metrics.serviceMonitor.enabled

Create ServiceMonitor resources for Prometheus Operator. This requires the prometheus CRDs to be available. ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml)

hubble.metrics.serviceMonitor.interval

Interval for scrape metrics.

hubble.metrics.serviceMonitor.jobLabel

jobLabel to add for ServiceMonitor hubble

hubble.metrics.serviceMonitor.labels

Labels to add to ServiceMonitor hubble

hubble.metrics.serviceMonitor.metricRelabelings

Metrics relabeling configs for the ServiceMonitor hubble

hubble.metrics.serviceMonitor.relabelings

Relabeling configs for the ServiceMonitor hubble

[{"action":"replace","replacement":"${1}","sourceLabels":["__meta_kubernetes_pod_node_name"],"targetLabel":"node"}]

hubble.metrics.serviceMonitor.scrapeTimeout

Timeout after which scrape is considered to be failed.

hubble.metrics.tls.server.cert

base64 encoded PEM values for the Hubble metrics server certificate (deprecated). Use existingSecret instead.

hubble.metrics.tls.server.existingSecret

Name of the Secret containing the certificate and key for the Hubble metrics server. If specified, cert and key are ignored.

hubble.metrics.tls.server.extraDnsNames

Extra DNS names added to certificate when it’s auto generated

hubble.metrics.tls.server.extraIpAddresses

Extra IP addresses added to certificate when it’s auto generated

hubble.metrics.tls.server.key

base64 encoded PEM values for the Hubble metrics server key (deprecated). Use existingSecret instead.

hubble.metrics.tls.server.mtls

Configure mTLS for the Hubble metrics server.

{"enabled":false,"key":"ca.crt","name":null,"useSecret":false}

hubble.metrics.tls.server.mtls.key

Entry of the ConfigMap containing the CA.

hubble.metrics.tls.server.mtls.name

Name of the ConfigMap containing the CA to validate client certificates against. If mTLS is enabled and this is unspecified, it will default to the same CA used for Hubble metrics server certificates.

hubble.networkPolicyCorrelation

Enables network policy correlation of Hubble flows, i.e. populating egress_allowed_by, ingress_denied_by fields with policy information.

hubble.peerService.clusterDomain

The cluster domain to use to query the Hubble Peer service. It should be the local cluster.

hubble.peerService.targetPort

Target Port for the Peer service, must match the hubble.listenAddress’ port.

Whether Hubble should prefer to announce IPv6 or IPv4 addresses if both are available.

Enables redacting sensitive information present in Layer 7 flows.

{"enabled":false,"http":{"headers":{"allow":[],"deny":[]},"urlQuery":false,"userInfo":true},"kafka":{"apiKey":true}}

hubble.redact.http.headers.allow

List of HTTP headers to allow: headers not matching will be redacted. Note: allow and deny lists cannot be used both at the same time, only one can be present. Example: redact: enabled: true http: headers: allow: - traceparent - tracestate - Cache-Control You can specify the options from the helm CLI: –set hubble.redact.enabled=”true” –set hubble.redact.http.headers.allow=”traceparent,tracestate,Cache-Control”

hubble.redact.http.headers.deny

List of HTTP headers to deny: matching headers will be redacted. Note: allow and deny lists cannot be used both at the same time, only one can be present. Example: redact: enabled: true http: headers: deny: - Authorization - Proxy-Authorization You can specify the options from the helm CLI: –set hubble.redact.enabled=”true” –set hubble.redact.http.headers.deny=”Authorization,Proxy-Authorization”

hubble.redact.http.urlQuery

Enables redacting URL query (GET) parameters. Example: redact: enabled: true http: urlQuery: true You can specify the options from the helm CLI: –set hubble.redact.enabled=”true” –set hubble.redact.http.urlQuery=”true”

hubble.redact.http.userInfo

Enables redacting user info, e.g., password when basic auth is used. Example: redact: enabled: true http: userInfo: true You can specify the options from the helm CLI: –set hubble.redact.enabled=”true” –set hubble.redact.http.userInfo=”true”

hubble.redact.kafka.apiKey

Enables redacting Kafka’s API key (deprecated, will be removed in v1.19). Example: redact: enabled: true kafka: apiKey: true You can specify the options from the helm CLI: –set hubble.redact.enabled=”true” –set hubble.redact.kafka.apiKey=”true”

hubble.relay.affinity

Affinity for hubble-replay

{"podAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"k8s-app":"cilium"}},"topologyKey":"kubernetes.io/hostname"}]}}

hubble.relay.annotations

Annotations to be added to all top-level hubble-relay objects (resources under templates/hubble-relay)

Enable Hubble Relay (requires hubble.enabled=true)

hubble.relay.extraEnv

Additional hubble-relay environment variables.

hubble.relay.extraVolumeMounts

Additional hubble-relay volumeMounts.

hubble.relay.extraVolumes

Additional hubble-relay volumes.

hubble.relay.gops.enabled

Enable gops for hubble-relay

hubble.relay.gops.port

Configure gops listen port for hubble-relay

Hubble-relay container image.

{"digest":"","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/hubble-relay","tag":"v1.18.5","useDigest":false}

hubble.relay.listenHost

Host to listen to. Specify an empty string to bind to all the interfaces.

hubble.relay.listenPort

hubble.relay.nodeSelector

Node labels for pod assignment ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

{"kubernetes.io/os":"linux"}

hubble.relay.podAnnotations

Annotations to be added to hubble-relay pods

hubble.relay.podDisruptionBudget.enabled

enable PodDisruptionBudget ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/

hubble.relay.podDisruptionBudget.maxUnavailable

Maximum number/percentage of pods that may be made unavailable

hubble.relay.podDisruptionBudget.minAvailable

Minimum number/percentage of pods that should remain scheduled. When it’s set, maxUnavailable must be disabled by maxUnavailable: null

hubble.relay.podDisruptionBudget.unhealthyPodEvictionPolicy

How are unhealthy, but running, pods counted for eviction

hubble.relay.podLabels

Labels to be added to hubble-relay pods

hubble.relay.podSecurityContext

hubble-relay pod security context

{"fsGroup":65532,"seccompProfile":{"type":"RuntimeDefault"}}

hubble.relay.pprof.address

Configure pprof listen address for hubble-relay

hubble.relay.pprof.enabled

Enable pprof for hubble-relay

hubble.relay.pprof.port

Configure pprof listen port for hubble-relay

hubble.relay.priorityClassName

The priority class to use for hubble-relay

hubble.relay.prometheus

Enable prometheus metrics for hubble-relay on the configured port at /metrics

{"enabled":false,"port":9966,"serviceMonitor":{"annotations":{},"enabled":false,"interval":"10s","labels":{},"metricRelabelings":null,"relabelings":null,"scrapeTimeout":null}}

hubble.relay.prometheus.serviceMonitor.annotations

Annotations to add to ServiceMonitor hubble-relay

hubble.relay.prometheus.serviceMonitor.enabled

Enable service monitors. This requires the prometheus CRDs to be available (see https://github.com/prometheus-operator/prometheus-operator/blob/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml)

hubble.relay.prometheus.serviceMonitor.interval

Interval for scrape metrics.

hubble.relay.prometheus.serviceMonitor.labels

Labels to add to ServiceMonitor hubble-relay

hubble.relay.prometheus.serviceMonitor.metricRelabelings

Metrics relabeling configs for the ServiceMonitor hubble-relay

hubble.relay.prometheus.serviceMonitor.relabelings

Relabeling configs for the ServiceMonitor hubble-relay

hubble.relay.prometheus.serviceMonitor.scrapeTimeout

Timeout after which scrape is considered to be failed.

hubble.relay.replicas

Number of replicas run for the hubble-relay deployment.

hubble.relay.resources

Specifies the resources for the hubble-relay pods

hubble.relay.retryTimeout

Backoff duration to retry connecting to the local hubble instance in case of failure (e.g. “30s”).

hubble.relay.rollOutPods

Roll out Hubble Relay pods automatically when configmap is updated.

hubble.relay.securityContext

hubble-relay container security context

{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}

hubble-relay service configuration.

{"nodePort":31234,"type":"ClusterIP"}

hubble.relay.service.nodePort

The port to use when the service type is set to NodePort.

hubble.relay.service.type

The type of service used for Hubble Relay access, either ClusterIP, NodePort or LoadBalancer.

hubble.relay.sortBufferDrainTimeout

When the per-request flows sort buffer is not full, a flow is drained every time this timeout is reached (only affects requests in follow-mode) (e.g. “1s”).

hubble.relay.sortBufferLenMax

Max number of flows that can be buffered for sorting before being sent to the client (per request) (e.g. 100).

hubble.relay.terminationGracePeriodSeconds

Configure termination grace period for hubble relay Deployment.

TLS configuration for Hubble Relay

{"client":{"cert":"","existingSecret":"","key":""},"server":{"cert":"","enabled":false,"existingSecret":"","extraDnsNames":[],"extraIpAddresses":[],"key":"","mtls":false,"relayName":"ui.hubble-relay.cilium.io"}}

hubble.relay.tls.client

The hubble-relay client certificate and private key. This keypair is presented to Hubble server instances for mTLS authentication and is required when hubble.tls.enabled is true. These values need to be set manually if hubble.tls.auto.enabled is false.

{"cert":"","existingSecret":"","key":""}

hubble.relay.tls.client.cert

base64 encoded PEM values for the Hubble relay client certificate (deprecated). Use existingSecret instead.

hubble.relay.tls.client.existingSecret

Name of the Secret containing the certificate and key for the Hubble metrics server. If specified, cert and key are ignored.

hubble.relay.tls.client.key

base64 encoded PEM values for the Hubble relay client key (deprecated). Use existingSecret instead.

hubble.relay.tls.server

The hubble-relay server certificate and private key

{"cert":"","enabled":false,"existingSecret":"","extraDnsNames":[],"extraIpAddresses":[],"key":"","mtls":false,"relayName":"ui.hubble-relay.cilium.io"}

hubble.relay.tls.server.cert

base64 encoded PEM values for the Hubble relay server certificate (deprecated). Use existingSecret instead.

hubble.relay.tls.server.existingSecret

Name of the Secret containing the certificate and key for the Hubble relay server. If specified, cert and key are ignored.

hubble.relay.tls.server.extraDnsNames

extra DNS names added to certificate when its auto gen

hubble.relay.tls.server.extraIpAddresses

extra IP addresses added to certificate when its auto gen

hubble.relay.tls.server.key

base64 encoded PEM values for the Hubble relay server key (deprecated). Use existingSecret instead.

hubble.relay.tolerations

Node tolerations for pod assignment on nodes with taints ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

hubble.relay.topologySpreadConstraints

Pod topology spread constraints for hubble-relay

hubble.relay.updateStrategy

hubble-relay update strategy

{"rollingUpdate":{"maxUnavailable":1},"type":"RollingUpdate"}

hubble.skipUnknownCGroupIDs

Skip Hubble events with unknown cgroup ids

Unix domain socket path to listen to when Hubble is enabled.

"/var/run/cilium/hubble.sock"

TLS configuration for Hubble

{"auto":{"certManagerIssuerRef":{},"certValidityDuration":365,"enabled":true,"method":"helm","schedule":"0 0 1 */4 *"},"enabled":true,"server":{"cert":"","existingSecret":"","extraDnsNames":[],"extraIpAddresses":[],"key":""}}

Configure automatic TLS certificates generation.

{"certManagerIssuerRef":{},"certValidityDuration":365,"enabled":true,"method":"helm","schedule":"0 0 1 */4 *"}

hubble.tls.auto.certManagerIssuerRef

certmanager issuer used when hubble.tls.auto.method=certmanager.

hubble.tls.auto.certValidityDuration

Generated certificates validity duration in days. Defaults to 365 days (1 year) because MacOS does not accept self-signed certificates with expirations > 825 days.

hubble.tls.auto.enabled

Auto-generate certificates. When set to true, automatically generate a CA and certificates to enable mTLS between Hubble server and Hubble Relay instances. If set to false, the certs for Hubble server need to be provided by setting appropriate values below.

hubble.tls.auto.method

Set the method to auto-generate certificates. Supported values: - helm: This method uses Helm to generate all certificates. - cronJob: This method uses a Kubernetes CronJob the generate any certificates not provided by the user at installation time. - certmanager: This method use cert-manager to generate & rotate certificates.

hubble.tls.auto.schedule

Schedule for certificates regeneration (regardless of their expiration date). Only used if method is “cronJob”. If nil, then no recurring job will be created. Instead, only the one-shot job is deployed to generate the certificates at installation time. Defaults to midnight of the first day of every fourth month. For syntax, see https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#schedule-syntax

Enable mutual TLS for listenAddress. Setting this value to false is highly discouraged as the Hubble API provides access to potentially sensitive network flow metadata and is exposed on the host network.

The Hubble server certificate and private key

{"cert":"","existingSecret":"","extraDnsNames":[],"extraIpAddresses":[],"key":""}

hubble.tls.server.cert

base64 encoded PEM values for the Hubble server certificate (deprecated). Use existingSecret instead.

hubble.tls.server.existingSecret

Name of the Secret containing the certificate and key for the Hubble server. If specified, cert and key are ignored.

hubble.tls.server.extraDnsNames

Extra DNS names added to certificate when it’s auto generated

hubble.tls.server.extraIpAddresses

Extra IP addresses added to certificate when it’s auto generated

hubble.tls.server.key

base64 encoded PEM values for the Hubble server key (deprecated). Use existingSecret instead.

Affinity for hubble-ui

hubble.ui.annotations

Annotations to be added to all top-level hubble-ui objects (resources under templates/hubble-ui)

hubble.ui.backend.extraEnv

Additional hubble-ui backend environment variables.

hubble.ui.backend.extraVolumeMounts

Additional hubble-ui backend volumeMounts.

hubble.ui.backend.extraVolumes

Additional hubble-ui backend volumes.

hubble.ui.backend.image

Hubble-ui backend image.

{"digest":"sha256:db1454e45dc39ca41fbf7cad31eec95d99e5b9949c39daaad0fa81ef29d56953","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/hubble-ui-backend","tag":"v0.13.3","useDigest":true}

hubble.ui.backend.livenessProbe.enabled

Enable liveness probe for Hubble-ui backend (requires Hubble-ui 0.12+)

hubble.ui.backend.readinessProbe.enabled

Enable readiness probe for Hubble-ui backend (requires Hubble-ui 0.12+)

hubble.ui.backend.resources

Resource requests and limits for the ‘backend’ container of the ‘hubble-ui’ deployment.

hubble.ui.backend.securityContext

Hubble-ui backend security context.

{"allowPrivilegeEscalation":false}

Defines base url prefix for all hubble-ui http requests. It needs to be changed in case if ingress for hubble-ui is configured under some sub-path. Trailing / is required for custom path, ex. /service-map/

Whether to enable the Hubble UI.

hubble.ui.frontend.extraEnv

Additional hubble-ui frontend environment variables.

hubble.ui.frontend.extraVolumeMounts

Additional hubble-ui frontend volumeMounts.

hubble.ui.frontend.extraVolumes

Additional hubble-ui frontend volumes.

hubble.ui.frontend.image

Hubble-ui frontend image.

{"digest":"sha256:661d5de7050182d495c6497ff0b007a7a1e379648e60830dd68c4d78ae21761d","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/hubble-ui","tag":"v0.13.3","useDigest":true}

hubble.ui.frontend.resources

Resource requests and limits for the ‘frontend’ container of the ‘hubble-ui’ deployment.

hubble.ui.frontend.securityContext

Hubble-ui frontend security context.

{"allowPrivilegeEscalation":false}

hubble.ui.frontend.server.ipv6

Controls server listener for ipv6

hubble-ui ingress configuration.

{"annotations":{},"className":"","enabled":false,"hosts":["chart-example.local"],"labels":{},"tls":[]}

Additional labels to be added to ‘hubble-ui’ deployment object

hubble.ui.nodeSelector

Node labels for pod assignment ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

{"kubernetes.io/os":"linux"}

hubble.ui.podAnnotations

Annotations to be added to hubble-ui pods

hubble.ui.podDisruptionBudget.enabled

enable PodDisruptionBudget ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/

hubble.ui.podDisruptionBudget.maxUnavailable

Maximum number/percentage of pods that may be made unavailable

hubble.ui.podDisruptionBudget.minAvailable

Minimum number/percentage of pods that should remain scheduled. When it’s set, maxUnavailable must be disabled by maxUnavailable: null

hubble.ui.podDisruptionBudget.unhealthyPodEvictionPolicy

How are unhealthy, but running, pods counted for eviction

Labels to be added to hubble-ui pods

hubble.ui.priorityClassName

The priority class to use for hubble-ui

The number of replicas of Hubble UI to deploy.

hubble.ui.rollOutPods

Roll out Hubble-ui pods automatically when configmap is updated.

hubble.ui.securityContext

Security context to be added to Hubble UI pods

{"fsGroup":1001,"runAsGroup":1001,"runAsUser":1001}

hubble-ui service configuration.

{"annotations":{},"labels":{},"nodePort":31235,"type":"ClusterIP"}

hubble.ui.service.annotations

Annotations to be added for the Hubble UI service

hubble.ui.service.labels

Labels to be added for the Hubble UI service

hubble.ui.service.nodePort

The port to use when the service type is set to NodePort.

hubble.ui.service.type

The type of service used for Hubble UI access, either ClusterIP or NodePort.

hubble.ui.standalone.enabled

When true, it will allow installing the Hubble UI only, without checking dependencies. It is useful if a cluster already has cilium and Hubble relay installed and you just want Hubble UI to be deployed. When installed via helm, installing UI should be done via helm upgrade and when installed via the cilium cli, then cilium hubble enable --ui

hubble.ui.standalone.tls.certsVolume

When deploying Hubble UI in standalone, with tls enabled for Hubble relay, it is required to provide a volume for mounting the client certificates.

hubble.ui.tls.client.cert

base64 encoded PEM values for the Hubble UI client certificate (deprecated). Use existingSecret instead.

hubble.ui.tls.client.existingSecret

Name of the Secret containing the client certificate and key for Hubble UI If specified, cert and key are ignored.

hubble.ui.tls.client.key

base64 encoded PEM values for the Hubble UI client key (deprecated). Use existingSecret instead.

hubble.ui.tolerations

Node tolerations for pod assignment on nodes with taints ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

hubble.ui.topologySpreadConstraints

Pod topology spread constraints for hubble-ui

hubble.ui.updateStrategy

hubble-ui update strategy.

{"rollingUpdate":{"maxUnavailable":1},"type":"RollingUpdate"}

identityAllocationMode

Method to use for identity allocation (crd, kvstore or doublewrite-readkvstore / doublewrite-readcrd for migrating between identity backends).

identityChangeGracePeriod

Time to wait before using new identity on endpoint identity change.

identityManagementMode

Control whether CiliumIdentities are created by the agent (“agent”), the operator (“operator”) or both (“both”). “Both” should be used only to migrate between “agent” and “operator”. Operator-managed identities is a beta feature.

Agent container image.

{"digest":"","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/cilium","tag":"v1.18.5","useDigest":false}

Configure image pull secrets for pulling container images

ingressController.default

Set cilium ingress controller to be the default ingress controller This will let cilium ingress controller route entries without ingress class set

ingressController.defaultSecretName

Default secret name for ingresses without .spec.tls[].secretName set.

ingressController.defaultSecretNamespace

Default secret namespace for ingresses without .spec.tls[].secretName set.

ingressController.enableProxyProtocol

Enable proxy protocol for all Ingress listeners. Note that only Proxy protocol traffic will be accepted once this is enabled.

ingressController.enabled

Enable cilium ingress controller This will automatically set enable-envoy-config as well.

ingressController.enforceHttps

Enforce https for host having matching TLS host in Ingress. Incoming traffic to http listener will return 308 http error code with respective location in header.

ingressController.hostNetwork.enabled

Configure whether the Envoy listeners should be exposed on the host network.

ingressController.hostNetwork.nodes.matchLabels

Specify the labels of the nodes where the Ingress listeners should be exposed matchLabels: kubernetes.io/os: linux kubernetes.io/hostname: kind-worker

ingressController.hostNetwork.sharedListenerPort

Configure a specific port on the host network that gets used for the shared listener.

ingressController.ingressLBAnnotationPrefixes

IngressLBAnnotations are the annotation and label prefixes, which are used to filter annotations and/or labels to propagate from Ingress to the Load Balancer service

["lbipam.cilium.io","nodeipam.cilium.io","service.beta.kubernetes.io","service.kubernetes.io","cloud.google.com"]

ingressController.loadbalancerMode

Default ingress load balancer mode Supported values: shared, dedicated For granular control, use the following annotations on the ingress resource: “ingress.cilium.io/loadbalancer-mode: dedicated” (or “shared”).

ingressController.secretsNamespace

SecretsNamespace is the namespace in which envoy SDS will retrieve TLS secrets from.

{"create":true,"name":"cilium-secrets","sync":true}

ingressController.secretsNamespace.create

Create secrets namespace for Ingress.

ingressController.secretsNamespace.name

Name of Ingress secret namespace.

ingressController.secretsNamespace.sync

Enable secret sync, which will make sure all TLS secrets used by Ingress are synced to secretsNamespace.name. If disabled, TLS secrets must be maintained externally.

ingressController.service

Load-balancer service in shared mode. This is a single load-balancer service for all Ingress resources.

{"allocateLoadBalancerNodePorts":null,"annotations":{},"externalTrafficPolicy":"Cluster","insecureNodePort":null,"labels":{},"loadBalancerClass":null,"loadBalancerIP":null,"name":"cilium-ingress","secureNodePort":null,"type":"LoadBalancer"}

ingressController.service.allocateLoadBalancerNodePorts

Configure if node port allocation is required for LB service ref: https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-nodeport-allocation

ingressController.service.annotations

Annotations to be added for the shared LB service

ingressController.service.externalTrafficPolicy

Control how traffic from external sources is routed to the LoadBalancer Kubernetes Service for Cilium Ingress in shared mode. Valid values are “Cluster” and “Local”. ref: https://kubernetes.io/docs/reference/networking/virtual-ips/#external-traffic-policy

ingressController.service.insecureNodePort

Configure a specific nodePort for insecure HTTP traffic on the shared LB service

ingressController.service.labels

Labels to be added for the shared LB service

ingressController.service.loadBalancerClass

Configure a specific loadBalancerClass on the shared LB service (requires Kubernetes 1.24+)

ingressController.service.loadBalancerIP

Configure a specific loadBalancerIP on the shared LB service

ingressController.service.name

ingressController.service.secureNodePort

Configure a specific nodePort for secure HTTPS traffic on the shared LB service

ingressController.service.type

Service type for the shared LB service

resources & limits for the agent init containers

installNoConntrackIptablesRules

Install Iptables rules to skip netfilter connection tracking on all pod traffic. This option is only effective when Cilium is running in direct routing and full KPR mode. Moreover, this option cannot be enabled when Cilium is running in a managed Kubernetes environment or in a chained CNI setup.

Configure the eBPF-based ip-masq-agent

ipam.ciliumNodeUpdateRate

Maximum rate at which the CiliumNode custom resource is updated.

ipam.installUplinkRoutesForDelegatedIPAM

Install ingress/egress routes through uplink on host for Pods when working with delegated IPAM plugin.

Configure IP Address Management mode. ref: https://docs.cilium.io/en/stable/network/concepts/ipam/

ipam.multiPoolPreAllocation

Pre-allocation settings for IPAM in Multi-Pool mode

ipam.operator.autoCreateCiliumPodIPPools

IP pools to auto-create in multi-pool IPAM mode.

ipam.operator.clusterPoolIPv4MaskSize

IPv4 CIDR mask size to delegate to individual nodes for IPAM.

ipam.operator.clusterPoolIPv4PodCIDRList

IPv4 CIDR list range to delegate to individual nodes for IPAM.

ipam.operator.clusterPoolIPv6MaskSize

IPv6 CIDR mask size to delegate to individual nodes for IPAM.

ipam.operator.clusterPoolIPv6PodCIDRList

IPv6 CIDR list range to delegate to individual nodes for IPAM.

ipam.operator.externalAPILimitBurstSize

The maximum burst size when rate limiting access to external APIs. Also known as the token bucket capacity.

ipam.operator.externalAPILimitQPS

The maximum queries per second when rate limiting access to external APIs. Also known as the bucket refill rate, which is used to refill the bucket up to the burst size capacity.

Configure iptables–random-fully. Disabled by default. View https://github.com/cilium/cilium/issues/13037 for more information.

ipv4NativeRoutingCIDR

Allows to explicitly specify the IPv4 CIDR for native routing. When specified, Cilium assumes networking for this CIDR is preconfigured and hands traffic destined for that range to the Linux network stack without applying any SNAT. Generally speaking, specifying a native routing CIDR implies that Cilium can depend on the underlying networking stack to route packets to their destination. To offer a concrete example, if Cilium is configured to use direct routing and the Kubernetes CIDR is included in the native routing CIDR, the user must configure the routes to reach pods, either manually or by setting the auto-direct-node-routes flag.

ipv6NativeRoutingCIDR

Allows to explicitly specify the IPv6 CIDR for native routing. When specified, Cilium assumes networking for this CIDR is preconfigured and hands traffic destined for that range to the Linux network stack without applying any SNAT. Generally speaking, specifying a native routing CIDR implies that Cilium can depend on the underlying networking stack to route packets to their destination. To offer a concrete example, if Cilium is configured to use direct routing and the Kubernetes CIDR is included in the native routing CIDR, the user must configure the routes to reach pods, either manually or by setting the auto-direct-node-routes flag.

Configure Kubernetes specific configuration

{"requireIPv4PodCIDR":false,"requireIPv6PodCIDR":false}

k8s.requireIPv4PodCIDR

requireIPv4PodCIDR enables waiting for Kubernetes to provide the PodCIDR range via the Kubernetes node resource

k8s.requireIPv6PodCIDR

requireIPv6PodCIDR enables waiting for Kubernetes to provide the PodCIDR range via the Kubernetes node resource

k8sClientExponentialBackoff

Configure exponential backoff for client-go in Cilium agent.

{"backoffBaseSeconds":1,"backoffMaxDurationSeconds":120,"enabled":true}

k8sClientExponentialBackoff.backoffBaseSeconds

Configure base (in seconds) for exponential backoff.

k8sClientExponentialBackoff.backoffMaxDurationSeconds

Configure maximum duration (in seconds) for exponential backoff.

k8sClientExponentialBackoff.enabled

Enable exponential backoff for client-go in Cilium agent.

Configure the client side rate limit for the agent If the amount of requests to the Kubernetes API server exceeds the configured rate limit, the agent will start to throttle requests by delaying them until there is budget or the request times out.

{"burst":null,"operator":{"burst":null,"qps":null},"qps":null}

k8sClientRateLimit.burst

The burst request rate in requests per second. The rate limiter will allow short bursts with a higher rate.

k8sClientRateLimit.operator

Configure the client side rate limit for the Cilium Operator

{"burst":null,"qps":null}

k8sClientRateLimit.operator.burst

The burst request rate in requests per second. The rate limiter will allow short bursts with a higher rate.

k8sClientRateLimit.operator.qps

The sustained request rate in requests per second.

k8sClientRateLimit.qps

The sustained request rate in requests per second.

k8sNetworkPolicy.enabled

Enable support for K8s NetworkPolicy

Kubernetes service host - use “auto” for automatic lookup from the cluster-info ConfigMap

Configure the Kubernetes service endpoint dynamically using a ConfigMap. Mutually exclusive with k8sServiceHost.

{"key":null,"name":null}

k8sServiceHostRef.key

Key in the ConfigMap containing the Kubernetes service endpoint

k8sServiceHostRef.name

name of the ConfigMap containing the Kubernetes service endpoint

k8sServiceLookupConfigMapName

When k8sServiceHost=auto, allows to customize the configMap name. It defaults to cluster-info.

k8sServiceLookupNamespace

When k8sServiceHost=auto, allows to customize the namespace that contains k8sServiceLookupConfigMapName. It defaults to kube-public.

Kubernetes service port

Keep the deprecated selector labels when deploying Cilium DaemonSet.

Keep the deprecated probes when deploying Cilium DaemonSet

Kubernetes config path

Configure the kube-proxy replacement in Cilium BPF datapath Valid options are “true” or “false”. ref: https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/ @schema@ type: [string, boolean] @schema@

kubeProxyReplacementHealthzBindAddr

healthz server bind address for the kube-proxy replacement. To enable set the value to ‘0.0.0.0:10256’ for all ipv4 addresses and this ‘[::]:10256’ for all ipv6 addresses. By default it is disabled.

l2NeighDiscovery.enabled

Enable L2 neighbor discovery in the agent

Configure L2 announcements

l2announcements.enabled

Enable L2 announcements

Configure L2 pod announcements

{"enabled":false,"interface":"eth0"}

l2podAnnouncements.enabled

Enable L2 pod announcements

l2podAnnouncements.interface

Interface used for sending Gratuitous ARP pod announcements

Enable Layer 7 network policy.

livenessProbe.failureThreshold

failure threshold of liveness probe

livenessProbe.periodSeconds

interval between checks of the liveness probe

livenessProbe.requireK8sConnectivity

whether to require k8s connectivity as part of the check.

Configure service load balancing

{"acceleration":"disabled","l7":{"algorithm":"round_robin","backend":"disabled","ports":[]}}

loadBalancer.acceleration

acceleration is the option to accelerate service handling via XDP Applicable values can be: disabled (do not use XDP), native (XDP BPF program is run directly out of the networking driver’s early receive path), or best-effort (use native mode XDP acceleration on devices that support it).

{"algorithm":"round_robin","backend":"disabled","ports":[]}

loadBalancer.l7.algorithm

Default LB algorithm The default LB algorithm to be used for services, which can be overridden by the service annotation (e.g. service.cilium.io/lb-l7-algorithm) Applicable values: round_robin, least_request, random

loadBalancer.l7.backend

Enable L7 service load balancing via envoy proxy. The request to a k8s service, which has specific annotation e.g. service.cilium.io/lb-l7, will be forwarded to the local backend proxy to be load balanced to the service endpoints. Please refer to docs for supported annotations for more configuration. Applicable values: - envoy: Enable L7 load balancing via envoy proxy. This will automatically set enable-envoy-config as well. - disabled: Disable L7 load balancing by way of service annotation.

loadBalancer.l7.ports

List of ports from service to be automatically redirected to above backend. Any service exposing one of these ports will be automatically redirected. Fine-grained control can be achieved by using the service annotation.

localRedirectPolicies.addressMatcherCIDRs

Limit the allowed addresses in Address Matcher rule of Local Redirect Policies to the given CIDRs. @schema@ type: [null, array] @schema@

localRedirectPolicies.enabled

Enable local redirect policies.

Enable Local Redirect Policy (deprecated, please use ‘localRedirectPolicies.enabled’ instead)

Enables periodic logging of system load

Configure maglev consistent hashing

cilium-monitor sidecar.

Enable the cilium-monitor sidecar.

Agent daemonset name.

namespaceOverride allows to override the destination namespace for Cilium resources. This property allows to use Cilium as part of an Umbrella Chart with different targets.

Number of the top-k SNAT map connections to track in Cilium statedb.

Interval between how often SNAT map is counted for stats.

Configure standalone NAT46/NAT64 gateway

nat46x64Gateway.enabled

Enable RFC6052-prefixed translation

Configure Node IPAM ref: https://docs.cilium.io/en/stable/network/node-ipam/

Configure N-S k8s service loadbalancing

{"addresses":null,"autoProtectPortRange":true,"bindProtection":true,"enableHealthCheck":true,"enableHealthCheckLoadBalancerIP":false,"enabled":false}

List of CIDRs for choosing which IP addresses assigned to native devices are used for NodePort load-balancing. By default this is empty and the first suitable, preferably private, IPv4 and IPv6 address assigned to each device is used. Example: addresses: [“192.168.1.0/24”, “2001::/64”]

nodePort.autoProtectPortRange

Append NodePort range to ip_local_reserved_ports if clash with ephemeral ports is detected.

nodePort.bindProtection

Set to true to prevent applications binding to service ports.

nodePort.enableHealthCheck

Enable healthcheck nodePort server for NodePort services

nodePort.enableHealthCheckLoadBalancerIP

Enable access of the healthcheck nodePort on the LoadBalancerIP. Needs EnableHealthCheck to be enabled

Enable the Cilium NodePort service implementation.

Node selector for cilium-agent.

{"kubernetes.io/os":"linux"}

Enable/Disable use of node label based identity

Affinity for cilium-nodeinit

Annotations to be added to all top-level nodeinit objects (resources under templates/cilium-nodeinit)

nodeinit.bootstrapFile

bootstrapFile is the location of the file where the bootstrap timestamp is written by the node-init DaemonSet

"/tmp/cilium-bootstrap.d/cilium-bootstrap-time"

Enable the node initialization DaemonSet

Additional nodeinit environment variables.

nodeinit.extraVolumeMounts

Additional nodeinit volumeMounts.

nodeinit.extraVolumes

Additional nodeinit volumes.

{"digest":"sha256:5bdca3c2dec2c79f58d45a7a560bf1098c2126350c901379fe850b7f78d3d757","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/startup-script","tag":"1755531540-60ee83e","useDigest":true}

nodeinit.nodeSelector

Node labels for nodeinit pod assignment ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

{"kubernetes.io/os":"linux"}

nodeinit.podAnnotations

Annotations to be added to node-init pods.

Labels to be added to node-init pods.

nodeinit.podSecurityContext

Security Context for cilium-node-init pods.

{"appArmorProfile":{"type":"Unconfined"}}

nodeinit.podSecurityContext.appArmorProfile

AppArmorProfile options for the cilium-node-init and init containers

{"type":"Unconfined"}

prestop offers way to customize prestop nodeinit script (pre and post position)

{"postScript":"","preScript":""}

nodeinit.priorityClassName

The priority class to use for the nodeinit pod.

nodeinit resource limits & requests ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

{"requests":{"cpu":"100m","memory":"100Mi"}}

nodeinit.securityContext

Security context to be added to nodeinit pods.

{"allowPrivilegeEscalation":false,"capabilities":{"add":["SYS_MODULE","NET_ADMIN","SYS_ADMIN","SYS_CHROOT","SYS_PTRACE"]},"privileged":false,"seLinuxOptions":{"level":"s0","type":"spc_t"}}

startup offers way to customize startup nodeinit script (pre and post position)

{"postScript":"","preScript":""}

Node tolerations for nodeinit scheduling to nodes with taints ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

[{"operator":"Exists"}]

nodeinit.updateStrategy

node-init update strategy

{"type":"RollingUpdate"}

Affinity for cilium-operator

{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"io.cilium/app":"operator"}},"topologyKey":"kubernetes.io/hostname"}]}}

Annotations to be added to all top-level cilium-operator objects (resources under templates/cilium-operator)

Grafana dashboards for cilium-operator grafana can import dashboards based on the label and value ref: https://github.com/grafana/helm-charts/tree/main/charts/grafana#sidecar-for-dashboards

{"annotations":{},"enabled":false,"label":"grafana_dashboard","labelValue":"1","namespace":null}

DNS policy for Cilium operator pods. Ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy

Enable the cilium-operator component (required).

operator.endpointGCInterval

Interval for endpoint garbage collection.

Additional cilium-operator container arguments.

Additional cilium-operator environment variables.

operator.extraHostPathMounts

Additional cilium-operator hostPath mounts.

operator.extraVolumeMounts

Additional cilium-operator volumeMounts.

operator.extraVolumes

Additional cilium-operator volumes.

operator.identityGCInterval

Interval for identity garbage collection.

operator.identityHeartbeatTimeout

Timeout for identity heartbeats.

cilium-operator image.

{"alibabacloudDigest":"","awsDigest":"","azureDigest":"","genericDigest":"","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/operator","suffix":"","tag":"v1.18.5","useDigest":false}

operator.nodeGCInterval

Interval for cilium node garbage collection.

operator.nodeSelector

Node labels for cilium-operator pod assignment ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

{"kubernetes.io/os":"linux"}

operator.podAnnotations

Annotations to be added to cilium-operator pods

operator.podDisruptionBudget.enabled

enable PodDisruptionBudget ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/

operator.podDisruptionBudget.maxUnavailable

Maximum number/percentage of pods that may be made unavailable

operator.podDisruptionBudget.minAvailable

Minimum number/percentage of pods that should remain scheduled. When it’s set, maxUnavailable must be disabled by maxUnavailable: null

operator.podDisruptionBudget.unhealthyPodEvictionPolicy

How are unhealthy, but running, pods counted for eviction

Labels to be added to cilium-operator pods

operator.podSecurityContext

Security context to be added to cilium-operator pods

{"seccompProfile":{"type":"RuntimeDefault"}}

operator.pprof.address

Configure pprof listen address for cilium-operator

operator.pprof.enabled

Enable pprof for cilium-operator

Configure pprof listen port for cilium-operator

operator.priorityClassName

The priority class to use for cilium-operator

Enable prometheus metrics for cilium-operator on the configured port at /metrics

{"enabled":true,"metricsService":false,"port":9963,"serviceMonitor":{"annotations":{},"enabled":false,"interval":"10s","jobLabel":"","labels":{},"metricRelabelings":null,"relabelings":null,"scrapeTimeout":null}}

operator.prometheus.serviceMonitor.annotations

Annotations to add to ServiceMonitor cilium-operator

operator.prometheus.serviceMonitor.enabled

Enable service monitors. This requires the prometheus CRDs to be available (see https://github.com/prometheus-operator/prometheus-operator/blob/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml)

operator.prometheus.serviceMonitor.interval

Interval for scrape metrics.

operator.prometheus.serviceMonitor.jobLabel

jobLabel to add for ServiceMonitor cilium-operator

operator.prometheus.serviceMonitor.labels

Labels to add to ServiceMonitor cilium-operator

operator.prometheus.serviceMonitor.metricRelabelings

Metrics relabeling configs for the ServiceMonitor cilium-operator

operator.prometheus.serviceMonitor.relabelings

Relabeling configs for the ServiceMonitor cilium-operator

operator.prometheus.serviceMonitor.scrapeTimeout

Timeout after which scrape is considered to be failed.

operator.removeNodeTaints

Remove Cilium node taint from Kubernetes nodes that have a healthy Cilium pod running.

Number of replicas to run for the cilium-operator deployment

cilium-operator resource limits & requests ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

Roll out cilium-operator pods automatically when configmap is updated.

operator.securityContext

Security context to be added to cilium-operator pods

{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}

operator.setNodeNetworkStatus

Set Node condition NetworkUnavailable to ‘false’ with the reason ‘CiliumIsUp’ for nodes that have a healthy Cilium pod.

operator.setNodeTaints

Taint nodes where Cilium is scheduled but not running. This prevents pods from being scheduled to nodes where Cilium is not the default CNI provider.

same as removeNodeTaints

operator.skipCRDCreation

Skip CRDs creation for cilium-operator

Node tolerations for cilium-operator scheduling to nodes with taints ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ Toleration for agentNotReadyTaintKey taint is always added to cilium-operator pods. @schema type: [null, array] @schema

[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists"},{"key":"node-role.kubernetes.io/master","operator":"Exists"},{"key":"node.kubernetes.io/not-ready","operator":"Exists"},{"key":"node.cloudprovider.kubernetes.io/uninitialized","operator":"Exists"}]

operator.topologySpreadConstraints

Pod topology spread constraints for cilium-operator

operator.unmanagedPodWatcher.intervalSeconds

Interval, in seconds, to check if there are any pods that are not managed by Cilium.

operator.unmanagedPodWatcher.restart

Restart any pod that are not managed by Cilium.

operator.updateStrategy

cilium-operator update strategy

{"rollingUpdate":{"maxSurge":"25%","maxUnavailable":"50%"},"type":"RollingUpdate"}

pmtuDiscovery.enabled

Enable path MTU discovery to send ICMP fragmentation-needed replies to the client.

Annotations to be added to agent pods

Labels to be added to agent pods

Security Context for cilium-agent pods.

{"appArmorProfile":{"type":"Unconfined"},"seccompProfile":{"type":"Unconfined"}}

podSecurityContext.appArmorProfile

AppArmorProfile options for the cilium-agent and init containers

{"type":"Unconfined"}

policyCIDRMatchMode is a list of entities that may be selected by CIDR selector. The possible value is “nodes”.

policyEnforcementMode

The agent can be put into one of the three policy enforcement modes: default, always and never. ref: https://docs.cilium.io/en/stable/security/policy/intro/#policy-enforcement-modes

Configure pprof listen address for cilium-agent

Enable pprof for cilium-agent

Configure pprof listen port for cilium-agent

Affinity for cilium-preflight

{"podAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"k8s-app":"cilium"}},"topologyKey":"kubernetes.io/hostname"}]}}

preflight.annotations

Annotations to be added to all top-level preflight objects (resources under templates/cilium-preflight)

Enable Cilium pre-flight resources (required for upgrade)

preflight.envoy.image

Envoy pre-flight image.

{"digest":"sha256:3108521821c6922695ff1f6ef24b09026c94b195283f8bfbfc0fa49356a156e1","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/cilium-envoy","tag":"v1.34.12-1765374555-6a93b0bbba8d6dc75b651cbafeedb062b2997716","useDigest":true}

Additional preflight environment variables.

preflight.extraVolumeMounts

Additional preflight volumeMounts.

preflight.extraVolumes

Additional preflight volumes.

Cilium pre-flight image.

{"digest":"","override":null,"pullPolicy":"IfNotPresent","repository":"quay.io/cilium/cilium","tag":"v1.18.5","useDigest":false}

preflight.nodeSelector

Node labels for preflight pod assignment ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

{"kubernetes.io/os":"linux"}

preflight.podAnnotations

Annotations to be added to preflight pods

preflight.podDisruptionBudget.enabled

enable PodDisruptionBudget ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/

preflight.podDisruptionBudget.maxUnavailable

Maximum number/percentage of pods that may be made unavailable

preflight.podDisruptionBudget.minAvailable

Minimum number/percentage of pods that should remain scheduled. When it’s set, maxUnavailable must be disabled by maxUnavailable: null

preflight.podDisruptionBudget.unhealthyPodEvictionPolicy

How are unhealthy, but running, pods counted for eviction

Labels to be added to the preflight pod.

preflight.podSecurityContext

Security context to be added to preflight pods.

preflight.priorityClassName

The priority class to use for the preflight pod.

preflight.readinessProbe.initialDelaySeconds

For how long kubelet should wait before performing the first probe

preflight.readinessProbe.periodSeconds

interval between checks of the readiness probe

preflight resource limits & requests ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

preflight.securityContext

Security context to be added to preflight pods

{"allowPrivilegeEscalation":false}

preflight.terminationGracePeriodSeconds

Configure termination grace period for preflight Deployment and DaemonSet.

preflight.tofqdnsPreCache

Path to write the --tofqdns-pre-cache file to.

preflight.tolerations

Node tolerations for preflight scheduling to nodes with taints ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

[{"operator":"Exists"}]

preflight.updateStrategy

preflight update strategy

{"type":"RollingUpdate"}

preflight.validateCNPs

By default we should always validate the installed CNPs before upgrading Cilium. This will make sure the user will have the policies deployed in the cluster with the right schema.

The priority class to use for cilium-agent.

Configure prometheus metrics on the configured port at /metrics

{"controllerGroupMetrics":["write-cni-file","sync-host-ips","sync-lb-maps-with-k8s-services"],"enabled":false,"metrics":null,"metricsService":false,"port":9962,"serviceMonitor":{"annotations":{},"enabled":false,"interval":"10s","jobLabel":"","labels":{},"metricRelabelings":null,"relabelings":[{"action":"replace","replacement":"${1}","sourceLabels":["__meta_kubernetes_pod_node_name"],"targetLabel":"node"}],"scrapeTimeout":null,"trustCRDsExist":false}}

prometheus.controllerGroupMetrics

Enable controller group metrics for monitoring specific Cilium subsystems. The list is a list of controller group names. The special values of “all” and “none” are supported. The set of controller group names is not guaranteed to be stable between Cilium versions.

["write-cni-file","sync-host-ips","sync-lb-maps-with-k8s-services"]

Metrics that should be enabled or disabled from the default metric list. The list is expected to be separated by a space. (+metric_foo to enable metric_foo , -metric_bar to disable metric_bar). ref: https://docs.cilium.io/en/stable/observability/metrics/

prometheus.serviceMonitor.annotations

Annotations to add to ServiceMonitor cilium-agent

prometheus.serviceMonitor.enabled

Enable service monitors. This requires the prometheus CRDs to be available (see https://github.com/prometheus-operator/prometheus-operator/blob/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml)

prometheus.serviceMonitor.interval

Interval for scrape metrics.

prometheus.serviceMonitor.jobLabel

jobLabel to add for ServiceMonitor cilium-agent

prometheus.serviceMonitor.labels

Labels to add to ServiceMonitor cilium-agent

prometheus.serviceMonitor.metricRelabelings

Metrics relabeling configs for the ServiceMonitor cilium-agent

prometheus.serviceMonitor.relabelings

Relabeling configs for the ServiceMonitor cilium-agent

[{"action":"replace","replacement":"${1}","sourceLabels":["__meta_kubernetes_pod_node_name"],"targetLabel":"node"}]

prometheus.serviceMonitor.scrapeTimeout

Timeout after which scrape is considered to be failed.

prometheus.serviceMonitor.trustCRDsExist

Set to true and helm will not check for monitoring.coreos.com/v1 CRDs before deploying

Enable creation of Resource-Based Access Control configuration.

readinessProbe.failureThreshold

failure threshold of readiness probe

readinessProbe.periodSeconds

interval between checks of the readiness probe

Enable resource quotas for priority classes used in the cluster.

{"cilium":{"hard":{"pods":"10k"}},"enabled":false,"operator":{"hard":{"pods":"15"}}}

Agent resource limits & requests ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

Roll out cilium agent pods automatically when configmap is updated.

Enable native-routing mode or tunneling mode. Possible values: - “” - native - tunnel

Scheduling configurations for cilium pods

{"mode":"anti-affinity"}

Mode specifies how Cilium daemonset pods should be scheduled to Nodes. anti-affinity mode applies a pod anti-affinity rule to the cilium daemonset. Pod anti-affinity may significantly impact scheduling throughput for large clusters. See: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity kube-scheduler mode forgoes the anti-affinity rule for full scheduling throughput. Kube-scheduler avoids host port conflict when scheduling pods.

Defaults to apply a pod anti-affinity rule to the agent pod - anti-affinity

SCTP Configuration Values

Enable SCTP support. NOTE: Currently, SCTP support does not support rewriting ports or multihoming.

secretsNamespaceAnnotations

Annotations to be added to all cilium-secret namespaces (resources under templates/cilium-secrets-namespace)

securityContext.allowPrivilegeEscalation

disable privilege escalation

securityContext.capabilities.applySysctlOverwrites

capabilities for the apply-sysctl-overwrites init container

["SYS_ADMIN","SYS_CHROOT","SYS_PTRACE"]

securityContext.capabilities.ciliumAgent

Capabilities for the cilium-agent container

["CHOWN","KILL","NET_ADMIN","NET_RAW","IPC_LOCK","SYS_MODULE","SYS_ADMIN","SYS_RESOURCE","DAC_OVERRIDE","FOWNER","SETGID","SETUID"]

securityContext.capabilities.cleanCiliumState

Capabilities for the clean-cilium-state init container

["NET_ADMIN","SYS_MODULE","SYS_ADMIN","SYS_RESOURCE"]

securityContext.capabilities.mountCgroup

Capabilities for the mount-cgroup init container

["SYS_ADMIN","SYS_CHROOT","SYS_PTRACE"]

securityContext.privileged

Run the pod with elevated privileges

securityContext.seLinuxOptions

SELinux options for the cilium-agent and init containers

{"level":"s0","type":"spc_t"}

Define serviceAccount names for components.

Component’s fully qualified name.

serviceAccounts.clustermeshcertgen

Clustermeshcertgen is used if clustermesh.apiserver.tls.auto.method=cronJob

{"annotations":{},"automount":true,"create":true,"name":"clustermesh-apiserver-generate-certs"}

serviceAccounts.hubblecertgen

Hubblecertgen is used if hubble.tls.auto.method=cronJob

{"annotations":{},"automount":true,"create":true,"name":"hubble-generate-certs"}

serviceAccounts.nodeinit.enabled

Enabled is temporary until https://github.com/cilium/cilium-cli/issues/1396 is implemented. Cilium CLI doesn’t create the SAs for node-init, thus the workaround. Helm is not affected by this issue. Name and automount can be configured, if enabled is set to true. Otherwise, they are ignored. Enabled can be removed once the issue is fixed. Cilium-nodeinit DS must also be fixed.

serviceNoBackendResponse

Configure what the response should be to traffic for a service without backends. Possible values: - reject (default) - drop

Do not run Cilium agent when running with clean mode. Useful to completely uninstall Cilium as it will stop Cilium from starting and create artifacts in the node.

startupProbe.failureThreshold

failure threshold of startup probe. Allow Cilium to take up to 600s to start up (300 attempts with 2s between attempts).

startupProbe.periodSeconds

interval between checks of the startup probe

Enable check of service source ranges (currently, only for LoadBalancer).

Synchronize Kubernetes nodes to kvstore and perform CNP GC.

Configure sysctl override described in #20072.

Enable the sysctl override. When enabled, the init container will mount the /proc of the host so that the sysctlfix utility can execute.

terminationGracePeriodSeconds

Configure termination grace period for cilium-agent DaemonSet.

Configure TLS configuration in the agent.

{"ca":{"cert":"","certValidityDuration":1095,"key":""},"caBundle":{"enabled":false,"key":"ca.crt","name":"cilium-root-ca.crt","useSecret":false},"readSecretsOnlyFromSecretsNamespace":null,"secretSync":{"enabled":null},"secretsBackend":null,"secretsNamespace":{"create":true,"name":"cilium-secrets"}}

Base64 encoded PEM values for the CA certificate and private key. This can be used as common CA to generate certificates used by hubble and clustermesh components. It is neither required nor used when cert-manager is used to generate the certificates.

{"cert":"","certValidityDuration":1095,"key":""}

Optional CA cert. If it is provided, it will be used by cilium to generate all other certificates. Otherwise, an ephemeral CA is generated.

tls.ca.certValidityDuration

Generated certificates validity duration in days. This will be used for auto generated CA.

Optional CA private key. If it is provided, it will be used by cilium to generate all other certificates. Otherwise, an ephemeral CA is generated.

Configure the CA trust bundle used for the validation of the certificates leveraged by hubble and clustermesh. When enabled, it overrides the content of the ‘ca.crt’ field of the respective certificates, allowing for CA rotation with no down-time.

{"enabled":false,"key":"ca.crt","name":"cilium-root-ca.crt","useSecret":false}

Enable the use of the CA trust bundle.

Entry of the ConfigMap containing the CA trust bundle.

Name of the ConfigMap containing the CA trust bundle.

tls.caBundle.useSecret

Use a Secret instead of a ConfigMap.

tls.readSecretsOnlyFromSecretsNamespace

Configure if the Cilium Agent will only look in tls.secretsNamespace for CiliumNetworkPolicy relevant Secrets. If false, the Cilium Agent will be granted READ (GET/LIST/WATCH) access to all secrets in the entire cluster. This is not recommended and is included for backwards compatibility. This value obsoletes tls.secretsBackend, with true == local in the old setting, and false == k8s.

Configures settings for synchronization of TLS Interception Secrets

tls.secretSync.enabled

Enable synchronization of Secrets for TLS Interception. If disabled and tls.readSecretsOnlyFromSecretsNamespace is set to ‘false’, then secrets will be read directly by the agent.

This configures how the Cilium agent loads the secrets used TLS-aware CiliumNetworkPolicies (namely the secrets referenced by terminatingTLS and originatingTLS). This value is DEPRECATED and will be removed in a future version. Use tls.readSecretsOnlyFromSecretsNamespace instead. Possible values: - local - k8s

Configures where secrets used in CiliumNetworkPolicies will be looked for

{"create":true,"name":"cilium-secrets"}

tls.secretsNamespace.create

Create secrets namespace for TLS Interception secrets.

tls.secretsNamespace.name

Name of TLS Interception secret namespace.

Node tolerations for agent scheduling to nodes with taints ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

[{"operator":"Exists"}]

Configure VXLAN and Geneve tunnel port.

Port 8472 for VXLAN, Port 6081 for Geneve

Tunneling protocol to use in tunneling mode and for ad-hoc tunnels. Possible values: - “” - vxlan - geneve

tunnelSourcePortRange

Configure VXLAN and Geneve tunnel source port range hint.

0-0 to let the kernel driver decide the range

IP family for the underlay.

Cilium agent update strategy

{"rollingUpdate":{"maxUnavailable":2},"type":"RollingUpdate"}

upgradeCompatibility helps users upgrading to ensure that the configMap for Cilium will not change critical values to ensure continued operation This flag is not required for new installations. For example: ‘1.7’, ‘1.8’, ‘1.9’

A space separated list of VTEP device CIDRs, for example “1.1.1.0/24 1.1.2.0/24”

Enables VXLAN Tunnel Endpoint (VTEP) Integration (beta) to allow Cilium-managed pods to talk to third party VTEP devices over Cilium tunnel.

A space separated list of VTEP device endpoint IPs, for example “1.1.1.1 1.1.2.1”

A space separated list of VTEP device MAC addresses (VTEP MAC), for example “x:x:x:x:x:x y:y:y:y:y:y:y”

VTEP CIDRs Mask that applies to all VTEP CIDRs, for example “255.255.255.0”

Wait for KUBE-PROXY-CANARY iptables rule to appear in “wait-for-kube-proxy” init container before launching cilium-agent. More context can be found in the commit message of below PR https://github.com/cilium/cilium/pull/20123

wellKnownIdentities.enabled

Enable the use of well-known identities.

---

## Protocol Documentation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/_api/v1/recorder/README/

**Contents:**
- Protocol Documentation
- Table of Contents
- recorder/recorder.proto
  - FileSinkConfiguration
  - FileSinkResult
  - Filter
  - RecordRequest
  - RecordResponse
  - RecordingRunningResponse
  - RecordingStatistics

recorder/recorder.proto

FileSinkConfiguration

RecordingRunningResponse

RecordingStoppedResponse

FileSinkConfiguration configures the file output. Possible future additions might be the selection of the output volume. The initial implementation will only support a single volume which is configured as a cilium-agent CLI flag.

file_prefix is an optional prefix for the file name. Defaults to hubble if empty. Must match the following regex if not empty: ^[a-z][a-z0-9]{0,19}$ The generated filename will be of format <file_prefix><unixtime><unique_random>_<node_name>.pcap

file_path is the absolute path to the captured pcap file

source_cidr. Must not be empty. Set to 0.0.0.0/0 to match any IPv4 source address (::/0 for IPv6).

source_port. Matches any source port if empty.

destination_cidr. Must not be empty. Set to 0.0.0.0/0 to match any IPv4 destination address (::/0 for IPv6).

destination_port. Matches any destination port if empty.

protocol. Matches any protocol if empty.

start starts a new recording with the given parameters.

stop stops the running recording.

name of the node where this recording is happening

google.protobuf.Timestamp

time at which this event was observed on the above node

RecordingRunningResponse

running means that the recording is capturing packets. This is emitted in regular intervals

RecordingStoppedResponse

stopped means the recording has stopped

stats for the running recording

bytes_captured is the total amount of bytes captured in the recording

packets_captured is the total amount of packets captured the recording

packets_lost is the total amount of packets matching the filter during the recording, but never written to the sink because it was overloaded.

bytes_lost is the total amount of bytes matching the filter during the recording, but never written to the sink because it was overloaded.

stats for the recording

filesink contains the path to the captured file

FileSinkConfiguration

filesink configures the outfile of this recording Future alternative sink configurations may be added as a backwards-compatible change by moving this field into a oneof.

include list for this recording. Packets matching any of the provided filters will be recorded.

max_capture_length specifies the maximum packet length. Full packet length will be captured if absent/zero.

stop_condition defines conditions which will cause the recording to stop early after any of the stop conditions has been hit

StopCondition defines one or more conditions which cause the recording to stop after they have been hit. Stop conditions are ignored if they are absent or zero-valued. If multiple conditions are defined, the recording stops after the first one is hit.

bytes_captured_count stops the recording after at least this many bytes have been captured. Note: The resulting file might be slightly larger due to added pcap headers.

packets_captured_count

packets_captured_count stops the recording after at least this many packets have been captured.

google.protobuf.Duration

time_elapsed stops the recording after this duration has elapsed.

Protocol is a one of the supported protocols for packet capture

Recorder implements the Hubble module for capturing network packets

RecordResponse stream

Record can start and stop a single recording. The recording is automatically stopped if the client aborts this rpc call.

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead.

Bignum or Fixnum (as required)

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead.

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s.

Always four bytes. More efficient than uint32 if values are often greater than 2^28.

Bignum or Fixnum (as required)

Always eight bytes. More efficient than uint64 if values are often greater than 2^56.

Bignum or Fixnum (as required)

A string must always contain UTF-8 encoded or 7-bit ASCII text.

May contain any arbitrary sequence of bytes.

---

## XFRM Reference Guide — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/reference-guides/xfrm/

**Contents:**
- XFRM Reference Guide
- Overview
  - XFRM Policies and States
  - Policy Templates
- XFRM Packet Flows
  - Egress Packet Flow
  - Ingress Packet Flow
- Output Description of ip xfrm
- XFRM Errors
- Performance Considerations

This documentation section is targeted at developers and users who want to understand the Linux XFRM subsystem. While reading this reference guide may help broaden your understanding of Cilium, it is not a requirement to use Cilium. Please refer to the Getting Started guide and eBPF Datapath for a higher level introduction.

IPsec encryption in the Linux kernel relies on XFRM. XFRM is an IP framework intended for packet transformations, from encryption to compression. It is configured via a set of policy and state objects, which for IPsec, correspond to Security Policies and Security Associations.

At a high-level, XFRM policies define what traffic to accept and reject, whereas states define how to perform the encryption and decryption. Policies can match on the direction (out, in, or fwd), the source and destination IP addresses with CIDRs, and the packet mark. As an example, the following policy matches egressing packets with any source IP address, 10.56.1.X destination IP addresses, and 0xcb93eXX packet marks. Policies default to allowing traffic as done here.

States are relatively similar, except that they are agnostic to the direction and can only match on exact IP addresses (or 0.0.0.0 to match all). The following state will apply to packets with IP addresses 10.56.0.17 -> 10.56.1.238, the same packet marks as above. In the case of tunnel-mode IPsec, these IP addresses correspond to the outer IP addresses. For ingressing, encrypted packets, the SPI will also be used (discussed below).

You may notice that nothing specifies if this state should perform encryption or decryption. That’s because it can actually do both. As said above, states are agnostic to the direction of traffic so the same state may theoretically be used for both encryption and decryption. What to do will be determined based on where in the stack the state is matched (ex., decryption on ingress).

XFRM policies also typically define a template, as below:

How this template is used depends on the direction. For egressing traffic, the template defines the encoding to perform. For example, the above template will encapsulate packets with an IP header and an ESP header. The IP header will have IP addresses 10.56.0.17 and 10.56.1.238. The ESP header will have SPI 3.

For ingressing and forwarded traffic however, the template acts as an additional filter. The following XFRM policy for example will only allow packets if they are ESP packets with outer IP addresses 10.56.1.238 and 10.56.0.17, in addition to having a packet mark matching 0xd00/0xf00.

Note that when using tunnel mode as is the case here, we should always see XFRM states matching the template of XFRM OUT policies. That is because, on egress, the states are matched after the template is applied. The IP addresses, the SPI, the protocol, the mode, and the reqid should all match between the XFRM state and the template in that case.

The following diagram represents the usual Netfilter packet flow with the XFRM elements in purple:

On egress, packets will first hit one of the “XFRM OUT policy” blocks. At this point, a lookup is performed against the XFRM OUT policies. If a match is found, the packet goes to the “XFRM encode” block, any template is applied (ex., encapsulation), and the packet is then matched against XFRM states. If a state is found, its information is used to encrypt the packet.

The encrypted packet will then navigate again through the OUTPUT and POSTROUTING chains.

On ingress, encrypted packets (ex., ESP packets) will hit the “XFRM decode” after they navigate through the INPUT chain.

In tunnel mode, encrypted packets will typically have one of the server’s IP addresses as the outer destination address, so they should automatically be routed through the INPUT chain. If not, it may be necessary to add IP routes to redirect packets to the INPUT chain. As an example, Cilium identifies IPsec traffic on tc-bpf ingress and marks them with a special value which is then used to reroute those packets to the INPUT chain.

At the “XFRM decode”, if packets match an XFRM state, they will be decoded (i.e., decapsulated and decrypted) using the state’s information. The match is based on the source & destination addresses, the mark, the SPI, and the protocol. In case of any decode error (ex., wrong key), the packet is dropped and an error counter is increased.

As illustrated on the diagram, an XFRM policy matching the packet isn’t required for the decoding to happen (it goes directly to “XFRM decode”), but is required for the packet to proceed to a local process or through the FORWARD chain. An XFRM policy with an optional template (i.e., level use) will allow all decoded packets through. Traffic that was never encrypted, and therefore does not come from “XFRM decode”, is allowed by default.

After a packet is decoded, it is recirculated in the stack, as if coming from the interface it was initially received on. More specifically, packets are recirculated before the tc layer, such that they are visible on the tc-bpf hook a second time (once before decryption, once after). The packet mark is preserved when recirculated, so it’s possible to identify and trace packets that have been decrypted and recirculated.

Outputs are from iproute2-6.1.0. More fields will likely appear in newer versions. For example, XFRM states have a dir field in newer kernels (v6.10+), which will likely appear in the ip xfrm state output at some point.

In the ip xfrm output, policies are ordered by date of creation, with newer policies at the top. This is important because, in case two policies match a packet and have the same priority, the newest one is used.

All XFRM errors correspond to packet drops. Some of them may also be associated with per-state counters increasing. CONFIG_XFRM_STATISTICS is required to see these error counters in /proc/net/xfrm_stat.

XfrmInError: If the kernel fails to allocate memory during encryption.

If a packet is going through too many XFRM states. The maximum is set to XFRM_MAX_DEPTH (6).

If too many XFRM policy templates apply to a packet. The maximum is also set to XFRM_MAX_DEPTH (6).

If the SPI portion of the packet is malformed.

If the outer IP header is malformed.

XfrmInNoStates: If no XFRM IN state was found that matches the AH or ESP packet ingressing on the INPUT chain.

If the AH or ESP checksum is incorrect.

If the packet’s IPsec protocol (ex., AH, ESP) doesn’t match the protocol specified by the XFRM state.

Also includes all protocol specific errors (ex., from esp_input) listed below:

If decryption/encryption fails (ex., because the key specified in the XFRM IN state doesn’t match the key with which the packet was encrypted).

If the protocol headers (ex., ESP) or trailers are malformed.

If there is not enough memory to perform encryption/decryption.

XfrmInStateModeError: If the packet is in IPsec tunnel mode, but the matched XFRM state is in transport mode.

XfrmInStateSeqError: If the anti-replay check rejected the packet. If the check failed because the sequence number was outside the window, the replay-window counter of the associated XFRM state will be incremented. If it failed because the sequence number was seen already, the replay counter is incremented instead.

XfrmInStateExpired: There can be a delay between when a state expires (hard limits) and when it’s actually deleted. During that time, matching packets are dropped with XfrmInStateExpired on ingress.

If the encapsulation protocol of the XFRM state (ex., espinudp in encap field of ip xfrm state) doesn’t match the encapsulation protocol of the packet.

If the decrypted packet doesn’t match the selector (sel field) of the used XFRM state.

XfrmInStateInvalid: If received packet matched an XFRM state that is being deleted or that expired.

If a packet matches an XFRM policy with a non-optional template, but the template doesn’t match any of the XFRM states used to decrypt the packet (yes, a packet can be decoded multiple times).

If an XFRM state with mode tunnel was used on the packet and it doesn’t match any XFRM policy template.

XfrmInNoPols: If the ingressing packet doesn’t match any XFRM policy and the default action is set to block. See ip xfrm policy {get,set}default to view and set the default XFRM policy actions.

XfrmInPolBlock: If the packet matches an XFRM IN policy with action block.

If the kernel fails to allocate memory during encryption.

In some cases, if the packet to encrypt is malformed.

XfrmOutBundleCheckError: Unused.

XfrmOutNoStates: If the packet matched an XFRM OUT policy, but no XFRM state was found that matches the policy’s template.

XfrmOutStateProtoError: If a protocol-specific (ex., ESP) encryption error happens.

XfrmOutStateModeError: If the packet exceeds the MTU once encapsulated and it shouldn’t be fragmented.

XfrmOutStateSeqError: The output sequence number (oseq) of an XFRM state reached its maximum value, UINT32_MAX when not using ESN mode.

XfrmOutStateExpired: There can be a delay between when a state expires (hard limits) and when it’s actually deleted. During that time, matching packets are dropped with XfrmOutStateExpired on egress.

XfrmOutPolBlock: If the packet matches an XFRM OUT policy with action block.

XfrmOutPolDead: Unused. XfrmOutStateInvalid is reported instead for XFRM states that in the process of being deleted.

If too many XFRM policy templates apply to a packet. The maximum is also set to XFRM_MAX_DEPTH (6).

If no XFRM state is found for a non-optional template of the matching XFRM policy.

XfrmFwdHdrError: If the packet is malformed when going through the FWD policy check.

XfrmOutStateInvalid: If egressing packet matched an XFRM state that is being deleted or that expired.

XfrmOutStateDirError: If the direction of the XFRM state found during the lookup is defined and isn’t XFRM_SA_DIR_OUT. Only on kernels v6.10 and newer.

XfrmInStateDirError: If the direction of the XFRM state found during the lookup is defined and isn’t XFRM_SA_DIR_IN. Only on kernels v6.10 and newer.

This section describes the data structures used to hold the XFRM policies and states. This is useful to understand when dealing with a large number of states and policies as the information they hold can help improve indexing and speed up the lookups. When dealing with thousands of policies and states, the lookup cost can become non-negligible even when compared to the encryption/decryption cost.

XFRM policies are stored in a rather complex data structure made of multiple red-black trees and hash tables. At the root, everything is contained in a resizable hashtable indexed by network namespace, IP family, direction, and interface (in case XFRM interfaces are used). Each entry in this resizable hash table contains several black-red trees, which themselves hold the XFRM policies. Those entries are represented by the structure xfrm_pol_inexact_bin.

Once xfrm_pol_inexact_bin has been retrieved (based on current IP family, namespace, and direction), each of its red-black trees is looked up using the source and destination IP addresses. The root_s tree contains policies sorted by source IP addresses; the root_d tree contains policies sorted by destination IP addresses. In addition, leaf nodes of the root_d tree also contain another tree with policies sorted by source IP addresses. That allows the lookups into root_s and root_d to return three lists of candidate (src_ip; dst_ip) policies from the leaf nodes:

A list of (src_ip; any) candidates from root_s.

A list of (any; dst_ip) candidates from root_d.

A list of (src_ip; dst_ip) candidates from the trees pointed by the leaf nodes of root_d.

These three lists of candidate XFRM policies are completed by a list of (any; any) candidates directly stored in the xfrm_pol_inexact_bin entry.

Note that an XFRM policy will only be present in one of the four candidate lists, according to its source and destination CIDRs.

These four lists of candidate XFRM policies are then evaluated. The kernel iterates through each list, looking for the highest-priority (lowest priority number) candidate that matches the packet. If two policies match and have the same priority, the newest one is preferred. It’s also only during this linear evaluation of candidates that the packet mark is compared with the policy marks.

XFRM states are organized in four hash tables, with different XFRM fields used for indexing and different purposes:

net->xfrm.state_bydst is indexed by source and destination IP addresses as well as reqid.

net->xfrm.state_bysrc is indexed only by source and destination IP addresses.

net->xfrm.state_byspi is indexed by destination IP address, SPI, and protocol.

net->xfrm.state_byseq is indexed by sequence number only.

net->xfrm.state_byspi is used when looking up an XFRM state for ingressing packets. This makes sense to speed up the search as each XFRM state is encouraged to have its own SPI (cf., RFC4301, section 4.1) and the encrypted packets carry the SPI.

When searching for the XFRM state that corresponds to an XFRM policy template (before encryption), net->xfrm.state_bydst is used. That makes sense because the indexing information is what the XFRM policy template provides. That hash table is typically also the one being used when iterating through all XFRM states (ex., when flushing them), but any hash table would do the job for that.

net->xfrm.state_bysrc and net->xfrm.state_byseq are used for various other management tasks, such as looking up an XFRM state to update, answering a netlink query from the user, or checking for existing states before adding a new one.

---

## BPF and XDP Reference Guide — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/reference-guides/bpf/

**Contents:**
- BPF and XDP Reference Guide

This documentation section is targeted at developers and users who want to understand BPF and XDP in great technical depth. While reading this reference guide may help broaden your understanding of Cilium, it is not a requirement to use Cilium. Please refer to the Getting Started guide and eBPF Datapath for a higher level introduction.

BPF is a highly flexible and efficient virtual machine-like construct in the Linux kernel allowing to execute bytecode at various hook points in a safe manner. It is used in a number of Linux kernel subsystems, most prominently networking, tracing and security (e.g. sandboxing).

Although BPF exists since 1992, this document covers the extended Berkeley Packet Filter (eBPF) version which has first appeared in Kernel 3.18 and renders the original version which is being referred to as “classic” BPF (cBPF) these days mostly obsolete. cBPF is known to many as being the packet filter language used by tcpdump. Nowadays, the Linux kernel runs eBPF only and loaded cBPF bytecode is transparently translated into an eBPF representation in the kernel before program execution. This documentation will generally refer to the term BPF unless explicit differences between eBPF and cBPF are being pointed out.

Even though the name Berkeley Packet Filter hints at a packet filtering specific purpose, the instruction set is generic and flexible enough these days that there are many use cases for BPF apart from networking. See Further Reading for a list of projects which use BPF.

Cilium uses BPF heavily in its data path, see eBPF Datapath for further information. The goal of this chapter is to provide a BPF reference guide in order to gain understanding of BPF, its networking specific use including loading BPF programs with tc (traffic control) and XDP (eXpress Data Path), and to aid with developing Cilium’s BPF templates.

---

## Program Types — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/reference-guides/bpf/progtypes/

**Contents:**
- Program Types
- XDP
- tc (traffic control)

At the time of this writing, there are eighteen different BPF program types available, two of the main types for networking are further explained in below subsections, namely XDP BPF programs as well as tc BPF programs. Extensive usage examples for the two program types for LLVM, iproute2 or other tools are spread throughout the toolchain section and not covered here. Instead, this section focuses on their architecture, concepts and use cases.

XDP stands for eXpress Data Path and provides a framework for BPF that enables high-performance programmable packet processing in the Linux kernel. It runs the BPF program at the earliest possible point in software, namely at the moment the network driver receives the packet.

At this point in the fast-path the driver just picked up the packet from its receive rings, without having done any expensive operations such as allocating an skb for pushing the packet further up the networking stack, without having pushed the packet into the GRO engine, etc. Thus, the XDP BPF program is executed at the earliest point when it becomes available to the CPU for processing.

XDP works in concert with the Linux kernel and its infrastructure, meaning the kernel is not bypassed as in various networking frameworks that operate in user space only. Keeping the packet in kernel space has several major advantages:

XDP is able to reuse all the upstream developed kernel networking drivers, user space tooling, or even other available in-kernel infrastructure such as routing tables, sockets, etc in BPF helper calls itself.

Residing in kernel space, XDP has the same security model as the rest of the kernel for accessing hardware.

There is no need for crossing kernel / user space boundaries since the processed packet already resides in the kernel and can therefore flexibly forward packets into other in-kernel entities like namespaces used by containers or the kernel’s networking stack itself. This is particularly relevant in times of Meltdown and Spectre.

Punting packets from XDP to the kernel’s robust, widely used and efficient TCP/IP stack is trivially possible, allows for full reuse and does not require maintaining a separate TCP/IP stack as with user space frameworks.

The use of BPF allows for full programmability, keeping a stable ABI with the same ‘never-break-user-space’ guarantees as with the kernel’s system call ABI and compared to modules it also provides safety measures thanks to the BPF verifier that ensures the stability of the kernel’s operation.

XDP trivially allows for atomically swapping programs during runtime without any network traffic interruption or even kernel / system reboot.

XDP allows for flexible structuring of workloads integrated into the kernel. For example, it can operate in “busy polling” or “interrupt driven” mode. Explicitly dedicating CPUs to XDP is not required. There are no special hardware requirements and it does not rely on hugepages.

XDP does not require any third-party kernel modules or licensing. It is a long-term architectural solution, a core part of the Linux kernel, and developed by the kernel community.

XDP is already enabled and shipped everywhere with major distributions running a kernel equivalent to 4.8 or higher and supports most major 10G or higher networking drivers.

As a framework for running BPF in the driver, XDP additionally ensures that packets are laid out linearly and fit into a single DMA’ed page which is readable and writable by the BPF program. XDP also ensures that additional headroom of 256 bytes is available to the program for implementing custom encapsulation headers with the help of the bpf_xdp_adjust_head() BPF helper or adding custom metadata in front of the packet through bpf_xdp_adjust_meta().

The framework contains XDP action codes further described in the section below which a BPF program can return in order to instruct the driver how to proceed with the packet, and it enables the possibility to atomically replace BPF programs running at the XDP layer. XDP is tailored for high-performance by design. BPF allows to access the packet data through ‘direct packet access’ which means that the program holds data pointers directly in registers, loads the content into registers, respectively writes from there into the packet.

The packet representation in XDP that is passed to the BPF program as the BPF context looks as follows:

data points to the start of the packet data in the page, and as the name suggests, data_end points to the end of the packet data. Since XDP allows for a headroom, data_hard_start points to the maximum possible headroom start in the page, meaning, when the packet should be encapsulated, then data is moved closer towards data_hard_start via bpf_xdp_adjust_head(). The same BPF helper function also allows for decapsulation in which case data is moved further away from data_hard_start.

data_meta initially points to the same location as data but bpf_xdp_adjust_meta() is able to move the pointer towards data_hard_start as well in order to provide room for custom metadata which is invisible to the normal kernel networking stack but can be read by tc BPF programs since it is transferred from XDP to the skb. Vice versa, it can remove or reduce the size of the custom metadata through the same BPF helper function by moving data_meta away from data_hard_start again. data_meta can also be used solely for passing state between tail calls similarly to the skb->cb[] control block case that is accessible in tc BPF programs.

This gives the following relation respectively invariant for the struct xdp_buff packet pointers: data_hard_start <= data_meta <= data < data_end.

The rxq field points to some additional per receive queue metadata which is populated at ring setup time (not at XDP runtime):

The BPF program can retrieve queue_index as well as additional data from the netdevice itself such as ifindex, etc.

BPF program return codes

After running the XDP BPF program, a verdict is returned from the program in order to tell the driver how to process the packet next. In the linux/bpf.h system header file all available return verdicts are enumerated:

XDP_DROP as the name suggests will drop the packet right at the driver level without wasting any further resources. This is in particular useful for BPF programs implementing DDoS mitigation mechanisms or firewalling in general. The XDP_PASS return code means that the packet is allowed to be passed up to the kernel’s networking stack. Meaning, the current CPU that was processing this packet now allocates a skb, populates it, and passes it onwards into the GRO engine. This would be equivalent to the default packet handling behavior without XDP. With XDP_TX the BPF program has an efficient option to transmit the network packet out of the same NIC it just arrived on again. This is typically useful when few nodes are implementing, for example, firewalling with subsequent load balancing in a cluster and thus, act as a hairpinned load balancer pushing the incoming packets back into the switch after rewriting them in XDP BPF. XDP_REDIRECT is similar to XDP_TX in that it is able to transmit the XDP packet, but through another NIC. Another option for the XDP_REDIRECT case is to redirect into a BPF cpumap, meaning, the CPUs serving XDP on the NIC’s receive queues can continue to do so and push the packet for processing the upper kernel stack to a remote CPU. This is similar to XDP_PASS, but with the ability that the XDP BPF program can keep serving the incoming high load as opposed to temporarily spend work on the current packet for pushing into upper layers. Last but not least, XDP_ABORTED which serves denoting an exception like state from the program and has the same behavior as XDP_DROP only that XDP_ABORTED passes the trace_xdp_exception tracepoint which can be additionally monitored to detect misbehavior.

Some of the main use cases for XDP are presented in this subsection. The list is non-exhaustive and given the programmability and efficiency XDP and BPF enables, it can easily be adapted to solve very specific use cases.

DDoS mitigation, firewalling

One of the basic XDP BPF features is to tell the driver to drop a packet with XDP_DROP at this early stage which allows for any kind of efficient network policy enforcement with having an extremely low per-packet cost. This is ideal in situations when needing to cope with any sort of DDoS attacks, but also more general allows to implement any sort of firewalling policies with close to no overhead in BPF e.g. in either case as stand alone appliance (e.g. scrubbing ‘clean’ traffic through XDP_TX) or widely deployed on nodes protecting end hosts themselves (via XDP_PASS or cpumap XDP_REDIRECT for good traffic). Offloaded XDP takes this even one step further by moving the already small per-packet cost entirely into the NIC with processing at line-rate.

Forwarding and load-balancing

Another major use case of XDP is packet forwarding and load-balancing through either XDP_TX or XDP_REDIRECT actions. The packet can be arbitrarily mangled by the BPF program running in the XDP layer, even BPF helper functions are available for increasing or decreasing the packet’s headroom in order to arbitrarily encapsulate respectively decapsulate the packet before sending it out again. With XDP_TX hairpinned load-balancers can be implemented that push the packet out of the same networking device it originally arrived on, or with the XDP_REDIRECT action it can be forwarded to another NIC for transmission. The latter return code can also be used in combination with BPF’s cpumap to load-balance packets for passing up the local stack, but on remote, non-XDP processing CPUs.

Pre-stack filtering / processing

Besides policy enforcement, XDP can also be used for hardening the kernel’s networking stack with the help of XDP_DROP case, meaning, it can drop irrelevant packets for a local node right at the earliest possible point before the networking stack sees them e.g. given we know that a node only serves TCP traffic, any UDP, SCTP or other L4 traffic can be dropped right away. This has the advantage that packets do not need to traverse various entities like GRO engine, the kernel’s flow dissector and others before it can be determined to drop them and thus, this allows for reducing the kernel’s attack surface. Thanks to XDP’s early processing stage, this effectively ‘pretends’ to the kernel’s networking stack that these packets have never been seen by the networking device. Additionally, if a potential bug in the stack’s receive path got uncovered and would cause a ‘ping of death’ like scenario, XDP can be utilized to drop such packets right away without having to reboot the kernel or restart any services. Due to the ability to atomically swap such programs to enforce a drop of bad packets, no network traffic is even interrupted on a host.

Another use case for pre-stack processing is that given the kernel has not yet allocated an skb for the packet, the BPF program is free to modify the packet and, again, have it ‘pretend’ to the stack that it was received by the networking device this way. This allows for cases such as having custom packet mangling and encapsulation protocols where the packet can be decapsulated prior to entering GRO aggregation in which GRO otherwise would not be able to perform any sort of aggregation due to not being aware of the custom protocol. XDP also allows to push metadata (non-packet data) in front of the packet. This is ‘invisible’ to the normal kernel stack, can be GRO aggregated (for matching metadata) and later on processed in coordination with a tc ingress BPF program where it has the context of a skb available for e.g. setting various skb fields.

Flow sampling, monitoring

XDP can also be used for cases such as packet monitoring, sampling or any other network analytics, for example, as part of an intermediate node in the path or on end hosts in combination also with prior mentioned use cases. For complex packet analysis, XDP provides a facility to efficiently push network packets (truncated or with full payload) and custom metadata into a fast lockless per CPU memory mapped ring buffer provided from the Linux perf infrastructure to a user space application. This also allows for cases where only a flow’s initial data can be analyzed and once determined as good traffic having the monitoring bypassed. Thanks to the flexibility brought by BPF, this allows for implementing any sort of custom monitoring or sampling.

One example of XDP BPF production usage is Facebook’s SHIV and Droplet infrastructure which implements their L4 load-balancing and DDoS countermeasures. Migrating their production infrastructure away from netfilter’s IPVS (IP Virtual Server) over to XDP BPF allowed for a 10x speedup compared to their previous IPVS setup. This was first presented at the netdev 2.1 conference:

Slides: https://netdevconf.info/2.1/slides/apr6/zhou-netdev-xdp-2017.pdf

Video: https://youtu.be/YEU2ClcGqts

Another example is the integration of XDP into Cloudflare’s DDoS mitigation pipeline, which originally was using cBPF instead of eBPF for attack signature matching through iptables’ xt_bpf module. Due to use of iptables this caused severe performance problems under attack where a user space bypass solution was deemed necessary but came with drawbacks as well such as needing to busy poll the NIC and expensive packet re-injection into the kernel’s stack. The migration over to eBPF and XDP combined best of both worlds by having high-performance programmable packet processing directly inside the kernel:

Slides: https://netdevconf.info/2.1/slides/apr6/bertin_Netdev-XDP.pdf

Video: https://youtu.be/7OuOukmuivg

XDP has three operation modes where ‘native’ XDP is the default mode. When talked about XDP this mode is typically implied.

This is the default mode where the XDP BPF program is run directly out of the networking driver’s early receive path. Most widespread used NICs for 10G and higher support native XDP already.

In the offloaded XDP mode the XDP BPF program is directly offloaded into the NIC instead of being executed on the host CPU. Thus, the already extremely low per-packet cost is pushed off the host CPU entirely and executed on the NIC, providing even higher performance than running in native XDP. This offload is typically implemented by SmartNICs containing multi-threaded, multicore flow processors where an in-kernel JIT compiler translates BPF into native instructions for the latter. Drivers supporting offloaded XDP usually also support native XDP for cases where some BPF helpers may not yet or only be available for the native mode.

For drivers not implementing native or offloaded XDP yet, the kernel provides an option for generic XDP which does not require any driver changes since run at a much later point out of the networking stack. This setting is primarily targeted at developers who want to write and test programs against the kernel’s XDP API, and will not operate at the performance rate of the native or offloaded modes. For XDP usage in a production environment either the native or offloaded mode is better suited and the recommended way to run XDP.

Drivers supporting native XDP

A list of drivers supporting native XDP can be found in the table below. The corresponding network driver name of an interface can be determined as follows:

tsne (TSN Express Path)

Drivers supporting offloaded XDP

Examples for writing and loading XDP programs are included in the Development Tools section under the respective tools.

Some BPF helper functions such as retrieving the current CPU number will not be available in an offloaded setting.

Aside from other program types such as XDP, BPF can also be used out of the kernel’s tc (traffic control) layer in the networking data path. On a high-level there are three major differences when comparing XDP BPF programs to tc BPF ones:

The BPF input context is a sk_buff not a xdp_buff. When the kernel’s networking stack receives a packet, after the XDP layer, it allocates a buffer and parses the packet to store metadata about the packet. This representation is known as the sk_buff. This structure is then exposed in the BPF input context so that BPF programs from the tc ingress layer can use the metadata that the stack extracts from the packet. This can be useful, but comes with an associated cost of the stack performing this allocation and metadata extraction, and handling the packet until it hits the tc hook. By definition, the xdp_buff doesn’t have access to this metadata because the XDP hook is called before this work is done. This is a significant contributor to the performance difference between the XDP and tc hooks.

Therefore, BPF programs attached to the tc BPF hook can, for instance, read or write the skb’s mark, pkt_type, protocol, priority, queue_mapping, napi_id, cb[] array, hash, tc_classid or tc_index, vlan metadata, the XDP transferred custom metadata and various other information. All members of the struct __sk_buff BPF context used in tc BPF are defined in the linux/bpf.h system header.

Generally, the sk_buff is of a completely different nature than xdp_buff where both come with advantages and disadvantages. For example, the sk_buff case has the advantage that it is rather straight forward to mangle its associated metadata, however, it also contains a lot of protocol specific information (e.g. GSO related state) which makes it difficult to simply switch protocols by solely rewriting the packet data. This is due to the stack processing the packet based on the metadata rather than having the cost of accessing the packet contents each time. Thus, additional conversion is required from BPF helper functions taking care that sk_buff internals are properly converted as well. The xdp_buff case however does not face such issues since it comes at such an early stage where the kernel has not even allocated an sk_buff yet, thus packet rewrites of any kind can be realized trivially. However, the xdp_buff case has the disadvantage that sk_buff metadata is not available for mangling at this stage. The latter is overcome by passing custom metadata from XDP BPF to tc BPF, though. In this way, the limitations of each program type can be overcome by operating complementary programs of both types as the use case requires.

Compared to XDP, tc BPF programs can be triggered out of ingress and also egress points in the networking data path as opposed to ingress only in the case of XDP.

The two hook points sch_handle_ingress() and sch_handle_egress() in the kernel are triggered out of __netif_receive_skb_core() and __dev_queue_xmit(), respectively. The latter two are the main receive and transmit functions in the data path that, setting XDP aside, are triggered for every network packet going in or coming out of the node allowing for full visibility for tc BPF programs at these hook points.

The tc BPF programs do not require any driver changes since they are run at hook points in generic layers in the networking stack. Therefore, they can be attached to any type of networking device.

While this provides flexibility, it also trades off performance compared to running at the native XDP layer. However, tc BPF programs still come at the earliest point in the generic kernel’s networking data path after GRO has been run but before any protocol processing, traditional iptables firewalling such as iptables PREROUTING or nftables ingress hooks or other packet processing takes place. Likewise on egress, tc BPF programs execute at the latest point before handing the packet to the driver itself for transmission, meaning after traditional iptables firewalling hooks like iptables POSTROUTING, but still before handing the packet to the kernel’s GSO engine.

One exception which does require driver changes however are offloaded tc BPF programs, typically provided by SmartNICs in a similar way as offloaded XDP just with differing set of features due to the differences in the BPF input context, helper functions and verdict codes.

BPF programs run in the tc layer are run from the cls_bpf classifier. While the tc terminology describes the BPF attachment point as a “classifier”, this is a bit misleading since it under-represents what cls_bpf is capable of. That is to say, a fully programmable packet processor being able not only to read the skb metadata and packet data, but to also arbitrarily mangle both and terminate the tc processing with an action verdict. cls_bpf can thus be regarded as a self-contained entity that manages and executes tc BPF programs.

cls_bpf can hold one or more tc BPF programs. In the case where Cilium deploys cls_bpf programs, it attaches only a single program for a given hook in direct-action mode. Typically, in the traditional tc scheme, there is a split between classifier and action modules, where the classifier has one or more actions attached to it that are triggered once the classifier has a match. In the modern world for using tc in the software data path this model does not scale well for complex packet processing. Given tc BPF programs attached to cls_bpf are fully self-contained, they effectively fuse the parsing and action process together into a single unit. Thanks to cls_bpf’s direct-action mode, it will just return the tc action verdict and terminate the processing pipeline immediately. This allows for implementing scalable programmable packet processing in the networking data path by avoiding linear iteration of actions. cls_bpf is the only such “classifier” module in the tc layer capable of such a fast-path.

Like XDP BPF programs, tc BPF programs can be atomically updated at runtime via cls_bpf without interrupting any network traffic or having to restart services.

Both the tc ingress and the egress hook where cls_bpf itself can be attached to is managed by a pseudo qdisc called sch_clsact. This is a drop-in replacement and proper superset of the ingress qdisc since it is able to manage both, ingress and egress tc hooks. For tc’s egress hook in __dev_queue_xmit() it is important to stress that it is not executed under the kernel’s qdisc root lock. Thus, both tc ingress and egress hooks are executed in a lockless manner in the fast-path. In either case, preemption is disabled and execution happens under RCU read side.

Typically, on egress there are qdiscs attached to netdevices such as sch_mq, sch_fq, sch_fq_codel or sch_htb where some of them are classful qdiscs that contain subclasses and thus require a packet classification mechanism to determine a verdict where to demux the packet. This is handled by a call to tcf_classify() which calls into tc classifiers if present. cls_bpf can also be attached and used in such cases. Such operation usually happens under the qdisc root lock and can be subject to lock contention. The sch_clsact qdisc’s egress hook comes at a much earlier point however which does not fall under that and operates completely independent from conventional egress qdiscs. Thus, for cases like sch_htb the sch_clsact qdisc could perform the heavy lifting packet classification through tc BPF outside of the qdisc root lock, setting the skb->mark or skb->priority from there such that sch_htb only requires a flat mapping without expensive packet classification under the root lock thus reducing contention.

Offloaded tc BPF programs are supported for the case of sch_clsact in combination with cls_bpf where the prior loaded BPF program was JITed from a SmartNIC driver to be run natively on the NIC. Only cls_bpf programs operating in direct-action mode are supported to be offloaded. cls_bpf only supports offloading a single program and cannot offload multiple programs. Furthermore, only the ingress hook supports offloading BPF programs.

One cls_bpf instance is able to hold multiple tc BPF programs internally. If this is the case, then the TC_ACT_UNSPEC program return code will continue execution with the next tc BPF program in that list. However, this has the drawback that several programs would need to parse the packet over and over again resulting in degraded performance.

BPF program return codes

Both the tc ingress and egress hook share the same action return verdicts that tc BPF programs can use. They are defined in the linux/pkt_cls.h system header:

There are a few more action TC_ACT_* verdicts available in the system header file which are also used in the two hooks. However, they share the same semantics with the ones above. Meaning, from a tc BPF perspective, TC_ACT_OK and TC_ACT_RECLASSIFY have the same semantics, as well as the three TC_ACT_STOLEN, TC_ACT_QUEUED and TC_ACT_TRAP opcodes. Therefore, for these cases we only describe TC_ACT_OK and the TC_ACT_STOLEN opcode for the two groups.

Starting out with TC_ACT_UNSPEC. It has the meaning of “unspecified action” and is used in three cases, i) when an offloaded tc BPF program is attached and the tc ingress hook is run where the cls_bpf representation for the offloaded program will return TC_ACT_UNSPEC, ii) in order to continue with the next tc BPF program in cls_bpf for the multi-program case. The latter also works in combination with offloaded tc BPF programs from point i) where the TC_ACT_UNSPEC from there continues with a next tc BPF program solely running in non-offloaded case. Last but not least, iii) TC_ACT_UNSPEC is also used for the single program case to simply tell the kernel to continue with the skb without additional side-effects. TC_ACT_UNSPEC is very similar to the TC_ACT_OK action code in the sense that both pass the skb onwards either to upper layers of the stack on ingress or down to the networking device driver for transmission on egress, respectively. The only difference to TC_ACT_OK is that TC_ACT_OK sets skb->tc_index based on the classid the tc BPF program set. The latter is set out of the tc BPF program itself through skb->tc_classid from the BPF context.

TC_ACT_SHOT instructs the kernel to drop the packet, meaning, upper layers of the networking stack will never see the skb on ingress and similarly, the packet will never be submitted for transmission on egress. TC_ACT_SHOT and TC_ACT_STOLEN are both similar in nature with few differences: TC_ACT_SHOT will indicate to the kernel that the skb was released through kfree_skb() and return NET_XMIT_DROP to the callers for immediate feedback, whereas TC_ACT_STOLEN will release the skb through consume_skb() and pretend to upper layers that the transmission was successful through NET_XMIT_SUCCESS. The perf’s drop monitor which records traces of kfree_skb() will therefore also not see any drop indications from TC_ACT_STOLEN since its semantics are such that the skb has been “consumed” or queued but certainly not “dropped”.

Last but not least the TC_ACT_REDIRECT action which is available for tc BPF programs as well. This allows to redirect the skb to the same or another’s device ingress or egress path together with the bpf_redirect() helper. Being able to inject the packet into another device’s ingress or egress direction allows for full flexibility in packet forwarding with BPF. There are no requirements on the target networking device other than being a networking device itself, there is no need to run another instance of cls_bpf on the target device or other such restrictions.

This section contains a few miscellaneous question and answer pairs related to tc BPF programs that are asked from time to time.

Question: What about act_bpf as a tc action module, is it still relevant?

Answer: Not really. Although cls_bpf and act_bpf share the same functionality for tc BPF programs, cls_bpf is more flexible since it is a proper superset of act_bpf. The way tc works is that tc actions need to be attached to tc classifiers. In order to achieve the same flexibility as cls_bpf, act_bpf would need to be attached to the cls_matchall classifier. As the name says, this will match on every packet in order to pass them through for attached tc action processing. For act_bpf, this is will result in less efficient packet processing than using cls_bpf in direct-action mode directly. If act_bpf is used in a setting with other classifiers than cls_bpf or cls_matchall then this will perform even worse due to the nature of operation of tc classifiers. Meaning, if classifier A has a mismatch, then the packet is passed to classifier B, reparsing the packet, etc, thus in the typical case there will be linear processing where the packet would need to traverse N classifiers in the worst case to find a match and execute act_bpf on that. Therefore, act_bpf has never been largely relevant. Additionally, act_bpf does not provide a tc offloading interface either compared to cls_bpf.

Question: Is it recommended to use cls_bpf not in direct-action mode?

Answer: No. The answer is similar to the one above in that this is otherwise unable to scale for more complex processing. tc BPF can already do everything needed by itself in an efficient manner and thus there is no need for anything other than direct-action mode.

Question: Is there any performance difference in offloaded cls_bpf and offloaded XDP?

Answer: No. Both are JITed through the same compiler in the kernel which handles the offloading to the SmartNIC and the loading mechanism for both is very similar as well. Thus, the BPF program gets translated into the same target instruction set in order to be able to run on the NIC natively. The two tc BPF and XDP BPF program types have a differing set of features, so depending on the use case one might be picked over the other due to availability of certain helper functions in the offload case, for example.

Some of the main use cases for tc BPF programs are presented in this subsection. Also here, the list is non-exhaustive and given the programmability and efficiency of tc BPF, it can easily be tailored and integrated into orchestration systems in order to solve very specific use cases. While some use cases with XDP may overlap, tc BPF and XDP BPF are mostly complementary to each other and both can also be used at the same time or one over the other depending on which is most suitable for a given problem to solve.

Policy enforcement for containers

One application which tc BPF programs are suitable for is to implement policy enforcement, custom firewalling or similar security measures for containers or pods, respectively. In the conventional case, container isolation is implemented through network namespaces with veth networking devices connecting the host’s initial namespace with the dedicated container’s namespace. Since one end of the veth pair has been moved into the container’s namespace whereas the other end remains in the initial namespace of the host, all network traffic from the container has to pass through the host-facing veth device allowing for attaching tc BPF programs on the tc ingress and egress hook of the veth. Network traffic going into the container will pass through the host-facing veth’s tc egress hook whereas network traffic coming from the container will pass through the host-facing veth’s tc ingress hook.

For virtual devices like veth devices XDP is unsuitable in this case since the kernel operates solely on a skb here and generic XDP has a few limitations where it does not operate with cloned skb’s. The latter is heavily used from the TCP/IP stack in order to hold data segments for retransmission where the generic XDP hook would simply get bypassed instead. Moreover, generic XDP needs to linearize the entire skb resulting in heavily degraded performance. tc BPF on the other hand is more flexible as it specializes on the skb input context case and thus does not need to cope with the limitations from generic XDP.

Forwarding and load-balancing

The forwarding and load-balancing use case is quite similar to XDP, although slightly more targeted towards east-west container workloads rather than north-south traffic (though both technologies can be used in either case). Since XDP is only available on ingress side, tc BPF programs allow for further use cases that apply in particular on egress, for example, container based traffic can already be NATed and load-balanced on the egress side through BPF out of the initial namespace such that this is done transparent to the container itself. Egress traffic is already based on the sk_buff structure due to the nature of the kernel’s networking stack, so packet rewrites and redirects are suitable out of tc BPF. By utilizing the bpf_redirect() helper function, BPF can take over the forwarding logic to push the packet either into the ingress or egress path of another networking device. Thus, any bridge-like devices become unnecessary to use as well by utilizing tc BPF as forwarding fabric.

Flow sampling, monitoring

Like in XDP case, flow sampling and monitoring can be realized through a high-performance lockless per-CPU memory mapped perf ring buffer where the BPF program is able to push custom data, the full or truncated packet contents, or both up to a user space application. From the tc BPF program this is realized through the bpf_skb_event_output() BPF helper function which has the same function signature and semantics as bpf_xdp_event_output(). Given tc BPF programs can be attached to ingress and egress as opposed to only ingress in XDP BPF case plus the two tc hooks are at the lowest layer in the (generic) networking stack, this allows for bidirectional monitoring of all network traffic from a particular node. This might be somewhat related to the cBPF case which tcpdump and Wireshark makes use of, though, without having to clone the skb and with being a lot more flexible in terms of programmability where, for example, BPF can already perform in-kernel aggregation rather than pushing everything up to user space as well as custom annotations for packets pushed into the ring buffer. The latter is also heavily used in Cilium where packet drops can be further annotated to correlate container labels and reasons for why a given packet had to be dropped (such as due to policy violation) in order to provide a richer context.

Packet scheduler pre-processing

The sch_clsact’s egress hook which is called sch_handle_egress() runs right before taking the kernel’s qdisc root lock, thus tc BPF programs can be utilized to perform all the heavy lifting packet classification and mangling before the packet is transmitted into a real full blown qdisc such as sch_htb. This type of interaction of sch_clsact with a real qdisc like sch_htb coming later in the transmission phase allows to reduce the lock contention on transmission since sch_clsact’s egress hook is executed without taking locks.

One concrete example user of tc BPF but also XDP BPF programs is Cilium. Cilium is open source software for transparently securing the network connectivity between application services deployed using Linux container management platforms like Docker and Kubernetes and operates at Layer 3/4 as well as Layer 7. At the heart of Cilium operates BPF in order to implement the policy enforcement as well as load balancing and monitoring.

Slides: https://www.slideshare.net/ThomasGraf5/dockercon-2017-cilium-network-and-application-security-with-bpf-and-xdp

Video: https://youtu.be/ilKlmTDdFgk

Github: https://github.com/cilium/cilium

Since tc BPF programs are triggered from the kernel’s networking stack and not directly out of the driver, they do not require any extra driver modification and therefore can run on any networking device. The only exception listed below is for offloading tc BPF programs to the NIC.

Drivers supporting offloaded tc BPF

Examples for writing and loading tc BPF programs are included in the Development Tools section under the respective tools.

---

## Administrative API Enablement — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/configuration/api-restrictions/

**Contents:**
- Administrative API Enablement
- Cilium Agent API
- Cilium Agent Clusterwide Health API
- Cilium Operator API

Cilium 1.14 introduced a new set of flags that you can use to selectively enable which API endpoints are exposed to clients. When an API client makes a request to an API endpoint that is administratively disabled, the server responds with an HTTP 403 Forbidden error.

You can configure the option with a list of endpoints as described in the following sections, or by specifying an option with the * suffix. If * is provided directly as a flag value, then all APIs are enabled. If there is text before the *, then the API flag must start with that prefix in order for the flag to enable that option. For example, Get* enables all read-only “GET” APIs without enabling any write APIs.

The cilium-agent relies on several of these APIs for its basic duties. In particular, disabling the following APIs will likely cause significant disruption to agent operations:

The following sections outline the flags for different Cilium binaries and the API endpoints that may be configured using those flags.

The following API flags are compatible with the cilium-agent flag enable-cilium-api-server-access.

Deletes a list of endpoints that have endpoints matching the provided properties

Deletes the endpoint specified by the ID. Deletion is imminent and atomic, if the deletion request is valid and the endpoint exists, deletion will occur even if errors are encountered in the process. If errors have been encountered, the code 202 will be returned, otherwise 200 on success. All resources associated with the endpoint will be freed and the workload represented by the endpoint will be disconnected.It will no longer be able to initiate or receive communications of any sort.

Deletes matching DNS lookups from the cache, optionally restricted by DNS name. The removed IP data will no longer be used in generated policies.

Deprecated: will be removed in v1.19

Retrieves current operational state of BGP peers created by Cilium BGP virtual router. This includes session state, uptime, information per address family, etc.

Retrieves route policies from BGP Control Plane.

Retrieves routes from BGP Control Plane RIB filtered by parameters you specify

GetCgroupDumpMetadata

Returns the configuration of the Cilium daemon.

Retrieves a list of endpoints that have metadata matching the provided parameters, or all endpoints if no parameters provided.

Returns endpoint information

Retrieves the configuration of the specified endpoint.

Retrieves the list of DNS lookups intercepted from endpoints, optionally filtered by DNS name, CIDR IP range or source.

Retrieves the list of DNS lookups intercepted from the specific endpoint, optionally filtered by endpoint id, DNS name, CIDR IP range or source.

Retrieves the list of DNS-related fields (names to poll, selectors and their corresponding regexes).

Returns health and status information of the Cilium daemon and related components such as the local container runtime, connected datastore, Kubernetes integration and Hubble.

Retrieves a list of IPs with known associated information such as their identities, host addresses, Kubernetes pod names, etc. The list can optionally filtered by a CIDR IP range.

Retrieves a list of identities that have metadata matching the provided parameters, or all identities if no parameters are provided.

Retrieves a list of node IDs allocated by the agent and their associated node IP addresses.

Returns the entire policy tree with all children. Deprecated: will be removed in v1.19

Updates the daemon configuration by applying the provided ConfigurationMap and regenerates & recompiles all required datapath components.

Applies the endpoint change request to an existing endpoint

PatchEndpointIDConfig

Update the configuration of an existing endpoint and regenerates & recompiles the corresponding programs automatically.

PatchEndpointIDLabels

Sets labels associated with an endpoint. These can be user provided or derived from the orchestration system.

Creates a new endpoint

Deprecated: will be removed in v1.19

The following API flags are compatible with the cilium-agent flag enable-cilium-health-api-server-access.

Returns health and status information of the local node including load and uptime, as well as the status of related components including the Cilium daemon.

Returns the connectivity status to all other cilium-health instances using interval-based probing.

Runs a synchronous probe to all other cilium-health instances and returns the connectivity status.

The following API flags are compatible with the cilium-operator flag enable-cilium-operator-server-access.

Returns the list of remote clusters and their status.

Returns the status of cilium operator instance.

Returns the metrics exposed by the Cilium operator.

---

## Further Reading — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/reference-guides/bpf/resources/

**Contents:**
- Further Reading
- Kernel Developer FAQ
- Projects using BPF
- XDP Newbies
- BPF Newsletter
- Podcasts
- Blog posts
- Books
- Talks
- Further Documents

Mentioned lists of docs, projects, talks, papers, and further reading materials are likely not complete. Thus, feel free to open pull requests to complete the list.

Under Documentation/bpf/, the Linux kernel provides two FAQ files that are mainly targeted for kernel developers involved in the BPF subsystem.

BPF Devel FAQ: this document provides mostly information around patch submission process as well as BPF kernel tree, stable tree and bug reporting workflows, questions around BPF’s extensibility and interaction with LLVM and more.

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/bpf/bpf_devel_QA.rst

BPF Design FAQ: this document tries to answer frequently asked questions around BPF design decisions related to the instruction set, verifier, calling convention, JITs, etc.

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/bpf/bpf_design_QA.rst

The following list includes a selection of open source projects making use of BPF respectively provide tooling for BPF. In this context the eBPF instruction set is specifically meant instead of projects utilizing the legacy cBPF:

BCC stands for BPF Compiler Collection, and its key feature is to provide a set of easy to use and efficient kernel tracing utilities all based upon BPF programs hooking into kernel infrastructure based upon kprobes, kretprobes, tracepoints, uprobes, uretprobes as well as USDT probes. The collection provides close to hundred tools targeting different layers across the stack from applications, system libraries, to the various different kernel subsystems in order to analyze a system’s performance characteristics or problems. Additionally, BCC provides an API in order to be used as a library for other projects.

https://github.com/iovisor/bcc

bpftrace is a DTrace-style dynamic tracing tool for Linux and uses LLVM as a back end to compile scripts to BPF-bytecode and makes use of BCC for interacting with the kernel’s BPF tracing infrastructure. It provides a higher-level language for implementing tracing scripts compared to native BCC.

https://github.com/ajor/bpftrace

The perf tool which is developed by the Linux kernel community as part of the kernel source tree provides a way to load tracing BPF programs through the conventional perf record subcommand where the aggregated data from BPF can be retrieved and post processed in perf.data for example through perf script and other means.

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/perf

ply is a tracing tool that follows the ‘Little Language’ approach of yore, and compiles ply scripts into Linux BPF programs that are attached to kprobes and tracepoints in the kernel. The scripts have a C-like syntax, heavily inspired by DTrace and by extension awk. ply keeps dependencies to very minimum and only requires flex and bison at build time, only libc at runtime.

https://github.com/wkz/ply

systemtap is a scripting language and tool for extracting, filtering and summarizing data in order to diagnose and analyze performance or functional problems. It comes with a BPF back end called stapbpf which translates the script directly into BPF without the need of an additional compiler and injects the probe into the kernel. Thus, unlike stap’s kernel modules this does neither have external dependencies nor requires to load kernel modules.

https://sourceware.org/git/gitweb.cgi?p=systemtap.git;a=summary

Performance Co-Pilot (PCP) is a system performance and analysis framework which is able to collect metrics through a variety of agents as well as analyze collected systems’ performance metrics in real-time or by using historical data. With pmdabcc, PCP has a BCC based performance metrics domain agent which extracts data from the kernel via BPF and BCC.

https://github.com/performancecopilot/pcp

Weave Scope is a cloud monitoring tool collecting data about processes, networking connections or other system data by making use of BPF in combination with kprobes. Weave Scope works on top of the gobpf library in order to load BPF ELF files into the kernel, and comes with a tcptracer-bpf tool which monitors connect, accept and close calls in order to trace TCP events.

https://github.com/weaveworks/scope

Cilium provides and transparently secures network connectivity and load-balancing between application workloads such as application containers or processes. Cilium operates at Layer 3/4 to provide traditional networking and security services as well as Layer 7 to protect and secure use of modern application protocols such as HTTP, gRPC and Kafka. It is integrated into orchestration frameworks such as Kubernetes. BPF is the foundational part of Cilium that operates in the kernel’s networking data path.

https://github.com/cilium/cilium

Suricata is a network IDS, IPS and NSM engine, and utilizes BPF as well as XDP in three different areas, that is, as BPF filter in order to process or bypass certain packets, as a BPF based load balancer in order to allow for programmable load balancing and for XDP to implement a bypass or dropping mechanism at high packet rates.

https://suricata.readthedocs.io/en/suricata-5.0.2/capture-hardware/ebpf-xdp.html

https://github.com/OISF/suricata

systemd allows for IPv4/v6 accounting as well as implementing network access control for its systemd units based on BPF’s cgroup ingress and egress hooks. Accounting is based on packets / bytes, and ACLs can be specified as address prefixes for allow / deny rules. More information can be found at:

http://0pointer.net/blog/ip-accounting-and-access-lists-with-systemd.html

https://github.com/systemd/systemd

iproute2 offers the ability to load BPF programs as LLVM generated ELF files into the kernel. iproute2 supports both, XDP BPF programs as well as tc BPF programs through a common BPF loader backend. The tc and ip command line utilities enable loader and introspection functionality for the user.

https://git.kernel.org/pub/scm/network/iproute2/iproute2.git/

p4c-xdp presents a P4 compiler backend targeting BPF and XDP. P4 is a domain specific language describing how packets are processed by the data plane of a programmable network element such as NICs, appliances or switches, and with the help of p4c-xdp P4 programs can be translated into BPF C programs which can be compiled by clang / LLVM and loaded as BPF programs into the kernel at XDP layer for high performance packet processing.

https://github.com/vmware/p4c-xdp

clang / LLVM provides the BPF back end in order to compile C BPF programs into BPF instructions contained in ELF files. The LLVM BPF back end is developed alongside with the BPF core infrastructure in the Linux kernel and maintained by the same community. clang / LLVM is a key part in the toolchain for developing BPF programs.

libbpf is a generic BPF library which is developed by the Linux kernel community as part of the kernel source tree and allows for loading and attaching BPF programs from LLVM generated ELF files into the kernel. The library is used by other kernel projects such as perf and bpftool.

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/lib/bpf

bpftool is the main tool for introspecting and debugging BPF programs and BPF maps, and like libbpf is developed by the Linux kernel community. It allows for dumping all active BPF programs and maps in the system, dumping and disassembling BPF or JITed BPF instructions from a program as well as dumping and manipulating BPF maps in the system. bpftool supports interaction with the BPF filesystem, loading various program types from an object file into the kernel and much more.

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/bpf/bpftool

cilium/ebpf (ebpf-go) is a pure Go library that provides utilities for loading, compiling, and debugging eBPF programs. It has minimal external dependencies and is intended to be used in long-running processes.

Its bpf2go utility automates away compiling eBPF C programs and embedding them into Go binaries.

It implements attaching programs to various kernel hooks, as well as kprobes and uprobes for tracing arbitrary kernel and user space functions. It also features a complete assembler that allows constructing eBPF programs at runtime using Go, or modifying them after they’ve been loaded from an ELF object.

https://github.com/cilium/ebpf

ebpf_asm provides an assembler for BPF programs written in an Intel-like assembly syntax, and therefore offers an alternative for writing BPF programs directly in assembly for cases where programs are rather small and simple without needing the clang / LLVM toolchain.

https://github.com/Xilinx-CNS/ebpf_asm

There are a couple of walk-through posts by David S. Miller to the xdp-newbies mailing list (http://vger.kernel.org/vger-lists.html#xdp-newbies), which explain various parts of XDP and BPF:

BPF Verifier Overview, David S. Miller, https://www.spinics.net/lists/xdp-newbies/msg00185.html

Contextually speaking…, David S. Miller, https://www.spinics.net/lists/xdp-newbies/msg00181.html

bpf.h and you…, David S. Miller, https://www.spinics.net/lists/xdp-newbies/msg00179.html

XDP example of the day, David S. Miller, https://www.spinics.net/lists/xdp-newbies/msg00009.html

Alexander Alemayhu initiated a newsletter around BPF roughly once per week covering latest developments around BPF in Linux kernel land and its surrounding ecosystem in user space.

All BPF update newsletters (01 - 12) can be found here:

https://cilium.io/blog/categories/technology/5/

And for the news on the latest resources and developments in the eBPF world, please refer to the link here:

There have been a number of technical podcasts partially covering BPF. Incomplete list:

Linux Networking Update from Netdev Conference, Thomas Graf, Software Gone Wild, Show 71, https://blog.ipspace.net/2017/02/linux-networking-update-from-netdev.html https://www.ipspace.net/nuggets/podcast/Show_71-NetDev_Update.mp3

The IO Visor Project, Brenden Blanco, OVS Orbit, Episode 23, https://ovsorbit.org/#e23 https://ovsorbit.org/episode-23.mp3

Fast Linux Packet Forwarding, Thomas Graf, Software Gone Wild, Show 64, https://blog.ipspace.net/2016/10/fast-linux-packet-forwarding-with.html https://www.ipspace.net/nuggets/podcast/Show_64-Cilium_with_Thomas_Graf.mp3

P4 on the Edge, John Fastabend, OVS Orbit, Episode 11, https://ovsorbit.org/#e11 https://ovsorbit.org/episode-11.mp3

Cilium, Thomas Graf, OVS Orbit, Episode 4, https://ovsorbit.org/#e4 https://ovsorbit.org/episode-4.mp3

The following (incomplete) list includes blog posts around BPF, XDP and related projects:

An entertaining eBPF XDP adventure, Suchakra Sharma, https://suchakra.wordpress.com/2017/05/23/an-entertaining-ebpf-xdp-adventure/

eBPF, part 2: Syscall and Map Types, Ferris Ellis, https://ferrisellis.com/posts/ebpf_syscall_and_maps/

Monitoring the Control Plane, Gary Berger, https://www.firstclassfunc.com/2018/07/monitoring-the-control-plane/

USENIX/LISA 2016 Linux bcc/BPF Tools, Brendan Gregg, http://www.brendangregg.com/blog/2017-04-29/usenix-lisa-2016-bcc-bpf-tools.html

Liveblog: Cilium for Network and Application Security with BPF and XDP, Scott Lowe, https://blog.scottlowe.org/2017/04/18/black-belt-cilium/

eBPF, part 1: Past, Present, and Future, Ferris Ellis, https://ferrisellis.com/posts/ebpf_past_present_future/

Analyzing KVM Hypercalls with eBPF Tracing, Suchakra Sharma, https://suchakra.wordpress.com/2017/03/31/analyzing-kvm-hypercalls-with-ebpf-tracing/

Golang bcc/BPF Function Tracing, Brendan Gregg, http://www.brendangregg.com/blog/2017-01-31/golang-bcc-bpf-function-tracing.html

Give me 15 minutes and I’ll change your view of Linux tracing, Brendan Gregg, http://www.brendangregg.com/blog/2016-12-27/linux-tracing-in-15-minutes.html

Cilium: Networking and security for containers with BPF and XDP, Daniel Borkmann, https://opensource.googleblog.com/2016/11/cilium-networking-and-security.html

Linux bcc/BPF tcplife: TCP Lifespans, Brendan Gregg, http://www.brendangregg.com/blog/2016-11-30/linux-bcc-tcplife.html

DTrace for Linux 2016, Brendan Gregg, http://www.brendangregg.com/blog/2016-10-27/dtrace-for-linux-2016.html

Linux 4.9’s Efficient BPF-based Profiler, Brendan Gregg, http://www.brendangregg.com/blog/2016-10-21/linux-efficient-profiler.html

Linux bcc tcptop, Brendan Gregg, http://www.brendangregg.com/blog/2016-10-15/linux-bcc-tcptop.html

Linux bcc/BPF Node.js USDT Tracing, Brendan Gregg, http://www.brendangregg.com/blog/2016-10-12/linux-bcc-nodejs-usdt.html

Linux bcc/BPF Run Queue (Scheduler) Latency, Brendan Gregg, http://www.brendangregg.com/blog/2016-10-08/linux-bcc-runqlat.html

Linux bcc ext4 Latency Tracing, Brendan Gregg, http://www.brendangregg.com/blog/2016-10-06/linux-bcc-ext4dist-ext4slower.html

Linux MySQL Slow Query Tracing with bcc/BPF, Brendan Gregg, http://www.brendangregg.com/blog/2016-10-04/linux-bcc-mysqld-qslower.html

Linux bcc Tracing Security Capabilities, Brendan Gregg, http://www.brendangregg.com/blog/2016-10-01/linux-bcc-security-capabilities.html

Suricata bypass feature, Eric Leblond, https://www.stamus-networks.com/blog/2016/09/28/suricata-bypass-feature

Introducing the p0f BPF compiler, Gilberto Bertin, https://blog.cloudflare.com/introducing-the-p0f-bpf-compiler/

Ubuntu Xenial bcc/BPF, Brendan Gregg, http://www.brendangregg.com/blog/2016-06-14/ubuntu-xenial-bcc-bpf.html

Linux BPF/bcc Road Ahead, March 2016, Brendan Gregg, http://www.brendangregg.com/blog/2016-03-28/linux-bpf-bcc-road-ahead-2016.html

Linux BPF Superpowers, Brendan Gregg, http://www.brendangregg.com/blog/2016-03-05/linux-bpf-superpowers.html

Linux eBPF/bcc uprobes, Brendan Gregg, http://www.brendangregg.com/blog/2016-02-08/linux-ebpf-bcc-uprobes.html

Who is waking the waker? (Linux chain graph prototype), Brendan Gregg, http://www.brendangregg.com/blog/2016-02-05/ebpf-chaingraph-prototype.html

Linux Wakeup and Off-Wake Profiling, Brendan Gregg, http://www.brendangregg.com/blog/2016-02-01/linux-wakeup-offwake-profiling.html

Linux eBPF Off-CPU Flame Graph, Brendan Gregg, http://www.brendangregg.com/blog/2016-01-20/ebpf-offcpu-flame-graph.html

Linux eBPF Stack Trace Hack, Brendan Gregg, http://www.brendangregg.com/blog/2016-01-18/ebpf-stack-trace-hack.html

Linux Networking, Tracing and IO Visor, a New Systems Performance Tool for a Distributed World, Suchakra Sharma, https://thenewstack.io/comparing-dtrace-iovisor-new-systems-performance-platform-advance-linux-networking-virtualization/

BPF Internals - II, Suchakra Sharma, https://suchakra.wordpress.com/2015/08/12/bpf-internals-ii/

eBPF: One Small Step, Brendan Gregg, http://www.brendangregg.com/blog/2015-05-15/ebpf-one-small-step.html

BPF Internals - I, Suchakra Sharma, https://suchakra.wordpress.com/2015/05/18/bpf-internals-i/

Introducing the BPF Tools, Marek Majkowski, https://blog.cloudflare.com/introducing-the-bpf-tools/

BPF - the forgotten bytecode, Marek Majkowski, https://blog.cloudflare.com/bpf-the-forgotten-bytecode/

BPF Performance Tools (Gregg, Addison Wesley, 2019)

The following (incomplete) list includes talks and conference papers related to BPF and XDP:

eBPF & Cilium Office Hours episode 13: XDP Hands-on Tutorial, with Liz Rice, https://www.youtube.com/watch?v=YUI78vC4qSQ&t=300s

eBPF & Cilium Office Hours episode 9: XDP and Load Balancing, with Daniel Borkmann, https://www.youtube.com/watch?v=OIyPm6K4ooY&t=308s

PyCon 2017, Portland, Executing python functions in the linux kernel by transpiling to bpf, Alex Gartrell, https://www.youtube.com/watch?v=CpqMroMBGP4

gluecon 2017, Denver, Cilium + BPF: Least Privilege Security on API Call Level for Microservices, Dan Wendlandt, http://gluecon.com/#agenda

Lund Linux Con, Lund, XDP - eXpress Data Path, Jesper Dangaard Brouer, http://people.netfilter.org/hawk/presentations/LLC2017/XDP_DDoS_protecting_LLC2017.pdf

Polytechnique Montreal, Trace Aggregation and Collection with eBPF, Suchakra Sharma, https://hsdm.dorsal.polymtl.ca/system/files/eBPF-5May2017%20(1).pdf

DockerCon, Austin, Cilium - Network and Application Security with BPF and XDP, Thomas Graf, https://www.slideshare.net/ThomasGraf5/dockercon-2017-cilium-network-and-application-security-with-bpf-and-xdp

NetDev 2.1, Montreal, XDP Mythbusters, David S. Miller, https://netdevconf.info/2.1/slides/apr7/miller-XDP-MythBusters.pdf

NetDev 2.1, Montreal, Droplet: DDoS countermeasures powered by BPF + XDP, Huapeng Zhou, Doug Porter, Ryan Tierney, Nikita Shirokov, https://netdevconf.info/2.1/slides/apr6/zhou-netdev-xdp-2017.pdf

NetDev 2.1, Montreal, XDP in practice: integrating XDP in our DDoS mitigation pipeline, Gilberto Bertin, https://netdevconf.info/2.1/slides/apr6/bertin_Netdev-XDP.pdf

NetDev 2.1, Montreal, XDP for the Rest of Us, Andy Gospodarek, Jesper Dangaard Brouer, https://netdevconf.info/2.1/slides/apr7/gospodarek-Netdev2.1-XDP-for-the-Rest-of-Us_Final.pdf

SCALE15x, Pasadena, Linux 4.x Tracing: Performance Analysis with bcc/BPF, Brendan Gregg, https://www.slideshare.net/brendangregg/linux-4x-tracing-performance-analysis-with-bccbpf

XDP Inside and Out, David S. Miller, https://raw.githubusercontent.com/iovisor/bpf-docs/master/XDP_Inside_and_Out.pdf

OpenSourceDays, Copenhagen, XDP - eXpress Data Path, Used for DDoS protection, Jesper Dangaard Brouer, http://people.netfilter.org/hawk/presentations/OpenSourceDays2017/XDP_DDoS_protecting_osd2017.pdf

source{d}, Infrastructure 2017, Madrid, High-performance Linux monitoring with eBPF, Alfonso Acosta, https://www.youtube.com/watch?v=k4jqTLtdrxQ

FOSDEM 2017, Brussels, Stateful packet processing with eBPF, an implementation of OpenState interface, Quentin Monnet, https://archive.fosdem.org/2017/schedule/event/stateful_ebpf/

FOSDEM 2017, Brussels, eBPF and XDP walkthrough and recent updates, Daniel Borkmann, http://borkmann.ch/talks/2017_fosdem.pdf

FOSDEM 2017, Brussels, Cilium - BPF & XDP for containers, Thomas Graf, https://archive.fosdem.org/2017/schedule/event/cilium/

linuxconf.au, Hobart, BPF: Tracing and more, Brendan Gregg, https://www.slideshare.net/brendangregg/bpf-tracing-and-more

USENIX LISA 2016, Boston, Linux 4.x Tracing Tools: Using BPF Superpowers, Brendan Gregg, https://www.slideshare.net/brendangregg/linux-4x-tracing-tools-using-bpf-superpowers

Linux Plumbers, Santa Fe, Cilium: Networking & Security for Containers with BPF & XDP, Thomas Graf, https://www.slideshare.net/ThomasGraf5/clium-container-networking-with-bpf-xdp

OVS Conference, Santa Clara, Offloading OVS Flow Processing using eBPF, William (Cheng-Chun) Tu, http://www.openvswitch.org/support/ovscon2016/7/1120-tu.pdf

One.com, Copenhagen, XDP - eXpress Data Path, Intro and future use-cases, Jesper Dangaard Brouer, http://people.netfilter.org/hawk/presentations/xdp2016/xdp_intro_and_use_cases_sep2016.pdf

Docker Distributed Systems Summit, Berlin, Cilium: Networking & Security for Containers with BPF & XDP, Thomas Graf, https://www.slideshare.net/Docker/cilium-bpf-xdp-for-containers-66969823

NetDev 1.2, Tokyo, Data center networking stack, Tom Herbert, https://netdevconf.info/1.2/session.html?tom-herbert

NetDev 1.2, Tokyo, Fast Programmable Networks & Encapsulated Protocols, David S. Miller, https://netdevconf.info/1.2/session.html?david-miller-keynote

NetDev 1.2, Tokyo, XDP workshop - Introduction, experience, and future development, Tom Herbert, https://netdevconf.info/1.2/session.html?herbert-xdp-workshop

NetDev1.2, Tokyo, The adventures of a Suricate in eBPF land, Eric Leblond, https://netdevconf.info/1.2/slides/oct6/10_suricata_ebpf.pdf

NetDev1.2, Tokyo, cls_bpf/eBPF updates since netdev 1.1, Daniel Borkmann, http://borkmann.ch/talks/2016_tcws.pdf

NetDev1.2, Tokyo, Advanced programmability and recent updates with tc’s cls_bpf, Daniel Borkmann, http://borkmann.ch/talks/2016_netdev2.pdf https://netdevconf.info/1.2/papers/borkmann.pdf

NetDev 1.2, Tokyo, eBPF/XDP hardware offload to SmartNICs, Jakub Kicinski, Nic Viljoen, https://netdevconf.info/1.2/papers/eBPF_HW_OFFLOAD.pdf

LinuxCon, Toronto, What Can BPF Do For You?, Brenden Blanco, https://events.static.linuxfound.org/sites/events/files/slides/iovisor-lc-bof-2016.pdf

LinuxCon, Toronto, Cilium - Fast IPv6 Container Networking with BPF and XDP, Thomas Graf, https://www.slideshare.net/ThomasGraf5/cilium-fast-ipv6-container-networking-with-bpf-and-xdp

P4, EBPF and Linux TC Offload, Dinan Gunawardena, Jakub Kicinski, https://de.slideshare.net/Open-NFP/p4-epbf-and-linux-tc-offload

Linux Meetup, Santa Clara, eXpress Data Path, Brenden Blanco, https://www.slideshare.net/IOVisor/express-data-path-linux-meetup-santa-clara-july-2016

Linux Meetup, Santa Clara, CETH for XDP, Yan Chan, Yunsong Lu, https://www.slideshare.net/IOVisor/ceth-for-xdp-linux-meetup-santa-clara-july-2016

P4 workshop, Stanford, P4 on the Edge, John Fastabend, https://schd.ws/hosted_files/2016p4workshop/1d/Intel%20Fastabend-P4%20on%20the%20Edge.pdf

Performance @Scale 2016, Menlo Park, Linux BPF Superpowers, Brendan Gregg, https://www.slideshare.net/brendangregg/linux-bpf-superpowers

eXpress Data Path, Tom Herbert, Alexei Starovoitov, https://raw.githubusercontent.com/iovisor/bpf-docs/master/Express_Data_Path.pdf

NetDev1.1, Seville, On getting tc classifier fully programmable with cls_bpf, Daniel Borkmann, http://borkmann.ch/talks/2016_netdev.pdf https://netdevconf.info/1.1/proceedings/papers/On-getting-tc-classifier-fully-programmable-with-cls-bpf.pdf

FOSDEM 2016, Brussels, Linux tc and eBPF, Daniel Borkmann, http://borkmann.ch/talks/2016_fosdem.pdf

LinuxCon Europe, Dublin, eBPF on the Mainframe, Michael Holzheu, https://events.static.linuxfound.org/sites/events/files/slides/ebpf_on_the_mainframe_lcon_2015.pdf

Tracing Summit, Seattle, LLTng’s Trace Filtering and beyond (with some eBPF goodness, of course!), Suchakra Sharma, https://raw.githubusercontent.com/iovisor/bpf-docs/master/ebpf_excerpt_20Aug2015.pdf

LinuxCon Japan, Tokyo, Exciting Developments in Linux Tracing, Elena Zannoni, https://events.static.linuxfound.org/sites/events/files/slides/tracing-linux-ezannoni-linuxcon-ja-2015_0.pdf

Collaboration Summit, Santa Rosa, BPF: In-kernel Virtual Machine, Alexei Starovoitov, https://events.static.linuxfound.org/sites/events/files/slides/bpf_collabsummit_2015feb20.pdf

NetDev 0.1, Ottawa, BPF: In-kernel Virtual Machine, Alexei Starovoitov, https://netdevconf.info/0.1/sessions/15.html

DevConf.cz, Brno, tc and cls_bpf: lightweight packet classifying with BPF, Daniel Borkmann, http://borkmann.ch/talks/2014_devconf.pdf

Dive into BPF: a list of reading material, Quentin Monnet (https://qmonnet.github.io/whirl-offload/2016/09/01/dive-into-bpf/)

XDP - eXpress Data Path, Jesper Dangaard Brouer (https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/index.html)

---

## Protocol Documentation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/_api/v1/standalone-dns-proxy/README/

**Contents:**
- Protocol Documentation
- Table of Contents
- standalone-dns-proxy/standalone-dns-proxy.proto
  - DNSPolicy
  - DNSServer
  - EndpointInfo
  - FQDNMapping
  - IdentityToEndpointMapping
  - PolicyState
  - PolicyStateResponse

standalone-dns-proxy/standalone-dns-proxy.proto

IdentityToEndpointMapping

UpdateMappingResponse

L7 DNS policy specifying which requests are permitted to which DNS server

Endpoint ID of the workload this L7 DNS policy should apply to

Allowed DNS pattern this identity is allowed to resolve.

List of DNS servers to be allowed to connect.

DNServer identity, port and protocol the requests be allowed to

Identity of destination DNS server

cilium endpoint ipaddress and ID

FQDN-IP mapping goalstate sent from SDP to agent

List of IPs corresponding to dns name

Identity of the client making the DNS request

IP address of the client making the DNS request

DNS Response code as specified in RFC2316

Cilium Identity ID to IP address mapping

L7 DNS policy snapshot of all local endpoints and identity to ip mapping of source and destinatione egress endpoints enforcing fqdn rules.

Random UUID based identifier which will be referenced in ACKs

identity_to_endpoint_mapping

IdentityToEndpointMapping

Identity to Endpoint mapping for the DNS server and the source identity

Ack sent from SDP to Agent on processing DNS policy rules

Request ID for which response is sent to

Ack returned by cilium agent to SDP on receiving FQDN-IP mapping update

Response code returned by RPC methods.

RESPONSE_CODE_UNSPECIFIED

RESPONSE_CODE_NO_ERROR

RESPONSE_CODE_FORMAT_ERROR

RESPONSE_CODE_SERVER_FAILURE

RESPONSE_CODE_NOT_IMPLEMENTED

RESPONSE_CODE_REFUSED

Cilium agent runs the FQDNData service and Standalone DNS proxy connects to it to get the DNS Policy rules. Standalone DNS proxy sends FQDN-IP mapping updates to Cilium Agent. CFP: https://github.com/cilium/design-cfps/pull/54

PolicyStateResponse stream

StreamPolicyState is used by the Standalone DNS proxy to get the current policy state. Policy state includes the DNS policies and the identity to IP mapping. Cilium agent will stream DNS policies state to Standalone DNS proxy. In case of any client side error, cilium agent will cancel the stream and SDP will have to re-subscribe. In case of any server side error, cilium agent will send an error response and SDP will have to re-subscribe.

UpdateMappingResponse

UpdateMappingRequest is used by the Standalone DNS proxy to update ciliium agent with FQDN-IP mappings which in turn update L3/L4 policy maps. In case of any error, SDP will either retry the connection if the error is server side or will error out. Note: In case of concurrent updates, since this is called in a callback(notifyDNSMsg) from the DNS server it follows the same behavior as the inbuilt dns proxy in cilium.

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead.

Bignum or Fixnum (as required)

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead.

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s.

Always four bytes. More efficient than uint32 if values are often greater than 2^28.

Bignum or Fixnum (as required)

Always eight bytes. More efficient than uint64 if values are often greater than 2^56.

Bignum or Fixnum (as required)

A string must always contain UTF-8 encoded or 7-bit ASCII text.

May contain any arbitrary sequence of bytes.

---

## Protocol Documentation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/_api/v1/peer/README/

**Contents:**
- Protocol Documentation
- Table of Contents
- peer/peer.proto
  - ChangeNotification
  - NotifyRequest
  - TLS
  - ChangeNotificationType
  - Peer
- Scalar Value Types

ChangeNotificationType

ChangeNotification indicates a change regarding a hubble peer.

Name is the name of the peer, typically the hostname. The name includes the cluster name if a value other than default has been specified. This value can be used to uniquely identify the host. When the cluster name is not the default, the cluster name is prepended to the peer name and a forward slash is added.

Examples: - runtime1 - testcluster/runtime1 | | address | string | | Address is the address of the peer’s gRPC service. | | type | ChangeNotificationType | | ChangeNotificationType indicates the type of change, ie whether the peer was added, deleted or updated. | | tls | TLS | | TLS provides information to connect to the Address with TLS enabled. If not set, TLS shall be assumed to be disabled. |

TLS provides information to establish a TLS connection to the peer.

ServerName is used to verify the hostname on the returned certificate.

ChangeNotificationType defines the peer change notification type.

Peer lists hubble peers and notifies of changes.

ChangeNotification stream

Notify sends information about hubble peers in the cluster. When Notify is called, it sends information about all the peers that are already part of the cluster (with the type as PEER_ADDED). It subsequently notifies of any change.

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead.

Bignum or Fixnum (as required)

Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead.

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s.

Bignum or Fixnum (as required)

Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s.

Always four bytes. More efficient than uint32 if values are often greater than 2^28.

Bignum or Fixnum (as required)

Always eight bytes. More efficient than uint64 if values are often greater than 2^56.

Bignum or Fixnum (as required)

A string must always contain UTF-8 encoded or 7-bit ASCII text.

May contain any arbitrary sequence of bytes.

---
