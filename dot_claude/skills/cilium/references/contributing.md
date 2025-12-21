# Cilium - Contributing

**Pages:** 33

---

## BPF Unit and Integration Testing — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/testing/bpf/

**Contents:**
- BPF Unit and Integration Testing
- Running tests
- Writing tests
  - Sub-tests
  - Integration tests
  - Function reference
  - Function mocking
  - Limitations

Our BPF datapath has its own test framework, which allows us to write unit and integration tests that verify that our BPF code works as intended, independently from the other Cilium components. The framework uses the BPF_PROG_RUN feature to run eBPF programs in the kernel without attaching them to actual hooks.

The framework is designed to allow datapath developers to quickly write tests for the code they are working on. The tests themselves are fully written in C to minimize context switching. Tests pass results back to the framework which will outputs the results in Go test output, for optimal integration with CI and other tools.

To run the tests in your local environment, execute the following command from the project root:

Running BPF tests requires Docker and is only expected to work on Linux.

To run a single test, specify its name without extension. For example:

$ make run_bpf_tests BPF_TEST_FILE=”xdp_nodeport_lb4_nat_lb”

All BPF tests live in the bpf/tests directory. All .c files in this directory are assumed to contain BPF test programs which can be independently compiled, loaded, and executed using BPF_PROG_RUN. All files in this directory are automatically picked up, so all you have to do is create a new .c file and start writing. All other files like .h files are ignored and can be used for sharing code for example.

Each .c file must at least have one CHECK program. The CHECK macro replaces the SEC which is typically used in BPF programs. The CHECK macro takes two arguments, the first being the program type (for example xdp or tc. See the list of recognized types in the Go library), the second being the name of the test which will appear in the output. All macros are defined in bpf/tests/common.h, so all programs should start by including this file: #include "common.h".

Each CHECK program should start with test_init() and end with test_finish(), CHECK programs will return implicitly with the result of the test, a user doesn’t need to add return statements to the code manually. A test will PASS if it reaches test_finish(), unless it is marked as failed(test_fail(), test_fail_now(), test_fatal()) or skipped(test_skip(), test_skip_now()).

The name of the function has no significance for the tests themselves. The function names are still used as indicators in the kernel (at least the first 15 chars), used to populate tail call maps, and should be unique for the purposes of compilation.

Each CHECK program may contain sub-tests, each of which has its own test status. A sub-test is created with the TEST macro like so:

Since all sub-tests are part of the same BPF program they are executed consecutively in one BPF_PROG_RUN invocation and can share setup code which can improve run speed and reduce code duplication. The name passed to the TEST macro for each sub-test serves to self-document the steps and makes it easier to spot what part of a test fails.

Writing tests for a single function or small group of functions should be fairly straightforward, only requiring a CHECK program. Testing functionality across tail calls requires an additional step: given that the program does not return to the CHECK function after making a tail call, we can’t check whether it was successful.

The workaround is to use PKTGEN and SETUP programs in addition to a CHECK program. These programs will run before the CHECK program with the same name. Intended usage is that the PKGTEN program builds a BPF context (for example fill a struct __sk_buff for TC programs), and passes it on to the SETUP program, which performs further setup steps (for example fill a BPF map). The two-stage pattern is needed so that BPF_PROG_RUN gets invoked with the actual packet content (and for example fills skb->protocol).

The BPF context is then passed to the CHECK program, which can inspect the result. By executing the test setup and executing the tail call in SETUP we can execute complete programs. The return code of the SETUP program is prepended as a u32 to the start of the packet data passed to CHECK, meaning that the CHECK program will find the actual packet data at (void *)data + 4.

This is an abbreviated example showing the key components:

test_log(fmt, args...) - writes a log message. The conversion specifiers supported by fmt are the same as for bpf_trace_printk(). They are %d, %i, %u, %x, %ld, %li, %lu, %lx, %lld, %lli, %llu, %llx. No modifier (size of field, padding with zeroes, etc.) is available.

test_fail() - marks the current test or sub-test as failed but will continue execution.

test_fail_now() - marks the current test or sub-test as failed and will stop execution of the test or sub-test (If called in a sub-test, the other sub-tests will still run).

test_fatal(fmt, args...) - writes a log and then calls test_fail_now()

assert(stmt) - asserts that the statement within is true and call test_fail_now() otherwise. assert will log the file and line number of the assert statement.

test_skip() - marks the current test or sub-test as skipped but will continue execution.

test_skip_now() - marks the current test or sub-test as skipped and will stop execution of the test or sub-test (If called in a sub-test, the other sub-tests will still run).

test_init() - initializes the internal state for the test and must be called before any of the functions above can be called.

test_finish() - submits the results and returns from the current function.

Functions that halt the execution (test_fail_now(), test_fatal(), test_skip_now()) can’t be used within both a sub-test (TEST) and for, while, or switch/case blocks since they use the break keyword to stop a sub-test. These functions can still be used from within for, while and switch/case blocks if no sub-tests are used, because in that case the flow interruption happens via return.

Being able to mock out a function is a great tool to have when creating tests for a number of reasons. You might for example want to test what happens if a specific function returns an error to see if it is handled gracefully. You might want to proxy function calls to record if the function under test actually called specific dependencies. Or you might want to test code that uses helpers which rely on a state we can’t set in BPF, like the routing table.

Mocking is easy with this framework:

Create a function with a unique name and the same signature as the function it is replacing.

Create a macro with the exact same name as the function we want to replace and point it to the function created in step 1. For example #define original_function our_mocked_function

Include the file which contains the definition we are replacing.

The following example mocks out the fib_lookup helper call and replaces it with our mocked version, since we don’t actually have routes for the IPs we want to test:

For all its benefits there are some limitations to this way of testing:

Code must pass the verifier, so our setup and test code has to obey the same rules as other BPF programs. A side effect is that it automatically guarantees that all code that passes will also load. The biggest concern is the complexity limit on older kernels, this can be somewhat mitigated by separating heavy setup work into its own SETUP program and optionally tail calling into the code to be tested, to ensure the testing harness doesn’t push us over the complexity limit.

Test functions like test_log(), test_fail(), test_skip() can only be executed within the scope of the main program or a TEST. These functions rely on local variables set by test_init() and will produce errors when used in other functions.

Functions that halt the execution (test_fail_now(), test_fatal(), test_skip_now()) can’t be used within both a sub-test (TEST) and for, while, or switch/case blocks since they use the break keyword to stop a sub-test. These functions can still be used from within for, while and switch/case blocks if no sub-tests are used, because in that case the flow interruption happens via return.

Sub-test names can’t use more than 127 characters.

Log messages can’t use more than 127 characters and have no more than 12 arguments.

---

## Testing — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/testing/

**Contents:**
- Testing

There are multiple ways to test Cilium functionality, including unit-testing and integration testing. In order to improve developer throughput, we provide ways to run both the unit and integration tests in your own workspace as opposed to being fully reliant on the Cilium CI infrastructure. We encourage all PRs to add unit tests and if necessary, integration tests. Consult the following pages to see how to run the variety of tests that have been written for Cilium, and information about Cilium’s CI infrastructure.

The best way to get help if you get stuck is to ask a question on the Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

---

## Documentation framework — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/docs/docsframework/

**Contents:**
- Documentation framework
- Sphinx
  - Sphinx usage
  - Sphinx features
  - Sphinx version
- Auto-generated contents
- Build system
  - Makefile targets
  - Generating documentation
- Tweaks and tools

This page contains notes on the framework in use for Cilium documentation. Its objective is to help contributors understand the tools and build process for the documentation, and to help maintain it.

Alas, this sort of document goes quickly out of date. When in doubt of accuracy, double-check the codebase to verify information. If you find discrepancies, please update this page.

Cilium relies on Sphinx to generate its documentation.

Contributors do not usually call Sphinx directly, but rather use the Makefile targets defined in Documentation/Makefile. For instructions on how to quickly render the documentation, see testing documentation.

Here are some specific Sphinx features used in Cilium’s documentation:

OpenAPI documentation generation

Mark-up languages: reStructuredText (rST) and Markdown (MyST flavor)

Substitutions, for example:

Multiple versions (for all supported branches, plus two aliases: stable and latest)

The version of Sphinx in use is defined in Documentation/requirements-min/requirements.txt. For more details, see the section on requirements.

Some contents are automatically generated at build time. File Documentation/Makefile contains the following target, shown here in a simplified version, which regenerates a number of documents and then checks that they are all up-to-date:

Regeneration happens when the different dependency targets for check are run. They are:

Runs go run tools/apiflaggen

Generates Documentation/configuration/api-restrictions-table.rst

Runs ./update-cmdref.sh

Includes running various binaries with --cmdref

Generates Documentation/cmdref/\*

make -C ../ generate-crd-docs

Runs tools/crdlistgen/main.go

Parses docs to list CRDs

Generates Documentation/crdlist.rst

Generates from install/kubernetes

Generates Documentation/helm-values.rst

./update-codeowners.sh

Synchronizes teams description from CODEOWNERS

Generates Documentation/codeowners.rst

make -C Documentation update-redirects

Automatically generates redirects based on moved files based on git history.

Validates that all moved or deleted files have a redirect.

Generates Documentation/redirects.txt

Other auto-generated contents include:

YAML generated from the Makefile at the root of the repository

Relies on the contents of api, linked as Documentation/_api

Processed and included via a dedicated add-on, from Documentation/api.rst: .. openapi:: ../api/v1/openapi.yaml

Markdown generated from the main Makefile at the root of the repository

Relies on the contents of api, linked as Documentation/_api

Included from Documentation/grpcapi.rst

SDP gRPC API reference

Markdown generated from the main Makefile at the root of the repository

Relies on the contents of api, linked as Documentation/_api

Included from Documentation/sdpapi.rst

Here are the main Makefile targets related to documentation to run from the root of the Cilium repository, as well as some indications on what they call:

make -> all: ... postcheck -> make -C Documentation check: Build Cilium and validate the documentation via the postcheck target

make -C Documentation html: Render the documentation as HTML

make test-docs -> make -C Documentation html: Render the documentation as HTML

make -C Documentation live-preview: Build the documentation and start a server for local preview

make render-docs -> make -C Documentation live-preview: Build the documentation and start a server for local preview

The Makefile builds the documentation using the docs-builder Docker image.

The build includes running check-build.sh. This script:

Runs the linter (rstcheck), unless the environment variable SKIP_LINT is set

Runs the spell checker

Builds the HTML version of the documentation

Exits with an error if any unexpected warning or error is found

See also file Documentation/conf.py.

The build system relies on Sphinx’s spell-checker module (considered a builder in Sphinx).

The spell checker uses a list of known exceptions contained in Documentation/spelling_wordlist.txt. Words in the list that are written with lowercase exclusively, or uppercase exclusively, are case-insensitive exceptions for spell-checking. Words with mixed case are case-sensitive. Keep this file sorted alphabetically.

To add new entries to the list, run Documentation/update-spelling_wordlist.sh.

To clean-up obsolete entries, first make sure the spell checker reports no issue on the current version of the documentation. Then remove all obsolete entries from the file, run the spell checker, and re-add all reported exceptions.

Cilium’s build framework uses a custom filter for the spell checker, for spelling WireGuard correctly as WireGuard, or wireguard in some contexts, but never as Wireguard. This filter is implemented in Documentation/_exts/cilium_spellfilters.py and registered in Documentation/conf.py.

The build system relies on the Sphinx extension sphinxext-rediraffe (considered a builder in Sphinx) for redirects.

The redirect checker uses the git history to determine if a file has been moved or deleted in order to validate that a redirect for the file has been created in Documentation/redirects.txt. Redirects are defined as a mapping from the original source file location to the new location within the Documentation/ directory. The extension uses the rediraffe_branch as the git ref to diff against to determine which files have been moved or deleted. Any changes prior to the ref specified by rediraffe_branch will not be detected.

To add new entries to the redirects.txt, run make -C Documentation update-redirects.

If a file has been deleted, or has been moved and is not similar enough to the original source file, then you must manually update redirects.txt with the correct mapping.

The documentation framework relies on rstcheck to validate the rST formatting. There is a list of warnings to ignore, in part because the linter has bugs. The call to the tool, and this list of exceptions, are configured in Documentation/check-build.sh.

The documentation framework has a link checker under Documentation/check-links.sh. However, due to some unsolved issues, it does not run in CI. See GitHub issue 27116 for details.

Launch a web server to preview the generated documentation locally with make render-docs.

For more information on this topic, see testing documentation.

The documentation defines several custom roles:

Calling these roles helps insert links based on specific URL templates, via the extlinks extension. They are all configured in Documentation/conf.py. They should be used wherever relevant, to ensure that formatting for all links to the related resources remain consistent.

Cilium’s documentation does not implement custom directives as of this writing.

Cilium’s documentation uses custom extensions for Sphinx, implemented under Documentation/_exts.

One defines the custom filters for the spell checker.

One patches Sphinx’s HTML translator to open all external links in new tabs.

The documentation uses Google Analytics to collect metrics. This is configured in Documentation/conf.py.

Here are additional elements of customization for Cilium’s documentation defined in the main repository:

Some custom CSS; see also class wrapped-table in the related CSS file Documentation/_static/wrapped-table.css

A “Copy” button, including a button to copy only commands from console-code blocks, implemented in Documentation/_static/copybutton.js and Documentation/_static/copybutton.css

Custom header and footer definitions, for example to make link to Slack target available on all pages

Warning banner on older branches, telling to check out the latest version (these may be handled directly in the ReadTheDocs configuration in the future, see also GitHub issue 29969)

Algolia provides a search engine for the documentation website. See also the repository for the DocSearch scraper.

The repository contains two files for requirements: one that declares and pins the core dependencies for the documentation build system, and that maintainers use to generate a second requirement files that includes all sub-dependencies, via a dedicated Makefile target.

The base requirements are defined in Documentation/requirements-min/requirements.txt.

Running make -C Documentation update-requirements uses this file as a base to generate Documentation/requirements.txt.

Dependencies defined in Documentation/requirements-min/requirements.txt should never be updated in Documentation/requirements.txt directly. Instead, update the former and regenerate the latter.

File Documentation/requirements.txt is used to build the docs-builder Docker image.

Dependencies defined in these requirements files include the documentation’s custom theme.

The documentation build system relies on a Docker image, docs-builder, to ensure the build environment is consistent across different systems. Resources related to this image include Documentation/Dockerfile and the requirement files.

Versions of this image are automatically built and published to a registry when the Dockerfile or the list of dependencies is updated. This is handled in CI workflow .github/workflows/build-images-docs-builder.yaml.

If a Pull Request updates the Dockerfile or its dependencies, have someone run the two-steps deployment described in this workflow to ensure that the CI picks up an updated image.

Cilium’s documentation is hosted on ReadTheDocs. The main configuration options are defined in Documentation/.readthedocs.yaml.

Some options, however, are only configurable in the ReadTheDocs web interface. For example:

The location of the configuration file in the repository

Triggers for deployment

The online documentation uses a custom theme based on the ReadTheDocs theme. This theme is defined in its dedicated sphinx_rtd_theme fork repository.

Do not use the master branch of this repository. The commit or branch to use is referenced in Documentation/requirements.txt, generated from Documentation/requirements-min/requirements.txt, in the Cilium repository.

There are several workflows relating to the documentation in CI:

Documentation workflow:

Defined in .github/workflows/documentation.yaml

Tests the build, runs the linter, checks the spelling, ensures auto-generated contents are up-to-date

Runs ./Documentation/check-builds.sh html from the docs-builder image

Hook defined at Netlify, configured in Netlify’s web interface

Used for previews on Pull Requests, but not for deploying the documentation

Uses a separate Makefile target (html-netlify), runs check-build.sh with SKIP_LINT=1

In the absence of updates to the Dockerfile or documentation dependencies, runtime tests are the only workflow that always rebuilds the docs-builder image before generating the docs.

Image update workflow:

Rebuilds the docs-builder image, pushes it to Quay.io, and updates the image reference with the new one in the documentation workflow

Triggers when requirements or Documentation/Dockerfile are updated

Needs approval from one of the docs-structure team members

Some pages change location or name over time. To improve user experience, there is a set of redirects in place. These redirects are configured from the ReadTheDocs interface. They are a pain to maintain.

Redirects could possibly be configured from existing, dedicated Sphinx extensions, but this option would require research to analyze and implement.

---

## Configuring the Datapath — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/datapath_config/

**Contents:**
- Configuring the Datapath
- Introduction
- Getting Started
  - Declaring C Variable
  - Wiring up Go Values
  - Reading the Variable in C
- Node Configuration
- Guidelines and Recommendations
- Defaults
- Testing

In order for the Cilium datapath to function, it needs access to configuration data such as feature flags, addresses, timeouts, security IDs and all sorts of tunables and user configuration. These values are provided by the agent at the time of loading the BPF program. This page outlines the configuration mechanism, some recommendations, how to migrate legacy configuration, as well as practical examples.

First, let’s look at a practical example to illustrate the configuration API and see the configuration process in action. This will help you understand how to declare, assign, and use configuration variables effectively in the Cilium datapath.

To start off, let’s take a look at a straightforward example of a configuration value used in the datapath. This is an example from bpf/include/bpf/config/lxc.h, included by bpf_lxc.c:

This invokes the DECLARE_CONFIG macro, which declares the 16-bit unsigned integer config value named endpoint_id, followed by a description. We’ll see why the description is useful later on.

With our variable declared, make the bpf/ directory to rebuild the datapath and run dpgen to generate Go code:

This will emit our variable to one of the Go config scaffoldings in the pkg/datapath/config Go package.

One of the files in package config will now contain a new struct field that can be populated at BPF load time.

As shown in the preceding snippet, the new struct field carries our helpful comment we provided in the C code and refers to the endpoint_id variable we declared.

At the time of writing, populating Go configuration scaffolding still mostly happens in pkg/datapath/loader and is scattered between a few places. The goal is to create StateDB tables for each configuration object. These can be managed from Hive Cells and automatically trigger a reload of the necessary BPF programs when any of the values change. This document will be updated along with these changes.

Now, we need to wire up the field with an actual value. Depending on which object you’re adding configuration to and depending on whether the value is “node configuration” (more below) or object-specific, you may need to look in different places. For example, adding a value to bpf_lxc.c like in this example, the value is typically set in endpointRewrites():

This plumbing needs to be done for every object that needs access to the variable! For example, if you declare a variable in a header common to both bpf_lxc.c and bpf_host.c, you’ll need to make sure the agent supplies the value to both structs.

If this document no longer matches the codebase, grep around for uses of the various structs and their fields, and extend the existing code. Over time, Hive Cells will be able to write to these structs using StateDB tables.

We’ve declared our global config variable. We’ve generated Go code and wired up a value from the agent. Now, we need to put the variable to use!

In datapath BPF code, we can refer to it using the CONFIG() macro. This macro resolves to a special variable name representing our configuration value, which could change in the future. The macro is there to avoid cross-cutting code changes if we ever need to make changes here.

The variable is not a compile-time constant, so it cannot be used to control things like BPF map sizes or to initialize other global const variables at compile time.

Use the macro like you would typically use a variable:

Historically, most of the agent’s configuration was presented to the datapath as “node configuration” (in node_config.h), but this pattern is discouraged going forward and may go away at some point in the future. More on this in Guidelines and Recommendations.

To make migration from #define-style configuration more straightforward, we’ve kept the concept of node configuration, albeit with runtime-provided values instead of #ifdef.

Node configuration can be declared in bpf/include/bpf/config/node.h:

This will show up in the Go scaffolding as:

Populate it in the agent through pkg/datapath/loader.nodeConfig():

It behaves identically with regards to CONFIG().

A few guiding principles:

Avoid dead code in the form of variables that are never set by the agent. For example, if only bpf_lxc.c uses your variable, don’t put it in a shared header across multiple BPF objects. To share types with other objects, put those in a separate header instead.

Declare variables close to where they’re used, e.g. in header files implementing a feature.

Avoid conditional #include statements.

Use the following procedure to determine where to declare your configuration:

For new features, use DECLARE_CONFIG() in the header implementing your feature. Only import the header in the BPF object(s) where the feature is utilized.

For new config in existing features, DECLARE_CONFIG() as close as possible to the code that consumes it.

For porting over node configuration from node_config.h (WriteNodeConfig), try narrowing down where the config is used and see if it can use DECLARE_CONFIG() in a header imported by a small number of BPF objects instead. Refactoring is worth it here, since it avoids dead code in objects that don’t use the node config.

If none of the above cases apply, use NODE_CONFIG().

To assign a default value other than 0 to a configuration variable directly from C, the ASSIGN_CONFIG() macro can be used after declaring the variable. This can be useful for setting sane defaults that will automatically apply even when the agent doesn’t supply a value.

For example, the agent uses this for device MTU:

ASSIGN_CONFIG() can only be used once per variable per compilation unit. This makes it so the variable cannot be overridden from tests without a workaround, so use sparingly. See Testing for more details.

When writing tests, you may need to override configuration values to test different code paths. This can be done by using the ASSIGN_CONFIG() macro in a test file as described in Defaults after importing the main object under test, e.g. bpf_lxc.c. See the test suite itself for the most up-to-date examples.

Note that there are some restrictions, primarily that the literal passed to ASSSIGN_CONFIG() must be compile-time constant, and can’t e.g. be the name of another variable.

Occasionally, you may need to override a config that already has a default value set using ASSIGN_CONFIG(), in which case a workaround is needed:

Then, from the test file, set #define OVERRIDABLE_CONFIG before including the object under test to make the override take precedence.

This is somewhat surprising, so use sparingly and consider refactoring the code to avoid the need for this.

Runtime-based configuration cannot currently be set during verifier tests. This means that if you have a branch behind a (boolean) config, it will currently not be evaluated by the verifier, and there may be latent verifier errors that pop up when enabled through agent configuration. However, with the new configuration mechanism, we can now fully automate testing all permutations of config flags, without having to maintain them manually going forward. Hold off on migrating ENABLE_ defines until this is resolved.

Generating Go scaffolding for struct variables is not yet supported.

Historically, configuration was fed into the datapath using #define statements generated at runtime, with sections of optional code cordoned off by #ifdef and similar mechanisms. This has served us well over the years, but with the increasing complexity of the agent and the datapath, it has become clear that we need a more structured and maintainable way to configure the datapath.

Linux kernels 5.2 and later support read-only maps to store config data that cannot be changed after the kernel verified the program. If these values are used in branches, the verifier can then perform dead code elimination, eliminating branches it deems unreachable. This minimizes the amount of work the verifier needs to do in subsequent verification steps and ensures the BPF program image is as lean as possible.

This also means we no longer need to conditionally compile out parts of code we don’t need, so we can adopt an approach where the datapath’s BPF code is built and embedded into the agent at compile time. This, in turn, means we no longer need to ship LLVM with the agent (maybe you’ve heard of the term clang-free), reducing the size of the agent container image and significantly cutting down on agent startup time and CPU usage. Endpoints will also regenerate faster during configuration changes.

---

## StateDB in Cilium — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/statedb/

**Contents:**
- StateDB in Cilium
- Introduction
- Motivation
- Architecture vision
- Defining tables
  - Pitfalls
  - Inspecting with cilium-dbg
  - Kubernetes reflection
- Reconcilers
  - BPF maps

StateDB and the reconciler are still under active development and the APIs & metrics documented here are not guaranteed to be stable yet.

StateDB is an in-memory database developed for the Cilium project to manage control-plane state. It aims to simplify access and indexing of state and to increase resilience, modularity and testability by separating the control-plane state from the controllers that operates on it.

This document focuses on how StateDB is leveraged by Cilium and how to develop new features using it. For a detailed guide on StateDB API itself see the StateDB documentation.

We assume familiarity with the Hive framework. If you’re not familiar with it, consider reading through Guide to the Hive first.

StateDB is a project born from lessons learned from development and production struggles. It aims to be a tool to systematically improve the resilience, testability and inspectability of the Cilium agent.

For developers it aims to offer simpler and safer ways to extend the agent by giving a unified API (Table[Obj]) for accessing shared state. The immutable data structures backing StateDB allow for lockless readers which improves resiliency compared to the RWMutex+hashmap+callback pattern where a bug in a controller observing the state may cause critical functions to either stop or significantly decrease throughput. Additionally having flexible ways to access and index the state allows for opportunities to deduplicate the state. Many components of the agent have historically functioned through callback-based subscriptions to and maintained their own copies of state which has a significant impact on memory usage and GC overhead.

Unifying state storage behind a database-like abstraction allows building reusable utilities for inspecting the state (cilium-dbg shell -- db), reconciling state (StateDB reconciler) and observing operations on state (StateDB metrics). At scale this leads to an architecture that is easier to understand (smaller API surface), operate (state can be inspected) and extend (easy to access data).

The separation of state from logic operating on it (e.g. moving away from kitchen-sink “Manager” pattern) also opens up the ability to do wider and more meaningful integration testing on components of the agent. When most of the inputs and outputs of a component are tables, we can combine multiple components into an integration test that is solely defined in terms of test inputs and expected outputs. This allows more validation to be performed with fairly simple integration tests rather than with slower and costly end-to-end tests.

The agent in this architectural style can be broadly considered to consist of:

User intent tables: objects from external data sources that tell the agent what it should do. These would be for example the Kubernetes core objects like Pods or the Cilium specific CRDs such as CiliumNetworkPolicy, or data ingested from other sources such as kvstore.

Controllers: control-loops that observe the user intent tables and compute the contents of the desired state tables.

Desired state tables: the internal state that the controllers produce to succinctly describe what should be done. For example a desired state table could describe what the contents of a BPF map should be or what routes should be installed.

Reconcilers: control-loops that observe the desired state tables and reconcile them against a target such as a BPF map or the Linux routing table. The reconciler is usually an instance of the StateDB reconciler which is defined in terms of a table of objects with a status field and the operations Update, Delete and Prune.

Dividing the agent this way we achieve a nice separation of concerns:

Separating the user intent into its own tables keeps the parsing and validation from the computation we’ll perform on the data. It also makes it nicer to reuse as it’s purely about representing the outside intent internally in an efficient way without tying it too much into implementation details of a specific feature.

By defining the controller as essentially the function from input tables to output tables it becomes easy to understand and test.

Separating the reconciliation from the desired state computation the complex logic of dealing with low-level errors and retrying is separate from the pure “business logic” computation.

Using the generic reconcilers allows using tried-and-tested and instrumented retry implementation.

The control-plane of the agent is essentially everything outside the reconcilers This allows us to integration test, simulate or benchmark the control-plane code without unreasonable amount of scaffolding. The easier it is to write reliable integration tests the more resilient the codebase becomes.

What we’re trying to achieve is well summarized by Fred Brooks in “The Mythical Man Month”:

StateDB documentation gives a good introduction into how to create a table and its indexes, so we won’t repeat that here, but instead focus on Cilium specific details.

Let’s start off with some guidelines that you might want to consider:

By default publicly provide Table[Obj] so new features can build on it and it can be used in tests. Also export the table’s indexes or the query functions (var ByName = nameIndex.Query).

Do not export RWTable[Obj] if outside modules do not need to directly write into the table. If other modules do write into the table, consider defining “writer functions” that validate that the writes are well-formed.

If the table is closely associated with a specific feature, define it alongside the implementation of the feature. If the table is shared by many modules, consider defining it in daemon/k8s or pkg/datapath/tables so it is easy to discover.

Make sure the object can be JSON marshalled so it can be inspected. If you need to store non-marshallable data (e.g. functions), make them private or mark them with json:"-" struct tag.

If the object contains a map or set and it is often mutated, consider using the immutable part.Map or part.Set from cilium/statedb. Since these are immutable they don’t need to be deep-copied when modifying the object and there’s no risk of accidentally mutating them in-place.

When designing a table consider how it can be used in tests outside your module. It’s a good idea to export your table constructor (New*Table) so it can be used by itself in an integration test of a module that depends on it.

Take into account the fact that objects be immutable by designing them to be cheap to shallow-clone. For example this could mean splitting off fields that are constant from creation into their own struct that’s referenced from the object.

Write benchmarks for your table to understand the cost of the indexing and storage use. See benchmarks_test.go in cilium/statedb for examples.

If the object is small (<100 bytes) prefer storing it by value instead of by reference, e.g. Table[MyObject] instead of Table[*MyObject]. This reduces memory fragmentation and makes it safer to use since the fields can’t be accidentally mutated (anything inside that’s by reference of course can be mutated accidentally). Note though that each index will store a separate copy of the object. Measure if needed.

With that out of the way, let’s get concrete with a code example of a simple table and a controller that populates it:

To understand how the table defined by our example module can be consumed, we can construct a small mini-application:

You can find and run the above examples in contrib/examples/statedb:

Here are some common mistakes to be aware of:

Object is mutated after insertion to database. Since StateDB queries do not return copies, all readers will see the modifications.

Object (stored by reference, e.g. *T) returned from a query is mutated and then inserted. StateDB will catch this and panic. Objects stored by reference must be (shallow) cloned before mutating.

Query is made with ReadTxn and results are used in a WriteTxn. The results may have changed between the ReadTxn and WriteTxn! If you want optimistic concurrency control, then use CompareAndSwap in the write transaction.

StateDB comes with script commands to inspect the tables. These can be invoked via cilium-dbg shell.

The db command lists all registered tables:

The show command prints out the table using the TableRow and TableHeader methods:

The db/get, db/prefix, db/list and db/lowerbound allow querying a table, provided that the Index.FromString method has been defined:

The shell session can also be run interactively:

To reflect Kubernetes objects from the API server into a table, the reflector utility in pkg/k8s can be used to automate this. For example, we can define a table of pods and reflect them from Kubernetes into the table:

As earlier, we can then construct a small application to try this out:

You can run the example in contrib/examples/statedb_k8s to watch the pods in your current cluster:

The StateDB reconciler can be used to reconcile changes on table against a target system.

To set up the reconciler you will need the following.

Add reconciler.Status as a field into your object (there can be multiple):

Implement the reconciliation operations (reconciler.Operations):

Register the reconciler:

Insert objects with the Status set to pending:

The reconciler watches the tables (using Changes()) and calls Update for each changed object that is Pending or Delete for each deleted object. On errors the object will be retried (with configurable backoff) until the operation succeeds.

See the full runnable example in the StateDB repository.

The reconciler runs a background job which reports the health status of the reconciler. The status is degraded if any objects failed to be reconciled and queued for retries. Health can be inspected either with cilium-dbg status --all-health or cilium-dbg statedb health.

BPF maps can be reconciled with the operations returned by bpf.NewMapOps. The target object needs to implement the BinaryKey and BinaryValue to construct the BPF key and value respectively. These can either construct the binary value on the fly, or reference a struct defining the value. The example below uses a struct as this is the prevalent style in Cilium.

For a real-world example see pkg/maps/bwmap/cell.go.

StateDB comes with a rich set of script commands for inspecting and manipulating tables:

See help db for full reference in cilium-dbg shell or in the break prompt in tests. A good reference is also the existing tests. These can be found with git grep db/insert.

Metrics are available for both StateDB and the reconciler, but they are disabled by default due to their fine granularity. These are defined in pkg/hive/statedb_metrics.go and pkg/hive/reconciler_metrics.go. As this documentation is manually maintained it may be out-of-date so if things are not working, check the source code.

The metrics can be enabled by adding them to the helm prometheus.metrics option with the syntax +cilium_<name>, where <name> is the name of the metric in the table below. For example, here is how to turn on all the metrics:

These are still under development and the metric names may change.

The metrics can be inspected even when disabled with the metrics and metrics/plot script commands as Cilium keeps samples of all metrics for the past 2 hours. These metrics are also available in sysdump in HTML form (look for cilium-dbg-shell----metrics-html.html).

statedb_write_txn_duration_seconds

Duration of the write transaction

statedb_write_txn_acquisition_seconds

How long it took to lock target tables

statedb_table_contention_seconds

How long it took to lock a table for writing

statedb_table_objects

Number of objects in a table

statedb_table_revision

statedb_table_delete_trackers

Number of delete trackers (e.g. Changes())

statedb_table_graveyard_objects

Number of deleted objects in graveyard

statedb_table_graveyard_low_watermark

Low watermark revision for deleting objects

statedb_table_graveyard_cleaning_duration_seconds

How long it took to GC the graveyard

The label handle is the database handle name (created with (*DB).NewHandle). The default handle is named DB. The label table and tables (formatted as tableA+tableB) are the StateDB tables which the metric concerns.

Number of reconcilation rounds performed

reconciler_duration_seconds

Histogram of operation durations

reconciler_errors_total

Total number of errors (update/delete)

reconciler_errors_current

reconciler_prune_count

Number of pruning rounds

reconciler_prune_errors_total

Total number of errors during pruning

reconciler_prune_duration_seconds

Histogram of operation durations

The label module_id is the identifier for the Hive module under which the reconciler was registered. op is the operation performed, either update or delete.

---

## Reviewing for @cilium/vendor — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/reviewers_committers/review_vendor/

**Contents:**
- Reviewing for @cilium/vendor
- What is @cilium/vendor?
- Reviewing Pull Requests
  - Existing Dependencies
  - New Dependencies
  - Cilium Imports

Team @cilium/vendor is a GitHub team of Cilium contributors who are responsible for maintaining the good state of Go dependencies for Cilium and its related projects by reviewing Pull Requests (PRs) that update files related to dependency declaration:

Each time a contributor opens a PR modifying these files, GitHub automatically assigns one member of the team for review.

Open Pull Requests awaiting reviews from @cilium/vendor are listed here.

To join the team, you must be a Cilium Reviewer. see Cilium’s Contributor Ladder for details on the requirements and the application process.

The team has a dedicated Slack channel in the Cilium Community Slack Workspace named #sig-vendor, which can be used for starting discussions and asking questions in regards to dependency management for Cilium and its related projects.

This section describes some of the processes and expectations for reviewing PRs on behalf of @cilium/vendor. Note that the generic PR review process for Committers still applies, even though it is not specific to dependencies.

Updates to existing dependencies most commonly occur through PRs opened by Renovate, which is a 3rd party service used throughout the Cilium organization. Renovate continually checks repositories for out-of-date dependencies and opens new PRs to update any it finds.

When reviewing PRs that update an existing dependency, members of the @cilium/vendor team are required to ensure that the update does not include any breaking changes or licensing issues. These checks are facilitated via GitHub Action CI workflows, which are triggered by commenting /test within a PR. See CI / GitHub Actions for more information on their use.

When a new dependency is added as part of a PR, the @cilium/vendor team will be assigned to ensure the new dependency meets the following criteria:

The new dependency must add functionality that is not already provided, in order of preference, within Go’s standard library, an internal package to the project, or an existing dependency.

The functionality provided by the new dependency must be non-trivial to re-implement manually.

The new dependency must be actively maintained, having new commits and/or releases within the past year.

The new dependency must appear to be of generally good quality, having a strong user base, automated testing with high code coverage, and documentation.

The new dependency must have a license which is allowed by the CNCF, as either one of the generally approved licenses or one that is allowed via exception. An automated CI check is in place to help check this requirement, but may need updating as the list of allowable licenses by the CNCF changes and Cilium dependencies change. The source for the license check tool can be found here.

These criteria ensure the long-term success of the project by justifying the inclusion of the new dependency into the project’s codebase.

A subset of the repositories the @cilium/vendor team is responsible for import code from cilium/cilium as a dependency. A complication in this relationship is the usage of replace directives in the cilium/cilium go.mod file. Replace directives are only applied to the main module’s go.mod file and do not carry over when imported by another module. This creates the need for replace directives used in the cilium/cilium go.mod file to be synced with any module which imports cilium/cilium as a dependency.

The vendor team is therefore responsible for explicitly discouraging the use of replace directives where possible, due to the extra maintenance burden that they incur.

A replace directive may be used if a required change to an imported library is in the process of being upstreamed and a fork of the upstream library is used as a temporary alternative until the upstream library is released with the required change. The developer introducing the replace directive should ensure that the replace directive will be removed before the next release, even if it involves creating a fork of the upstream library and modifying import statements of the library to point to the fork.

When a replace directive is added into the go.mod file, the vendor team is responsible for the following:

A comment is added above the replace directive in the go.mod file describing the reason it was added.

An issue is created in the project’s repository with a release-blocker label attached, tracking the removal of the replace directive before the next release of the project. The issue should be assigned to the developer who added the replace directive.

Ensuring that replace directives are synced when reviewing PRs which update the version of a cilium/cilium dependency.

If a change that is required to be made to an imported library cannot be upstreamed, the library’s import in the go.mod file should be changed to directly use a fork of the library containing the change, avoiding the need for a replace directive. For an example of this change, see cilium/cilium#27582.

---

## End-To-End Testing Framework (Legacy) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/testing/e2e_legacy/

**Contents:**
- End-To-End Testing Framework (Legacy)
- Introduction
  - Running Tests with GitHub Actions (GHA)
- Running End-To-End Tests
  - Running Locally Ginkgo Tests based on Ginkgo’s GitHub Workflow
  - Running Runtime Tests
  - Available CLI Options
  - Running Specific Tests Within a Test Suite
  - Compiling the tests without running them
  - Updating Cilium images for Kubernetes tests

The Ginkgo end-to-end testing framework is deprecated. New end-to-end tests should be implemented using the cilium-cli connectivity testing framework. For more information, see End-To-End Connectivity Testing.

This section provides an overview of the two modes available for running Cilium’s end-to-end tests locally: Kubeconfig and similar to GitHub Actions (GHA). It offers instructions on setting up and running tests in these modes.

Before proceeding, it is recommended to familiarize yourself with Ginkgo by reading the Ginkgo Getting-Started Guide. You can also run the example tests to get a feel for the Ginkgo workflow.

The tests in the test directory are built on top of Ginkgo and utilize the Ginkgo focus concept to determine which Kubernetes nodes are necessary to run specific tests. All test names must begin with one of the following prefixes:

Runtime: Tests Cilium in a runtime environment running on a single node.

K8s: Sets up a small multi-node Kubernetes environment for testing features beyond a single host and Kubernetes-specific functionalities.

GitHub Actions provide an alternative mode for running Cilium’s end-to-end tests. The configuration is set up to closely match the environment used in GHA. Refer to the relevant documentation for instructions on running tests using GHA.

Although it is not possible to run conformance-ginkgo.yaml or conformance-runtime.yaml locally, it is possible to setup an environment similar to the one used on GitHub.

The following example will provide the steps to run one of the tests of the focus f09-datapath-misc-2 on Kubernetes 1.27 with the kernel net-next for the commit SHA 7b368923823e63c9824ea2b5ee4dc026bc4d5cd8.

You can also perform these steps automatically using the script contrib/scripts/run-gh-ginkgo-workflow.sh. Run this script with -h for usage information.

Download dependencies locally (helm, ginkgo).

For helm, the instructions can be found here

Store these dependencies under a specific directory that will be used to run Qemu in the next steps.

For ginkgo, we will be using the same version used on GitHub action:

Build the Ginkgo tests locally. This will create a binary named test.test which we can use later on to run our tests.

Provision VMs using Qemu:

Retrieve the image tag for the k8s and kernel versions that will be used for testing by checking the file .github/actions/ginkgo/main-k8s-versions.yaml.

kernel: bpf-next-20230526.105339@sha256:4133d4e09b1e86ac175df8d899873180281bb4220dc43e2566c47b0241637411

k8s: kindest/node:v1.27.1@sha256:b7d12ed662b873bd8510879c1846e87c7e676a79fefc93e17b2a52989d3ff42b

Store the compressed VM image under a directory (/tmp/_images).

Uncompress the VM image into a directory.

Provision the VM. Qemu will use the current terminal to provision the VM and will mount the current directory into the VM under /host.

Installing dependencies in the VM (helm).

The VM is ready to be used for tests. Similarly to the GitHub Action, Kind will also be used to run the CI. The provisioning of Kind is different depending on the kernel version that is used, i.e., ginkgo tests are meant to run on differently when running on bpf-next.

Verify that kind is running inside the VM:

Now that Kind is provisioned, the tests can be executed inside the VM. Let us first retrieve the focus regex, under cliFocus, of f09-datapath-misc-2 from .github/actions/ginkgo/main-focus.yaml.

cliFocus="K8sDatapathConfig Check|K8sDatapathConfig IPv4Only|K8sDatapathConfig High-scale|K8sDatapathConfig Iptables|K8sDatapathConfig IPv4Only|K8sDatapathConfig IPv6|K8sDatapathConfig Transparent"

Run the binary test.test that was compiled in the previous step. The following code block is exactly the same as used on the GitHub workflow with one exception: the flag -cilium.holdEnvironment=true. This flag will hold the testing environment in case the test fails to allow for further diagnosis of the current cluster.

Wait until the test execution completes.

Once tests are performed, terminate qemu to halt the VM:

The VM state is kept in /tmp/_images/datapath-conformance.qcow2 and the dependencies are installed. Thus steps up to and excluding step installing kind can be skipped next time and the VM state can be re-used from step installing kind onwards.

To run all of the runtime tests, execute the following command from the test directory:

Ginkgo searches for all tests in all subdirectories that are “named” beginning with the string “Runtime” and contain any characters after it. For instance, here is an example showing what tests will be ran using Ginkgo’s dryRun option:

The output has been truncated. For more information about this functionality, consult the aforementioned Ginkgo documentation.

For more advanced workflows, check the list of available custom options for the Cilium framework in the test/ directory and interact with ginkgo directly:

For more information about other built-in options to Ginkgo, consult the ginkgo-documentation.

If you want to run one specified test, there are a few options:

By modifying code: add the prefix “FIt” on the test you want to run; this marks the test as focused. Ginkgo will skip other tests and will only run the “focused” test. For more information, consult the Focused Specs documentation from Ginkgo.

From the command line: specify a more granular focus if you want to focus on, say, Runtime L7 tests:

This will focus on tests that contain “Runtime”, followed by any number of any characters, followed by “L7”. --focus is a regular expression and quotes are required if it contains spaces and to escape shell expansion of *.

To validate that the Go code you’ve written for testing is correct without needing to run the full test, you can build the test directory:

Sometimes when running the CI suite for a feature under development, it’s common to re-run the CI suite on the CI VMs running on a local development machine after applying some changes to Cilium. For this the new Cilium images have to be built, and then used by the CI suite. To do so, one can run the following commands on the k8s1 VM:

The commands were adapted from the test/provision/compile.sh script.

The Cilium Ginkgo framework formulates JUnit reports for each test. The following files currently are generated depending upon the test suite that is ran:

Provide informative output to console during a test using the By construct. This helps with debugging and gives those who did not write the test a good idea of what is going on. The lower the barrier of entry is for understanding tests, the better our tests will be!

Leave the testing environment in the same state that it was in when the test started by deleting resources, resetting configuration, etc.

Gather logs in the case that a test fails. If a test fails while running on Ginkgo, a postmortem needs to be done to analyze why. So, dumping logs to a location where Ginkgo can pick them up is of the highest imperative. Use the following code in an AfterFailed method:

In Cilium, some Ginkgo features are extended to cover some uses cases that are useful for testing Cilium.

This function will run before all BeforeEach within a Describe or Context. This method is an equivalent to SetUp or initialize functions in common unit test frameworks.

This method will run after all AfterEach functions defined in a Describe or Context. This method is used for tearing down objects created which are used by all Its within the given Context or Describe. It is ran after all Its have ran, this method is a equivalent to tearDown or finalize methods in common unit test frameworks.

A good use case for using AfterAll method is to remove containers or pods that are needed for multiple Its in the given Context or Describe.

This method will run just after each test and before AfterFailed and AfterEach. The main reason of this method is to perform some assertions for a group of tests. A good example of using a global JustAfterEach function is for deadlock detection, which checks the Cilium logs for deadlocks that may have occurred in the duration of the tests.

This method will run before all AfterEach and after JustAfterEach. This function is only called when the test failed.This construct is used to gather logs, the status of Cilium, etc, which provide data for analysis when tests fail.

Here is an example layout of how a test may be written with the aforementioned constructs:

Test description diagram:

You can retrieve all run commands and their output in the report directory (./test/test_results). Each test creates a new folder, which contains a file called log where all information is saved, in case of a failing test an exhaustive data will be added.

Delve is a debugging tool for Go applications. If you want to run your test with delve, you should add a new breakpoint using runtime.BreakPoint() in the code, and run ginkgo using dlv.

Example how to run ginkgo using dlv:

You can run the end-to-end tests with an arbitrary kubeconfig file by specifying --cilium.kubeconfig parameter on the Ginkgo command line. This will skip provisioning the environment and some setup tasks like labeling nodes for testing.

The current directory is cilium/test

A test focus with --focus. --focus="K8s" selects all kubernetes tests. If not passing --focus=K8s then you must pass -cilium.testScope=K8s.

Cilium images as full URLs specified with the --cilium.image and --cilium.operator-image options.

A working kubeconfig with the --cilium.kubeconfig option

A populated K8S_VERSION environment variable set to the version of the cluster

If appropriate, set the CNI_INTEGRATION environment variable set to one of gke, eks, eks-chaining, microk8s or minikube. This selects matching configuration overrides for cilium. Leaving this unset for non-matching integrations is also correct.

For k8s environments that invoke an authentication agent, such as EKS and aws-iam-authenticator, set --cilium.passCLIEnvironment=true

An example invocation is

To run tests with Kind, try

1- Setup a cluster as in Cilium Quick Installation or utilize an existing cluster.

You do not need to deploy Cilium in this step, as the End-To-End Testing Framework handles the deployment of Cilium.

The tests require machines larger than n1-standard-4. This can be set with --machine-type n1-standard-4 on cluster creation.

2- Invoke the tests from cilium/test with options set as explained in Running End-To-End Tests In Other Environments via kubeconfig

The tests require the NATIVE_CIDR environment variable to be set to the value of the cluster IPv4 CIDR returned by the gcloud container clusters describe command.

The kubernetes version defaults to 1.23 but can be configured with versions between 1.16 and 1.23. Version should match the server version reported by kubectl version.

The tests require the NATIVE_CIDR environment variable to be set to the value of the cluster IPv4 CIDR.

Setup a cluster as in Cilium Quick Installation or utilize an existing cluster. You do not need to deploy Cilium in this step, as the End-To-End Testing Framework handles the deployment of Cilium.

2. Invoke the tests from cilium/test with options set as explained in Running End-To-End Tests In Other Environments via kubeconfig

Not all tests can succeed on EKS. Many do, however and may be useful. GitHub issue 9678#issuecomment-749350425 contains a list of tests that are still failing.

Setup a cluster as in Cilium Quick Installation or utilize an existing cluster.

Source the testing integration script from cilium/contrib/testing/integrations.sh.

Invoke the gks function by passing which cilium docker image to run and the test focus. The command also accepts additional ginkgo arguments.

All Managed Kubernetes test support relies on using a pre-configured kubeconfig file. This isn’t always adequate, however, and adding defaults specific to each provider is possible. The commit adding GKE support is a good reference.

Add a map of helm settings to act as an override for this provider in test/helpers/kubectl.go. These should be the helm settings used when generating cilium specs for this provider.

Add a unique CI Integration constant. This value is passed in when invoking ginkgo via the CNI_INTEGRATON environment variable.

Update the helm overrides mapping with the constant and the helm settings.

For cases where a test should be skipped use the SkipIfIntegration. To skip whole contexts, use SkipContextIf. More complex logic can be expressed with functions like IsIntegration. These functions are all part of the test/helpers package.

If you want to run tests in an arbitrary environment with SSH access, you can use --cilium.SSHConfig to provide the SSH configuration of the endpoint on which tests will be run. The tests presume the following on the remote instance:

Cilium source code is located in the directory /home/$USER/go/src/github.com/cilium/cilium/.

Cilium is installed and running.

The ssh connection needs to be defined as a ssh-config file and need to have the following targets:

runtime: To run runtime tests

k8s{1..2}-${K8S_VERSION}: to run Kubernetes tests. These instances must have Kubernetes installed and running as a prerequisite for running tests.

An example ssh-config can be the following:

To run this you can use the following command:

There are a variety of configuration options that can be passed as environment variables:

Number of Kubernetes nodes in the cluster

Comma-separated list of K8s nodes that should not run Cilium

Kubernetes version to install

If 0 the Kubernetes’ kube-proxy won’t be installed

Have a question about how the tests work or want to chat more about improving the testing infrastructure for Cilium? Hop on over to the #testing channel on Cilium Slack.

---

## Release Management — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/release/

**Contents:**
- Release Management

This section includes information around the release cycles and guides for developers responsible for backporting fixes.

Release preparation steps can be found under github.com/cilium/release.

---

## Documentation testing — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/docs/docstest/

**Contents:**
- Documentation testing
- Set up your development environment
- For Windows
- Preview documentation locally
- Submit local changes on GitHub (Pull Request)

First, start a local document server that automatically refreshes when you save files for real-time preview. It relies on the cilium/docs-builder Docker container.

To run Cilium’s documentation locally, you need to install docker engine and also the make package. To verify that make and docker is installed, run the command make --version and docker --version in your terminal.

The preferred method is to upgrade to Windows 10 version 1903 Build 18362 or higher, you can upgrade to Windows Subsystem for Linux WSL2 and run make in Linux.

Verify you have access to the make command in your WSL2 terminal.

Download and install docker desktop.

Set up docker to use WSL2 as backend.

Start docker desktop.

Navigate to the root of the folder where you cloned the project, then run the code below in your terminal:

This will build a docker image and start a docker container. Preview the documentation at http://localhost:9081/ as you make changes. After making changes to Cilium documentation you should check that you did not introduce any new warnings or errors, and also check that your changes look as you intended one last time before opening a pull request. To do this you can build the docs:

By default, render-docs generates a preview with instructions to install Cilium from the latest version on GitHub (i.e. from the HEAD of the main branch that has not been released) regardless of which Cilium branch you are in. You can target a specific branch by specifying READTHEDOCS_VERSION environment variable:

See the submit a pull request section of the contributing guide.

---

## Integration Testing — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/testing/unit/

**Contents:**
- Integration Testing
- Prerequisites
- Running all tests
- Testing individual packages
- Automatically run unit tests on code changes

Cilium uses the standard go test framework. All new tests must use the standard test framework.

Some tests interact with the kvstore and depend on a local kvstore instances of etcd. To start the local instances, run:

To run integration tests over the entire repository, run the following command in the project root directory:

To run just unit tests, run:

It is possible to test individual packages by invoking go test directly. You can then cd into the package subject to testing and invoke go test:

Integration tests have some prerequisites like Prerequisites, you can use the following command to automatically set up the prerequisites, run the unit tests and tear down the prerequisites:

Some tests are marked as ‘privileged’ if they require the test suite to be run as a privileged user or with a given set of capabilities. They are skipped by default when running go test.

There are a few ways to run privileged tests.

Run the whole test suite with sudo.

To narrow down the packages under test, specify TESTPKGS. Note that this takes the Go package pattern syntax, including ... wildcard specifier.

Set the PRIVILEGED_TESTS environment variable and run go test directly. This only escalates privileges when executing the test binaries, the go build process is run unprivileged.

The script contrib/shell/test.sh contains some helpful bash functions to improve the feedback cycle between writing tests and seeing their results. If you’re writing unit tests in a particular package, the watchtest function will watch for changes in a directory and run the unit tests for that package any time the files change. For example, if writing unit tests in pkg/policy, run this in a terminal next to your editor:

This shell script depends on the inotify-tools package on Linux.

---

## Organization — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/release/organization/

**Contents:**
- Organization
- Release Cadence
  - Feature Releases
  - Stable Releases

New feature releases of Cilium are released on a cadence of around six months. Minor releases are typically designated by incrementing the Y in the version format X.Y.Z.

Three stable branches are maintained at a time: One for the most recent minor release, and two for the prior two minor releases. For each minor release that is currently maintained, the stable branch vX.Y on github contains the code for the next stable release. New patch releases for an existing stable version X.Y.Z are published incrementing the Z in the version format.

New patch releases for stable branches are made periodically to provide security and bug fixes, based upon community demand and bugfix severity. Potential fixes for an upcoming release are first merged into the main branch, then backported to the relevant stable branches according to the Backport Criteria.

The following sections describe in more detail the general guidelines that the release management team follows for Cilium. The team may diverge from this process at their discretion.

There are several key dates during the feature development cycle of Cilium which are important for developers:

Pre-release days: The Cilium release management team aims to publish a snapshot of the latest changes in the main branch on the first weekday of each month. This provides developers a target delivery date to incrementally ship functionality, and allows community members to get early access to upcoming features to test and provide feedback. Pre-releases may not be published when a release candidate or final stable release is being published.

Feature freeze: Around six weeks prior to a target feature release, the main branch is frozen for new feature contributions. The goal of the freeze is to focus community attention on stabilizing and hardening the upcoming release by prioritizing bugfixes, documentation improvements, and tests. In general, all new functionality that the community intends to distribute as part of the upcoming release must land into the main branch prior to this date. Any bugfixes, docs changes, or testing improvements can continue to be merged as usual following this date.

Release candidates: Following the feature freeze, the release management team publishes a series of release candidates. These candidates should represent the functionality and behaviour of the final release. The release management team encourages community participation in testing and providing feedback on the release candidates, as this feedback is crucial to identifying any issues that may not have been discovered during development. Problems identified during this period may be reported as known issues in the final release or fixed, subject to severity and community contributions towards solutions. Release candidates are typically published every two weeks until the final release is published.

Branching and feature thaw: Within two weeks of the feature freeze, the release management team aims to create a new branch to manage updates for the new stable feature release series. After this, all Pull Requests for the upcoming feature release must be labeled with a needs-backport/X.Y label with X.Y matching the target minor release version to trigger the backporting process and ensure the changes are ported to the release branch. The main branch is then unfrozen for feature changes and refactoring. Until the final release date, it is better to avoid invasive refactoring or significant new feature additions just to minimize the impact on backporting for the upcoming release during that period.

Stable release: The new feature release X.Y.0 version is published. All restrictions on submissions are lifted, and the cycle begins again.

The Cilium release management team typically aims to publish fresh releases for all maintained stable branches around the middle of each month. All changes that are merged into the target branch by the first week of the month should typically be published in that month’s patch release. Changes which do not land into the target branch by that time may be deferred to the following month’s patch release. For more information about how patches are merged into the main branch and subsequently backported to stable branches, see the Backporting process.

---

## Guide to the Hive — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/hive/

**Contents:**
- Guide to the Hive
- Introduction
- Hive and Cells
- The Hive API
  - Provide
  - Invoke
  - Module
  - Decorate
  - Config
  - Metric

Cilium is using dependency injection (via pkg/hive) to wire up the initialization, starting and stopping of its components.

Dependency injection (DI) is a technique for separating the use of objects from their creation and initialization. Essentially dependency injection is about automating the manual management of dependencies. Object constructors only need to declare their dependencies as function parameters and the rest is handled by the library. This helps with building a loosely-coupled modular architecture as it removes the need for centralization of initialization and configuration. It also reduces the inclination to use global variables over explicit passing of objects, which is often a source of bugs (due to unexpected initialization order) and difficult to deal with in tests (as the state needs to be restored for the next test). With dependency injection components are described as plain values (Cell in our flavor of DI) enabling visualization of inter-component dependencies and opening the internal architecture up for inspection.

Dependency injection and the machinery described here are only a tool to help us towards the real goal: a modular software architecture that can be easily understood, extended, repurposed, tested and refactored by a large group of developers with minimal overlap between modules. To achieve this we also need to have modularity in mind when designing the architecture and APIs.

Cilium applications are composed using runtime dependency injection from a set of modular components called cells that compose together to form a hive (as in bee hive). A hive can then be supplied with configuration and executed. To provide a feel for what this is about, here is how a simple modular HTTP server application would leverage hive:

With the above generic HTTP server in the server package, we can now implement a simple handler for /hello in the hello package:

And then put the two together into a simple application:

If you prefer to learn by example you can find a more complete and runnable example application from pkg/hive/example. Try running it with go run . and also try go run . hive. And if you’re interested in how all this is implemented internally, see pkg/hive/example/mini, a minimal example of how to do dependency injection with reflection.

With the example hopefully having now whetted the appetite, we’ll take a proper look at the hive API.

hive provides the Hive type and hive.New constructor. The hive.Hive type can be thought of as an application container, composed from cells:

hive/cell defines the Cell interface that hive.New() consumes and the following functions for creating cells:

Module: A named set of cells.

Provide: Provides constructor(s) to the hive. Lazy and only invoked if referenced by an Invoke function (directly or indirectly via other constructor).

ProvidePrivate: Provides private constructor(s) to a module and its sub-modules.

Decorate: Wraps a set of cells with a decorator function to provide these cells with augmented objects.

Config: Provides a configuration struct to the hive.

Invoke: Registers an invoke function to instantiate and initialize objects.

Metric: Provides metrics to the hive.

Hive also by default provides the following globally available objects:

Lifecycle: Methods for registering Start and Stop functions that are executed when Hive is started and stopped. The hooks are appended to it in dependency order (since the constructors are invoked in dependency order).

Shutdowner: Allows gracefully shutting down the hive from anywhere in case of a fatal error post-start.

logrus.FieldLogger: Interface to the logger. Module() decorates it with subsys=<module id>.

We’ll now take a look at each of the different kinds of cells, starting with Provide(), which registers one or more constructors with the hive:

If the constructors take many parameters, we’ll want to group them into a struct with cell.In, and conversely if there are many return values, into a struct with cell.Out. This tells hive to unpack them:

Sometimes we want to depend on a group of values sharing the same type, e.g. to collect API handlers or metrics. This can be done with value groups by combining cell.In and cell.Out with the group struct tag:

For a working example of group values this, see hive/example.

Use Provide() when you want to expose an object or an interface to the application. If there is nothing meaningful to expose, consider instead using Invoke() to register lifecycle hooks for an unexported object.

Invoke is used to invoke a function to initialize some part of the application. The provided constructors won’t be called unless an invoke function references them, either directly or indirectly via another constructor:

Cells can be grouped into modules (a named set of cells):

Module() also provides the wrapped cells with a personalized logrus.FieldLogger with the subsys field set to module identifier (“example” above).

The scope created by Module() is useful when combined with ProvidePrivate():

Sometimes one may want to use a modified object inside a module, for example how above Module() provided the cells with a personalized logger. This can be done with a decorator:

Cilium applications use the cobra and pflag libraries for implementing the command-line interface. With Cobra, one defines a Command, with optional sub-commands. Each command has an associated FlagSet which must be populated before a command is executed in order to parse or to produce usage documentation. Hive bridges to Cobra with cell.Config, which takes a value that implements cell.Flagger for adding flags to a command’s FlagSet and returns a cell that “provides” the parsed configuration to the application:

Every field in the default configuration structure must be explicitly populated. When selecting defaults for the option, consider which option will introduce the minimal disruption to existing users during upgrade. For instance, if the flag retains existing behavior from a previous release, then the default flag value should retain that behavior. If you are introducing a new optional feature, consider disabling the option by default.

In tests the configuration can be populated in various ways:

The metric cell allows you to define a collection of metrics near a feature you would like to instrument. Like the Provide cell, you define a new type and a constructor. In the case of a metric cell the type should be a struct with only public fields. The types of these fields should implement both metric.WithMetadata and prometheus.Collector. The easiest way to get such metrics is to use the types defined in pkg/metrics/metric.

The metric collection struct type returned by the given constructor is made available in the hive just like a normal provide. In addition all of the metrics are made available via the hive-metrics value group. This value group is consumed by the metrics package so any metrics defined via a metric cell are automatically registered.

In addition to cells an important building block in hive is the lifecycle. A lifecycle is a list of start and stop hook pairs that are executed in order (reverse when stopping) when running the hive.

The lifecycle hooks can be implemented either by implementing the HookInterface methods, or using the Hook struct. Lifecycle is accessible from any cell:

These hooks are executed when hive.Run() is called. The HookContext given to these hooks is there to allow graceful aborting of the starting or stopping, either due to user pressing Control-C or due to a timeout. By default Hive has 5 minute start timeout and 1 minute stop timeout, but these are configurable with SetTimeouts(). A grace time of 5 seconds is given on top of the timeout after which the application is forcefully terminated, regardless of whether the hook has finished or not.

Sometimes there’s nothing else to do but crash. If a fatal error is encountered in a Start() hook it’s easy: just return the error and abort the start. After starting one can initiate a shutdown using the hive.Shutdowner:

A hive is created using hive.New():

New() creates a new hive and registers all providers to it. Invoke functions are not yet executed as our application may have multiple hives and we need to delay object instantiation to until we know which hive to use.

However New does execute an invoke function to gather all command-line flags from all configuration cells. These can be then registered with a Cobra command:

After that the hive can be started with myHive.Run().

Run() will first construct the parsed configurations and will then execute all invoke functions to instantiate all needed objects. As part of this the lifecycle hooks will have been appended (in dependency order). After that the start hooks can be executed one after the other to start the hive. Once started, Run() waits for SIGTERM and SIGINT signals and upon receiving one will execute the stop hooks in reverse order to bring the hive down.

Now would be a good time to try this out in practice. You’ll find a small example application in hive/example. Try running it with go run . and exploring the implementation (try what happens if a provider is commented out!).

The hive.Hive can be inspected with the ‘hive’ command after it’s been registered with cobra:

The hive command prints out the cells, showing what modules, providers, configurations etc. exist and what they’re requiring and providing. Finally the command prints out all registered start and stop hooks. Note that these hooks often depend on the configuration (e.g. k8s-client will not insert a hook unless e.g. –k8s-kubeconfig-path is given). The hive command takes the same command-line flags as the root command.

The provider dependencies in a hive can also be visualized as a graphviz dot-graph:

Few guidelines one should strive to follow when implementing larger cells:

A constructor function should only do validation and allocation. Spawning of goroutines or I/O operations must not be performed from constructors, but rather via the Start hook. This is required as we want to inspect the object graph (e.g. hive.PrintObjects) and side-effectful constructors would cause undesired effects.

Stop functions should make sure to block until all resources (goroutines, file handles, …) created by the module have been cleaned up (with e.g. sync.WaitGroup). This makes sure that independent tests in the same test suite are not affecting each other. Use goleak to check that goroutines are not leaked.

Preferably each non-trivial cell would come with a test that validates that it implements its public API correctly. The test also serves as an example of how the cell’s API is used and it also validates the correctness of the cells it depends on which helps with refactoring.

Utility cells should not Invoke(). Since cells may be used in many applications it makes sense to make them lazy to allow bundling useful utilities into one collection. If a utility cell has an invoke, it may be instantiated even if it is never used.

For large cells, provide interfaces and not struct pointers. A cell can be thought of providing a service to the rest of the application. To make it accessible, one should think about what APIs the module provides and express these as well documented interface types. If the interface is large, try breaking it up into multiple small ones. Interface types also allows integration testing with mock implementations. The rational here is the same as with “return structs, accept interfaces”: since hive works with the names of types, we want to “inject” interfaces into the object graph and not struct pointers. Extra benefit is that separating the API implemented by a module into one or more interfaces it is easier to document and easier to inspect as all public method declarations are in one place.

Use parameter (cell.In) and result (cell.Out) objects liberally. If a constructor takes more than two parameters, consider using a parameter struct instead.

The hive library comes with script, a simple scripting engine for writing tests. It is a fork of the internal/script library used by the Go compiler for testing the compiler CLI usage. For usage with hive it has been extended with support for interactive use, retrying of failures and ability to inject commands from Hive cells. The same scripting language and commands provided by cells is available via the cilium-dbg shell command for live inspection of the Cilium Agent.

Hive scripts are txtar (text archive) files that contain a sequence of commands and a set of embedded input files. When the script is executed a temporary directory ($WORK) is created and the input files are extracted there.

To understand how this is put together, let’s take a look at a minimal example:

We’ve now defined a module providing Example object and some commands for interacting with it. We can now define our test runner:

And with the test runner in place we can now write our test script:

With everything in place we can now run the tests:

In the test execution we can see that a temporary working directory $WORK was created and our test files from the example.txtar extracted there. Each command was then executed in order.

As many of the cells bring rich set of commands it’s important that they’re easy to discover. To find the commands available, use the help command to interactively explore the available commands to use in tests. Try for example adding break as the last command in example.txtar:

The important default commands are:

help: List available commands. Takes an optional regex to filter.

hive: Dump the hive object graph

hive/start: Start the test hive

stdout regex: Grep the stdout buffer

cmp file1 file2: Compare two files

exec cmd args...: Execute an external program ($PATH needs to be set!)

replace old new file: Replace text in a file

empty: Check if file is empty

The commands can be modified with prefixes:

! cmd args...: Fail if the command succeeds

* cmd args...: Retry all commands in the section until this succeeds

!* cmd args...: Retry all commands in the section until this fails

A section is defined by a # comment line and consists of all commands between the comment and the next comment.

New commands should use the naming scheme <component>/<command>, e.g. hive/start and not build sub-commands. This makes help more useful and makes it easier to discover the commands.

These cells when included in the test hive will bring useful commands that can be used in tests.

FakeClientCell: Commands for interacting with the fake client to add or delete objects. See help k8s.

StateDB: Commands for inspecting and manipulating StateDB. Also available via cilium-dbg shell. See help db.

metrics.Cell: Commands for dumping and plotting metrics. See help metrics and pkg/metrics/testdata.

Note that StateDB and metrics are part of Cilium’s Hive wrapper defined in pkg/hive, so if you use (pkg/hive).New() they will be included automatically.

To find existing tests to use as reference you can grep for usage of scripttest.Test:

Here’s a few scripts that are worth calling out:

daemon/k8s/testdata/pod.txtar: Tests populating Table[LocalPod] from K8s objects defined in YAML. Good reference for the k8s/* and db/* commands.

pkg/ciliumenvoyconfig/testdata: Complex component integration tests that go from K8s objects down to BPF maps.

pkg/datapath/linux/testdata/device-detection.txtar: Low-level test that manipulates network devices in a new network namespace

Hive is built on top of uber/dig, a reflection based library for building dependency injection frameworks. In dig, you create a container, add in your constructors and then “invoke” to create objects:

This is the basis on top of which Hive is built. Hive calls dig’s Provide() for each of the constructors registered with cell.Provide and then calls invoke functions to construct the needed objects. The results from the constructors are cached, so each constructor is called only once.

uber/dig uses Go’s “reflect” package that provides access to the type information of the provide and invoke functions. For example, the Provide method does something akin to this under the hood:

Invoke will similarly reflect on the function value to find out what are the required inputs and then find the required constructors for the input objects and recursively their inputs.

While building this on reflection is flexible, the downside is that missing dependencies lead to runtime errors. Luckily dig produces excellent errors and suggests closely matching object types in case of typos. Due to the desire to avoid these runtime errors the constructed hive should be as static as possible, e.g. the set of constructors and invoke functions should be determined at compile time and not be dependent on runtime configuration. This way the hive can be validated once with a simple unit test (daemon/cmd/cells_test.go).

Logging is provided to all cells by default with the *slog.Logger. The log lines will include the attribute module=<module id>.

The client package provides the Clientset API that combines the different clientsets used by Cilium into one composite value. Also provides FakeClientCell for writing integration tests for cells that interact with the K8s api-server.

Resource and the store (see below) is the preferred way of accessing Kubernetes object state to minimize traffic to the api-server. The Clientset should usually only be used for creating and updating objects.

The Resource[T] pattern is being phased out in the Cilium Agent and new code should use StateDB. See daemon/k8s/tables.go, pkg/k8s/statedb.go and PR 34060.

While not a cell by itself, pkg/k8s/resource provides an useful abstraction for providing shared event-driven access to Kubernetes objects. Implemented on top of the client-go informer, workqueue and store to codify the suggested pattern for controllers in a type-safe way. This shared abstraction provides a simpler API to write and test against and allows central control over what data (and at what rate) is pulled from the api-server and how it’s stored (in-memory or persisted).

The resources are usually made available centrally for the application, e.g. in cilium-agent they’re provided from pkg/k8s/resource.go. See also the runnable example in pkg/k8s/resource/example.

The job package contains logic that makes it easy to manage units of work that the package refers to as “jobs”. These jobs are scheduled as part of a job group.

Every job is a callback function provided by the user with additional logic which differs slightly for each job type. The jobs and groups manage a lot of the boilerplate surrounding lifecycle management. The callbacks are called from the job to perform the actual work.

These jobs themselves come in several varieties. The OneShot job invokes its callback just once. This job type can be used for initialization after cell startup, routines that run for the full lifecycle of the cell, or for any other task you would normally use a plain goroutine for.

The Timer job invokes its callback periodically. This job type can be used for periodic tasks such as synchronization or garbage collection. Timer jobs can also be externally triggered in addition to the periodic invocations.

The Observer job invokes its callback for every message sent on a stream.Observable. This job type can be used to react to a data stream or events created by other cells.

---

## Recommendations on documentation structure — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/docs/docsstructure/

**Contents:**
- Recommendations on documentation structure
- Maintaining good information architecture
- Adding a new page
- Updating an existing page
- Removing content and entire pages

This page contains recommendations to help contributors write better documentation. The goal of better documentation is a better user experience. If you take only one thing away from this guide, let it be this: don’t document your feature. Instead, document how your feature guides users on their journey.

When you add, update, or remove documentation, consider how the change affects the site’s information architecture. Information architecture is what shapes a user’s experience and their ability to accomplish their goals with Cilium. If an addition, change, or removal would significantly alter a user’s journey or prevent their success, make sure to flag the change clearly in upgrade notes.

When you need to write completely new content, create one or more new pages as one of the three following types:

Concept (no steps, just knowledge)

Task (how to do one discrete thing)

Tutorial (how to combine multiple features to accomplish specific goals)

A concept explains some aspect of Cilium. Typically, concept pages don’t include sequences of steps. Instead, they link to tasks or tutorials.

For an example of a concept page, see Routing.

A task shows how to do one discrete thing with Cilium. Task pages give readers a sequence of steps to perform. A task page can be short or long, but must remain focused on the task’s singular goal. Task pages can blend brief explanations with the steps to perform, but if you need to provide a lengthy explanation, write a separate concept and link to it. Link related task and concept pages to each other.

For an example of a task page, see Migrating a Cluster to Cilium.

A tutorial shows how to accomplish a goal using multiple Cilium features. Tutorials are flexible: for example, a tutorial page could provide several discrete sequences of steps to perform, or show how related pieces of code could interact. Tutorials can blend brief explanations with the steps to perform, but lengthy explanations should link to related concept topics.

For an example of a tutorial page, see Inspecting Network Flows with the CLI.

You may need to add multiple pages to support a new feature. For example, if a new feature requires an explanation of its underlying ideas, add a concept page as well as a task page.

Consider whether you can update an existing page or whether to add a new one.

If adding or updating content to a page keeps it centered on a single concept or task, then you can update an existing page. If adding or updating content to a page expands it to include multiple concepts or tasks, then add new pages for individual concepts and tasks.

If you’re moving a page and changing its URL, make sure you update every link to that page in the documentation. Ask on Cilium Slack (#sig-docs) for someone to set up a HTTP redirection from the old URL to the new one, if necessary.

Removing stale content is a part of maintaining healthy docs.

Whether you’re removing stale content on a page or removing a page altogether, make sure to consider the impact of removal on a user’s journey. Specific considerations include:

Updating any links to removed content

Ensuring users have clear guidance on what to do next

Without a clearly defined user journey, evaluation is largely qualitative. Practice empathy: would someone succeed if they had your skills but not your context?

---

## CI / GitHub Actions — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/testing/ci/

**Contents:**
- CI / GitHub Actions
- Triggering Smoke Tests
- Triggering Platform Tests
- Using GitHub Actions for testing
  - Bisect process
  - GitHub Test Results
  - Testing matrix
- CI Failure Triage
  - Triage process
- Disabling Github Actions Workflows

The main CI infrastructure is maintained on GitHub Actions (GHA).

This infrastructure is broadly comprised of smoke tests and platform tests. Smoke tests are typically initiated by pull_request or pull_request_target triggers automatically when opening or updating a pull request. Platform tests often require an organization member to manually trigger the test when the pull request is ready to be tested.

Several short-running tests are automatically triggered for all contributor submissions, subject to GitHub’s limitations around first-time contributors. If no GitHub workflows are triggering on your PR, a committer for the project should trigger these within a few days. Reach out in the #testing channel on Cilium Slack for assistance in running these tests.

To ensure that build resources are used judiciously, some tests on GHA are manually triggered via comments. These builds typically make use of cloud infrastructure, such as allocating clusters or VMs in AKS, EKS or GKE. In order to trigger these jobs, a member of the GitHub organization must post a comment on the Pull Request with a “trigger phrase”.

If you’d like to trigger these jobs, ask in Cilium Slack in the #testing channel. If you’re regularly contributing to Cilium, you can also become a member of the Cilium organization.

Depending on the PR target branch, a specific set of jobs is marked as required, as per the Cilium CI matrix. They will be automatically featured in PR checks directly on the PR page. The /test trigger phrase may be used to trigger them all at once.

More triggers can be found in ariane-config.yaml

For a full list of GHA, see GitHub Actions Page

On GHA, running a specific set of Ginkgo tests (conformance-ginkgo.yaml) can also be accomplished by modifying the files under .github/actions/ginkgo/ by adding or removing entries.

This file contains a list of tests to include and exclude. The cliFocus defined for each element in the “include” section is expanded to the specific defined focus. This mapping allows us to determine which regex should be used with ginkgo --focus for each element in the “focus” list. See Running Specific Tests Within a Test Suite for more information about --focus flag.

Additionally, there is a list of excluded tests along with justifications in the form of comments, explaining why each test is excluded based on constraints defined in the ginkgo tests.

For more information, refer to GitHub’s documentation on expanding matrix configurations

main-k8s-versions.yaml:

This file defines which kernel versions should be run with specific Kubernetes (k8s) versions. It contains an “include” section where each entry consists of a k8s version, IP family, Kubernetes image, and kernel version. These details determine the combinations of k8s versions and kernel versions to be tested.

This file specifies the k8s versions to be executed for each pull request (PR). The list of k8s versions under the “k8s-version” section determines the matrix of jobs that should be executed for CI when triggered by PRs.

This file specifies the k8s versions to be executed on a regular basis. The list of k8s versions under the “k8s-version” section determines the matrix of jobs that should be executed for CI as part of scheduled jobs.

Workflow interactions:

The main-focus.yaml file helps define the test focus for CI jobs based on specific criteria, expanding the cliFocus to determine the relevant focus regex for ginkgo --focus.

The main-k8s-versions.yaml file defines the mapping between k8s versions and the associated kernel versions to be tested.

Both main-prs.yaml and main-scheduled.yaml files utilize the “k8s-version” section to specify the k8s versions that should be included in the job matrix for PRs and scheduled jobs respectively.

These files collectively contribute to the generation of the job matrix for GitHub Actions workflows, ensuring appropriate testing and validation of the defined k8s versions.

For example, to only run the test under f09-datapath-misc-2 with Kubernetes version 1.26, the following files can be modified to have the following content:

The main-k8s-versions.yaml and main-scheduled.yaml files can be left unmodified and this will result in the execution on the tests under f09-datapath-misc-2 for the k8s-version “1.26”.

Bisecting Ginkgo tests (conformance-ginkgo.yaml) can be performed by modifying the workflow file, as well as modifying the files under .github/actions/ginkgo/ as explained in the previous section. The sections that need to be modified for the conformance-ginkgo.yaml can be found in form of comments inside that file under the on section and enable the event type of pull_request. Additionally, the following section also needs to be modified:

As per the instructions, the base_branch needs to be uncommented and should point to the base branch name that we are testing. The sha must to point to the commit SHA that we want to bisect. The SHA must point to an existing image tag under the ``quay.io/cilium/cilium-ci`` docker image repository.

It is possible to find out whether or not a SHA exists by running either docker manifest inspect or docker buildx imagetools inspect. This is an example output for the non-existing SHA 22fa4bbd9a03db162f08c74c6ef260c015ecf25e and existing SHA 7b368923823e63c9824ea2b5ee4dc026bc4d5cd8:

Once the changes are committed and pushed into a draft Pull Request, it is possible to visualize the test results on the Pull Request’s page.

Once the test finishes, its result is sent to the respective Pull Request’s page.

In case of a failure, it is possible to check with test failed by going over the summary of the test on the GitHub Workflow Run’s page:

On this example, the test K8sDatapathConfig Transparent encryption DirectRouting Check connectivity with transparent encryption and direct routing with bpf_host failed. With the cilium-sysdumps artifact available for download we can retrieve it and perform further inspection to identify the cause for the failure. To investigate CI failures, see CI Failure Triage.

Up to date CI testing information regarding k8s - kernel version pairs can always be found in the Cilium CI matrix.

This section describes the process to triage CI failures. We define 3 categories:

Failure due to a temporary situation such as loss of connectivity to external services or bug in system component, e.g. quay.io is down, VM race conditions, kube-dns bug, …

Bug in the test itself that renders the test unreliable, e.g. timing issue when importing and missing to block until policy is being enforced before connectivity is verified.

Failure is due to a regression, all failures in the CI that are not caused by bugs in the test are considered regressions.

Investigate the failure you are interested in and determine if it is a CI-Bug, Flake, or a Regression as defined in the table above.

Search GitHub issues to see if bug is already filed. Make sure to also include closed issues in your search as a CI issue can be considered solved and then re-appears. Good search terms are:

The line on which the test failed, e.g.

The error message, e.g.

If a corresponding GitHub issue exists, update it with:

A link to the failing GHA build (note that the build information is eventually deleted).

If no existing GitHub issue was found, file a new GitHub issue:

Attach failure case and logs from failing test

If the failure is a new regression or a real bug:

Title: <Short bug description>

Labels kind/bug and needs/triage.

If failure is a new CI-Bug, Flake or if you are unsure:

Title CI: <testname>: <cause>, e.g. CI: K8sValidatedPolicyTest Namespaces: cannot curl service

Labels kind/bug/CI and needs/triage

Include the test name and whole Stacktrace section to help others find this issue.

Be extra careful when you see a new flake on a PR, and want to open an issue. It’s much more difficult to debug these without context around the PR and the changes it introduced. When creating an issue for a PR flake, include a description of the code change, the PR, or the diff. If it isn’t related to the PR, then it should already happen in the main branch, and a new issue isn’t needed.

Flake, quay.io is down

Flake, DNS not ready, #3333

CI-Bug, K8sValidatedPolicyTest: Namespaces, pod not ready, #9939

Regression, k8s host policy, #1111

Do not use the GitHub web UI to disable GitHub Actions workflows. It makes it difficult to find out who disabled the workflows and why.

Before proceeding, consider the following alternatives to disabling an entire GitHub Actions workflow.

Skip individual tests. If specific tests are causing the workflow to fail, disable those tests instead of disabling the workflow. When you disable a workflow, all the tests in the workflow stop running. This makes it easier to introduce new regressions that would have been caught by these tests otherwise.

Remove the workflow from the list of required status checks. This way the workflow still runs on pull requests, but you can still merge them without the workflow succeeding. To remove the workflow from the required status check list, post a message in the #testing Slack channel and @mention people in the cilium-maintainers team.

Open a GitHub issue to track activities related to fixing the workflow. If there are existing test flake GitHub issues, list them in the tracking issue. Find an assignee for the tracking issue to avoid the situation where the workflow remains disabled indefinitely because nobody is assigned to actually fix the workflow.

If the workflow is in the required status check list, it needs to be removed from the list. Notify the cilium-maintainers team by mentioning @cilium/cilium-maintainers in the tracking issue and ask them to remove the workflow from the required status check list.

Update the workflow configuration as described in the following sub-steps depending on whether the workflow is triggered by the /test comment or by the pull_request or pull_request_target trigger. Open a pull request with your changes, have it reviewed, then merged.

For those workflows that get triggered by the /test comment, update ariane-config.yaml and remove the workflow from triggers:/test:workflows section (an example). Do not remove the targeted trigger (triggers:/ci-e2e for example) so that you can still use the targeted trigger to run the workflow when needed.

For those workflows that get triggered by the pull_request or pull_request_target trigger, remove the trigger from the workflow file. Do not remove the schedule trigger if the workflow has it. It is useful to be able to see if the workflow has stabilized enough over time when making the decision to re-enable the workflow.

---

## Backporting process — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/release/backports/

**Contents:**
- Backporting process
- Backport Criteria
  - Backport Criteria for Current Minor Release
  - Backport Criteria for X.Y-1.Z and X.Y-2.Z
  - Backport Criteria for documentation changes
  - Proposing PRs for backporting
  - Marking PRs to be backported by the author
- Backporting Guide for the Backporter
  - One-time Setup
  - Preparation

Committers may nominate PRs that have been merged into main as candidates for backport into stable releases if they affect the stable production usage of community users.

Criteria for inclusion into the next stable release of the current latest minor version of Cilium, for example in a v1.2.z release prior to the release of version v1.3.0:

Debug tool improvements

Criteria for the inclusion into the next stable release of the prior two minor versions of Cilium, for example in a v1.0.z or v1.1.z release prior to the release of version v1.3.0:

Security relevant fixes

Major bugfixes relevant to the correct operation of Cilium

Debug tool improvements

Changes to Cilium’s documentation should generally be subject to backports for all supported branches to which they apply (all supported branches containing the parent features to which the modified sections relate).

The motivation is that users can then simply look at the branch of the documentation related to the version they are deploying, and find the latest correct instructions for their version.

PRs are proposed for backporting by adding a needs-backport/X.Y label to them. Normally this is done by the author when the PR is created or one of the maintainers when the PR is reviewed. When proposing PRs that have already been merged, also add a comment to the PR to ensure that the backporters are notified.

For PRs which need to be backported, but are likely to run into conflicts or other difficulties, the author has the option of adding the backport/author label. This will exclude the PR from backporting automation, and the author is expected to perform the backport themselves.

Cilium PRs that are marked with the label needs-backport/X.Y need to be backported to the stable branch X.Y. The following steps summarize the process for backporting these PRs:

Preparing PRs for backport

Cherry-picking commits into a backport branch

Posting the PR and updating GitHub labels

Make sure you have a GitHub developer access token with the public_repos workflow, read:user scopes available. You can do this directly from https://github.com/settings/tokens or by opening GitHub and then navigating to: User Profile -> Settings -> Developer Settings -> Personal access token -> Generate new token.

The scripts referred to below need to be run on Linux, they do not work on macOS. It is recommended to create a container using (contrib/backporting/Dockerfile), as it will have all the correct versions of dependencies / libraries.

If you are running on a mac OS, and see /home/user/.ssh/config: line 3: Bad configuration option: usekeychain error message while running any of the backporting scripts, comment out the line UseKeychain yes.

Once you have a setup ready, you need to configure git to have your name and email address to be used in the commit messages:

Add remotes for the Cilium upstream repository and your Cilium repository fork.

Skip this step if you have created a setup using the pre-defined Dockerfile. This guide makes use of several tools to automate the backporting process. The basics require bash and git, but to automate interactions with github, further tools are required.

pip3 install PyGithub

Github hub CLI (>= 2.8.3)

Verify your machine is correctly configured by running

Pull requests that are candidates for backports to the X.Y stable release are tracked through the following links:

PRs with the needs-backport/X.Y label (1.18: GitHub Link)

PRs with the backport-pending/X.Y label (1.18: GitHub Link)

The X.Y GitHub project (1.18: GitHub Link)

Make sure that the Github labels are up-to-date, as this process will deal with all commits from PRs that have the needs-backport/X.Y label set (for a stable release version X.Y).

Check whether there are any outstanding backport PRs for the target branch. If there are already backports for that branch, create a thread in the #launchpad channel in Cilium Slack and reach out to the author to coordinate triage, review and merge of the existing PR into the target branch.

Run contrib/backporting/start-backport for the release version that you intend to backport PRs for. This will pull the latest repository commits from the Cilium repository (assumed to be the git remote origin), create a new branch, and runs the contrib/backporting/check-stable script to fetch the full set of PRs to backport.

This command will leave behind a file in the current directory with a name based upon the release version and the current date in the form vRELEASE-backport-YYYY-MM-DD.txt which contains a prepared backport pull-request description so you don’t need to write one yourself.

Cherry-pick the commits using the main branch git SHAs listed, starting from the oldest (top), working your way down and fixing any merge conflicts as they appear. Note that for PRs that have multiple commits you will want to check that you are cherry-picking oldest commits first. The cherry-pick script accepts multiple arguments, in which case it will attempt to apply each commit in the order specified on the command line until one cherry pick fails or every commit is cherry-picked.

Conflicts may be resolved by applying changes or backporting other PRs to completely avoid conflicts. Backporting entire PRs is preferred if the changes in the dependent PRs are small. This stackoverflow.com question describes how to determine the original PR corresponding to a particular commit SHA in the GitHub UI.

If a conflict is resolved by modifying a commit during backport, describe the changes made in the commit message and collect these to add to the backport PR description when creating the PR below. This helps to direct backport reviewers towards which changes may deviate from the original commits to ensure that the changes are correctly backported. This can be fairly simple, for example inside the commit message of the modified commit:

It is the backporter’s responsibility to check that the backport commits they are preparing are identical to the original commits. This can be achieved by preparing the commits, then running git show <commit> for both the original upstream commit and the prepared backport, and read through the commits side-by-side, line-by-line to check that the changes are the same. If there is any uncertainty about the backport, reach out to the original author directly to coordinate how to prepare the backport for the target branch.

For backporting commits that update cilium-builder and cilium-runtime images, the backporter builds new images as described in Update cilium-builder and cilium-runtime images.

(Optional) If there are any commits or pull requests that are tricky or time-consuming to backport, consider reaching out for help on Cilium Slack. If the commit does not cherry-pick cleanly, please mention the necessary changes in the pull request description in the next section.

The backport pull-request may be created via CLI tools, or alternatively you can use the GitHub web interface to achieve these steps.

These steps require all of the tools described in the One-time Setup section above. It pushes the git tree, creates the pull request and updates the labels for the PRs that are backported, based on the vRELEASE-backport-YYYY-MM-DD.txt file in the current directory.

The script takes up to three positional arguments:

The first parameter is the version of the branch against which the PR should be done, and defaults to the version passed to start-backport.

The second one is the name of the file containing the text summary to use for the PR, and defaults to the file created by start-backport.

The third one is the name of the git remote of your (forked) repository to which your changes will be pushed. It defaults to the git remote which matches github.com/<your github username>/cilium.

Push your backports branch to your fork of the Cilium repo.

Create a new PR from your branch towards the feature branch you are backporting to. Note that by default Github creates PRs against the main branch, so you will need to change it. The title and description for the pull request should be based upon the vRELEASE-backport-YYYY-MM-DD.txt file that was generated by the scripts above.

The vRELEASE-backport-YYYY-MM-DD.txt file will include:

The upstream-prs tag is required, so add it if you manually write the message.

Label the new backport PR with the backport label for the stable branch such as backport/X.Y as well as kind/backports so that it is easy to find backport PRs later.

Mark all PRs you backported with the backport pending label backport-pending/X.Y and clear the needs-backport/X.Y label. This can be done with the command printed out at the bottom of the output from the start-backport script above (GITHUB_TOKEN needs to be set for this to work).

To validate a cross-section of various tests against the PRs, backport PRs should be validated in the CI by running all CI targets. This can be triggered by adding a comment to the PR with exactly the text /test, as described in Triggering Platform Tests. The comment must not contain any other characters.

After the backport PR is merged, the GH workflow “Call Backport Label Updater” should take care of marking all backported PRs with the backport-done/X.Y label and clear the backport-pending/X.Y label(s). Verify that the workflow succeeded by looking here.

Committers should mark PRs needing backport as needs-backport/X.Y, based on the backport criteria. It is up to the reviewers to confirm that the backport request is reasonable and, if not, raise concerns on the PR as comments. In addition, if conflicts are foreseen or significant changes to the PR are necessary for older branches, consider adding the backport/author label to mark the PR to be backported by the author.

At some point, changes will be picked up on a backport PR and the committer will be notified and asked to approve the backport commits. Confirm that:

All the commits from the original PR have been indeed backported.

In case of conflicts, the resulting changes look good.

---

## Scalability and Performance Testing — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/testing/scalability/

**Contents:**
- Scalability and Performance Testing
- Introduction
- Overview of existing tests
- Running CL2 tests locally
  - Accessing Grafana and Prometheus during the test run
- Metrics-based testing and alerting
- Running tests in CI
  - Accessing test results from PR or CI runs
  - Visualizing results in Perfdash
  - Accessing Prometheus snapshot

Cilium scalability and performance tests leverage ClusterLoader2. For an overview of ClusterLoader2, please refer to the Readme and Getting Started. At a high level, ClusterLoader2 allows for specifying states of the cluster, how to transition between them and what metrics to measure during the test run. Additionally, it allows for failing the test if the metrics are not within the expected thresholds.

Tests based on kOps and GCP VMs:

100 nodes scale test - /scale-100 Workflow that executes two test scenarios:

Network policy scale test

FQDN performance test - /fqdn-perf Workflow is a simple two-node test that deploys pods with FQDN policies and measures the time it takes to resolve FQDNs from a client point of view.

ClusterMesh scale test - /scale-clustermesh Workflow leverages a mock Clustermesh control plane that simulates large deployments of ClusterMesh.

Egress Gateway scale test - /scale-egw. Workflow tests Egress Gateway on a small cluster, but with synthetically created Endpoints and Nodes to simulate a large cluster.

Whenever developing a new test, consider if you want to add a test to an already existing workflow, create a new one, or extend some existing test. If you are unsure, you can always ask in the #sig-scalabilty Slack channel. For example, if you want to run a test on a large cluster, you might consider adding it as a separate test scenario to the already existing 100-nodes scale test to reduce the cost of CI, because spinning up a new cluster and tearing it down is quite a long process. For some use cases, it might be better to simulate only a large cluster but execute the test on a small cluster, like in the case of the Egress Gateway scale test or the ClusterMesh scale test.

Each CL2 test should be designed in a way that scales with the number of nodes. This allows for running a specific test case scenario in a local environment, to validate the test case. For example, let’s run the network policy scale test in a local Kind cluster. First, set up a Kind cluster with Cilium, as documented in Development Setup. Build the ClusterLoader2 binary from the perf-tests repository. Then you can run:

Some additional options worth mentioning are:

--tear-down-prometheus-server=false - Leaves Prometheus and Grafana running after the test finishes, this helps speed up the test run when running multiple tests in a row, but also for exploring the metrics in Grafana.

--experimental-prometheus-snapshot-to-report-dir=true - Creates a snapshot of the Prometheus data and saves it to the report directory

By setting deleteAutomanagedNamespaces: false in the test config, you can also leave the test namespaces after the test finishes. This is especially useful for checking if your test created the expected resources.

At the end of output, the test should end successfully with:

All the test results are saved in the report directory, ./report in this case. Most importantly, it contains:

generatedConfig_netpol.yaml - Rendered test scenario

'GenericPrometheusQuery NetPol Average CPU Usage_netpol_.*.json' - GenericPrometheusQuery contains results of the Prometheus queries executed during the test. In this example, it contains the CPU usage of the Cilium agents. All of the Prometheus Queries will be automatically visualized in perfdash.

'PodPeriodicCommand.*Profiles-stdout.*' - Contains memory and CPU profiles gathered during the test run. To understand how to interpret them, refer to the Accessing CPU and memory profiles subsection.

During the test execution, ClusterLoader2 deploys Prometheus and Grafana to the cluster. You can access Grafana and Prometheus by running:

This can be especially useful for exploring the metrics and adding additional queries to the test.

Sometimes, you might want to scrape additional targets during test execution on top of the default ones. In this case, you can simply create a Pod or Service monitor example monitor. Then you need to pass it as an additional argument to ClusterLoader2:

Now you can use the additional metrics in your test, by leveraging regular GenericPrometheusQuery measurement. For example, Egress Gateway ensures that various percentiles of masquerade latency observed by clients are below specific thresholds. This can be achieved by the following measurement in ClusterLoader2:

Once you are happy with the test and validated it locally, you can create a PR with the test. You can base your GitHub workflow on the existing tests, or add a test scenario to an already existing workflow.

You can run the specific scalability or performance test in your PR, some example commands are:

After the test run, all results will be saved in the Google Storage bucket. In the workflow run, you will see a link to the test results at the bottom. For example, open test runs and pick one of the runs. You should see a link like this:

To see how to install gsutil check Install gsutil section. To see the results, you can run:

You can also copy results to your local machine by running:

Perfdash leverages exported results from ClusterLoader2 and visualizes them. Currently, we do not host a publicly available instance of Perfdash. To visualize the results, please check the Scaffolding repository. As an example, you can check CPU usage of the Cilium agent:

Note that clicking on the graph redirects you to the Google Cloud Storage page containing all of the results for the specific test run.

Each test run creates a snapshot of the Prometheus data and saves it to the report directory. This is enabled by setting --experimental-prometheus-snapshot-to-report-dir=true. Prometheus snapshots help with debugging, give a good overview of the cluster state during the test run and can be used to further improve alerting in CI based on existing metrics.

For example, a snapshot can be found in the directory gs://cilium-scale-results/logs/scale-100-main/1745287079/artifacts/prometheus_snapshot.tar.gz. You need to extract it and run Prometheus locally:

To visualize the data, you can run Grafana locally and connect it to the Prometheus instance.

All of the scalability tests collect CPU and memory profiles. They are collected under file names like PodPeriodicCommand.*Profiles-stdout.*. Each profile is taken periodically during the test run. The simplest way to visualize them is to leverage pprof-merge. Example commands to aggregate CPU and memory profiles from the whole test run:

Then you can visualize the aggregated CPU and memory profiles by running:

If you want to compare the profiles, you can compare them against the baseline extracted from different test run:

---

## Documentation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/docs/

**Contents:**
- Documentation

This section provides guidance on the structure of Cilium documentation, describes its style, and explains how to test it. Before contributing, please review the structure recommendations and style guide.

See the clone and provision environment section to learn how to fork and clone the repository.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

---

## Debugging — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/debugging/

**Contents:**
- Debugging
- Attaching a Debugger
  - Visual Studio Code
  - Neovim
- toFQDNs and DNS Debugging
  - Isolating the source of toFQDNs issues
    - REFUSED vs NXDOMAIN responses
    - Monitor Events
    - DNS Proxy Errors
    - Identities and Policy

Cilium comes with a set of Makefile targets for quickly deploying development builds to a local Kind cluster. One of these targets is kind-debug-agent, which generates a container image that wraps the Cilium agent with a Delve (dlv) invocation. This causes the agent process to listen for connections from a debugger front-end on port 2345.

To build and push a debug image to your local Kind cluster, run:

The image is automatically pushed to the Kind nodes, but running Cilium Pods are not restarted. To do so, run:

If your Kind cluster was set up using make kind, it will automatically be configured using with the following port mappings:

23401: kind-control-plane-1

2340*: Subsequent kind-control-plane-* nodes, if defined

2341*: Subsequent kind-worker-* nodes, if defined

The Delve listener supports multiple debugging protocols, so any IDEs or debugger front-ends that understand either the Debug Adapter Protocol or Delve API v2 are supported.

The Cilium repository contains a VS Code launch configuration (.vscode/launch.json) that includes debug targets for the Kind control plane, the first two kind-worker nodes and the Cilium Operator.

The preceding screenshot is taken from the ‘Run And Debug’ section in VS Code. The default shortcut to access this section is Shift+Ctrl+D. Select a target to attach to, start the debug session and set a breakpoint to halt the agent or operator on a specific code statement. This only works for Go code, BPF C code cannot be debugged this way.

See the VS Code debugging guide for more details.

The Cilium repository contains a .nvim directory containing a DAP configuration as well as a README on how to configure nvim-dap.

The interactions of L3 toFQDNs and L7 DNS rules can be difficult to debug around. Unlike many other policy rules, these are resolved at runtime with unknown data. Pods may create large numbers of IPs in the cache or the IPs returned may not be compatible with our datapath implementation. Sometimes we also just have bugs.

While there is no common culprit when debugging, the DNS Proxy shares the least code with other system and so is more likely the least audited in this chain. The cascading caching scheme is also complex in its behaviour. Determining whether an issue is caused by the DNS components, in the policy layer or in the datapath is often the first step when debugging toFQDNs related issues. Generally, working top-down is easiest as the information needed to verify low-level correctness can be collected in the initial debug invocations.

The proxy uses REFUSED DNS responses to indicate a denied request. Some libc implementations, notably musl which is common in Alpine Linux images, terminate the whole DNS search in these cases. This often manifests as a connect error in applications, as the libc lookup returns no data. To work around this, denied responses can be configured to be NXDOMAIN by setting --tofqdns-dns-reject-response-code=nameError on the command line.

The DNS Proxy emits multiple L7 DNS monitor events. One for the request and one for the response (if allowed). Often the L7 DNS rules are paired with L3 toFQDNs rules and events relating to those rules are also relevant.

Be sure to run cilium-dbg monitor on the same node as the pod being debugged!

The above is for a simple curl cilium.io in a pod. The L7 DNS request is the first set of message and the subsequent L3 connection is the HTTP component. AAAA DNS lookups commonly happen but were removed to simplify the example.

If no L7 DNS requests appear, the proxy redirect is not in place. This may mean that the policy does not select this endpoint or there is an issue with the proxy redirection. Whether any redirects exist can be checked with cilium-dbg status --all-redirects. In the past, a bug occurred with more permissive L3 rules overriding the proxy redirect, causing the proxy to never see the requests.

If the L7 DNS request is blocked, with an explicit denied message, then the requests are not allowed by the proxy. This may be due to a typo in the network policy, or the matchPattern rule not allowing this domain. It may also be due to a bug in policy propagation to the DNS Proxy.

If the DNS request is allowed, with an explicit message, and it should not be, this may be because a more general policy is in place that allows the request. matchPattern: "*" visibility policies are commonly in place and would supersede all other, more restrictive, policies. If no other policies are in place, incorrect allows may indicate a bug when passing policy information to the proxy. There is no way to dump the rules in the proxy, but a debug log is printed when a rule is added. Look for DNS Proxy updating matchNames in allowed list during UpdateRules. The pkg/proxy/dns.go file contains the DNS proxy implementation.

If L7 DNS behaviour seems correct, see the sections below to further isolate the issue. This can be verified with cilium-dbg fqdn cache list. The IPs in the response should appear in the cache for the appropriate endpoint. The lookup time is included in the json output of the command.

As of Cilium 1.16, the ExpirationTime represents the next time that the entry will be evaluated for staleness. If the entry Source is lookup, then the entry will expire at that time. An equivalent entry with source connection may be established when a lookup entry expires. If the corresponding Endpoint continues to communicate to this domain via one of the related IP addresses, then Cilium will continue to keep the connection entry alive. When the expiration time for a connection entry is reached, the entry will be re-evaluated to determine whether it is still used by active connections, and at that time may expire or be renewed with a new target expiration time.

REFUSED responses are returned when the proxy encounters an error during processing. This can be confusing to debug as that is also the response when a DNS request is denied. An error log is always printed in these cases. Some are callbacks provided by other packages via daemon in cilium-agent.

Rejecting DNS query from endpoint due to error: This is the “normal” policy-reject message. It is a debug log.

cannot extract endpoint IP from DNS request: The proxy cannot read the socket information to read the source endpoint IP. This could mean an issue with the datapath routing and information passing.

cannot extract endpoint ID from DNS request: The proxy cannot use the source endpoint IP to get the cilium-internal ID for that endpoint. This is different from the Security Identity. This could mean that cilium is not managing this endpoint and that something has gone awry. It could also mean a routing problem where a packet has arrived at the proxy incorrectly.

cannot extract destination IP:port from DNS request: The proxy cannot read the socket information of the original request to obtain the intended target IP:Port. This could mean an issue with the datapath routing and information passing.

cannot find server ip in ipcache: The proxy cannot resolve a Security Identity for the target IP of the DNS request. This should always succeed, as world catches all IPs not set by more specific entries. This can mean a broken ipcache BPF table.

Rejecting DNS query from endpoint due to error: While checking if the DNS request was allowed (based on Endpoint ID, destination IP:Port and the DNS query) an error occurred. These errors would come from the internal rule lookup in the proxy, the allowed field.

Timeout waiting for response to forwarded proxied DNS lookup: The proxy forwards requests 1:1 and does not cache. It applies a 10s timeout on responses to those requests, as the client will retry within this period (usually). Bursts of these errors can happen if the DNS target server misbehaves and many pods see DNS timeouts. This isn’t an actual problem with cilium or the proxy although it can be caused by policy blocking the DNS target server if it is in-cluster.

Timed out waiting for datapath updates of FQDN IP information; returning response: When the proxy updates the DNS caches with response data, it needs to allow some time for that information to get into the datapath. Otherwise, pods would attempt to make the outbound connection (the thing that caused the DNS lookup) before the datapath is ready. Many stacks retry the SYN in such cases but some return an error and some apps further crash as a response. This delay is configurable by setting the --tofqdns-proxy-response-max-delay command line argument but defaults to 100ms. It can be exceeded if the system is under load.

Once a DNS response has been passed back through the proxy and is placed in the DNS cache toFQDNs rules can begin using the IPs in the cache. There are multiple layers of cache:

A per-Endpoint DNSCache stores the lookups for this endpoint. It is restored on cilium startup with the endpoint. Limits are applied here for --tofqdns-endpoint-max-ip-per-hostname and TTLs are tracked. The --tofqdns-min-ttl is not used here.

A per-Endpoint DNSZombieMapping list of IPs that have expired from the per-Endpoint cache but are waiting for the Connection Tracking GC to mark them in-use or not. This can take up to 12 hours to occur. This list is size-limited by --tofqdns-max-deferred-connection-deletes.

A global DNSCache where all endpoint and poller DNS data is collected. It does apply the --tofqdns-min-ttl value but not the --tofqdns-endpoint-max-ip-per-hostname value.

If an IP exists in the FQDN cache (check with cilium-dbg fqdn cache list) then toFQDNs rules that select a domain name, either explicitly via matchName or via matchPattern, should cause IPs for that domain to have allocated Security Identities. These can be listed with:

Note that FQDN identities are allocated locally on the node and have a high-bit set so they are often in the 16-million range. Note that this is the identity in the monitor output for the HTTP connection.

In cases where there is no matching identity for an IP in the fqdn cache it may simply be because no policy selects an associated domain. The policy system represents each toFQDNs: rule with a FQDNSelector instance. These receive updates from a global NameManager in the daemon. They can be listed along with other selectors (roughly corresponding to any L3 rule):

In this example 16777217 is used by two selectors, one with matchPattern: "*" and another empty one. This is because of the policy in use:

The L7 DNS rule has an implicit L3 allow-all because it defines only L4 and L7 sections. This is the second selector in the list, and includes all possible L3 identities known in the system. In contrast, the first selector, which corresponds to the toFQDNS: matchName: "*" rule would list all identities for IPs that came from the DNS Proxy.

toFQDNSs policy enforcement relies on the source pod performing a DNS query before using an IP address returned in the DNS response. Sometimes pods may hold on to a DNS response and start new connections to the same IP address at a later time. This may trigger policy drops if the DNS response has expired as requested by the DNS server in the time-to-live (TTL) value in the response. When DNS is used for service load balancing the advertised TTL value may be short (e.g., 60 seconds).

Cilium honors the TTL values returned by the DNS server by default, but you can override them by setting a minimum TTL using --tofqdns-min-ttl flag. This setting overrides short TTLs and allows the pod to use the IP address in the DNS response for a longer duration. Existing connections also keep the IP address as allowed in the policy.

Any new connections opened by the pod using the same IP address without performing a new DNS query after the (possibly extended) DNS TTL has expired are dropped by Cilium policy enforcement. To allow pods to use the DNS response after TTL expiry for new connections, a command line option --tofqdns-idle-connection-grace-period may be used to keep the IP address / name mapping valid in the policy for an extended time after DNS TTL expiry. This option takes effect only if the pod has opened at least one connection during the DNS TTL period.

For a policy to be fully realized the datapath for an Endpoint must be updated. In the case of a new DNS-source IP, the FQDN identity associated with it must propagate from the selectors to the Endpoint specific policy. Unless a new policy is being added, this often only involves updating the Policy Map of the Endpoint with the new FQDN Identity of the IP. This can be verified:

Note that the labels for identities are resolved here. This can be skipped, or there may be cases where this doesn’t occur:

L3 toFQDNs rules are egress only, so we would expect to see an Egress entry with Security Identity 16777217. The L7 rule, used to redirect to the DNS Proxy is also present with a populated PROXY PORT. It has a 0 IDENTITY as it is an L3 wildcard, i.e. the policy allows any peer on the specified port.

An identity missing here can be an error in various places:

Policy doesn’t actually allow this Endpoint to connect. A sanity check is to use cilium-dbg endpoint list to see if cilium thinks it should have policy enforcement.

Endpoint regeneration is slow and the Policy Map has not been updated yet. This can occur in cases where we have leaked IPs from the DNS cache (i.e. they were never deleted correctly) or when there are legitimately many IPs. It can also simply mean an overloaded node or even a deadlock within cilium.

A more permissive policy has removed the need to include this identity. This is likely a bug, however, as the IP would still have an identity allocated and it would be included in the Policy Map. In the past, a similar bug occurred with the L7 redirect and that would stop this whole process at the beginning.

This section only applies to Golang code.

There are a few options available to debug Cilium data races and deadlocks.

To debug data races, Golang allows -race to be passed to the compiler to compile Cilium with race detection. Additionally, the flag can be provided to go test to detect data races in a testing context.

To compile a Cilium binary with race detection, you can do:

For building the Operator with race detection, you must also provide BASE_IMAGE which can be the cilium/cilium-runtime image from the root Dockerfile found in the Cilium repository.

To run integration tests with race detection, you can do:

Cilium can be compiled with a build tag lockdebug which will provide a seamless wrapper over the standard mutex types in Golang, via sasha-s/go-deadlock library. No action is required, besides building the binary with this tag.

Cilium bundles gops, a standard tool for Golang applications, which provides the ability to collect CPU and memory profiles using pprof. Inspecting profiles can help identify CPU bottlenecks and memory leaks.

To capture a profile, take a sysdump of the cluster with the Cilium CLI or more directly, use the cilium-bugtool command that is included in the Cilium image after enabling pprof in the Cilium ConfigMap:

Be mindful that the profile window is the number of seconds passed to --pprof-trace-seconds. Ensure that the number of seconds are enough to capture Cilium while it is exhibiting the problematic behavior to debug.

There are 6 files that encompass the tar archive:

The files prefixed with pprof- are profiles. For more information on each one, see Julia Evan’s blog on pprof.

To view the CPU or memory profile, simply execute the following command:

This opens a browser window for profile inspection.

---

## Introducing New CRDs — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/introducing_new_crds/

**Contents:**
- Introducing New CRDs
- Defining And Generating CRDs
  - Marks
  - Defining CRDs
  - Integrating CRDs Into Cilium
  - Generating CRD YAML
  - Generating Client Code
  - Register With API Scheme
  - Register With Client
  - Getting Your CRDs Installed

Cilium uses a combination of code generation tools to facilitate adding CRDs to the Kubernetes instance it is installed on.

These CRDs make themselves available in the generated Kubernetes client Cilium uses.

Currently, two API versions exist v2 and v2alpha1.

CRDs are defined via Golang structures, annotated with marks, and generated with Cilium make file targets.

Marks are used to tell controller-gen how to generate the CRD. This includes defining the CRD’s various names (Singular, plural, group), its Scope (Cluster, Namespaced), Shortnames, etc…

You can find CRD generation marks documentation here.

Marks are also used to generate json-schema validation. You can define validation criteria such as “format=cidr” and “required” via validation marks in your struct’s comments.

You can find CRD validation marks documentation here.

The portion of the directory after apis/ makes up the CRD’s Group and Version. See KubeBuilder-GVK

You can begin defining your CRD structure, making any subtypes you like to adequately define your data model and using marks to control the CRD generation process.

Here is a brief example, omitting any further definitions of sub-types to express the CRD data model.

Once you’ve coded your CRD data model you can use Cilium’s make infrastructure to generate and integrate your CRD into Cilium.

There are several make targets and a script which revolve around generating CRD and associated code gen (client, informers, DeepCopy implementations, DeepEqual implementations, etc).

Each of the next sections also detail the steps you should take to integrate your CRD into Cilium.

To simply generate the CRDs and copy them into the correct location you must perform two tasks:

Update the Makefile to edit the CRDS_CILIUM_V2 or CRDS_CILIUM_V2ALPHA1 variable (depending on the version of your new CRD) to contain the plural name of your new CRD.

This will generate your Golang structs into CRD manifests and copy them to ./pkg/k8s/apis/cilium.io/client/crds/ into the appropriate Version directory.

You can inspect your generated CRDs to confirm they look OK.

Additionally ./contrib/scripts/check-k8s-code-gen.sh is a script which will generate the CRD manifest along with generating the necessary K8s API changes to use your CRDs via K8s client in Cilium source code.

This make target will perform the necessary code-gen to integrate your CRD into Cilium’s client-go client, create listers, watchers, and informers.

Again, multiple steps must be taken to fully integrate your CRD into Cilium.

Make a change similar to this diff to register your CRDs with the API scheme.

You should also bump the CustomResourceDefinitionSchemaVersion variable in register.go to instruct Cilium that new CRDs have been added to the system.

pkg/k8s/apis/cilium.io/client/register.go

Make a change similar to the following to register CRD types with the client.

pkg/k8s/watchers/watcher.go

Also, configure the watcher for this resource (or tell the agent not to watch it)

Your new CRDs must be installed into Kubernetes. This is controlled in the pkg/k8s/synced/crd.go file.

Here is an example diff which installs the CRDs v2alpha1.BGPPName and v2alpha.BGPPoolName:

Cilium is installed with a service account and this service account should be given RBAC permissions to access your new CRDs. The following files should be updated to include permissions to create, read, update, and delete your new CRD.

Here is a diff of updating the Agent’s cluster role template to include our new BGP CRDs:

It’s important to note, neither the Agent nor the Operator installs these manifests to the Kubernetes clusters. This means when testing your CRD out the updated clusterrole must be written to the cluster manually.

Also please note, you should be specific about which ‘verbs’ are added to the Agent’s cluster role. This ensures a good security posture and best practice.

A convenient script for this follows:

The above script with install Cilium and newest clusterrole manifests to anywhere your kubectl is pointed.

---

## Documentation style — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/docs/docsstyle/

**Contents:**
- Documentation style
- General considerations
- Header
- Headings
- Body
- Capitalization
- Code blocks
- Links
- Lists
- Callouts

Here are some guidelines and best practices for contributing to Cilium’s documentation. They have several objectives:

Ensure that the documentation is rendered in the best possible way (in particular for code blocks).

Make the documentation easy to maintain and extend.

Help keep a consistent style throughout the documentation.

In the end, provide a better experience to users, and help them find the information they need.

See also the documentation for testing for instructions on how to preview documentation changes.

Write in US English. For example, use “prioritize” instead of “prioritise” and “color” instead of “colour”.

Maintain a consistent style with the rest of the documentation when possible, or at least with the rest of the updated page.

Omit hyphens when possible. For example, use “load balancing” instead of “load-balancing”.

Use the following header when adding new files to the Documentation.

One exception is reStructuredText fragments that are supposed to be sourced from other documentation files. Those do not need this header.

Prefer sentence case (capital letter on first word) rather than title case for all headings.

Wrap the lines for long sentences or paragraphs. There is no fixed convention on the length of lines, but targeting a width of about 80 characters should be safe in most circumstances.

Follow the section on capitalization for API objects from the Kubernetes style guide for when to (not) capitalize API objects. In particular:

When you refer specifically to interacting with an API object, use UpperCamelCase, also known as Pascal case.

When you are generally discussing an API object, use sentence-style capitalization

For example, write “Gateway API”, capitalized. Use “Gateway” when writing about an API object as an entity, and “gateway” for a specific instance.

The following examples are correct:

But the following examples are incorrect:

Code snippets and other literal blocks usually fall under one of those three categories:

They contain substitution references (for example: |SCM_WEB|). In that case, always use the .. parsed-literal directive, otherwise the token will not be substituted.

If the text is not a code snippet, but just some fragment that should be printed verbatim (for example, the unstructured output of a shell command), use the marker for literal blocks (::).

The reason is that because these snippets contain no code, there is no need to mark them as code or parsed literals. The former would tell Sphinx to attempt to apply syntax highlight, the second would tell it to look for reStructuredText markup to parse in the block.

If the text contained code or structured output, use the .. code-block directive. Do not use the .. code directive, which is slightly less flexible.

The .. code-block directive should always take a language name as argument, for example: .. code-block:: yaml or .. code-block:: shell-session. The use of bash is possible but should be limited to Bash scripts. For any listing of shell commands, and in particular if the snippet mixes commands and their output, use shell-session, which will bring the best coloration and may trigger the generation of the Copy commands button.

For snippets containing shell commands, in particular if they also contain the output for those commands, use prompt symbols to prefix the commands. Use $ for commands to run as a normal user, and # for commands to run with administrator privileges. You may use sudo as an alternative way to mark commands to run with privileges.

Avoid using embedded URIs (`... <...>`__), which make the document harder to read when looking at the source code of the documentation. Prefer to use block-level hyperlink targets (where the URI is not written directly in the sentence in the reStructuredText file, below the paragraph).

If using embedded URIs, use anonymous hyperlinks (`... <...>`__ with two underscores, see the documentation for embedded URIs) instead of named references (`... <...>`_, note the single underscore).

Prefer (but see previous item):

Left-align the body of a list item with the text on the first line, after the item symbol.

For enumerated lists, prefer auto-numbering with the #. marker rather than manually numbering the sections.

Be consistent with periods at the end of list items. In general, omit periods from bulleted list items unless the items are complete sentences. But if one list item requires a period, use periods for all items.

Use callouts effectively. For example, use the .. note:: directive to highlight information that helps users in a specific context. Do not use it to avoid refactoring a section or paragraph.

For example, when adding information about a new configuration flag that completes a feature, there is no need to append it as a note, given that it does not require particular attention from the reader. Avoid the following:

Instead, merge the new content with the existing paragraph:

We have a dedicated role for referencing Cilium GitHub issues, to reference them in a consistent fashion. Use it when relevant.

There are best practices for writing documentation; follow them. In general, default to the Kubernetes style guide, especially for content best practices. The following subsections cover the most common feedback given for Cilium documentation Pull Requests.

Assume that what you write will be localized with machine translation. Figures of speech often localize poorly, as do idioms like “above” and “below”.

Define abbreviations when you first use them on a page.

Use specific language. Avoid words like “this” (as a pronoun) and “it” when referring to concepts, actions, or process states. Be as specific as possible, even if specificity seems overly repetitive. This requirement exists for two reasons:

Indirect language assumes too much clarity on the part of the writer and too much understanding on the part of the reader.

Specific language is easier to review and easier to localize.

Words like “this” and “it” are indirect references. For example:

In the preceding paragraph, the word “this” indirectly references both an inferred consequence (“this means”) and a desired goal state (“to achieve this”). Instead, be as specific as possible:

The following subsections contain more examples.

---

## Contributing as a Reviewer or Committer — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/reviewers_committers/

**Contents:**
- Contributing as a Reviewer or Committer

Some contributors have specific roles, such as reviewers or committers. The following resources provide guidance for some specific tasks attached to those roles. Refer to Cilium’s Contributor Ladder for details about the different roles.

---

## Building Container Images — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/images/

**Contents:**
- Building Container Images
- Developer images
  - Race detection
- Official release images
- Experimental Docker BuildKit and Buildx support
- Official Cilium repositories
- Update cilium-builder and cilium-runtime images
- Image Building Process

Two make targets exists to build container images automatically based on the locally checked out branch:

Run make dev-docker-image to build a cilium-agent Docker image that contains your local changes.

Run make docker-operator-generic-image (respectively, docker-operator-aws-image or docker-operator-azure-image) to build the cilium-operator Docker image:

The commands above assumes that your username for quay.io is myaccount.

See section on compiling Cilium with race detection.

Anyone can build official release images using the make target below.

Docker BuildKit allows build artifact caching between builds and generally results in faster builds for the developer. Support can be enabled by:

Multi-arch image build support for arm64 (aka aarch64) and amd64 (aka x86-64) can be enabled by defining:

Multi-arch images are built using a cross-compilation builder by default, which uses Go cross compilation for Go targets, and QEMU based emulation for other build steps. You can also define your own Buildx builder if you have access to both arm64 and amd64 machines. The “cross” builder will be defined and used if your current builder is “default”.

Buildx targets push images automatically, so you must also have DOCKER_REGISTRY and DOCKER_DEV_ACCOUNT defined, e.g.:

Currently the cilium-runtime and cilium-builder images are released for amd64 only (see the table below). This means that you have to build your own cilium-runtime and cilium-builder images:

After the build finishes update the runtime image references in other Dockerfiles (docker buildx imagetools inspect is useful for finding image information). Then proceed to build the cilium-builder:

After the build finishes update the main Cilium Dockerfile with the new builder reference, then proceed to build Hubble from github.com/cilium/hubble. Hubble builds via buildx QEMU based emulation, unless you have an ARM machine added to your buildx builder:

Update the main Cilium Dockerfile with the new Hubble reference and build the multi-arch versions of the Cilium images:

The following table contains the main container image repositories managed by Cilium team. It is planned to convert the build process for all images based on GH actions.

container image repository

github.com/cilium/cilium

images/runtime/Dockerfile

quay.io/cilium/cilium-runtime

images/builder/Dockerfile

quay.io/cilium/cilium-builder

images/cilium/Dockerfile

[docker|quay].io/cilium/cilium

images/cilium-docker-plugin/Dockerfile

[docker|quay].io/cilium/docker-plugin

images/hubble-relay/Dockerfile

[docker|quay].io/cilium/hubble-relay

images/operator/Dockerfile

[docker|quay].io/cilium/operator

images/operator-aws/Dockerfile

[docker|quay].io/cilium/operator-aws

images/operator-azure/Dockerfile

[docker|quay].io/cilium/operator-azure

images/operator-generic/Dockerfile

[docker|quay].io/cilium/operator-generic

images/clustermesh-apiserver/Dockerfile

[docker|quay].io/cilium/clustermesh-apiserver

github.com/cilium/proxy

quay.io/cilium/cilium-envoy-builder

quay.io/cilium/cilium-envoy

github.com/cilium/image-tools

images/bpftool/Dockerfile

docker.io/cilium/cilium-bpftool

images/llvm/Dockerfile

docker.io/cilium/cilium-llvm

images/compilers/Dockerfile

docker.io/cilium/image-compilers

images/maker/Dockerfile

docker.io/cilium/image-maker

images/startup-script/Dockerfile

docker.io/cilium/startup-script

The steps described here, starting with a commit that updates the image versions, build the necessary images and update all the appropriate locations in the Cilium codebase. Hence, before executing the following steps, the user should have such a commit (e.g., see this commit) in their local tree. After following the steps below, the result would be another commit with the image updates (e.g,. see this commit). Please keep the two commits separate to ease backporting.

If you only wish to update the packages in these images, then you can manually update the FORCE_BUILD variable in images/runtime/Dockerfile to have a different value and then proceed with the steps below.

Commit your changes and create a PR in cilium/cilium.

Ping one of the members of team/build to approve the build that was created by GitHub Actions here. Note that at this step cilium-builder build failure is expected since we have yet to update the runtime digest.

Wait for build to complete. If the PR was opened from an external fork the build will fail while trying to push the changes, this is expected.

If the PR was opened from an external fork, run the following commands and re-push the changes to your branch. Once this is done the CI can be executed.

If the PR was opened from the main repository, the build will automatically generate one commit and push it to your branch with all the necessary changes across files in the repository.

Run the full CI and ensure that it passes.

Images are automatically created by a GitHub action: build-images. This action will automatically run for any Pull Request, including Pull Requests submitted from forked repositories, and push the images into quay.io/cilium/*-ci. They will be available there for 1 week before they are removed by the ci-images-garbage-collect workflow. Once they are removed, the developer must re-push the Pull Request into GitHub so that new images are created.

---

## Periodic duties — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/reviewers_committers/duties/

**Contents:**
- Periodic duties
- Release managers
- Backporters
- Triagers
- CI Health managers

Some members of the Cilium organization have rotational duties that change periodically.

Release managers take care of the patch releases for each supported stable branch of Cilium. They typically coordinate in #launchpad on Cilium Slack.

Backporters handle backports to Cilium’s supported stable branches. They typically coordinate in #launchpad on Cilium Slack. The Backporting process provides some guidance on how to backport changes.

Triagers take care of several tasks:

They push and merge contributions from community contributors

They review updates to files without a dedicated code owner

They triage bugs, which means they interact with reporters until the issue is clear and can get the label associated to the corresponding working group, when possible

They keep an eye on Cilium Slack, to try and answer questions from the community

They are members of the TopHat team on GitHub.

CI Health managers monitor the status of the CI, track down flakes, and ensure that CI checks keep running smoothly. They typically coordinate in #testing on Cilium Slack.

---

## Development Setup — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/dev_setup/

**Contents:**
- Development Setup
- Quick Start
- Detailed Instructions
  - Verifying Your Development Setup
  - Version Requirements
  - Kind-based Setup (preferred)
    - For Linux and Mac OS
    - For Linux only - with shorter development workflow time
    - Configuration for Cilium
    - Configuration for clusters

This page provides an overview of different methods for efficient development on Cilium. Depending on your needs, you can choose the most suitable method.

The following commands install Cilium in a Kind-based Kubernetes cluster. Run them in the root directory of the Cilium repository. The make targets are described in section Kind-based Setup.

The command output informs you of any missing dependencies. In particular, if you get the message 'cilium' not found, it means you are missing the Cilium CLI.

Depending on your specific development environment and requirements, you can follow the detailed instructions below.

Assuming you have Go installed, you can quickly verify many elements of your development setup by running the following command:

Depending on your end-goal, not all dependencies listed are required to develop on Cilium. For example, “Ginkgo” is not required if you want to improve our documentation. Thus, do not consider that you need to have all tools installed.

If using these tools, you need to have the following versions from them in order to effectively contribute to Cilium:

>= 18.1 (latest recommended)

>= 18.1 (latest recommended)

go install github.com/onsi/ginkgo/ginkgo@v1.16.5

go install sigs.k8s.io/kind@v0.19.0

For Integration Testing, you will need to run docker without privileges. You can usually achieve this by adding your current user to the docker group.

You can find the setup for a Kind environment in contrib/scripts/kind.sh. This setup doesn’t require any VMs and/or VirtualBox on Linux, but does require Docker for Mac for Mac OS.

Makefile targets automate the task of spinning up an environment:

make kind: Creates a Kind cluster based on the configuration passed in. For more information, see Configuration for clusters.

make kind-down: Tears down and deletes the cluster.

Depending on your environment you can build Cilium by using the following makefile targets:

Makefile targets automate building and installing Cilium images:

make kind-image: Builds all Cilium images and loads them into the cluster.

make kind-image-agent: Builds only the Cilium Agent image and loads it into the cluster.

make kind-image-operator: Builds only the Cilium Operator (generic) image and loads it into the cluster.

make kind-debug: Builds all Cilium images with optimizations disabled and dlv embedded for live debugging enabled and loads the images into the cluster.

make kind-debug-agent: Like kind-debug, but for the agent image only. Use if only the agent image needs to be rebuilt for faster iteration.

make kind-install-cilium: Installs Cilium into the cluster using the Cilium CLI.

The preceding list includes the most used commands for convenience. For more targets, see the Makefile (or simply run make help).

On Linux environments, or on environments where you can compile and run Cilium, it is possible to use “fast” targets. These fast targets will build Cilium in the local environment and mount that binary, as well the bpf source code, in an pre-existing running Cilium container.

make kind-install-cilium-fast: Installs Cilium into the cluster using the Cilium CLI with the volume mounts defined.

make kind-image-fast: Builds all Cilium binaries and loads them into all Kind clusters available in the host.

The Makefile targets that install Cilium pass the following list of Helm values (YAML files) to the Cilium CLI.

contrib/testing/kind-common.yaml: Shared between normal and fast installation modes.

contrib/testing/kind-values.yaml: Used by normal installation mode.

contrib/testing/kind-fast.yaml: Used by fast installation mode.

contrib/testing/kind-custom.yaml: User defined custom values that are applied if the file is present. The file is ignored by Git as specified in contrib/testing/.gitignore.

make kind takes a few environment variables to modify the configuration of the clusters it creates. The following parameters are the most commonly used:

CONTROLPLANES: How many control-plane nodes are created.

WORKERS: How many worker nodes are created.

CLUSTER_NAME: The name of the Kubernetes cluster.

IMAGE: The image for Kind, for example: kindest/node:v1.11.10.

KUBEPROXY_MODE: Pass directly as kubeProxyMode to the Kind configuration Custom Resource Definition (CRD).

For more environment variables, see contrib/scripts/kind.sh.

Make sure the main branch of your fork is up-to-date:

Create a PR branch with a descriptive name, branching from main:

Make the changes you want.

Separate the changes into logical commits.

Describe the changes in the commit messages. Focus on answering the question why the change is required and document anything that might be unexpected.

If any description is required to understand your code changes, then those instructions should be code comments instead of statements in the commit description.

For submitting PRs, all commits need be to signed off (git commit -s). See the section Developer’s Certificate of Origin.

Make sure your changes meet the following criteria:

New code is covered by Integration Testing.

End to end integration / runtime tests have been extended or added. If not required, mention in the commit message what existing test covers the new code.

Follow-up commits are squashed together nicely. Commits should separate logical chunks of code and not represent a chronological list of changes.

Run git diff --check to catch obvious white space violations

Run make to build your changes. This will also run make lint and error out on any golang linting errors. The rules are configured in .golangci.yaml

Run make -C bpf checkpatch to validate against your changes coding style and commit messages.

See Integration Testing on how to run integration tests.

See End-To-End Connectivity Testing for information how to run the end to end integration tests

If you are making documentation changes, you can generate documentation files and serve them locally on http://localhost:9081 by running make render-docs. This make target works assuming that docker is running in the environment.

Cilium provides Dev Container configuration for Visual Studio Code Remote Containers and Github Codespaces. This allows you to use a preconfigured development environment in the cloud or locally. The container is based on the official Cilium builder image and provides all the dependencies required to build Cilium.

You can also install common packages, such as kind, kubectl, and cilium-cli, with contrib/scripts/devcontainer-setup.sh:

Package versions can be modified to fit your requirements. This needs to only be set up once when the devcontainer is first created.

The current Dev Container is running as root. Non-root user support requires non-root user in Cilium builder image, which is related to GitHub issue 23217.

Each Cilium release is tied to a specific version of Golang via an explicit constraint in our Renovate configuration.

We aim to build and release all maintained Cilium branches using a Golang version that is actively supported. This needs to be balanced against the desire to avoid regressions in Golang that may impact Cilium. Golang supports two minor versions at any given time – when updating the version used by a Cilium branch, you should choose the older of the two supported versions.

To update the minor version of Golang used by a release, you will first need to update the Renovate configuration found in .github/renovate.json5. For each minor release, there will be a section that looks like this:

To allow Renovate to create a pull request that updates the minor Golang version, bump the allowedVersions constraint to include the desired minor version. Once this change has been merged, Renovate will create a pull request that updates the Golang version. Minor version updates may require further changes to ensure that all Cilium features are working correctly – use the CI to identify any issues that require further changes, and bring them to the attention of the Cilium maintainers in the pull request.

Once the CI is passing, the PR will be merged as part of the standard version upgrade process.

New patch versions of Golang are picked up automatically by the CI; there should normally be no need to update the version manually.

Let’s assume we want to add github.com/containernetworking/cni version v0.5.2:

For a first run, it can take a while as it will download all dependencies to your local cache but the remaining runs will be faster.

Updating k8s is a special case which requires updating k8s libraries in a single change:

Cilium might use its own fork of kindest-node so that it can use k8s versions that have not been released by Kind maintainers yet.

One other reason for using a fork is that the base image used on kindest-node may not have been release yet. For example, as of this writing, Cilium requires Debian Bookworm (yet to be released), because the glibc version available on Cilium’s base Docker image is the same as the one used in the Bookworm Docker image which is relevant for testing with Go’s race detector.

Currently, only maintainers can publish an image on quay.io/cilium/kindest-node. However, anyone can build a kindest-node image and try it out

To build a cilium/kindest-node image, first build the base Docker image:

Take note of the resulting image tag for that command, it should be the last tag built for the gcr.io/k8s-staging-kind/base repository in docker ps -a.

Secondly, change into the directory with Kubernetes’ source code which will be used for the kindest node image. On this example, we will build a kindest-base image with Kubernetes version v1.28.3 using the recently-built base image gcr.io/k8s-staging-kind/base:v20231108-a9fbf702:

Finally, publish the image to a public repository. If you are a maintainer and have permissions to publish on quay.io/cilium/kindest-node, the Renovate bot will automatically pick the new version and create a new Pull Request with this update. If you are not a maintainer you will have to update the image manually in Cilium’s repository.

Let’s assume we want to add a new Kubernetes version v1.19.0:

Follow the above instructions to update the Kubernetes libraries.

Follow the next instructions depending on if it is a minor update or a patch update.

Check if it is possible to remove the last supported Kubernetes version from Kubernetes Compatibility, Requirements and add the new Kubernetes version to that list.

If the minimal supported version changed, leave a note in the upgrade guide stating the minimal supported Kubernetes version.

If the minimal supported version changed, search over the code, more likely under pkg/k8s, if there is code that can be removed which specifically exists for the compatibility of the previous Kubernetes minimal version supported.

If the minimal supported version changed, update the field MinimalVersionConstraint in pkg/k8s/version/version.go

Sync all “slim” types by following the instructions in pkg/k8s/slim/README.md. The overall goal is to update changed fields or deprecated fields from the upstream code. New functions / fields / structs added in upstream that are not used in Cilium, can be removed.

Make sure the workflows used on all PRs are running with the new Kubernetes version by default. Make sure the files contributing/testing/{ci,e2e}.rst are up to date with these changes.

Update documentation files: - Documentation/contributing/testing/e2e.rst - Documentation/network/kubernetes/compatibility.rst - Documentation/network/kubernetes/requirements.rst

Update the Kubernetes version with the newer version in - test/test_suite_test.go. - .github/actions/ginkgo/main-prs.yaml - .github/actions/ginkgo/main-scheduled.yaml - .github/actions/set-env-variables/action.yml - contrib/scripts/devcontainer-setup.sh - .github/actions/ginkgo/main-focus.yaml

Bump the kindest/node version in .github/actions/ginkgo/main-k8s-versions.yaml.

Run ./contrib/scripts/check-k8s-code-gen.sh

Check controller-runtime compatibility with the new Kubernetes version. If there are any changes required, update the controller-runtime version in go.mod. See https://github.com/kubernetes-sigs/controller-runtime?tab=readme-ov-file#compatibility.

Run go mod vendor && go mod tidy

Run ./contrib/scripts/check-k8s-code-gen.sh (again)

Run make -C Documentation update-helm-values

Compile the code locally to make sure all the library updates didn’t removed any used code.

Provision a new dev VM to check if the provisioning scripts work correctly with the new k8s version.

Run git add vendor/ test/provision/manifest/ Documentation/ && git commit -sam "Update k8s tests and libraries to v1.28.0-rc.0"

Submit all your changes into a new PR. Ensure the PR is opened against a branch in cilium/cilium and not a fork. Otherwise, CI is not triggered properly. Please open a thread on #development if you do not have permissions to create a branch in cilium/cilium.

Ensure that the target CI workflows are running and passing after updating the target k8s versions in the GitHub action workflows.

Once CI is green and PR has been merged, ping the CI team again so that they update the Cilium CI matrix, .github/maintainers-little-helper.yaml, and GitHub required PR checks accordingly.

Submit all your changes into a new PR.

The Helm chart is located in the install/kubernetes directory. The values.yaml.tmpl file contains the values for the Helm chart which are being used into the values.yaml file.

To prepare your changes you need to run the make scripts for the chart:

This does all needed steps in one command. Your change to the Helm chart is now ready to be submitted!

You can also run them one by one using the individual targets below.

When updating or adding a value they can be synced to the values.yaml file by running the following command:

Before submitting the changes the README.md file needs to be updated, this can be done using the docs target:

At last you might want to check the chart using the lint target:

Note that these instructions are useful to you if you care about having IPv6 addresses for your Docker containers.

If you’d like IPv6 addresses, you will need to follow these steps:

Edit /etc/docker/daemon.json and set the ipv6 key to true.

If that doesn’t work alone, try assigning a fixed range. Many people have reported trouble with IPv6 and Docker. Source here.

Restart the docker daemon to pick up the new configuration.

The new command for creating a network managed by Cilium:

Now new containers will have an IPv6 address assigned to them.

The tool cilium-dbg monitor can also be used to retrieve debugging information from the eBPF based datapath. To enable all log messages:

Start the cilium-agent with --debug-verbose=datapath, or

Run cilium-dbg config debug=true debugLB=true from an already running agent.

These options enable logging functions in the datapath: cilium_dbg(), cilium_dbg_lb() and printk().

The printk() logging function is used by the developer to debug the datapath outside of the cilium monitor. In this case, bpftool prog tracelog can be used to retrieve debugging information from the eBPF based datapath. Both cilium_dbg() and printk() functions are available from the bpf/lib/dbg.h header file.

The image below shows the options that could be used as startup options by cilium-agent (see upper blue box) or could be changed at runtime by running cilium-dbg config <option(s)> for an already running agent (see lower blue box). Along with each option, there is one or more logging function associated with it: cilium_dbg() and printk(), for DEBUG and cilium_dbg_lb() for DEBUG_LB.

If you need to enable the LB_DEBUG for an already running agent by running cilium-dbg config debugLB=true, you must pass the option debug=true along.

Debugging of an individual endpoint can be enabled by running cilium-dbg endpoint config ID debug=true. Running cilium-dbg monitor -v will print the normal form of monitor output along with debug messages:

Passing -v -v supports deeper detail, for example:

One of the most common issues when developing datapath code is that the eBPF code cannot be loaded into the kernel. This frequently manifests as the endpoints appearing in the “not-ready” state and never switching out of it:

Running cilium-dbg endpoint get for one of the endpoints will provide a description of known state about it, which includes eBPF verification logs.

The files under /var/run/cilium/state provide context about how the eBPF datapath is managed and set up. The .h files describe specific configurations used for eBPF program compilation. The numbered directories describe endpoint-specific state, including header configuration files and eBPF binaries.

Current eBPF map state for particular programs is held under /sys/fs/bpf/, and the bpf-map utility can be useful for debugging what is going on inside them, for example:

---

## How To Contribute — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/contributing_guide/

**Contents:**
- How To Contribute
- Cilium Feature Proposals
- Clone and Provision Environment
- Submitting a pull request
- Getting a pull request merged
  - Handling large pull requests
- Developer’s Certificate of Origin
- Contributor Ladder

This document shows how to contribute as a community contributor. Guidance for reviewers and committers is also available.

Before you start working on a significant code change, it’s a good idea to make sure that your approach is likely to be accepted. The best way to do this is to create a Cilium issue of type “Feature Request” on GitHub where you describe your plans.

For longer proposals, you might like to include a link to an external doc (e.g. a Google doc) where it’s easier for reviewers to make comments and suggestions in-line. The GitHub feature request template includes a link to the Cilium Feature Proposal template which you are welcome to use to help structure your proposal. Please make a copy of that template, fill it in with your ideas, and ensure it’s publicly visible, before adding the link into the GitHub issue.

After the initial discussion, CFPs should be added to the design-cfps repo so the design and discussion can be stored for future reference.

Make sure you have a GitHub account.

Fork the Cilium repository to your GitHub user or organization.

Turn off GitHub actions for your fork as described in the GitHub Docs. This is recommended to avoid unnecessary CI notification failures on the fork.

Clone your ${YOUR_GITHUB_USERNAME_OR_ORG}/cilium fork and set up the base repository as upstream remote:

Set up your Development Setup.

Check the GitHub issues for good tasks to get started.

Follow the steps in Making Changes to start contributing :)

Contributions must be submitted in the form of pull requests against the upstream GitHub repository at https://github.com/cilium/cilium.

Fork the Cilium repository.

Push your changes to the topic branch in your fork of the repository.

Submit a pull request on https://github.com/cilium/cilium.

Before hitting the submit button, please make sure that the following requirements have been met:

Take some time to describe your change in the PR description! A well-written description about the motivation of the change and choices you made during the implementation can go a long way to help the reviewers understand why you’ve made the change and why it’s a good way to solve your problem. If it helps you to explain something, use pictures or Mermaid diagrams.

Each commit must compile and be functional on its own to allow for bisecting of commits in the event of a bug affecting the tree.

All code is covered by unit and/or runtime tests where feasible.

All changes have been tested and checked for regressions by running the existing testsuite against your changes. See the End-To-End Testing Framework (Legacy) section for additional details.

All commits contain a well written commit description including a title, description and a Fixes: #XXX line if the commit addresses a particular GitHub issue. Note that the GitHub issue will be automatically closed when the commit is merged.

Make sure to include a blank line in between commit title and commit description.

If any of the commits fixes a particular commit already in the tree, that commit is referenced in the commit message of the bugfix. This ensures that whoever performs a backport will pull in all required fixes:

The proper format for the Fixes: tag referring to commits is to use the first 12 characters of the git SHA followed by the full commit title as seen above without breaking the line.

If you change CLI arguments of any binaries in this repo, the CI will reject your PR if you don’t also update the command reference docs. To do so, make sure to run the postcheck make target.

All commits are signed off. See the section Developer’s Certificate of Origin.

Passing the -s option to git commit will add the Signed-off-by: line to your commit message automatically.

Document any user-facing or breaking changes in Documentation/operations/upgrade.rst.

(optional) Pick the appropriate milestone for which this PR is being targeted, e.g. 1.6, 1.7. This is in particular important in the time frame between the feature freeze and final release date.

If you have permissions to do so, pick the right release-note label. These labels will be used to generate the release notes which will primarily be read by users.

This is a non-trivial bugfix and is a user-facing bug

This is a major feature addition, e.g. Add MongoDB support

This is a minor feature addition, e.g. Add support for a Kubernetes version

This is a not user-facing change, e.g. Refactor endpoint package, a bug fix of a non-released feature

This is a CI feature or bug fix.

Verify the release note text. If not explicitly changed, the title of the PR will be used for the release notes. If you want to change this, you can add a special section to the description of the PR. These release notes are primarily going to be read by users, so it is important that release notes for bugs, major and minor features do not contain internal details of Cilium functionality which sometimes are irrelevant for users.

Example of a bad release note

Example of a good release note

If multiple lines are provided, then the first line serves as the high level bullet point item and any additional line will be added as a sub item to the first line.

If you have permissions, pick the right labels for your PR:

This is a bugfix worth mentioning in the release notes

This enhances existing functionality in Cilium

This PR should block the next X.Y release

PR needs to be backported to these stable releases

This is backport PR, may only be set as part of Backporting process

The code changes have a potential upgrade impact

Code area this PR covers

If you do not have permissions to set labels on your pull request. Leave a comment and a core team member will add the labels for you. Most reviewers will do this automatically without prior request.

Open a draft pull request. GitHub provides the ability to create a Pull Request in “draft” mode. On the “New Pull Request” page, below the pull request description box there is a button for creating the pull request. Click the arrow and choose “Create draft pull request”. If your PR is still a work in progress, please select this mode. You will still be able to run the CI against it.

To notify reviewers that the PR is ready for review, click Ready for review at the bottom of the page.

Engage in any discussions raised by reviewers and address any changes requested. Set the PR to draft PR mode while you address changes, then click Ready for review to re-request review.

As you submit the pull request as described in the section Submitting a pull request. One of the reviewers will start a CI run by replying with a comment /test as described in Triggering Platform Tests. If you are an organization member, you can trigger the CI run yourself. CI consists of:

Static code analysis by GitHub Actions and Travis CI. Golang linter suggestions are added in-line on PRs. For other failed jobs, please refer to build log for required action (e.g. Please run go mod tidy && go mod vendor and submit your changes, etc).

CI / GitHub Actions: Will run a series of tests:

Single node runtime tests

Multi node Kubernetes tests

If a CI test fails which seems unrelated to your PR, it may be a flaky test. Follow the process described in CI Failure Triage.

As part of the submission, GitHub will have requested a review from the respective code owners according to the CODEOWNERS file in the repository.

Address any feedback received from the reviewers

You can push individual commits to address feedback and then rebase your branch at the end before merging.

Once you have addressed the feedback, re-request a review from the reviewers that provided feedback by clicking on the button next to their name in the list of reviewers. This ensures that the reviewers are notified again that your PR is ready for subsequent review.

Owners of the repository will automatically adjust the labels on the pull request to track its state and progress towards merging.

Once the PR has been reviewed and the CI tests have passed, the PR will be merged by one of the repository owners. In case this does not happen, ping us on Cilium Slack in the #development channel.

If the PR is considerably large (e.g. with more than 200 lines changed and/or more than 6 commits), consider whether there is a good way to split the PR into smaller PRs that can be merged more incrementally. Reviewers are often more hesitant to review large PRs due to the level of complexity involved in understanding the changes and the amount of time required to provide constructive review comments. By making smaller logical PRs, this makes it easier for the reviewer to provide comments and to engage in dialogue on the PR, and also means there should be fewer overall pieces of feedback that you need to address as a contributor. Tighter feedback cycles like this then make it easier to get your contributions into the tree, which also helps with reducing conflicts with other contributions. Good candidates for smaller PRs may be individual bugfixes, or self-contained refactoring that adjusts the code in order to make it easier to build subsequent functionality on top.

While handling review on larger PRs, consider creating a new commit to address feedback from each review that you receive on your PR. This will make the review process smoother as GitHub has limitations that prevents reviewers from only seeing the new changes added since the last time they have reviewed a PR. Once all reviews are addressed those commits should be squashed against the commit that introduced those changes. This can be accomplished by the usage of git rebase -i upstream/main and in that window, move these new commits below the commit that introduced the changes and replace the work pick with fixup. In the following example, commit d2cb02265 will be combined into 9c62e62d8 and commit 146829b59 will be combined into 9400fed20.

Once this is done you can perform push force into your branch and request for your PR to be merged.

Reviewers should apply the documented Pull requests review process for committers when providing feedback to a PR.

To improve tracking of who did what, we’ve introduced a “sign-off” procedure.

The sign-off is a simple line at the end of the explanation for the commit, which certifies that you wrote it or otherwise have the right to pass it on as open-source work. The rules are pretty simple: if you can certify the below:

then you just add a line saying:

If you need to add your sign off to a commit you have already made, please see this article.

Cilium follows the real names policy described in the CNCF DCO Guidelines v1.0:

To help contributors grow in both privileges and responsibilities for the project, Cilium also has a contributor ladder. The ladder lays out how contributors can go from community contributor to a committer and what is expected for each level. Community members generally start at the first levels of the “ladder” and advance up it as their involvement in the project grows. Our contributors are happy to help you advance along the contributor ladder.

---

## End-To-End Connectivity Testing — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/testing/e2e/

**Contents:**
- End-To-End Connectivity Testing
- Introduction
- Running End-To-End Connectivity Tests
  - Running tests locally
  - Running tests in VM
    - Running tests in a VM with a custom kernel
  - Network performance test
  - Cleaning up tests

Cilium uses cilium-cli connectivity tests for implementing and running end-to-end tests which test Cilium all the way from the API level (for example, importing policies, CLI) to the datapath (in order words, whether policy that is imported is enforced accordingly in the datapath).

The connectivity tests are implemented in such a way that they can be run against any K8s cluster running Cilium. The built-in feature detection allows the testing framework to automatically skip tests when a required test condition cannot be met (for example, skip the Egress Gateway tests if the Egress Gateway feature is disabled).

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Alternatively, Cilium CLI can be manually built and installed by fetching https://github.com/cilium/cilium-cli, and then running make install.

Next, you need a Kubernetes cluster to run Cilium. The easiest way to create one is to use kind. Cilium provides a wrapper script which simplifies creating K8s cluster with kind. For example, to create a cluster consisting of 1 control-plane node, 3 worker nodes, without kube-proxy, and with DualStack enabled:

Afterwards, you need to install Cilium. The preferred way is to use cilium-cli install, as it is able to automate some steps (e.g., detecting kube-apiserver endpoint address which otherwise needs to be specified when running w/o kube-proxy, or set an annotation to a K8s worker node to prevent Cilium from being scheduled on it).

Assuming that Cilium was built with:

You can install Cilium with the following command:

Finally, to run tests:

Alternatively, you can select which tests to run:

Or, you can exclude specific test cases to run:

To run Cilium and the connectivity tests in a virtual machine, one can use little-vm-helper (LVH). The project provides a runner of qemu-based VMs, a builder of VM images, and a registry containing pre-built VM images.

First, install the LVH cli tool:

Second, fetch a VM image:

See https://quay.io/repository/lvh-images/kind?tab=tags for all available images. To build a new VM image (or to update any existing) please refer to little-vm-helper-images.

Finally, you can SSH into the VM to start a K8s cluster, install Cilium, and finally run the connectivity tests:

To stop the VM, run from the host:

It is possible to test Cilium on an LVH VM with a custom built Linux kernel (for example, for fast testing iterations when doing kernel development work for Cilium features).

First, to configure and to build the kernel:

Second, start the LVH VM with the custom kernel:

Third, SSH into the VM, and install the custom kernel modules (this step is no longer required once little-vm-helper#117 has been resolved):

Finally, you can use the instructions from the previous chapter to run and to test Cilium.

Cilium also provides cilium-cli connectivity perf to test the network performance of pod-to-pod communication in the same node and different nodes.

To run performance test:

If you want to test the network performance between specific nodes, you can label the nodes to run test:

If the connectivity tests are interrupted or timeout, that will leave the test pods deployed. To clean this up, simply delete the connectivity tests namespace:

If you specified the test namespace with --test-namespace, make sure to replace cilium-test (default).

---

## Updating dependencies with Renovate — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/renovate/

**Contents:**
- Updating dependencies with Renovate
- Linting locally
- Testing on a fork

The Cilium project uses Renovate Bot to maintain and update dependencies on a regular basis. This guide describes how to contribute a PR which modifies the Renovate configuration. There are two complementary methods for validating Renovate changes: Linting with the “local” platform, and testing the updates in your own fork.

Use the renovate/renovate docker image to perform a dry run of Renovate. This step should complete in less than ten minutes, and it will report syntax errors in the configuration.

Make some changes to the Renovate configuration in .github/renovate.json5.

Run the renovate image against the new configuration.

This approach is based on the Local platform guide provided by Renovate. See that guide for more details about usage and limitations.

For most changes to the Renovate configuration, you will likely need to test the changes on your own fork of Cilium.

Make some changes to the Renovate configuration. Renovate is configured in .github/renovate.json5.

(Optional) Disable unrelated configuration. For an example, see this commit.

Push the branch to the default branch of your own fork.

Enable the Renovate GitHub app in your GitHub account.

Ensure that Renovate is enabled in the repository settings in the Renovate Dashboard.

Trigger the Renovate app from the dashboard or push a fresh commit to your fork’s default branch to trigger Renovate again.

Use the dashboard to trigger Renovate to create a PR on your fork and validate that the proposed PRs are updating the correct parts of the codebase.

Once you have tested that the Renovate configuration works in your own fork, create a PR against Cilium and provide links in the description to inform reviewers about the testing you have performed on the changes.

---

## Development — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/

**Contents:**
- Development

We’re happy you’re interested in contributing to the Cilium project.

This section of the Cilium documentation will help you make sure you have an environment capable of testing changes to the Cilium source code, and that you understand the workflow of getting these changes reviewed and merged upstream.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

---

## Code Overview — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/codeoverview/

**Contents:**
- Code Overview
- High-level
- Cilium
- Hubble
- Important common packages

This section provides an overview of the Cilium & Hubble source code directory structure. It is useful to get an initial overview on where to find what.

Top-level directories github.com/cilium/cilium:

The Cilium & Hubble API definition.

The eBPF datapath code

CLI for collecting agent & system information for bug reporting

Additional tooling and resources used for development

The cilium-agent running on each node

Various example resources and manifests. Typically require to be modified before usage is possible.

Helm deployment manifests for all components

Common Go packages shared between all components

Operator responsible for centralized tasks which do not require to be performed on each node.

Plugins to integrate with Kubernetes and Docker

End-to-end integration tests run in the End-To-End Testing Framework (Legacy).

API specification of the Cilium API. Used for code generation.

Go code generated from openapi.yaml representing all API resources

The eBPF datapath code

Cilium cluster connectivity CLI client

cilium-agent specific code

The CNI plugin to integrate with Kubernetes

The Docker integration plugin

The server-side code of Hubble is integrated into the Cilium repository. The Hubble CLI can be found in the separate repository github.com/cilium/hubble. The Hubble UI can be found in the separate repository github.com/cilium/hubble-ui.

API specifications of the Hubble APIs.

All Hubble specific code

Ring buffer implementation

Flow filtering capabilities

Metrics plugins providing Prometheus based on Hubble’s visibility

Layer running on top of the Cilium datapath monitoring, feeding the metrics and ring buffer.

Peer service implementation

Hubble Relay service implementation

The server providing the API for the Hubble client and UI

Security identity allocation

Abstraction layer to interact with the eBPF runtime

Go client to access Cilium API

Multi-cluster implementation including control plane and global services

Base controller implementation for any background operation that requires retries or interval-based invocation.

Abstraction layer for datapath interaction

ELF abstraction library for the eBPF loader

Abstraction of a Cilium endpoint, representing all workloads.

Manager of all endpoints

Envoy proxy interactions

FQDN proxy and FQDN policy implementation

Network connectivity health checking

A dependency injection framework for modular composition of applications

Representation of a security identity for workloads

IP address management

Global cache mapping IPs to endpoints and security identities

All interactions with Kubernetes

Key-value store abstraction layer with backends for etcd

Base metadata type to describe all label/metadata requirements for workload identity specification and policy matching.

Control plane for load-balancing functionality

eBPF map representations

Prometheus metrics implementation

eBPF datapath monitoring abstraction

Representation of a network node

All available configuration options

Policy enforcement specification & implementation

Layer 7 proxy abstraction

Implementation of trigger functionality to implement event-driven functionality

---

## Pull requests review process for committers — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/reviewers_committers/review_process/

**Contents:**
- Pull requests review process for committers
- Review process
- Reviewer Teams
- Code owners
  - Project-wide
  - Repository Owners
  - Cloud Integrations
  - Cilium Internals

These instructions assume that reviewers are members of the Cilium GitHub organization. This is required to obtain the privileges to modify GitHub labels on the pull request. See Cilium’s Contributor Ladder for details.

Find Pull Requests (PRs) needing a review from you, or from one of your teams.

If this PR was opened by a contributor who is not part of the Cilium organization, please assign yourself to that PR and keep track of the PR to ensure it gets reviewed and merged.

If the contributor is a Cilium committer, then they are responsible for getting the PR ready to be merged by addressing review comments and resolving all CI checks for “Required” workflows.

If this PR is a backport PR (typically with the label kind/backport) and no-one else has reviewed the PR, review the changes as a sanity check. If any individual commits deviate from the original patch, request review from the original author to validate that the backport was correctly applied.

Review overall correctness of the PR according to the rules specified in the section Submitting a pull request.

Set the labels accordingly. A bot called maintainer’s little helper might automatically help you with this.

dont-merge/needs-sign-off

Some commits are not signed off

PR is outdated and needs to be rebased

Validate that bugfixes are marked with kind/bug and validate whether the assessment of backport requirements as requested by the submitter conforms to the Backport Criteria.

PR needs to be backported to these stable releases

If the PR is subject to backport, validate that the PR does not mix bugfix and refactoring of code as it will heavily complicate the backport process. Demand for the PR to be split.

Validate the release-note/* label and check the release note suitability. Release notes are passed through the dedicated release-note block (see Submitting a pull request), or through the PR title if this block is missing. To check if the notes are suitable, put yourself into the perspective of a future release notes reader with lack of context and ensure the title is precise but brief.

dont-merge/needs-release-note

Do NOT merge PR, needs a release note

This is a non-trivial bugfix and is a user-facing bug

This is a major feature addition, e.g. Add MongoDB support

This is a minor feature addition, e.g. Add support for a Kubernetes version

This is a not user-facing change , e.g. Refactor endpoint package, a bug fix of a non-released feature

This is a CI feature or bug fix.

Check for upgrade compatibility impact and if in doubt, set the label upgrade-impact and discuss in Cilium Slack’s #development channel or in the weekly meeting.

The code changes have a potential upgrade impact

When submitting a review, provide explicit approval or request specific changes whenever possible. Clear feedback indicates whether contributors must take action before a PR can merge.

If you need more information before you can approve or request changes, you can leave comments seeking clarity. If you do not explicitly approve or request changes, it’s best practice to raise awareness about the discussion so that others can participate. Here are some ways you can raise awareness:

Re-request review from codeowners in the PR

Raise the topic for discussion in Slack or during community meetings

When requesting changes, summarize your feedback for the PR, including overall issues for a contributor to consider and/or encouragement for what a contributor is already doing well.

When all review objectives for all CODEOWNERS are met, all CI tests have passed, and all reviewers have approved the requested changes, you can merge the PR by clicking on the “Rebase and merge” button.

Every reviewer, including committers in the committers team, belongs to one or more teams in the Cilium organization. If you would like to add or remove yourself from any team, please submit a PR against the community repository.

Once a contributor opens a PR, GitHub automatically picks which teams should review the PR using the CODEOWNERS file. Each reviewer can see the PRs they need to review by filtering by reviews requested. A good filter is provided in this link so make sure to bookmark it.

Reviewers are expected to focus their review on the areas of the code where GitHub requested their review. For small PRs, it may make sense to simply review the entire PR. However, if the PR is quite large then it can help to narrow the area of focus to one particular aspect of the code. When leaving a review, share which areas you focused on and which areas you think that other reviewers should look into. This helps others to focus on aspects of review that have not been covered as deeply.

Belonging to a team does not mean that a reviewer needs to know every single line of code the team is maintaining. Once you have reviewed a PR, if you feel that another pair of eyes is needed, re-request a review from the appropriate team. In the following example, the reviewer belonging to the CI team is re-requesting a review for other team members to review the PR. This allows other team members belonging to the CI team to see the PR as part of the PRs that require review in the filter.

When all review objectives for all CODEOWNERS are met, all required CI tests have passed and a proper release label is set, a PR may be merged by any committer with access rights to click the green merge button. Maintainer’s little helper may set the ready-to-merge label automatically to recognize the state of the PR. Periodically, a rotating assigned committer will review the list of PRs that are marked ready-to-merge.

Code owners are used by the Cilium community to consolidate common knowledge into teams that can provide consistent and actionable feedback to contributors. This section will describe groups of teams and suggestions about the focus areas for review.

The primary motivation for these teams is to provide structure around review processes to ensure that contributors know how to reach out to community members to conduct discussions, ensure contributions meet the expectations of the community, and align on the direction of proposed changes. Furthermore, while these teams are primarily drawn upon to provide review on specific pull requests, they are also encouraged to self-organize around how to make improvements to their areas of the Cilium project over time.

Any committer may self-nominate to code owner teams. Reach out to the core team on the #committers channel in Slack to coordinate. Committers do not require expert knowledge in an area in order to join a code owner team, only a willingness to engage in discussions and learn about the area.

These code owners may provide feedback for Pull Requests submitted to any repository in the Cilium project:

@cilium/api: Ensure the backwards-compatibility of Cilium REST and gRPC APIs, excluding Hubble which is owned by @cilium/sig-hubble-api.

@cilium/build: Provide feedback on languages and scripting used for build and packaging system: Make, Shell, Docker.

@cilium/cli: Provide user experience feedback on changes to Command-Line Interfaces. These owners are a stand-in for the user community to bring a user perspective to the review process. Consider how information is presented, consistency of flags and options.

@cilium/ci-structure: Provide guidance around the best use of Cilium project continuous integration and testing infrastructure, including GitHub actions, VM helpers, testing frameworks, etc.

@cilium/community: Maintain files that refer to Cilium community users such as USERS.md.

@cilium/contributing: Encourage practices that ensure an inclusive contributor community. Review tooling and scripts used by contributors.

@cilium/docs-structure: Ensure the consistency and layout of documentation. General feedback on the use of Sphinx, how to communicate content clearly to the community. This code owner is not expected to validate the technical correctness of submissions. Correctness is typically handled by another code owner group which is also assigned to any given piece of documentation.

@cilium/sig-foundations: Review changes to the core libraries and provide guidance to overall software architecture.

@cilium/github-sec: Responsible for maintaining the security of repositories in the Cilium project by maintaining best practices for workflow usage, for instance preventing malicious use of GitHub actions.

@cilium/helm: Provide input on the way that Helm can be used to configure features. These owners are a stand-in for the user community to bring a user perspective to the review process. Ensure that Helm changes are defined in manners that will be forward-compatible for upgrade and follow best practices for deployment (for example, being GitOps-friendly).

@cilium/sig-hubble-api: Review Hubble API changes related to gRPC endpoints. The team ensures that API changes are backward compatible or that a new API version is created for backward incompatible changes.

@cilium/metrics: Provide recommendations about the types, names and labels for metrics to follow best practices. This includes considering the cardinality impact of metrics being added or extended.

@cilium/release-managers: Review files related to releases like AUTHORS and VERSION.

@cilium/security: Provide feedback on changes that could have security implications for Cilium, and maintain security-related documentation.

@cilium/vendor: Review vendor updates for software dependencies to check for any potential upstream breakages / incompatibilities. Discourage the use of unofficial forks of upstream libraries if they are actively maintained.

The following code owners are responsible for a range of general feedback for contributions to specific repositories:

@cilium/sig-hubble: Review all Cilium and Hubble code related to observing system events, exporting those via gRPC protocols outside the node and outside the cluster. those event channels, for example via TLS.

@cilium/hubble-metrics: Review code related to Hubble metrics, ensure changes in exposed metrics are consistent and not breaking without careful consideration.

@cilium/hubble-ui: Maintain the Hubble UI graphical interface.

@cilium/tetragon: Review of all Tetragon code, both for Go and C (for eBPF).

The teams above are responsible for reviewing the majority of contributions to the corresponding repositories. Additionally, there are “maintainer” teams listed below which may not be responsible for overall code review for a repository, but they have administrator access to the repositories and so they can assist with configuring GitHub repository settings, secrets, and related processes. For the full codeowners for individual repositories, see the CODEOWNERS file in the corresponding repository.

@cilium/cilium-cli-maintainers

@cilium/cilium-maintainers

@cilium/cilium-packer-ci-build-maintainers

@cilium/ebpf-lib-maintainers

@cilium/hubble-maintainers

@cilium/image-tools-maintainers

@cilium/metallb-maintainers

@cilium/openshift-terraform-maintainers

@cilium/proxy-maintainers

@cilium/tetragon-maintainers

The following codeowner groups provide insight into the integrations with specific cloud providers:

The following codeowner groups cover more specific knowledge about Cilium Agent internals or the way that particular Cilium features interact with external software and protocols:

@cilium/docker: Maintain the deprecated docker-plugin.

@cilium/endpoint: Provide background on how the Cilium Endpoint package fits into the overall agent architecture, relationship with generation of policy / datapath constructs, serialization and restore from disk.

@cilium/envoy: Maintain the L7 proxy integration with Envoy. This includes the configurations for Envoy via xDS protocols as well as the extensible proxylib framework for Go-based layer 7 filters.

@cilium/egress-gateway: Maintain the egress gateway control plane and datapath logic.

@cilium/fqdn: Maintain the L7 DNS proxy integration.

@cilium/ipcache: Provide background on how the userspace IPCache structure fits into the overall agent architecture, ordering constraints with respect to network policies and encryption. Handle the relationship between Kubernetes state and datapath state as it pertains to remote peers.

@cilium/ipsec: Maintain the kernel IPsec configuration and related eBPF logic to ensure traffic is correctly encrypted.

@cilium/kvstore: Review Cilium interactions with key-value stores, particularly etcd. Understand the client libraries used by Cilium for sharing state between nodes and clusters.

@cilium/loader: Maintain the tooling that allows eBPF programs to be loaded into the kernel: LLVM, bpftool, use of cilium/ebpf for loading programs in the agent, ELF templating, etc.

@cilium/operator: Review operations that occur once per cluster via the Cilium Operator component. Take care of the corresponding garbage collection and leader election logic.

@cilium/proxy: Review low-level implementations used to redirect L7 traffic to the actual proxy implementations (FQDN, Envoy, …).

@cilium/sig-agent: Provide Cilium (agent) general Go review. Internal architecture, core data structures and daemon startup.

@cilium/sig-bgp: Review changes to our BGP integration.

@cilium/sig-clustermesh: Ensure the reliability of state sharing between clusters to ensure that each cluster maintains a separate fault domain.

@cilium/sig-datapath: Provide feedback on all eBPF code changes, use of the kernel APIs for configuring the networking and socket layers. Coordination of kernel subsystems such as xfrm (IPsec), iptables / nftables, tc. Maintain the control plane layers that populate most eBPF maps; account for endianness and system architecture impacts on the datapath code.

@cilium/sig-encryption Review control and data plane logic related with encryption (IPSec and WireGuard).

@cilium/sig-hubble: Review all Cilium and Hubble code related to observing system events, exporting those via gRPC protocols outside the node and outside the cluster. Ensure the security of those event channels, for example via TLS.

@cilium/sig-ipam: Coordinate the implementation between all of the IP Address Management modes, provide awareness/insight into IP resource exhaustion and garbage collection concerns.

@cilium/sig-k8s: Provide input on all interactions with Kubernetes, both for standard resources and CRDs. Ensure best practices are followed for the coordination of clusterwide state in order to minimize memory usage.

@cilium/sig-lb: Maintain the layers necessary to coordinate all load balancing configurations within the agent control plane, including Services, ClusterIP, NodePorts, Maglev, local redirect policies, and NAT46/NAT64.

@cilium/sig-policy: Ensure consistency of semantics for all network policy representations. Responsible for all policy logic from Kubernetes down to eBPF policymap entries, including all intermediate layers such as the Policy Repository, SelectorCache, PolicyCache, CachedSelectorPolicy, EndpointPolicy, etc.

@cilium/sig-scalability: Maintain scalability and performance tests. Provide input on scalability and performance related changes.

@cilium/sig-servicemesh: Provide input on the way that Service Mesh constructs such as Gateway API are converted into lower-level constructs backed by eBPF or Envoy configurations. Maintain the CRDs necessary for Service Mesh functionality.

@cilium/wireguard: Maintain the kernel WireGuard configuration and datapath impacts related to ensuring traffic is encrypted correctly when WireGuard mode is enabled.

---

## Hubble — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/hubble/

**Contents:**
- Hubble
- Bumping the vendored Cilium dependency

This section is specific to Hubble contributions.

Hubble vendors Cilium using Go modules. You can bump the dependency by first running:

However, Cilium’s go.mod contains replace directives, which are ignored by go get and go mod. Therefore you must also manually copy any updated replace directives from Cilium’s go.mod to Hubble’s go.mod.

Once you have done this you can tidy up, vendor the modules, and verify them:

The bumped dependency should be committed as a single commit containing all the changes to go.mod, go.sum, and the vendor directory.

---

## Reviewing for @cilium/docs-structure — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/reviewers_committers/review_docs/

**Contents:**
- Reviewing for @cilium/docs-structure
- What is @cilium/docs-structure?
- Reviewing Pull Requests
  - Technical contents
  - Documentation structure
  - Specific items to look out for
    - Backport labels
    - CODEOWNERS updates
    - Beta disclaimer
    - Upgrade notes

Team @cilium/docs-structure is a GitHub team of Cilium contributors who are responsible for maintaining the good state of the project’s documentation, by reviewing Pull Requests (PRs) that update the documentation. Each time a non-draft PR touching files owned by the team opens, GitHub automatically assigns one member of the team for review.

Open Cilium Pull Requests awaiting for reviews from @cilium/docs-structure are listed here.

To join the team, you must be a Cilium Reviewer. See Cilium’s Contributor Ladder for details on the requirements and the application process.

This section describes some of the process and expectations for reviewing PRs on behalf of cilium/docs-structure. Note that the generic PR review process for Committers applies, even though it is not specific to documentation.

You are not expected to review the technical aspects of the documentation changes in a PR. However, if you do have knowledge of the topic and if you find some elements that are incorrect or missing, do flag them.

One essential part of a review is to ensure that the contribution maintains a coherent structure for the documentation. Ask yourself if the changes are located on the right page, at the right place. This is especially important if pages are added, removed, or shuffled around. If the addition is large, consider whether the page needs to split. Consider also whether new text comes with a satisfactory structure. For example, does it fit well with the surrounding context, or did the author simply use a “note” box instead of trying to integrate the new information to the relevant paragraph?

See also the recommendations on documentation structure for contributors.

See the backport criteria for documentation changes. Mark the PR for backports by setting the labels for all supported branches to which the changes apply, that is to say, all supported branches containing the parent features to which the modified sections relate.

All documentation sources are assigned to cilium/docs-structure for review by default. However, when a contributor creates a new page, consider whether it should be covered by another team as well so that this other team can review the technical aspects. If this is the case, ask the author to update the CODEOWNERS file.

When a feature is advertised as Beta in the PR, make sure that the author clearly indicates the Beta status in the documentation, both by mentioning “(Beta)” in the heading of the section for the feature and by including the dedicated banner, as follows:

When the PR introduces new user-facing options, metrics, or behavior that affects upgrades or downgrades, ensure that the author summarizes the changes with a note in Documentation/operations/upgrade.rst.

Make sure that new or updated content is complete, with no TODOs.

When certain parts of the Cilium repository change, contributors may have to update some auto-generated reference documents that are part of Cilium’s documentation, such as the command reference or the Helm reference. The CI validates that these updates are present in the PR. If they are missing, you may have to help contributors figure out what commands they need to run to perform the updates. These commands are usually provided in the logs of the GitHub workflows that failed to pass.

The Documentation checks include running a spell checker. This spell checker uses a file, Documentation/spelling_wordlist.txt, containing a list of spelling exceptions to ignore. Team cilium/docs-structure is the owner for this file. Usually, there is not much feedback to provide on updates to the list of exceptions. However, it’s useful for reviewers to know that:

Entries are sorted alphabetically, with all words starting with uppercase letters coming before words starting with lowercase letters.

Entries in the list of exceptions must be spelled correctly.

Lowercase entries are case-insensitive for the spell checker, so reviewers should reject new entries with capital letters if the lowercase versions are already in the list.

Netlify builds a new preview for each PR touching the documentation. You are not expected to check the preview for each PR. However, if the PR contains detailed formatting changes, such as nested blocks or directives, or changes to tables or tabs, then it’s good to validate that changes render as expected. Also check the preview if you have a doubt as to the validity of the reStructuredText (RST) mark-up that the author uses.

The list of checks on the PR page contains a link to the Netlify preview. If the preview build failed, the link leads to the build logs.

Read Cilium’s documentation style guide.

Flag poor formatting or obvious mistakes. The syntax for RST is not always trivial and some contributors make mistakes, or they simply forget to use RST and they employ Markdown mark-up instead. Make sure authors fix such issues.

Keep an eye on code-blocks: do they include RST substitutions, and if so, do they use the right directive? If not, do they use the right language?

Beyond that, the amount of time you spend on suggestions for improving formatting is up to you.

Read Cilium’s documentation style guide.

Flag obvious grammar mistakes. Try to read the updated text as a user would. Ask the contributors to revise any sentence that is too difficult to read or to understand.

@cilium/docs-structure aims to keep the documentation clean, consistent, and in a clear and comprehensible state. User experience must always be as good as possible. To achieve this objective, Documentation updates must follow best practices, such as the ones from the style guide. Reviewing PRs at sufficient depth to flag all potential style improvements can be time consuming, so the amount of effort that you put into style guidance is up to you.

There is no tooling in place to enforce particular style recommendations.

Here are the main resources involved or related to Cilium’s documentation build framework:

Instructions for building the documentation locally

Documentation/Makefile, Documentation/Dockerfile, Documentation/check-build.sh

Dependencies are in Documentation/requirements.txt, which is generated from Documentation/requirements_min/requirements.txt

The Sphinx theme we use is our own fork of Read the Docs’s theme

Documentation changes trigger the build of a new Netlify preview. If the build fails, the PR authors or reviewers must investigate it. Ideally the author should take care of this investigation, but in practice, contributors are not always familiar with RST or with our build framework, so consider giving a hand.

Same as the Netlify preview, the Documentation workflow runs on doc changes and can raise missing updates on various generated pieces of documentation.

The Checkpatch workflow is part of the BPF tests and is not directly relevant to documentation, but may raise some patch formatting issues, for example when the commit title is too long. So it should run on doc-only PRs, like for any other PR.

Integration tests, be it on Travis or on GitHub Actions, are the only workflows that rebuild the docs-builder image. Building this image is necessary to validate changes to the Documentation/Dockerfile or to the list of Python dependencies located in Documentation/requirements.txt. The GitHub workflow uses a pre-built image instead, and won’t incorporate changes to these files.

Integration tests also run a full build in the Cilium repository, including the post-build checks, in particular Documentation/Makefile’s check target. Therefore, integration tests are able to raise inconsistencies in auto-generated files in the documentation.

For PRs that only update documentation contents, the CI framework skips tests that are not relevant to the changes. Therefore, authors or reviewers should trigger the CI suite by commenting with /test, just like for any other PR. Once all code owners for the PR have approved, and all tests have passed, the PR should automatically receive the ready-to-merge label.

---

## BGP Control Plane — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/contributing/development/bgp_cplane/

**Contents:**
- BGP Control Plane
- Development Environment
  - Prerequisites
  - Deploy Lab
  - Install Cilium on the Lab
  - Peering with Router
  - Validating Peering Status
  - Validating Connectivity to Cilium Nodes from Non-Cilium Node
  - Destroy Lab

This section is specific to Cilium BGP Control Plane contributions.

BGP Control Plane requires a BGP peer for testing. This section describes a ContainerLab and Kind-based development environment. The following diagram shows the topology:

The following describes the role of each node:

router0 is an FRRouting (FRR) router. It is pre-configured with minimal peering settings with server0 and server1.

server0 and server1 are nicolaka/netshoot containers that each share a network namespace with their own Kind node.

server2 is a non-Cilium nicolaka/netshoot node useful for testing traffic connectivity from outside of the k8s cluster.

ContainerLab v0.45.1 or later

Kind v0.20.0 or later

Your container runtime networks must not use 10.0.0.0/8 and fd00::/16

The prior example sets up an IPv4 single-stack environment. You can change the v4 part to v6 or dual to set up an IPv6 single-stack or dual-stack environment respectively. The same goes for the following examples.

Install Cilium on the lab with your favorite way. The following example assumes you are modifying the source and want to build your own image. The minimal mandatory Helm values are provided in contrib/containerlab/bgp-cplane-dev-v4/values.yaml. If needed, you can add Helm values to deploy BGP Control Plane with a different Cilium configuration.

Peer Cilium nodes with FRR by applying a CiliumBGPPeeringPolicy:

At this point, there are only minimal peering settings on the policy and no advertisement configuration present. You need to edit policies, for example, with kubectl edit bgpp to realize your desired settings. If you need to change the router side, you can edit FRRouting settings with docker exec -it clab-bgp-cplane-dev-v4-router0 vtysh.

You can validate the peering status with the following command. Confirm that the session state is established and Received and Advertised counters are zero.

The below example validates connectivity from server2 to server0 (10.0.1.2) and server1 (10.0.2.2). You should see the packets go through router0 (10.0.3.1).

---
