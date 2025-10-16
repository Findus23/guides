---
title: "All XLA Options/Flags"
slug: all-xla-options
date: 2025-04-08
toc: end
description: "A list of all XLA options extracted from the latest JAX version"
---

Unfortunately the [JAX documentation](https://docs.jax.dev/en/latest/xla_flags.html) only seems to list a few common XLA flags. 
The rest of them is not documented at all outside of the OpenXLA source code. Here I am listing all of them as of **JAX/jaxlib 0.8.0** (XLA [9f150f6](https://github.com/openxla/xla/commit/9f150f6)).
Keep in mind that most of them are experimental and don't depend on their behaviour to be stable between JAX/XLA versions.

<!--more-->


```python
import subprocess
import sys

use_jax = False

if use_jax:
    out = subprocess.run(
        [
            sys.executable,
            "-c",
            "import jax;jax.numpy.zeros(10)"
        ],
        env={"XLA_FLAGS": "--help"},
        capture_output=True
    )
    text = out.stderr.decode().split("Flags:")[2].rstrip()
else:
    # read from output of `bazel run //xla/tools:hlo-opt -- --help`
    with open("out.txt") as f:
        text = f.read().rstrip()

for line in text.splitlines()[1:]:
    print("")
    if not line.lstrip().startswith("--"):
        print(line)
        continue
    _, arg, type, description = line.split("\t", maxsplit=3)
    arg_name, default = arg.strip().split("=")
    print(f"## {arg_name}")
    print(f"- default: `{default}`")
    print(f"- type: **{type}**")
    if description.startswith("[Stable]"):
        print(f"- **[Stable]**")
        description = description.replace("[Stable]", "").lstrip()
    print("")
    print(description)

```

All content below is extracted from https://github.com/openxla/xla and licensed under the [Apache License 2.0](https://github.com/openxla/xla/blob/main/LICENSE).


-------------

## --xla_cpu_enable_fast_math
- default: `false`
- type: **bool**

Enable unsafe fast-math optimizations in the CPU compiler; this may produce faster code at the expense of some accuracy.

## --xla_cpu_fast_math_honor_nans
- default: `true`
- type: **bool**

When xla_cpu_enable_fast_math is true then this controls whether we allow operations to produce NaNs. Ignored when xla_cpu_enable_fast_math is false.

## --xla_cpu_fast_math_honor_infs
- default: `true`
- type: **bool**

When xla_cpu_enable_fast_math is true then this controls whether we allow operations to produce infinites. Ignored when xla_cpu_enable_fast_math is false.

## --xla_cpu_fast_math_honor_division
- default: `true`
- type: **bool**

When xla_cpu_enable_fast_math is true then this controls whether we forbid to use multiplication by the reciprocal instead of division. Ignored when xla_cpu_enable_fast_math is false.

## --xla_cpu_fast_math_honor_functions
- default: `true`
- type: **bool**

When xla_cpu_enable_fast_math is true then this controls whether we forbid to approximate calculations for functions. Ignored when xla_cpu_enable_fast_math is false.

## --xla_cpu_enable_fast_min_max
- default: `true`
- type: **bool**

Enable fast floating point min/max lowering that might not propagate NaNs.

## --xla_gpu_enable_fast_min_max
- default: `false`
- type: **bool**

Enable fast floating point min/max lowering that does not propagate NaNs.

## --xla_llvm_enable_alias_scope_metadata
- default: `true`
- type: **bool**

In LLVM-based backends, enable the emission of !alias.scope metadata in the generated IR.

## --xla_llvm_enable_noalias_metadata
- default: `true`
- type: **bool**

In LLVM-based backends, enable the emission of !noalias metadata in the generated IR.

## --xla_llvm_enable_invariant_load_metadata
- default: `true`
- type: **bool**

In LLVM-based backends, enable the emission of !invariant.load metadata in the generated IR.

## --xla_llvm_disable_expensive_passes
- default: `false`
- type: **bool**

In LLVM-based backends, disable a custom set of expensive optimization passes.

## --xla_backend_optimization_level
- default: `3`
- type: **int32**

Numerical optimization level for the XLA compiler backend.

## --xla_disable_hlo_passes
- default: `""`
- type: **string**

Comma-separated list of hlo passes to be disabled. These names must exactly match the passes' names; no whitespace around commas.

## --xla_enable_hlo_passes_only
- default: `""`
- type: **string**

Comma-separated list of hlo passes to be enabled. These names must exactly match the passes' names; no whitespace around commas. The unspecified passes are all disabled.

## --xla_disable_all_hlo_passes
- default: `false`
- type: **bool**

Disables all HLO passes. Notes that some passes are necessary for correctness and the invariants that must be satisfied by 'fully optimized' HLO are different for different devices and may change over time. The only 'guarantee', such as it is, is that if you compile XLA and dump the optimized HLO for some graph, you should be able to run it again on the same device with the same build of XLA.

## --xla_embed_ir_in_executable
- default: `false`
- type: **bool**

Embed the compiler IR as a string in the executable.

## --xla_eliminate_hlo_implicit_broadcast
- default: `true`
- type: **bool**

Eliminate implicit broadcasts when lowering user computations to HLO instructions; use explicit broadcast instead.

## --xla_cpu_multi_thread_eigen
- default: `true`
- type: **bool**

When generating calls to Eigen in the CPU backend, use multi-threaded Eigen mode.

## --xla_gpu_cuda_data_dir
- default: `"./cuda_sdk_lib"`
- type: **string**

If non-empty, specifies a local directory containing ptxas and nvvm libdevice files; otherwise we use those from runfile directories.

## --xla_gpu_ftz
- default: `false`
- type: **bool**

If true, flush-to-zero semantics are enabled in the code generated for GPUs.

## --xla_gpu_ptx_file
- default: `""`
- type: **string**

If non-empty, specifies a file containing ptx to use. The filename prefix must have the same pattern as PTX dumped by XLA. This allows to match one specific module. General workflow. Get the generated module ptx from XLA, modify it, then pass it back via this option.

## --xla_gpu_llvm_ir_file
- default: `""`
- type: **string**

If non-empty, specifies a file containing textual LLVM IR to use. The filename prefix must have the same pattern as LLVM dumped by XLA (i.e. module_0001.ir-no-opt.ll -> module_0001.MY_NEW_FILE.ll). This allows to match one specific module. General workflow. Get the not optimized LLVM IR from XLA, modify it, then pass it back via this option.

## --xla_test_all_output_layouts
- default: `false`
- type: **bool**

Let ClientLibraryTestBase::ComputeAndCompare* test all permutations of output layouts. For example, with a 3D shape, all permutations of the set {0, 1, 2} are tried.

## --xla_test_all_input_layouts
- default: `false`
- type: **bool**

Let ClientLibraryTestBase::ComputeAndCompare* test all permutations of *input* layouts. For example, for 2 input arguments with 2D shape and 4D shape, the computation will run 2! * 4! times for every possible layouts

## --xla_test_add_command_buffer_mode
- default: `false`
- type: **bool**

If true, the test launched with ClientLibraryTestBase will use command buffer to execute the computation.

## --xla_hlo_profile
- default: `false`
- type: **bool**

Instrument the computation to collect per-HLO cycle counts

## --xla_backend_extra_options
- default: `""`
- type: **string**

Extra options to pass to a backend; comma-separated list of 'key=val' strings (=val may be omitted); no whitespace around commas.

## --xla_cpu_use_onednn
- default: `false`
- type: **bool**

Call oneDNN thunks for matmul and convolution fusions in the CPU backend.

## --xla_cpu_experimental_onednn_custom_call
- default: `false`
- type: **bool**

Call oneDNN custom call thunks in the CPU backend.

## --xla_cpu_experimental_onednn_fusion_type
- default: `""`
- type: **string**

Comma-separated list of oneDNN fusion types to be enabled; no whitespace around commas. Two ways to pass values:

  1. Exact type names. This overwrites the default setting.

  2. '+' or '-' prefix: This adds or removes a fusion type from the default list. Cannot be mixed with the overwrite mode. Every item must have the sign prefix.

Available fusion types: dot, eltwise, and reduce.

The default list is currently empty.

## --xla_cpu_use_acl
- default: `false`
- type: **bool**

Generate calls to ACL (Arm Compute Library) in the CPU backend.

## --xla_cpu_use_fusion_emitters
- default: `true`
- type: **bool**

Use fusion emitters for code generation in the CPU backend.

## --xla_cpu_use_thunk_runtime
- default: `true`
- type: **bool**

Deprecated.

## --xla_cpu_use_xnnpack
- default: `true`
- type: **bool**

Use XNNPACK for supported operations.

## --xla_cpu_experimental_xnn_fusion_type
- default: `""`
- type: **string**

Comma-separated list of XNN fusion types to be enabled.; no whitespace around commas. Two ways to pass values:

  1. Exact type names. This overwrites the default setting.

  2. '+' or '-' prefix: This adds or removes a fusion type from the default list. Cannot be mixed with the overwrite mode. Every item must have the sign prefix.

Available fusion types: dot, eltwise, and reduce.

The default list is currently empty.

## --xla_cpu_experimental_xnn_graph_fusion_mode
- default: `"XNN_GRAPH_FUSION_MODE_DISABLED"`
- type: **string**

Controls XnnGraphFusion pass.   `XNN_GRAPH_FUSION_MODE_DISABLED` - default value,

  `XNN_GRAPH_FUSION_MODE_GREEDY` - greedy extraction of XNNPACK-compatible subgraphs starting from root instructions,

  `XNN_GRAPH_FUSION_MODE_GREEDY_SLINKY` - same as GREEDY plus operations that are only supported with slinky,  `XNN_GRAPH_FUSION_MODE_BYPASS_COST_MODEL` - test-only value for disabling XNNPACK cost models.

## --xla_cpu_parallel_codegen_split_count
- default: `32`
- type: **int32**

Split LLVM module into at most this many parts before codegen to enable parallel compilation for the CPU backend.

## --xla_cpu_copy_insertion_use_region_analysis
- default: `false`
- type: **bool**

Use region based analysis in copy insertion pass.

## --xla_cpu_enable_concurrency_optimized_scheduler
- default: `true`
- type: **bool**

Use HLO module scheduler that is optimized for extracting concurrency from an HLO module by trading off extra memory pressure.

## --xla_cpu_prefer_vector_width
- default: `256`
- type: **int32**

Preferred vector width for the XLA:CPU LLVM backend.

## --xla_cpu_max_isa
- default: `""`
- type: **string**

Maximum ISA that XLA:CPU LLVM backend will codegen, i.e., it will not use newer instructions. Available values: SSE4_2, AVX, AVX2, AVX512, AVX512_VNNI, AVX512_BF16, AMX, and AMX_FP16. (`AMX` will enable both `AMX_BF16` and `AMX_INT8` instructions.)

## --xla_cpu_emitter_verification_level
- default: `0`
- type: **int32**

Sets how often we verify the emitted modules. Higher levels mean more frequent verification. Currently supported: 0, 1.

## --xla_gpu_crash_on_verification_failures
- default: `false`
- type: **bool**

Crashes the program on extra verification failures, e.g. cuDNN cross checking failures

## --xla_gpu_strict_conv_algorithm_picker
- default: `true`
- type: **bool**

Upgrades warnings to failures when all algorithms fail conv autotuning.

## --xla_gpu_autotune_level
- default: `4`
- type: **int32**
- **[Stable]**

Set GEMM and Convolution auto-tuning level. 0 = off; 1 = on; 2 = on+init; 3 = on+init+reinit; 4 = on+init+reinit+check; 5 = on+init+reinit+check and skip WRONG_RESULT solutions. See also the related flag xla_gpu_autotune_gemm_rtol. Remark that, setting the level to 5 only makes sense if you are sure that the reference (first in the list) solution is numerically CORRECT. Otherwise, the autotuner might discard many other correct solutions based on the failed BufferComparator test.

## --xla_gpu_autotune_max_solutions
- default: `0`
- type: **int64**

Maximal number of GEMM solutions to consider for autotuning: 0 means consider all solutions returned by the GEMM library.

## --xla_gpu_autotune_gemm_rtol
- default: `0.100000`
- type: **float**

Relative precision for comparing GEMM solutions vs the reference one

## --xla_force_host_platform_device_count
- default: `1`
- type: **int32**

Force the host platform to pretend that there are these many host "devices". All of these host devices are backed by the same threadpool. Setting this to anything other than 1 can increase overhead from context switching but we let the user override this behavior to help run tests on the host that run models in parallel across multiple devices.

## --xla_gpu_disable_gpuasm_optimizations
- default: `false`
- type: **bool**

In XLA:GPU run ptxas in -O0 (default is -O3).

## --xla_gpu_generate_debug_info
- default: `false`
- type: **bool**

Generate debug info for codegened CUDA kernels.

## --xla_gpu_generate_line_info
- default: `false`
- type: **bool**

Generate line info for codegened CUDA kernels.

## --xla_fuel
- default: `""`
- type: **string**

Sets compiler fuel, useful for bisecting bugs in passes. Format --xla_fuel=PASS1=NUM1,PASS2=NUM2,...

## --xla_dump_to
- default: `""`
- type: **string**

Directory into which debugging data is written. If not specified but another dumping flag is passed, data will be written to stdout. To explicitly write to stdout, set this to "-". The values "sponge" and "test_undeclared_outputs_dir" have a special meaning: They cause us to dump into the directory specified by the environment variable TEST_UNDECLARED_OUTPUTS_DIR. One or more --xla_dump_hlo_as_* flags can be set to specify the formats of the dumps. For example, if both --xla_dump_hlo_as_text and --xla_dump_hlo_as_proto are set, then the HLO modules will be dumped as text and as protos.

## --xla_flags_reset
- default: `false`
- type: **bool**

Whether to reset XLA_FLAGS next time to parse.

## --xla_gpu_unsupported_annotate_with_emitter_loc
- default: `false`
- type: **bool**

Forces emitters that use MLIR to annotate all the created MLIR instructions with the emitter's C++ source file and line number. The annotations should appear in the MLIR dumps. The emitters should use EmitterLocOpBuilder for that.

## --xla_dump_hlo_as_text
- default: `false`
- type: **bool**

Dumps HLO modules as text before and after optimizations. debug_options are written to the --xla_dump_to dir, or, if no dir is specified, to stdout.

## --xla_dump_hlo_as_long_text
- default: `true`
- type: **bool**

Dumps HLO modules as long text before and after optimizations. debug_options are written to the --xla_dump_to dir, or, if no dir is specified, to stdout. Ignored unless xla_dump_hlo_as_text is true.

## --xla_dump_large_constants
- default: `false`
- type: **bool**

Dumps HLO modules including large constants before and after optimizations. debug_options are written to the --xla_dump_to dir, or, if no dir is specified, to stdout. Ignored unless xla_dump_hlo_as_text is true.

## --xla_dump_hlo_as_proto
- default: `false`
- type: **bool**

Dumps HLO modules as HloProtos to the directory specified by --xla_dump_to.

## --xla_gpu_experimental_dump_fdo_profiles
- default: `false`
- type: **bool**

Dumps FDO profiles as text to the directory specified by --xla_dump_to.

## --xla_dump_hlo_as_dot
- default: `false`
- type: **bool**

Dumps HLO modules rendered as dot files to the directory specified by --xla_dump_to.

## --xla_dump_hlo_as_html
- default: `false`
- type: **bool**

Dumps HLO modules rendered as HTML files to the directory specified by --xla_dump_to.

## --xla_dump_hlo_as_url
- default: `false`
- type: **bool**

Tries to dump HLO modules rendered as URLs to stdout (and also to the directory specified by --xla_dump_to). This is not implemented by default; you need to add a plugin which calls RegisterGraphToURLRenderer().

## --xla_dump_fusion_visualization
- default: `false`
- type: **bool**

Tries to generate HLO fusion visualization as an HTML page to the directory specified by --xla_dump_to). This is not implemented by default; you need to add a plugin which calls RegisterGraphToURLRenderer(). Generates a file per computation. Currently only implemented for the GPU backend.

## --xla_dump_hlo_snapshots
- default: `false`
- type: **bool**

Every time an HLO module is run, dumps an HloSnapshot to the directory specified by --xla_dump_to.

## --xla_dump_hlo_module_re
- default: `""`
- type: **string**

Limits dumping only to modules which match this regular expression. Default is to dump all modules.

## --xla_dump_hlo_pass_re
- default: `""`
- type: **string**

If specified, dumps HLO before and after optimization passes which match this regular expression, in addition to dumping at the very beginning and end of compilation.

## --xla_dump_include_timestamp
- default: `false`
- type: **bool**

If specified, includes a timestamp in the dumped filenames.

## --xla_dump_max_hlo_modules
- default: `-1`
- type: **int32**

Max number of hlo module dumps in a directory. Set to < 0 for unbounded.

## --xla_dump_module_metadata
- default: `false`
- type: **bool**

Dumps HloModuleMetadata as text protos to the directory specified by --xla_dump_to.

## --xla_dump_compress_protos
- default: `false`
- type: **bool**

Gzip-compress protos dumped by --xla_dump_hlo_as_proto.

## --xla_hlo_graph_addresses
- default: `false`
- type: **bool**

When rendering graphs (--xla_dump_hlo_as_{dot,html,url}), displays the address in memory of each HloInstruction object.

## --xla_hlo_graph_sharding_color
- default: `false`
- type: **bool**

Assign colors based on sharding assignments when generating the HLO graphs.

## --xla_allow_excess_precision
- default: `true`
- type: **bool**

Allow xla to increase the output precision of an instruction.

## --xla_gpu_force_conv_nchw
- default: `false`
- type: **bool**

For cuDNN convolutions, always use NCHW layouts.

## --xla_gpu_force_conv_nhwc
- default: `false`
- type: **bool**

For cuDNN convolutions, always use NHWC layouts.

## --xla_gpu_algorithm_denylist_path
- default: `""`
- type: **string**

An AlgorithmDenylist text proto file as a denylist of convolutions to avoid to use.

## --xla_gpu_use_runtime_fusion
- default: `false`
- type: **bool**

For using cuDNN runtime compiled fusion kernels.

## --xla_tpu_detect_nan
- default: `false`
- type: **bool**

Trigger error on execution on TPU if a NAN value is detected

## --xla_tpu_detect_inf
- default: `false`
- type: **bool**

Trigger error on execution on TPU if a INF value is detected

## --xla_cpu_enable_xprof_traceme
- default: `false`
- type: **bool**

If true, XLA CPU generates code to call TraceMe::Activity{Start|End} around HLO operations.

## --xla_gpu_unsafe_fallback_to_driver_on_ptxas_not_found
- default: `false`
- type: **bool**

If true, XLA GPU falls back to the driver if ptxas is not found. Note that falling back to the driver can have drawbacks like using more memory and/or other bugs during compilation, so we recommend setting this flag to false.

## --xla_multiheap_size_constraint_per_heap
- default: `-1`
- type: **int32**

Generates multiple heaps (i.e., temp buffers) with a size constraint on each heap to avoid Out-of-Memory due to memory fragmentation. The constraint is soft, so it works with tensors larger than the given constraint size. -1 corresponds to no constraints.

## --xla_gpu_force_compilation_parallelism
- default: `0`
- type: **int32**

Overrides normal multi-threaded compilation setting to use this many threads. Setting to 0 (the default value) means no enforcement.

## --xla_gpu_enable_llvm_module_compilation_parallelism
- default: `false`
- type: **bool**

Decides whether we can do LLVM module compilation in a parallelised way. If set to false, then it will be single threaded, otherwise the number of threads depends on the --xla_gpu_force_compilation_parallelism flag and the thread pool supplied to GpuCompiler.

## --xla_gpu_deterministic_ops
- default: `false`
- type: **bool**

Guarantees run-to-run determinism on GPU.

## --xla_gpu_exclude_nondeterministic_ops
- default: `false`
- type: **bool**

Excludes non-deterministic ops from compiled executables.

## --xla_gpu_disable_async_collectives
- default: `""`
- type: **string**

This disables a certain set of async collectives and turn them into synchronous ones. By default, this is empty which indicates enabling async execution for all collectives. A sample usage is:  --xla_gpu_disable_async_collectives=ALLREDUCE,REDUCESCATTER

## --xla_gpu_enable_while_loop_unrolling
- default: `"WHILE_LOOP_UNROLLING_AUTO_UNROLL"`
- type: **string**

Enables while loop unrolling features. `WHILE_LOOP_UNROLLING_DOUBLE_BUFFER` unrolls the loop by factor of 2, `WHILE_LOOP_UNROLLING_FULL_UNROLL` will unroll the entire loop `WHILE_LOOP_UNROLLING_AUTO_UNROLL` unrolls by a factor of 2, if there is any collective present within a while loop.

## --xla_gpu_all_reduce_combine_threshold_bytes
- default: `31457287`
- type: **int64**
- **[Stable]**

Size threshold (in bytes) for the GPU all-reduce combiner.

## --xla_gpu_all_gather_combine_threshold_bytes
- default: `31457287`
- type: **int64**

Size threshold (in bytes) for the GPU all-gather combiner.

## --xla_gpu_reduce_scatter_combine_threshold_bytes
- default: `31457287`
- type: **int64**
- **[Stable]**

Size threshold (in bytes) for the GPU reduce-scatter combiner.

## --xla_gpu_collective_permute_combine_threshold_bytes
- default: `31457287`
- type: **int64**

Size threshold (in bytes) for the GPU collective-permute combiner.

## --xla_gpu_enable_all_gather_combine_by_dim
- default: `false`
- type: **bool**

Combine all-gather ops with the same gather dimension or irrespective of their dimension.

## --xla_gpu_enable_reduce_scatter_combine_by_dim
- default: `false`
- type: **bool**

Combine reduce-scatter ops with the same dimension or irrespective of their dimension.

## --xla_gpu_enable_approx_costly_collectives
- default: `false`
- type: **bool**

Enables more accurate latency approximation of collectives. Used in `ApproximateLatencyEstimator` scheduler.

## --xla_gpu_all_reduce_blueconnect_num_devices_per_host
- default: `0`
- type: **int32**

Number of devices per host for first stage of BlueConnect decomposition pass. The pass will attempt to decompose all-reduces ops into a ReduceScatter-AllReduce-AllGather sequence, with the initial ReduceScatter being performed over all of the devices in the same host. Set to < 1 to disable all-reduce decomposition.

## --xla_gpu_enable_while_loop_reduce_scatter_code_motion
- default: `false`
- type: **bool**

Enable hoisting of reduce-scatter outside while loops.

## --xla_gpu_collective_inflation_factor
- default: `1`
- type: **int32**

Inflation factor for collectives. If set to > 1, each XLA/GPU collective will execute multiple times (will yield incorrect results)

## --xla_llvm_force_inline_before_split
- default: `true`
- type: **bool**

Decide whether to force inline before llvm module split to get a more balanced splits for parallel compilation

## --xla_gpu_enable_reassociation_for_converted_ar
- default: `true`
- type: **bool**

Enable allreduce reassociation on allreduces that are converted to a wider type. The reassociated allreduce will be promoted to a wider-typed allreduce.

## --xla_gpu_dump_llvmir
- default: `false`
- type: **bool**

Dump LLVM IR.

## --xla_dump_hlo_unoptimized_snapshots
- default: `false`
- type: **bool**

Every time an HLO module is run, dumps an HloUnoptimizedSnapshot to the directory specified by --xla_dump_to.

## --xla_gpu_enable_cudnn_fmha
- default: `false`
- type: **bool**

[Deprecated, do not use]

## --xla_gpu_fused_attention_use_cudnn_rng
- default: `false`
- type: **bool**

Use cudnn random number generator for fused attention kernel.

## --xla_gpu_enable_cudnn_layer_norm
- default: `false`
- type: **bool**

Rewrite layer norm patterns into cuDNN library call.

## --xla_gpu_enable_cublaslt
- default: `false`
- type: **bool**

Use cuBLASLt for GEMMs when possible.

## --xla_gpu_collectives_use_persistent_cliques
- default: `false`
- type: **bool**

Use persistent per-process XLA:GPU collectives cliques

## --xla_gpu_enable_command_buffer
- default: `"FUSION, CUBLAS, CUBLASLT, CUSTOM_CALL, CUDNN"`
- type: **string**

The types of the commands that are recorded into command buffers. It can either be a list of command types or a list of command types with + and - as prefix, which indicate adding or removing a command type to/from the default list.

## --xla_gpu_graph_min_graph_size
- default: `5`
- type: **int32**

Capture a region as a function to be launched as cuda graph if the number of moved instructions reaches this threshold.

## --xla_gpu_graph_enable_concurrent_region
- default: `false`
- type: **bool**

[Deprecated, do not use]

## --xla_gpu_command_buffer_scheduling_mode
- default: `"LHS"`
- type: **string**

The command buffer scheduling mode for XLA:GPU.

## --xla_cmd_buffer_trace_cache_size
- default: `16`
- type: **int64**

Set the command buffer trace cache size, increasing the cache size may sometimes reduces the chances of doing command buffer tracing for updating command buffer instance.

## --xla_dump_disable_metadata
- default: `false`
- type: **bool**

Disable dumping HLO metadata in HLO dumps.

## --xla_dump_hlo_pipeline_re
- default: `""`
- type: **string**

If specified, dumps HLO before and after optimization passes in the pass pipelines that match this regular expression.

## --xla_dump_enable_mlir_pretty_form
- default: `true`
- type: **bool**

Enable dumping MLIR using pretty print form. If set to false, the dumped MLIR will be in the llvm-parsable format and can be processed by mlir-opt tools. Pretty print form is not legal MLIR.

## --xla_dump_full_hlo_config
- default: `true`
- type: **bool**

Enable dumping the full HloModuleConfig proto.

## --xla_gpu_enable_dynamic_slice_fusion
- default: `false`
- type: **bool**
- **[Stable]**

Whether to enable address computation fusion to optimize dynamic-slice and dynamic-update-slice operations.

## --xla_gpu_nccl_termination_timeout_seconds
- default: `-1`
- type: **int64**

Timeout in seconds before terminating jobs stuck in NCCL Rendezvous.

## --xla_gpu_enable_shared_constants
- default: `true`
- type: **bool**

Enable constant sharing between GPU executables

## --xla_gpu_enable_nccl_user_buffers
- default: `false`
- type: **bool**

Enables NCCL User Buffer Registration. collective_memory_size in the allocator config must also be set to a non-zero value that is large enough to meet peak collective memory usage.

## --xla_gpu_experimental_enable_nccl_symmetric_buffers
- default: `false`
- type: **bool**

Enables NCCL symmetric buffer registration.

## --xla_gpu_experimental_enable_nvshmem
- default: `false`
- type: **bool**

Enables NVSHMEM.

## --xla_gpu_temp_buffer_use_separate_color
- default: `false`
- type: **bool**

Enables temp User Buffer Registration. Enable this flag will use a separate cuda async memory allocator to allocate temp buffer, this will allocate temp buffer to the fixed address on every iteration

## --xla_gpu_require_exclusive_lock
- default: `false`
- type: **bool**

if true, running gpu executable will require exclusive lock on gpu, so there is no multi thread conlicts on gpu. this can enable some optimizations that reduce the cost of resource management, e.g, command buffer update to ensure correctness when running in multi thread mode.

## --xla_gpu_enable_nccl_comm_splitting
- default: `true`
- type: **bool**

Enables NCCL communicator splitting which allows sharing NCCL resources between different NCCL cliques.

## --xla_gpu_nccl_init_max_rank_per_root_ratio
- default: `0`
- type: **int64**

Maximum number of ranks associated with a root rank to initialize a NCCL communicator via ncclCommInitRankScalable. A value of zero will lead to a single root.

## --xla_gpu_redzone_padding_bytes
- default: `8388608`
- type: **int64**

Amount of padding the redzone allocator will put on one side of each buffer it allocates. (So the buffer's total size will be increased by 2x this value.)

## --xla_gpu_shape_checks
- default: `"RUNTIME"`
- type: **string**

When to perform shape checks in XLA:GPU.

## --xla_cpu_strict_dot_conv_math
- default: `false`
- type: **bool**

By default, XLA:CPU will run fp16 dot/conv as fp32, as this is generally (much) faster on our hardware. Set this flag to true to disable this behavior.

## --xla_dump_latency_hiding_schedule
- default: `false`
- type: **bool**

Dump the schedule from the latency-hiding scheduler.

## --xla_gpu_enable_latency_hiding_scheduler
- default: `false`
- type: **bool**
- **[Stable]**

Enable latency-hiding scheduler for XLA:GPU

## --xla_gpu_enable_analytical_latency_estimator
- default: `false`
- type: **bool**

Enable analytical latency estimator for latency-hiding scheduler for XLA:GPU

## --xla_gpu_enable_analytical_sol_latency_estimator
- default: `true`
- type: **bool**

Enable analytical Speed-of-Light latency estimator for latency-hiding scheduler for XLA:GPU, must be used without xla_gpu_enable_analytical_latency_estimator. It can also benefit from user-passed options in xla_gpu_analytical_latency_estimator_options

## --xla_gpu_analytical_latency_estimator_options
- default: `""`
- type: **string**

Extra platform-specific options to improve analytical latency estimator precision; comma-separated list of 'key=val' strings (=val may be omitted); no whitespace around commas.Available options: --xla_gpu_analytical_latency_estimator_options='nccl_op_launch_us=55,nic_speed_gbps=40,chunk_prep_us=1,rtt_us=2,gpus_per_node=4,chunk_size_bytes=1024'

## --xla_gpu_pgle_profile_file_or_directory_path
- default: `""`
- type: **string**

Directory or file for PGLE profiles in XLA:GPU

## --xla_gpu_memory_limit_slop_factor
- default: `95`
- type: **int32**

Slop factor for memory limits in XLA:GPU. This flag serves as a multiplier applied to the total available memory, creating a threshold that guides the Latency Hiding Scheduler (LHS) in balancing memory reduction and latency hiding optimizations. This factor effectively establishes a memory limit for compiler passes, determining when the scheduler should prioritize:   1. Memory reduction: When memory usage approaches or exceeds the calculated      threshold.   2. Latency hiding: When memory usage is below the threshold, allowing for      more aggressive optimizations that may temporarily increase memory usage      but improve overall performance. By adjusting this factor, users can fine-tune the trade-off between memory efficiency and performance optimizations. The default value is 95.

## --xla_gpu_enable_highest_priority_async_stream
- default: `true`
- type: **bool**

Enable async stream to have the highest priority.

## --xla_gpu_enable_pipelined_all_reduce
- default: `false`
- type: **bool**
- **[Stable]**

Enable pipelinling of all-reduce instructions.

## --xla_gpu_enable_pipelined_all_gather
- default: `false`
- type: **bool**
- **[Stable]**

Enable pipelinling of all-gather instructions.

## --xla_gpu_enable_pipelined_reduce_scatter
- default: `true`
- type: **bool**
- **[Stable]**

Enable pipelinling of reduce-scatter instructions.

## --xla_gpu_enable_pipelined_p2p
- default: `false`
- type: **bool**

Enable pipelinling of P2P instructions.

## --xla_gpu_collective_permute_decomposer_threshold
- default: `9223372036854775807`
- type: **int64**
- **[Stable]**

Collective permute decomposer threshold.

## --xla_gpu_experimental_pipeline_parallelism_opt_level
- default: `"PIPELINE_PARALLELISM_OPT_LEVEL_DISABLE"`
- type: **string**

Experimental optimizations for SPMD-based pipeline parallelism on GPU.

## --xla_partitioning_algorithm
- default: `"PARTITIONING_ALGORITHM_NOOP"`
- type: **string**

The partitioning algorithm to be used in the PartitionAssignment pass

## --xla_gpu_enable_triton_gemm
- default: `true`
- type: **bool**
- **[Stable]**

Whether to use Triton-based matrix multiplication.

## --xla_gpu_unsupported_generic_triton_emitter_features
- default: `"GENERIC_TRITON_EMITTER_ENABLE_NESTED_GEMM"`
- type: **string**

Comma-separated list of individual features of generic Triton emitter. Use +/- prefix to modify the default list, or list features to enable explicitly - that will override the defaults.

## --xla_gpu_unsupported_enable_triton_multi_output_fusion
- default: `true`
- type: **bool**

Enable Triton multi-output fusions.

## --xla_gpu_verify_triton_fusion_numerics
- default: `false`
- type: **bool**

Whether to verify that the numeric results of Triton fusions match the results of regular emitters.

## --xla_gpu_enable_cudnn_int8x32_convolution_reordering
- default: `true`
- type: **bool**

Enable cuDNN frontend for int8x32 convolutions with reordered filter.

## --xla_gpu_triton_gemm_any
- default: `true`
- type: **bool**

Use Triton-based matrix multiplication for any GEMM it supports without filtering only faster ones. To make sure only triton gemm is chosen by the autotuner run with `xla_gpu_cublas_fallback` set to false.

## --xla_gpu_exhaustive_tiling_search
- default: `false`
- type: **bool**
- **[Stable]**

Search for Triton GEMM tilings exhaustively during autotuning. This increases the compile time.

## --xla_gpu_experimental_enable_subchannel_dequantisation_fusion
- default: `false`
- type: **bool**

Enable fusion for the subchannel dequantisation sequences like [x,z]param -> [x,y,z]broadcast -> [x*y,z]bitcast -> multiply -> dot. Performance can be worse, because some block sizes / split-k > 1 is not considered for subchannel dequant fusions.

## --xla_gpu_experimental_enable_triton_heroless_priority_fusion
- default: `false`
- type: **bool**

Enable heroless Triton fusions in the PriorityFusion pass. The pass will try to make Triton fusions first and foremost where it is possible.

## --xla_gpu_dump_autotune_results_to
- default: `""`
- type: **string**

File to write autotune results to. It will be a binary file unless the name ends with .txt or .textproto. Warning: The results are written at every compilation, possibly multiple times per process. This only works on CUDA. In tests, the TEST_UNDECLARED_OUTPUTS_DIR prefix can be used to write to their output directory.

## --xla_gpu_load_autotune_results_from
- default: `""`
- type: **string**

File to load autotune results from. It will be considered a binary file unless the name ends with .txt or .textproto. It will be loaded at most once per process. This only works on CUDA. In tests, the TEST_WORKSPACE prefix can be used to load files from their data dependencies.

## --xla_gpu_require_complete_aot_autotune_results
- default: `false`
- type: **bool**

Whether to require complete AOT autotuning results.

## --xla_gpu_auto_spmd_partitioning_memory_budget_gb
- default: `0`
- type: **int32**

Memory budget in GB per device for AutoSharding.

## --xla_gpu_auto_spmd_partitioning_memory_budget_ratio
- default: `1.100000`
- type: **float**

Enabled when xla_gpu_auto_spmd_partitioning_memory_budget_gb is 0. The memory budget is set to xla_gpu_auto_spmd_partitioning_memory_budget_ratio times the estimated memory usage lower bound.

## --xla_gpu_dump_autotuned_gemm_fusions
- default: `false`
- type: **bool**

Dumps autotuned GEMM fusions to the directory specified by xla_dump_to or stdout. Each fusion is dumped only once, as an optimized HLO.

## --xla_gpu_override_gemm_autotuner
- default: `""`
- type: **string**

Overrides the GEMM autotuner to use the specified (AutotuneResult::TritonGemmKey) textproto configuration for all Triton GEMM fusions. (You can get such textprotos from the debug logs of the GEMM autotuner.)

## --xla_gpu_command_buffer_unroll_loops
- default: `false`
- type: **bool**

During command buffer lowering, unroll the loop command if loop has known loop count.

## --xla_gpu_copy_insertion_use_region_analysis
- default: `false`
- type: **bool**

If true, use the new fine-grain region-based live range interference analysis in the copy insertion optimization pass.

## --xla_gpu_collect_cost_model_stats
- default: `false`
- type: **bool**

If true, each fusion instruction will have a cost model runtime estimate in backend config after compilation.

## --xla_gpu_enable_split_k_autotuning
- default: `true`
- type: **bool**

Enable split_k autotuning for triton gemms.

## --xla_gpu_enable_reduction_epilogue_fusion
- default: `true`
- type: **bool**

Enable fusion for reduction epilogues

## --xla_gpu_enable_nccl_clique_optimization
- default: `false`
- type: **bool**

[Deprecated, do not use].

## --xla_gpu_cublas_fallback
- default: `true`
- type: **bool**
- **[Stable]**

Whether to allow GEMM fusion autotuning to fall back to cuBLAS when it is faster than Triton.

## --xla_gpu_cudnn_gemm_fusion_level
- default: `0`
- type: **int32**

cuDNN GEMM fusion level; higher level corresponds to more kinds of fused operations.

## --xla_gpu_mock_custom_calls
- default: `false`
- type: **bool**

Replace custom calls with noop operations.

## --xla_gpu_enable_while_loop_double_buffering
- default: `false`
- type: **bool**
- **[Stable]**

Enable double buffering for while loop

## --xla_gpu_filter_kernels_spilling_registers_on_autotuning
- default: `true`
- type: **bool**

Filter out kernels that spill registers during autotuning

## --xla_gpu_fail_ptx_compilation_on_register_spilling
- default: `false`
- type: **bool**

Fails the PTX compilation if a kernel spills registers.

## --xla_debug_buffer_assignment_show_max
- default: `15`
- type: **int64**

Number of buffers to display when debugging the buffer assignment

## --xla_gpu_llvm_verification_level
- default: `0`
- type: **int32**

Sets how often we verify the generated llvm modules. Higher levels mean more frequent verification. Currently supported: 0, 1.

## --xla_gpu_target_config_filename
- default: `""`
- type: **string**

Filename for GPU TargetConfig. Triggers devicless compilation: attached device is ignored, and the proto is queried instead

## --xla_gpu_enable_cub_radix_sort
- default: `true`
- type: **bool**

Enable radix sort using CUB for simple shapes

## --xla_gpu_threshold_for_windowed_einsum_mib
- default: `100000`
- type: **int64**

Threshold to enable windowed einsum (collective matmul) in MB.Einsums that have partitioned operand(can be either LHS or RHS) that's larger than this threshold will be transformed to use windowed einsums.Default is 100000

## --xla_gpu_operand_bytes_threshold_for_windowed_einsum
- default: `-1`
- type: **int64**

This controls whether to enable windowed einsum (collective matmul) based on the sum of sizes of 2 operands if set >= 0.If set >= 0, xla_gpu_threshold_for_windowed_einsum_mib is ignored.Default is -1

## --xla_gpu_experimental_enable_fusion_block_level_rewriter
- default: `false`
- type: **bool**

Enabling this flag will attempt to redirect every fusion possible to the Triton emitter

## --xla_gpu_enable_libnvptxcompiler
- default: `false`
- type: **bool**

Use libnvptxcompiler for PTX-to-GPU-assembly compilation instead of calling ptxas.

## --xla_gpu_enable_libnvjitlink
- default: `false`
- type: **bool**

Use libnvjitlink for PTX-to-GPU-assembly compilation instead of calling ptxas.

## --xla_gpu_nccl_async_execution
- default: `false`
- type: **bool**

Whether to use asynchronous execution for NCCL communicators

## --xla_gpu_nccl_blocking_communicators
- default: `true`
- type: **bool**

Whether to use non-blocking NCCL communicators

## --xla_gpu_nccl_collective_max_nchannels
- default: `0`
- type: **int64**

Specify the maximum number of channels(SMs) NCCL will use for collective operations. Default is 0 which is to let NCCL decide.

## --xla_gpu_nccl_p2p_max_nchannels
- default: `0`
- type: **int64**

Specify the maximum number of channels(SMs) NCCL will use for p2p operations. Default is 0 which is to let NCCL decide.

## --xla_gpu_multi_streamed_windowed_einsum
- default: `true`
- type: **bool**

Whether to run windowed einsum using multiple compute streams.

## --xla_gpu_gemm_rewrite_size_threshold
- default: `100`
- type: **int64**

Threshold until which elemental dot emitter is preferred for GEMMs (minimum combined number of elements of both matrices in non-batch dimensions to be considered for a rewrite).

## --xla_gpu_use_embeded_device_lib
- default: `false`
- type: **bool**

Whether to use embeded bitcode library in codegen.

## --xla_gpu_use_memcpy_local_p2p
- default: `false`
- type: **bool**

Whether to use memcpy for local p2p communication.

## --xla_gpu_use_inprocess_lld
- default: `false`
- type: **bool**

Whether to use lld as a library for the linking.

## --xla_gpu_dump_autotune_logs_to
- default: `""`
- type: **string**

File to write autotune logs to. It will be a binary file unless the name ends with .txt or .textproto.

## --xla_reduce_window_rewrite_base_length
- default: `16`
- type: **int64**

Base length to rewrite the reduce window to, no rewrite if set to 0.

## --xla_gpu_enable_host_memory_offloading
- default: `false`
- type: **bool**

Whether to trigger host memory offloading on a device.

## --xla_gpu_nccl_terminate_on_error
- default: `false`
- type: **bool**

If set, then NCCL errors will terminate the process.

## --xla_gpu_shard_autotuning
- default: `true`
- type: **bool**

Shard autotuning between participating compiler processes (typically in multi-host setups) and join the results when it's done.

## --xla_syntax_sugar_async_ops
- default: `false`
- type: **bool**

Enable syntax sugar for async ops in HLO dumps.

## --xla_gpu_kernel_cache_file
- default: `""`
- type: **string**

Path to a file to cache compiled kernels. Cached kernels get reused in further compilations; not yet cached kernels are compiled as usual and get appended to the cache file whenever possible.

## --xla_gpu_per_fusion_autotune_cache_dir
- default: `""`
- type: **string**

Experimental: Maintain a per-fusion autotune cache in the given directory. XLA will try to read existing results when they are needed and write new results when they are determined. The directory must exist. Cache invalidation has to be handled by the user (e.g. please use an empty directory if you want to start with an empty cache). XLA version checks must be done by the user (e.g. if you want to use separate caches for different versions of XLA, please use different directories). Default: no cache.

## --xla_gpu_experimental_autotune_cache_mode
- default: `"AUTOTUNE_CACHE_MODE_UPDATE"`
- type: **string**

Experimental: Specify the behavior of per kernel autotuning cache. Supported modes: read (provides readonly access to the cache), update (loads if the cache exists, runs autotuning and dumps the result otherwise). Default: update.

## --xla_gpu_experimental_autotuner_cache_dir
- default: `""`
- type: **string**

Experimental: Specify the directory to read/write autotuner cache to.

## --xla_enable_command_buffers_during_profiling
- default: `false`
- type: **bool**

Experimental: Enable command buffers while a profiling active. By default, enabling profiling switches from command buffers to op-by-op mode.

## --xla_gpu_cudnn_gemm_max_plans
- default: `5`
- type: **int32**

Limit for the number of kernel configurations (plans) to use during autotuning of cuDNN GEMM fusions.

## --xla_gpu_enable_triton_gemm_int4
- default: `true`
- type: **bool**

[Deprecated, do not use]

## --xla_gpu_async_dot
- default: `false`
- type: **bool**

Wrap `dot` operations into async computations in an effort to parallelize matrix operations.

## --xla_step_marker_location
- default: `"STEP_MARK_AT_ENTRY"`
- type: **string**

Option to emit a target-specific marker to indicate the start of a training. The location of the marker (if any) is determined by the option value of type DebugOptions::StepMarkerLocation.

## --xla_gpu_pgle_accuracy_checker
- default: `"PGLE_STRICTNESS_LEVEL_WARN"`
- type: **string**

If an FDO profile is specified and latency hiding scheduler encounters missing instructions in the profile, then the compilation will halt (ERROR), or a warning will be emitted (WARN), or the checker is disabled (OFF)

## --xla_gpu_executable_warn_stuck_timeout
- default: `10`
- type: **int32**

Set timeout for Rendezvous stuck warning

## --xla_gpu_executable_terminate_timeout
- default: `30`
- type: **int32**

Set timeout for Rendezvous termination

## --xla_gpu_first_collective_call_warn_stuck_timeout_seconds
- default: `20`
- type: **int32**

Set timeout for First Collective Call Rendezvous stuck warning

## --xla_gpu_first_collective_call_terminate_timeout_seconds
- default: `40`
- type: **int32**

Set timeout for First Collective Call Rendezvous termination

## --xla_gpu_experimental_disable_binary_libraries
- default: `false`
- type: **bool**

Disable XLA GPU passes that depend on non-open source binary libraries

## --xla_ignore_channel_id
- default: `false`
- type: **bool**

Ignore channel ids for collective operations.

## --xla_gpu_dot_merger_threshold_mb
- default: `32`
- type: **int32**
- **[Stable]**

Dot merger pass threshold to be set in MB.

## --xla_enable_fast_math
- default: `false`
- type: **bool**

Enable optimizations that assume finite math, i.e., no NaN.

## --xla_gpu_experimental_stream_annotation
- default: `true`
- type: **bool**

Enable the experimental explicit stream annotation support. If false, the annotations are ignored.

## --xla_gpu_experimental_parallel_collective_overlap_limit
- default: `1`
- type: **int32**

This controls how many in-flight collectives latency hiding scheduler can schedule.

## --xla_pjrt_allow_auto_layout_in_hlo
- default: `false`
- type: **bool**

Experimental: Make unset entry computation layout mean auto layout instead of default layout in HLO when run through PjRT. In other cases (StableHLO or non-PjRT) the auto layout is already used.

## --xla_gpu_enable_scatter_determinism_expander
- default: `false`
- type: **bool**

Enable the scatter determinism expander, an optimized pass that rewrites scatter operations to ensure deterministic behavior with high performance.Note that even when this flag is disabled, scatter operations may still be deterministic, although with additional overhead.

## --xla_gpu_unsupported_enable_all_reduce_decomposer
- default: `false`
- type: **bool**

Internal: Enable the AllReduceDecomposer, an unsupported pass that rewrites small all-reduce operations as a sequence of all-gather and reduce operations.

## --xla_gpu_unsupported_enable_ragged_all_to_all_decomposer
- default: `false`
- type: **bool**

Internal: Enable the RaggedAllToAllDecomposer, an experimental pass that rewrites ragged-all-to-all as a dense all-to-all operation.

## --xla_gpu_unsupported_enable_ragged_all_to_all_multi_host_decomposer
- default: `false`
- type: **bool**

Internal: Enable the RaggedAllToAllMultiHostDecomposer, an experimental pass to decompose ragged-all-to-all operation in intra-host and inter-host parts.

## --xla_gpu_unsupported_override_fast_interconnect_slice_size
- default: `0`
- type: **int64**

Internal: Override the number of devices in the fast interconnect domain. Default is 0, which means the number of devices is not overridden.

## --xla_gpu_unsupported_use_all_reduce_one_shot_kernel
- default: `false`
- type: **bool**

Internal: Enable the one-shot kernel for single-host all-reduce operations.

## --xla_gpu_unsupported_use_ragged_all_to_all_one_shot_kernel
- default: `true`
- type: **bool**

Internal: Enable the one-shot kernel for single-host ragged-all-to-all operations.

## --xla_gpu_experimental_enable_alltoall_windowed_einsum
- default: `false`
- type: **bool**

Enable windowed einsum rewrite for all-to-all+gemm pattern, This optimization slices the all-to-all into smaller all-to-alls.It is an experimental feature.

## --xla_gpu_experimental_pack_dot_operands_along_k_dimension
- default: `true`
- type: **bool**

For sub-byte dot operands, layout them along contracting dimensions.

## --xla_unsupported_crash_on_hlo_pass_fix_max_iterations
- default: `false`
- type: **bool**

Crash if HloPassFix can not converge after a fixed number of iterations.

## --xla_hlo_pass_fix_detect_cycles
- default: `false`
- type: **bool**

Perform hash-based cycle detection in fixed-point loops.

## --xla_gpu_experimental_enable_heuristic_collective_combining
- default: `true`
- type: **bool**

Enable heuristic based collective combining.

## --xla_gpu_experimental_collective_cse_distance_threshold
- default: `0`
- type: **int64**

Set distance threshold for Collective CSE.

## --xla_gpu_experimental_collective_perf_table_path
- default: `""`
- type: **string**

If non empty will interpret this variable as a path for performance tables for collectives. Expects `xla.gpu.DeviceHloInstructionProfiles` proto.

## --xla_unsupported_crash_on_hlo_pass_noop_change
- default: `false`
- type: **bool**

Crash if a pass reports that it did change the HLO but in fact it did not.

## --xla_unsupported_crash_on_hlo_pass_silent_hlo_change
- default: `false`
- type: **bool**

Crash if a pass reports that it did not change the HLO but in fact it did.

## --xla_disable_automatic_host_compute_offload
- default: `false`
- type: **bool**

Return an error if HostOffloader would have automatically offloaded some compute to the host.

## --xla_gpu_experimental_matmul_perf_table_path
- default: `""`
- type: **string**

If non empty will interpret this variable as a path for performance tables for matmuls. Expects `xla.gpu.DeviceHloInstructionProfiles` proto.

## --xla_gpu_experimental_enable_split_k_rewrite
- default: `false`
- type: **bool**

Enable the pass that splits GEMMs that underutilize the GPU load by splitting the K dimension using a heuristic.

## --xla_gpu_experimental_enable_triton_tma
- default: `false`
- type: **bool**

Enable Triton's TMA loads/stores for arguments where applicable.

## --xla_gpu_experimental_enable_triton_warp_specialization
- default: `false`
- type: **bool**

Enable Triton's auto warp specialization feature where applicable.

## --xla_gpu_experimental_enable_command_buffer_on_thunks
- default: `true`
- type: **bool**

Enables an experimental feature for command buffer conversion on thunks.

## --xla_gpu_experimental_use_autotuner_pass
- default: `false`
- type: **bool**

If true, use the AutotunerPass to autotune fusions, instead of the gemm_fusion_autotuner.

## --xla_detect_unstable_reductions
- default: `"UNSTABLE_REDUCTION_DETECTION_MODE_NONE"`
- type: **string**

Controls the behavior of the unstable reduction detector pass that checks for unstable reductions in HLO computations. Acceptable values are: 'none', 'log', and 'crash'. 'none' is the default.

## --xla_gpu_experimental_use_raft_select_k
- default: `false`
- type: **bool**

If true, use the raft::matrix::select_k implementation of TopK.

## --xla_gpu_experimental_scaled_dot_with_triton
- default: `false`
- type: **bool**

If true, use the Triton emitter for scaled dot.

## --xla_cpu_collective_call_warn_stuck_timeout_seconds
- default: `20`
- type: **int32**

Set timeout for Collective Call Rendezvous stuck warning

## --xla_cpu_collective_call_terminate_timeout_seconds
- default: `40`
- type: **int32**

Set timeout for Collective Call Rendezvous termination

## --xla_keep_shardings_after_spmd
- default: `false`
- type: **bool**

If true, keep shardings after SPMD.
