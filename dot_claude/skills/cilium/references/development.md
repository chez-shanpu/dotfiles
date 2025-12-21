# Cilium - Development

**Pages:** 1

---

## Development Tools — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/reference-guides/bpf/toolchain/

**Contents:**
- Development Tools
- Development Environment
  - Compiling the Kernel
  - Verifying the Setup
  - Compiling iproute2
  - Compiling bpftool
- LLVM
- iproute2

Current user space tooling, introspection facilities and kernel control knobs around BPF are discussed in this section.

The tooling and infrastructure around BPF is still rapidly evolving and thus may not provide a complete picture of all available tools.

A step by step guide for setting up a development environment for BPF can be found below for both Fedora and Ubuntu. This will guide you through building, installing and testing a development kernel as well as building and installing iproute2.

The step of manually building iproute2 and Linux kernel is usually not necessary given that major distributions already ship recent enough kernels by default, but would be needed for testing bleeding edge versions or contributing BPF patches to iproute2 and to the Linux kernel, respectively. Similarly, for debugging and introspection purposes building bpftool is optional but recommended.

The following applies to Fedora 25 or later:

If you are running some other Fedora derivative and dnf is missing, try using yum instead.

The following applies to Ubuntu 17.04 or later:

The following applies to openSUSE Tumbleweed and openSUSE Leap 15.0 or later:

Development of new BPF features for the Linux kernel happens inside the net-next git tree, latest BPF fixes in the net tree. The following command will obtain the kernel source for the net-next tree through git:

If the git commit history is not of interest, then --depth 1 will clone the tree much faster by truncating the git history only to the most recent commit.

In case the net tree is of interest, it can be cloned from this url:

There are dozens of tutorials on the Internet on how to build Linux kernels, one good resource is the Kernel Newbies website (https://kernelnewbies.org/KernelBuild) that can be followed with one of the two git trees mentioned above.

Make sure that the generated .config file contains the following CONFIG_* entries for running BPF. These entries are also needed for Cilium.

Some of the entries cannot be adjusted through make menuconfig. For example, CONFIG_HAVE_EBPF_JIT is selected automatically if a given architecture does come with an eBPF JIT. In this specific case, CONFIG_HAVE_EBPF_JIT is optional but highly recommended. An architecture not having an eBPF JIT compiler will need to fall back to the in-kernel interpreter with the cost of being less efficient executing BPF instructions.

After you have booted into the newly compiled kernel, navigate to the BPF selftest suite in order to test BPF functionality (current working directory points to the root of the cloned git tree):

The verifier tests print out all the current checks being performed. The summary at the end of running all tests will dump information of test successes and failures:

For kernel releases 4.16+ the BPF selftest has a dependency on LLVM 6.0+ caused by the BPF function calls which do not need to be inlined anymore. See section BPF to BPF Calls or the cover letter mail from the kernel patch (https://lwn.net/Articles/741773/) for more information. Not every BPF program has a dependency on LLVM 6.0+ if it does not use this new feature. If your distribution does not provide LLVM 6.0+ you may compile it by following the instruction in the LLVM section.

In order to run through all BPF selftests, the following command is needed:

If you see any failures, please contact us on Cilium Slack with the full test output.

Similar to the net (fixes only) and net-next (new features) kernel trees, iproute2 is split into two separate trees, namely iproute and iproute2-next. The iproute2 repository is based on the net tree and the iproute2-next repository is based against the net-next kernel tree. This is necessary, so that changes in header files can be synchronized in the iproute2 tree.

To clone the stable iproute2 repository:

Similarly, to clone the mentioned development iproute2-next tree:

After that, proceed with the build and installation:

Ensure that the configure script shows ELF support: yes, so that iproute2 can process ELF files from LLVM’s BPF back end. libelf was listed in the instructions for installing the dependencies in case of Fedora and Ubuntu earlier.

bpftool is an essential tool around debugging and introspection of BPF programs and maps. It is part of the kernel tree and available under tools/bpf/bpftool/.

Make sure to have cloned either the net or net-next kernel tree as described earlier. In order to build and install bpftool, the following steps are required:

LLVM is currently the only compiler suite providing a BPF back end. gcc does not support BPF at this point.

The BPF back end was merged into LLVM’s 3.7 release. Major distributions enable the BPF back end by default when they package LLVM, therefore installing clang and llvm is sufficient on most recent distributions to start compiling C into BPF object files.

The typical workflow is that BPF programs are written in C, compiled by LLVM into object / ELF files, which are parsed by user space BPF ELF loaders (such as iproute2 or others) and pushed into the kernel through the BPF system call. The kernel verifies the BPF instructions and JITs them, returning a new file descriptor for the program, which then can be attached to a subsystem (e.g. networking). If supported, the subsystem could then further offload the BPF program to hardware (e.g. NIC).

For LLVM, BPF target support can be checked, for example, through the following:

By default, the bpf target uses the endianness of the CPU it compiles on, meaning that if the CPU’s endianness is little endian, the program is represented in little endian format as well, and if the CPU’s endianness is big endian, the program is represented in big endian. This also matches the runtime behavior of BPF, which is generic and uses the CPU’s endianness it runs on in order to not disadvantage architectures in any of the format.

For cross-compilation, the two targets bpfeb and bpfel were introduced, thanks to that BPF programs can be compiled on a node running in one endianness (e.g. little endian on x86) and run on a node in another endianness format (e.g. big endian on arm). Note that the front end (clang) needs to run in the target endianness as well.

Using bpf as a target is the preferred way in situations where no mixture of endianness applies. For example, compilation on x86_64 results in the same output for the targets bpf and bpfel due to being little endian, therefore scripts triggering a compilation also do not have to be endian aware.

A minimal, stand-alone XDP drop program might look like the following example (xdp-example.c):

It can then be compiled and loaded into the kernel as follows:

Attaching an XDP BPF program to a network device as above requires Linux 4.11 with a device that supports XDP, or Linux 4.12 or later.

For the generated object file LLVM (>= 3.9) uses the official BPF machine value, that is, EM_BPF (decimal: 247 / hex: 0xf7). In this example, the program has been compiled with bpf target under x86_64, therefore LSB (as opposed to MSB) is shown regarding endianness:

readelf -a xdp-example.o will dump further information about the ELF file, which can sometimes be useful for introspecting generated section headers, relocation entries and the symbol table.

In the unlikely case where clang and LLVM need to be compiled from scratch, the following commands can be used:

Make sure that --version mentions Optimized build., otherwise the compilation time for programs when having LLVM in debugging mode will significantly increase (e.g. by 10x or more).

For debugging, clang can generate the assembler output as follows:

Starting from LLVM’s release 6.0, there is also assembler parser support. You can program using BPF assembler directly, then use llvm-mc to assemble it into an object file. For example, you can assemble the xdp-example.S listed above back into object file using:

Furthermore, more recent LLVM versions (>= 4.0) can also store debugging information in dwarf format into the object file. This can be done through the usual workflow by adding -g for compilation.

The llvm-objdump tool can then annotate the assembler output with the original C code used in the compilation. The trivial example in this case does not contain much C code, however, the line numbers shown as 0: and 1: correspond directly to the kernel’s verifier log.

This means that in case BPF programs get rejected by the verifier, llvm-objdump can help to correlate the instructions back to the original C code, which is highly useful for analysis.

As it can be seen in the verifier analysis, the llvm-objdump output dumps the same BPF assembler code as the kernel.

Leaving out the --no-show-raw-insn option will also dump the raw struct bpf_insn as hex in front of the assembly:

For LLVM IR debugging, the compilation process for BPF can be split into two steps, generating a binary LLVM IR intermediate file xdp-example.bc, which can later on be passed to llc:

The generated LLVM IR can also be dumped in human readable format through:

LLVM can attach debug information such as the description of used data types in the program to the generated BPF object file. By default, this is in DWARF format.

A heavily simplified version used by BPF is called BTF (BPF Type Format). The resulting DWARF can be converted into BTF and is later on loaded into the kernel through BPF object loaders. The kernel will then verify the BTF data for correctness and keeps track of the data types the BTF data is containing.

BPF maps can then be annotated with key and value types out of the BTF data such that a later dump of the map exports the map data along with the related type information. This allows for better introspection, debugging and value pretty printing. Note that BTF data is a generic debugging data format and as such any DWARF to BTF converted data can be loaded (e.g. kernel’s vmlinux DWARF data could be converted to BTF and loaded). Latter is in particular useful for BPF tracing in the future.

In order to generate BTF from DWARF debugging information, elfutils (>= 0.173) is needed. If that is not available, then adding the -mattr=dwarfris option to the llc command is required during compilation:

The reason using -mattr=dwarfris is because the flag dwarfris (dwarf relocation in section) disables DWARF cross-section relocations between DWARF and the ELF’s symbol table since libdw does not have proper BPF relocation support, and therefore tools like pahole would otherwise not be able to properly dump structures from the object.

elfutils (>= 0.173) implements proper BPF relocation support and therefore the same can be achieved without the -mattr=dwarfris option. Dumping the structures from the object file could be done from either DWARF or BTF information. pahole uses the LLVM emitted DWARF information at this point, however, future pahole versions could rely on BTF if available.

For converting DWARF into BTF, a recent pahole version (>= 1.12) is required. A recent pahole version can also be obtained from its official git repository if not available from one of the distribution packages:

pahole comes with the option -J to convert DWARF into BTF from an object file. pahole can be probed for BTF support as follows (note that the llvm-objcopy tool is required for pahole as well, so check its presence, too):

Generating debugging information also requires the front end to generate source level debug information by passing -g to the clang command line. Note that -g is needed independently of whether llc’s dwarfris option is used. Full example for generating the object file:

Alternatively, by using clang only to build a BPF program with debugging information (again, the dwarfris flag can be omitted when having proper elfutils version):

After successful compilation pahole can be used to properly dump structures of the BPF program based on the DWARF information:

Through the option -J pahole can eventually generate the BTF from DWARF. In the object file DWARF data will still be retained alongside the newly added BTF data. Full clang and pahole example combined:

The presence of a .BTF section can be seen through readelf tool:

BPF loaders such as iproute2 will detect and load the BTF section, so that BPF maps can be annotated with type information.

LLVM by default uses the BPF base instruction set for generating code in order to make sure that the generated object file can also be loaded with older kernels such as long-term stable kernels (e.g. 4.9+).

However, LLVM has a -mcpu selector for the BPF back end in order to select different versions of the BPF instruction set, namely instruction set extensions on top of the BPF base instruction set in order to generate more efficient and smaller code.

Available -mcpu options can be queried through:

The generic processor is the default processor, which is also the base instruction set v1 of BPF. Options v1 and v2 are typically useful in an environment where the BPF program is being cross compiled and the target host where the program is loaded differs from the one where it is compiled (and thus available BPF kernel features might differ as well).

The recommended -mcpu option which is also used by Cilium internally is -mcpu=probe! Here, the LLVM BPF back end queries the kernel for availability of BPF instruction set extensions and when found available, LLVM will use them for compiling the BPF program whenever appropriate.

A full command line example with llc’s -mcpu=probe:

Generally, LLVM IR generation is architecture independent. However, there are a few differences when using clang --target=bpf versus leaving --target=bpf out and thus using clang’s default target which, depending on the underlying architecture, might be x86_64, arm64 or others.

Quoting from the kernel’s Documentation/bpf/bpf_devel_QA.txt:

BPF programs may recursively include header file(s) with file scope inline assembly codes. The default target can handle this well, while bpf target may fail if bpf backend assembler does not understand these assembly codes, which is true in most cases.

When compiled without -g, additional elf sections, e.g., .eh_frame and .rela.eh_frame, may be present in the object file with default target, but not with bpf target.

The default target may turn a C switch statement into a switch table lookup and jump operation. Since the switch table is placed in the global read-only section, the bpf program will fail to load. The bpf target does not support switch table optimization. The clang option -fno-jump-tables can be used to disable switch table generation.

For clang --target=bpf, it is guaranteed that pointer or long / unsigned long types will always have a width of 64 bit, no matter whether underlying clang binary or default target (or kernel) is 32 bit. However, when native clang target is used, then it will compile these types based on the underlying architecture’s conventions, meaning in case of 32 bit architecture, pointer or long / unsigned long types e.g. in BPF context structure will have width of 32 bit while the BPF LLVM back end still operates in 64 bit.

The native target is mostly needed in tracing for the case of walking the kernel’s struct pt_regs that maps CPU registers, or other kernel structures where CPU’s register width matters. In all other cases such as networking, the use of clang --target=bpf is the preferred choice.

Also, LLVM started to support 32-bit subregisters and BPF ALU32 instructions since LLVM’s release 7.0. A new code generation attribute alu32 is added. When it is enabled, LLVM will try to use 32-bit subregisters whenever possible, typically when there are operations on 32-bit types. The associated ALU instructions with 32-bit subregisters will become ALU32 instructions. For example, for the following sample code:

At default code generation, the assembler looks like:

64-bit registers are used, hence the addition means 64-bit addition. Now, if you enable the new 32-bit subregisters support by specifying -mattr=+alu32, then the assembler looks like:

w register, meaning 32-bit subregister, will be used instead of 64-bit r register.

Enable 32-bit subregisters might help reducing type extension instruction sequences. It could also help kernel eBPF JIT compiler for 32-bit architectures for which registers pairs are used to model the 64-bit eBPF registers and extra instructions are needed for manipulating the high 32-bit. Given read from 32-bit subregister is guaranteed to read from low 32-bit only even though write still needs to clear the high 32-bit, if the JIT compiler has known the definition of one register only has subregister reads, then instructions for setting the high 32-bit of the destination could be eliminated.

When writing C programs for BPF, there are a couple of pitfalls to be aware of, compared to usual application development with C. The following items describe some of the differences for the BPF model:

Everything needs to be inlined, there are no function calls (on older LLVM versions) or shared library calls available.

Shared libraries, etc cannot be used with BPF. However, common library code used in BPF programs can be placed into header files and included in the main programs. For example, Cilium makes heavy use of it (see bpf/lib/). However, this still allows for including header files, for example, from the kernel or other libraries and reuse their static inline functions or macros / definitions.

Unless a recent kernel (4.16+) and LLVM (6.0+) is used where BPF to BPF function calls are supported, then LLVM needs to compile and inline the entire code into a flat sequence of BPF instructions for a given program section. In such case, best practice is to use an annotation like __inline for every library function as shown below. The use of always_inline is recommended, since the compiler could still decide to uninline large functions that are only annotated as inline.

In case the latter happens, LLVM will generate a relocation entry into the ELF file, which BPF ELF loaders such as iproute2 cannot resolve and will thus produce an error since only BPF maps are valid relocation entries which loaders can process.

Multiple programs can reside inside a single C file in different sections.

C programs for BPF make heavy use of section annotations. A C file is typically structured into 3 or more sections. BPF ELF loaders use these names to extract and prepare the relevant information in order to load the programs and maps through the bpf system call. For example, iproute2 uses maps and license as default section name to find metadata needed for map creation and the license for the BPF program, respectively. On program creation time the latter is pushed into the kernel as well, and enables some of the helper functions which are exposed as GPL only in case the program also holds a GPL compatible license, for example bpf_ktime_get_ns(), bpf_probe_read() and others.

The remaining section names are specific for BPF program code, for example, the below code has been modified to contain two program sections, ingress and egress. The toy example code demonstrates that both can share a map and common static inline helpers such as the account_data() function.

The xdp-example.c example has been modified to a tc-example.c example that can be loaded with tc and attached to a netdevice’s ingress and egress hook. It accounts the transferred bytes into a map called acc_map, which has two map slots, one for traffic accounted on the ingress hook, one on the egress hook.

The example also demonstrates a couple of other things which are useful to be aware of when developing programs. The code includes kernel headers, standard C headers and an iproute2 specific header containing the definition of struct bpf_elf_map. iproute2 has a common BPF ELF loader and as such the definition of struct bpf_elf_map is the very same for XDP and tc typed programs.

A struct bpf_elf_map entry defines a map in the program and contains all relevant information (such as key / value size, etc) needed to generate a map which is used from the two BPF programs. The structure must be placed into the maps section, so that the loader can find it. There can be multiple map declarations of this type with different variable names, but all must be annotated with __section("maps").

The struct bpf_elf_map is specific to iproute2. Different BPF ELF loaders can have different formats, for example, the libbpf in the kernel source tree, which is mainly used by perf, has a different specification. iproute2 guarantees backwards compatibility for struct bpf_elf_map. Cilium follows the iproute2 model.

The example also demonstrates how BPF helper functions are mapped into the C code and being used. Here, map_lookup_elem() is defined by mapping this function into the BPF_FUNC_map_lookup_elem enum value which is exposed as a helper in uapi/linux/bpf.h. When the program is later loaded into the kernel, the verifier checks whether the passed arguments are of the expected type and re-points the helper call into a real function call. Moreover, map_lookup_elem() also demonstrates how maps can be passed to BPF helper functions. Here, &acc_map from the maps section is passed as the first argument to map_lookup_elem().

Since the defined array map is global, the accounting needs to use an atomic operation, which is defined as lock_xadd(). LLVM maps __sync_fetch_and_add() as a built-in function to the BPF atomic add instruction, that is, BPF_STX | BPF_XADD | BPF_W for word sizes.

Last but not least, the struct bpf_elf_map tells that the map is to be pinned as PIN_GLOBAL_NS. This means that tc will pin the map into the BPF pseudo file system as a node. By default, it will be pinned to /sys/fs/bpf/tc/globals/acc_map for the given example. Due to the PIN_GLOBAL_NS, the map will be placed under /sys/fs/bpf/tc/globals/. globals acts as a global namespace that spans across object files. If the example used PIN_OBJECT_NS, then tc would create a directory that is local to the object file. For example, different C files with BPF code could have the same acc_map definition as above with a PIN_GLOBAL_NS pinning. In that case, the map will be shared among BPF programs originating from various object files. PIN_NONE would mean that the map is not placed into the BPF file system as a node, and as a result, will not be accessible from user space after tc quits. It would also mean that tc creates two separate map instances for each program, since it cannot retrieve a previously pinned map under that name. The acc_map part from the mentioned path is the name of the map as specified in the source code.

Thus, upon loading of the ingress program, tc will find that no such map exists in the BPF file system and creates a new one. On success, the map will also be pinned, so that when the egress program is loaded through tc, it will find that such map already exists in the BPF file system and will reuse that for the egress program. The loader also makes sure in case maps exist with the same name that also their properties (key / value size, etc) match.

Just like tc can retrieve the same map, also third party applications can use the BPF_OBJ_GET command from the bpf system call in order to create a new file descriptor pointing to the same map instance, which can then be used to lookup / update / delete map elements.

The code can be compiled and loaded via iproute2 as follows:

As soon as packets pass the em1 device, counters from the BPF map will be increased.

There are no global variables allowed.

For the reasons already mentioned in point 1, BPF cannot have global variables as often used in normal C programs.

However, there is a work-around in that the program can simply use a BPF map of type BPF_MAP_TYPE_PERCPU_ARRAY with just a single slot of arbitrary value size. This works, because during execution, BPF programs are guaranteed to never get preempted by the kernel and therefore can use the single map entry as a scratch buffer for temporary data, for example, to extend beyond the stack limitation. This also functions across tail calls, since it has the same guarantees with regards to preemption.

Otherwise, for holding state across multiple BPF program runs, normal BPF maps can be used.

There are no const strings or arrays allowed.

Defining const strings or other arrays in the BPF C program does not work for the same reasons as pointed out in sections 1 and 3, which is, that relocation entries will be generated in the ELF file which will be rejected by loaders due to not being part of the ABI towards loaders (loaders also cannot fix up such entries as it would require large rewrites of the already compiled BPF sequence).

In the future, LLVM might detect these occurrences and early throw an error to the user.

Helper functions such as trace_printk() can be worked around as follows:

The program can then use the macro naturally like printk("skb len:%u\n", skb->len);. The output will then be written to the trace pipe. tc exec bpf dbg can be used to retrieve the messages from there.

The use of the trace_printk() helper function has a couple of disadvantages and thus is not recommended for production usage. Constant strings like the "skb len:%u\n" need to be loaded into the BPF stack each time the helper function is called, but also BPF helper functions are limited to a maximum of 5 arguments. This leaves room for only 3 additional variables which can be passed for dumping.

Therefore, despite being helpful for quick debugging, it is recommended (for networking programs) to use the skb_event_output() or the xdp_event_output() helper, respectively. They allow for passing custom structs from the BPF program to the perf event ring buffer along with an optional packet sample. For example, Cilium’s monitor makes use of these helpers in order to implement a debugging framework, notifications for network policy violations, etc. These helpers pass the data through a lockless memory mapped per-CPU perf ring buffer, and is thus significantly faster than trace_printk().

Use of LLVM built-in functions for memset()/memcpy()/memmove()/memcmp().

Since BPF programs cannot perform any function calls other than those to BPF helpers, common library code needs to be implemented as inline functions. In addition, also LLVM provides some built-ins that the programs can use for constant sizes (here: n) which will then always get inlined:

The memcmp() built-in had some corner cases where inlining did not take place due to an LLVM issue in the back end, and is therefore not recommended to be used until the issue is fixed.

There are no loops available (yet).

The BPF verifier in the kernel checks that a BPF program does not contain loops by performing a depth first search of all possible program paths besides other control flow graph validations. The purpose is to make sure that the program is always guaranteed to terminate.

A very limited form of looping is available for constant upper loop bounds by using #pragma unroll directive. Example code that is compiled to BPF:

Another possibility is to use tail calls by calling into the same program again and using a BPF_MAP_TYPE_PERCPU_ARRAY map for having a local scratch space. While being dynamic, this form of looping however is limited to a maximum of 34 iterations (the initial program, plus 33 iterations from the tail calls).

In the future, BPF may have some native, but limited form of implementing loops.

Partitioning programs with tail calls.

Tail calls provide the flexibility to atomically alter program behavior during runtime by jumping from one BPF program into another. In order to select the next program, tail calls make use of program array maps (BPF_MAP_TYPE_PROG_ARRAY), and pass the map as well as the index to the next program to jump to. There is no return to the old program after the jump has been performed, and in case there was no program present at the given map index, then execution continues on the original program.

For example, this can be used to implement various stages of a parser, where such stages could be updated with new parsing features during runtime.

Another use case are event notifications, for example, Cilium can opt in packet drop notifications during runtime, where the skb_event_output() call is located inside the tail called program. Thus, during normal operations, the fall-through path will always be executed unless a program is added to the related map index, where the program then prepares the metadata and triggers the event notification to a user space daemon.

Program array maps are quite flexible, enabling also individual actions to be implemented for programs located in each map index. For example, the root program attached to XDP or tc could perform an initial tail call to index 0 of the program array map, performing traffic sampling, then jumping to index 1 of the program array map, where firewalling policy is applied and the packet either dropped or further processed in index 2 of the program array map, where it is mangled and sent out of an interface again. Jumps in the program array map can, of course, be arbitrary. The kernel will eventually execute the fall-through path when the maximum tail call limit has been reached.

Minimal example extract of using tail calls:

When loading this toy program, tc will create the program array and pin it to the BPF file system in the global namespace under jmp_map. Also, the BPF ELF loader in iproute2 will also recognize sections that are marked as __section_tail(). The provided id in struct bpf_elf_map will be matched against the id marker in the __section_tail(), that is, JMP_MAP_ID, and the program therefore loaded at the user specified program array map index, which is 0 in this example. As a result, all provided tail call sections will be populated by the iproute2 loader to the corresponding maps. This mechanism is not specific to tc, but can be applied with any other BPF program type that iproute2 supports (such as XDP, lwt).

The generated elf contains section headers describing the map id and the entry within that map:

In this case, the section 1/0 indicates that the looper() function resides in the map id 1 at position 0.

The pinned map can be retrieved by user space applications (e.g. Cilium daemon), but also by tc itself in order to update the map with new programs. Updates happen atomically, the initial entry programs that are triggered first from the various subsystems are also updated atomically.

Example for tc to perform tail call map updates:

In case iproute2 would update the pinned program array, the graft command can be used. By pointing it to globals/jmp_map, tc will update the map at index / key 0 with a new program residing in the object file new.o under section foo.

Limited stack space of maximum 512 bytes.

Stack space in BPF programs is limited to only 512 bytes, which needs to be taken into careful consideration when implementing BPF programs in C. However, as mentioned earlier in point 3, a BPF_MAP_TYPE_PERCPU_ARRAY map with a single entry can be used in order to enlarge scratch buffer space.

Use of BPF inline assembly possible.

LLVM 6.0 or later allows use of inline assembly for BPF for the rare cases where it might be needed. The following (nonsense) toy example shows a 64 bit atomic add. Due to lack of documentation, LLVM source code in lib/Target/BPF/BPFInstrInfo.td as well as test/CodeGen/BPF/ might be helpful for providing some additional examples. Test code:

The above program is compiled into the following sequence of BPF instructions:

Remove struct padding with aligning members by using #pragma pack.

In modern compilers, data structures are aligned by default to access memory efficiently. Structure members are packed to memory addresses and padding is added for the proper alignment with the processor word size (e.g. 8-byte for 64-bit processors, 4-byte for 32-bit processors). Because of this, the size of struct may often grow larger than expected.

The BPF verifier in the kernel checks the stack boundary that a BPF program does not access outside of boundary or uninitialized stack area. Using struct with the padding as a map value, will cause invalid indirect read from stack failure on bpf_prog_load().

Corresponding output on bpf_load_program():

At bpf_prog_load(), an eBPF verifier bpf_check() is called, and it’ll check stack boundary by calling check_func_arg() -> check_stack_boundary(). From the upper error shows, struct called_info is compiled to 24-byte size, and the message says reading a data from +20 is an invalid indirect read. And as we discussed earlier, the address 0x14(20) is the place where PADDING is.

The check_stack_boundary() internally loops through the every access_size (24) byte from the start pointer to make sure that it’s within stack boundary and all elements of the stack are initialized. Since the padding isn’t supposed to be used, it gets the ‘invalid indirect read from stack’ failure. To avoid this kind of failure, removing the padding from the struct is necessary.

Removing the padding by using #pragma pack(n) directive:

By locating #pragma pack(4) before of struct called_info, the compiler will align members of a struct to the least of 4-byte and their natural alignment. As you can see, the size of struct called_info has been shrunk to 20-byte and the padding no longer exists.

But, removing the padding has downsides too. For example, the compiler will generate less optimized code. Since we’ve removed the padding, processors will conduct unaligned access to the structure and this might lead to performance degradation. And also, unaligned access might get rejected by verifier on some architectures.

However, there is a way to avoid downsides of packed structure. By simply adding the explicit padding u32 pad member at the end will resolve the same problem without packing of the structure.

Accessing packet data via invalidated references

Some networking BPF helper functions such as bpf_skb_store_bytes might change the size of a packet data. As verifier is not able to track such changes, any a priori reference to the data will be invalidated by verifier. Therefore, the reference needs to be updated before accessing the data to avoid verifier rejecting a program.

To illustrate this, consider the following snippet:

Verifier will reject the snippet due to dereference of the invalidated ip4->protocol:

To fix this, the reference to ip4 has to be updated:

There are various front ends for loading BPF programs into the kernel such as bcc, perf, iproute2 and others. The Linux kernel source tree also provides a user space library under tools/lib/bpf/, which is mainly used and driven by perf for loading BPF tracing programs into the kernel. However, the library itself is generic and not limited to perf only. bcc is a toolkit providing many useful BPF programs mainly for tracing that are loaded ad-hoc through a Python interface embedding the BPF C code. Syntax and semantics for implementing BPF programs slightly differ among front ends in general, though. Additionally, there are also BPF samples in the kernel source tree (samples/bpf/) which parse the generated object files and load the code directly through the system call interface.

This and previous sections mainly focus on the iproute2 suite’s BPF front end for loading networking programs of XDP, tc or lwt type, since Cilium’s programs are implemented against this BPF loader. In future, Cilium will be equipped with a native BPF loader, but programs will still be compatible to be loaded through iproute2 suite in order to facilitate development and debugging.

All BPF program types supported by iproute2 share the same BPF loader logic due to having a common loader back end implemented as a library (lib/bpf.c in iproute2 source tree).

The previous section on LLVM also covered some iproute2 parts related to writing BPF C programs, and later sections in this document are related to tc and XDP specific aspects when writing programs. Therefore, this section will rather focus on usage examples for loading object files with iproute2 as well as some of the generic mechanics of the loader. It does not try to provide a complete coverage of all details, but enough for getting started.

1. Loading of XDP BPF object files.

Given a BPF object file prog.o has been compiled for XDP, it can be loaded through ip to a XDP-supported netdevice called em1 with the following command:

The above command assumes that the program code resides in the default section which is called prog in XDP case. Should this not be the case, and the section is named differently, for example, foobar, then the program needs to be loaded as:

Note that it is also possible to load the program out of the .text section. Changing the minimal, stand-alone XDP drop program by removing the __section() annotation from the xdp_drop entry point would look like the following:

And can be loaded as follows:

By default, ip will throw an error in case a XDP program is already attached to the networking interface, to prevent it from being overridden by accident. In order to replace the currently running XDP program with a new one, the -force option must be used:

Most XDP-enabled drivers today support an atomic replacement of the existing program with a new one without traffic interruption. There is always only a single program attached to an XDP-enabled driver due to performance reasons, hence a chain of programs is not supported. However, as described in the previous section, partitioning of programs can be performed through tail calls to achieve a similar use case when necessary.

The ip link command will display an xdp flag if the interface has an XDP program attached. ip link | grep xdp can thus be used to find all interfaces that have XDP running. Further introspection facilities are provided through the detailed view with ip -d link and bpftool can be used to retrieve information about the attached program based on the BPF program ID shown in the ip link dump.

In order to remove the existing XDP program from the interface, the following command must be issued:

In the case of switching a driver’s operation mode from non-XDP to native XDP and vice versa, typically the driver needs to reconfigure its receive (and transmit) rings in order to ensure received packet are set up linearly within a single page for BPF to read and write into. However, once completed, then most drivers only need to perform an atomic replacement of the program itself when a BPF program is requested to be swapped.

In total, XDP supports three operation modes which iproute2 implements as well: xdpdrv, xdpoffload and xdpgeneric.

xdpdrv stands for native XDP, meaning the BPF program is run directly in the driver’s receive path at the earliest possible point in software. This is the normal / conventional XDP mode and requires drivers to implement XDP support, which all major 10G/40G/+ networking drivers in the upstream Linux kernel already provide.

xdpgeneric stands for generic XDP and is intended as an experimental test bed for drivers which do not yet support native XDP. Given the generic XDP hook in the ingress path comes at a much later point in time when the packet already enters the stack’s main receive path as a skb, the performance is significantly less than with processing in xdpdrv mode. xdpgeneric therefore is for the most part only interesting for experimenting, less for production environments.

Last but not least, the xdpoffload mode is implemented by SmartNICs such as those supported by Netronome’s nfp driver and allow for offloading the entire BPF/XDP program into hardware, thus the program is run on each packet reception directly on the card. This provides even higher performance than running in native XDP although not all BPF map types or BPF helper functions are available for use compared to native XDP. The BPF verifier will reject the program in such case and report to the user what is unsupported. Other than staying in the realm of supported BPF features and helper functions, no special precautions have to be taken when writing BPF C programs.

When a command like ip link set dev em1 xdp obj [...] is used, then the kernel will attempt to load the program first as native XDP, and in case the driver does not support native XDP, it will automatically fall back to generic XDP. Thus, for example, using explicitly xdpdrv instead of xdp, the kernel will only attempt to load the program as native XDP and fail in case the driver does not support it, which provides a guarantee that generic XDP is avoided altogether.

Example for enforcing a BPF/XDP program to be loaded in native XDP mode, dumping the link details and unloading the program again:

Same example now for forcing generic XDP, even if the driver would support native XDP, and additionally dumping the BPF instructions of the attached dummy program through bpftool:

And last but not least offloaded XDP, where we additionally dump program information via bpftool for retrieving general metadata:

Note that it is not possible to use xdpdrv and xdpgeneric or other modes at the same time, meaning only one of the XDP operation modes must be picked.

A switch between different XDP modes e.g. from generic to native or vice versa is not atomically possible. Only switching programs within a specific operation mode is:

Switching between modes requires to first leave the current operation mode in order to then enter the new one:

2. Loading of tc BPF object files.

Given a BPF object file prog.o has been compiled for tc, it can be loaded through the tc command to a netdevice. Unlike XDP, there is no driver dependency for supporting attaching BPF programs to the device. Here, the netdevice is called em1, and with the following command the program can be attached to the networking ingress path of em1:

The first step is to set up a clsact qdisc (Linux queueing discipline). clsact is a dummy qdisc similar to the ingress qdisc, which can only hold classifier and actions, but does not perform actual queueing. It is needed in order to attach the bpf classifier. The clsact qdisc provides two special hooks called ingress and egress, where the classifier can be attached to. Both ingress and egress hooks are located in central receive and transmit locations in the networking data path, where every packet on the device passes through. The ingress hook is called from __netif_receive_skb_core() -> sch_handle_ingress() in the kernel and the egress hook from __dev_queue_xmit() -> sch_handle_egress().

The equivalent for attaching the program to the egress hook looks as follows:

The clsact qdisc is processed lockless from ingress and egress direction and can also be attached to virtual, queue-less devices such as veth devices connecting containers.

Next to the hook, the tc filter command selects bpf to be used in da (direct-action) mode. da mode is recommended and should always be specified. It basically means that the bpf classifier does not need to call into external tc action modules, which are not necessary for bpf anyway, since all packet mangling, forwarding or other kind of actions can already be performed inside a single BPF program, and is therefore significantly faster.

At this point, the program has been attached and is executed once packets traverse the device. Like in XDP, should the default section name not be used, then it can be specified during load, for example, in case of section foobar:

iproute2’s BPF loader allows for using the same command line syntax across program types, hence the obj prog.o sec foobar is the same syntax as with XDP mentioned earlier.

The attached programs can be listed through the following commands:

The output of prog.o:[ingress] tells that program section ingress was loaded from the file prog.o, and bpf operates in direct-action mode. The program id and tag is appended for each case, where the latter denotes a hash over the instruction stream which can be correlated with the object file or perf reports with stack traces, etc. Last but not least, the id represents the system-wide unique BPF program identifier that can be used along with bpftool to further inspect or dump the attached BPF program.

tc can attach more than just a single BPF program, it provides various other classifiers which can be chained together. However, attaching a single BPF program is fully sufficient since all packet operations can be contained in the program itself thanks to da (direct-action) mode, meaning the BPF program itself will already return the tc action verdict such as TC_ACT_OK, TC_ACT_SHOT and others. For optimal performance and flexibility, this is the recommended usage.

In the above show command, tc also displays pref 49152 and handle 0x1 next to the BPF related output. Both are auto-generated in case they are not explicitly provided through the command line. pref denotes a priority number, which means that in case multiple classifiers are attached, they will be executed based on ascending priority, and handle represents an identifier in case multiple instances of the same classifier have been loaded under the same pref. Since in case of BPF, a single program is fully sufficient, pref and handle can typically be ignored.

Only in the case where it is planned to atomically replace the attached BPF programs, it would be recommended to explicitly specify pref and handle a priori on initial load, so that they do not have to be queried at a later point in time for the replace operation. Thus, creation becomes:

And for the atomic replacement, the following can be issued for updating the existing program at ingress hook with the new BPF program from the file prog.o in section foobar:

Last but not least, in order to remove all attached programs from the ingress respectively egress hook, the following can be used:

For removing the entire clsact qdisc from the netdevice, which implicitly also removes all attached programs from the ingress and egress hooks, the below command is provided:

tc BPF programs can also be offloaded if the NIC and driver has support for it, like XDP BPF programs. Netronome’s nfp supported NICs offer both types of BPF offload.

If the above error is shown, then tc hardware offload first needs to be enabled for the device through ethtool’s hw-tc-offload setting:

The in_hw flag confirms that the program has been offloaded to the NIC.

Note that BPF offloads for both tc and XDP cannot be loaded at the same time, either the tc or XDP offload option must be selected.

3. Testing BPF offload interface via netdevsim driver.

The netdevsim driver which is part of the Linux kernel provides a dummy driver which implements offload interfaces for XDP BPF and tc BPF programs and facilitates testing kernel changes or low-level user space programs implementing a control plane directly against the kernel’s UAPI.

A netdevsim device can be created as follows:

After that step, XDP BPF or tc BPF programs can be test loaded as shown in the various examples earlier:

These two workflows are the basic operations to load XDP BPF respectively tc BPF programs with iproute2.

There are other various advanced options for the BPF loader that apply both to XDP and tc, some of them are listed here. In the examples only XDP is presented for simplicity.

1. Verbose log output even on success.

The option verb can be appended for loading programs in order to dump the verifier log, even if no error occurred:

2. Load program that is already pinned in BPF file system.

Instead of loading a program from an object file, iproute2 can also retrieve the program from the BPF file system in case some external entity pinned it there and attach it to the device:

iproute2 can also use the short form that is relative to the detected mount point of the BPF file system:

When loading BPF programs, iproute2 will automatically detect the mounted file system instance in order to perform pinning of nodes. In case no mounted BPF file system instance was found, then tc will automatically mount it to the default location under /sys/fs/bpf/.

In case an instance has already been found, then it will be used and no additional mount will be performed:

By default tc will create an initial directory structure as shown above, where all subsystem users will point to the same location through symbolic links for the globals namespace, so that pinned BPF maps can be reused among various BPF program types in iproute2. In case the file system instance has already been mounted and an existing structure already exists, then tc will not override it. This could be the case for separating lwt, tc and xdp maps in order to not share globals among all.

As briefly covered in the previous LLVM section, iproute2 will install a header file upon installation which can be included through the standard include path by BPF programs:

The purpose of this header file is to provide an API for maps and default section names used by programs. It’s a stable contract between iproute2 and BPF programs.

The map definition for iproute2 is struct bpf_elf_map. Its members have been covered earlier in the LLVM section of this document.

When parsing the BPF object file, the iproute2 loader will walk through all ELF sections. It initially fetches ancillary sections like maps and license. For maps, the struct bpf_elf_map array will be checked for validity and whenever needed, compatibility workarounds are performed. Subsequently all maps are created with the user provided information, either retrieved as a pinned object, or newly created and then pinned into the BPF file system. Next the loader will handle all program sections that contain ELF relocation entries for maps, meaning that BPF instructions loading map file descriptors into registers are rewritten so that the corresponding map file descriptors are encoded into the instructions immediate value, in order for the kernel to be able to convert them later on into map kernel pointers. After that all the programs themselves are created through the BPF system call, and tail called maps, if present, updated with the program’s file descriptors.

---
