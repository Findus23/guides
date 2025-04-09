---
title: "JAX Tips and Tricks"
slug: jax-tips-and-tricks
date: 2025-04-07
categories: cheatsheet
author: Lukas Winkler
cc_license: true
description: "An assorted list of tricks for using Jax"
---


This is an unordered list of useful things I found while using [JAX](https://docs.jax.dev/en/latest/), that don't seem
to be documented well somewhere else. Partially this is because these features are experimental, so don't depend on them
working the exact same way in future versions of JAX. Nevertheless, they might be useful during development and testing
and have been tested using JAX 0.5.3 as of writing.

<!--more-->

## jax-array-info

- [Documentation](https://github.com/Findus23/jax-array-info/)

This is a collection of tools I wrote, that allow printing some useful information about JAX arrays and their
properties:

```python
from jax_array_info import sharding_info, sharding_vis, simple_array_info, print_array_stats, pretty_memory_stats
some_array = jax.numpy.zeros(shape=(N, N, N), dtype=jax.numpy.float32)
some_array = jax.device_put(some_array, NamedSharding(mesh, P(None, "gpus")))
sharding_info(some_array, "some_array")
```

```text
╭───────────────── some_array ─────────────────╮
│ shape: (128, 128, 128)                       │
│ dtype: float32                               │
│ size: 8.0 MiB                                │
│ NamedSharding: P(None, 'gpus')               │
│ axis 1 is sharded: CPU 0 contains 0:16 (1/8) │
│                    Total size: 128           │
╰──────────────────────────────────────────────╯
```

You can find a description of all features and many test cases of sharded JAX operations in
the [GitHub repository](https://github.com/Findus23/jax-array-info/).

## Visualizing the HLO Graph

- [Source](https://bnikolic.co.uk/blog/python/jax/2022/02/22/jax-outputgraph-rev.html)

One useful thing during debugging is to visualize the computational graph JAX creates (especially after JIT compilation) as a visual graph.

```python
import subprocess
from pathlib import Path
import jax
from jax._src.stages import Compiled
from jaxlib import xla_client

def todotgraph(x: str) -> str:
    return xla_client._xla.hlo_module_to_dot_graph(xla_client._xla.hlo_module_from_text(x))

def write_debug_graph(compiled: Compiled, output: Path):
    hlo = compiled.as_text()
    output.with_suffix(".hlo.txt").write_text(hlo)

    graph_file = output.with_suffix(".graph.dot")
    graph_file.write_text(todotgraph(hlo))

    with output.with_suffix(".graph.svg").open("w") as f:
        subprocess.run(["dot", "-Tsvg", graph_file], stdout=f)
```

Using the two above helper functions we can take a jit-compiled (and lowered) function and let XLA generate a [Graphviz](https://graphviz.org/) 
graph for all operations. The call to `dot -Tsvg input.dot` requires `graphviz` to be installed.

```python
def simple_function(x):
    return jax.numpy.sin(x[:3])

simple_function = jax.jit(simple_function)

input = jax.numpy.zeros((20,))

write_debug_graph(
    simple_function.lower(input).compile(), 
    Path("simple_function")
)
```

{{<image src="simple_function.graph.svg" title="The output graph" >}}

If you open [the generated SVG image](simple_function.graph.svg) in a web browser, you can also read additional metadata by hovering over nodes.

## Visualizing the HLO Graph without code modifications

- Documentation? This feature doesn't seem to be documented anywhere

There is an alternative way to achieve the same result as the previous section (compute graph as a figure), but without any code modifications and for all intermediate functions (before and after optimization).

For this we call our python script with the [`--xla_dump_to=tmp`](/all-xla-options/#xla_dump_to) flag to dump all intermediate XLA results into tmp/ and 
[`--xla_dump_hlo_as_html=true`](/all-xla-options/#xla_dump_hlo_as_html) to also generate HTML output.

```python
import jax

def simple_function(x):
    return jax.numpy.sin(x[:3])

simple_function = jax.jit(simple_function)
input = jax.numpy.zeros((20,))

simple_function(input)
```
```bash
➜ XLA_FLAGS="--xla_dump_hlo_as_html=true --xla_dump_to=tmp" python dot_test2.py
```

The [resulting output](/jax-tips-and-tricks-html) in tmp/ when opened in a browser will be similar to the one created in the previous section,
but with interactive zoom and pan.

## Additional XLA options

- [Documentation](https://docs.jax.dev/en/latest/xla_flags.html) (only a small subset)

Only a small subset of the possible XLA options are documented in the JAX documentation. [The full list](/all-xla-options/) can be extracted from the XLA `--help` command.

## print_environment_info

- [Documentation](https://docs.jax.dev/en/latest/_autosummary/jax.print_environment_info.html)

A very straightforward way to print some key information about the current setup.

```python
import jax
jax.print_environment_info()
```

```text
jax:    0.5.3
jaxlib: 0.5.3
numpy:  2.2.4
python: 3.13.2 (main, Mar 29 2025, 10:04:43) [GCC 14.2.0]
device info: cpu-1, 1 local devices"
process_count: 1
platform: uname_result(system='Linux', node='lukasnotebook', release='6.12.21-amd64', version='#1 SMPPREEMPT_DYNAMIC Debian 6.12.21-1 (2025-03-30)', machine='x86_64')
```
