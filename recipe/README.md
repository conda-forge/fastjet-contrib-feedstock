# FastJet Contrib packaging on conda-forge

This feedstock builds fjcontrib in two library layouts, and splits each layout into a runtime
package and a development package:

| | merged library | one library per contrib |
|---|---|---|
| runtime | **`fastjet-contrib`** | **`fastjet-contrib-split`** |
| development | **`fastjet-contrib-devel`** | **`fastjet-contrib-split-devel`** |

- **`fastjet-contrib`** – a single shared library, `libfastjetcontribfragile`
  (`fastjetcontribfragile.dll` on Windows), that holds every contrib.
- **`fastjet-contrib-split`** – one shared library per contrib (`libNsubjettiness`,
  `libRecursiveTools`, `libConstituentSubtractor`, …).
- **`fastjet-contrib-devel`** / **`fastjet-contrib-split-devel`** – the headers under
  `include/fastjet/contrib/`, the CMake package configuration (`find_package(fastjetcontrib)`), and
  the import libraries on Windows, for the matching layout. They depend on the exactly matching
  runtime build and on `fastjet-cxx-devel`, because `fastjetcontribConfig.cmake` calls
  `find_package(fastjet REQUIRED)`.
  - The merged layout exports the CMake target `fastjet::contrib::fastjetcontribfragile`.
  - The split layout exports one target per contrib (`fastjet::contrib::Nsubjettiness`, …).

The runtime packages carry no headers or CMake files. Every output carries `run_exports` (`x`) on its
layout's runtime package, so anything built against a `-devel` output gets the matching runtime
package as a run dependency automatically.

## Choosing a layout

Use the merged layout (`fastjet-contrib`, `-lfastjetcontribfragile`) unless your build system
expects fjcontrib's per-contrib libraries (`-lNsubjettiness -lRecursiveTools …`). Both `-devel`
outputs install the same header and CMake paths, so an environment holds one layout, not both.

## How recipes use these packages

### A. The recipe compiles or links against fjcontrib

Put the layout's `-devel` output in `host`. The runtime dependency comes from its `run_exports`.
`fastjet-cxx-devel` comes with it, so FastJet's headers and CMake configuration are there too.

```yaml
# recipe.yaml (excerpt)
requirements:
  host:
    - fastjet-contrib-devel        # or fastjet-contrib-split-devel
```

### B. The package compiles code against fjcontrib at run time, or its installed headers include fjcontrib headers

Some packages compile user code when they run, for example an analysis framework that builds
plugins against its own headers. If those builds or headers need fjcontrib, also put the layout's
`-devel` output in `run`. The same applies to the `run` requirements of your own `*-devel` output if
its installed headers or CMake configuration reference fjcontrib.

```yaml
# recipe.yaml (excerpt)
requirements:
  host:
    - fastjet-contrib-devel
  run:
    - fastjet-contrib-devel
```

### C. The package only runs software that was built against fjcontrib

Nothing to do: the `run_exports` above already pull in the runtime package.

### D. Interactive development

To compile your own code against fjcontrib in an environment, install the `-devel` output of the
layout you link against (plus a compiler, e.g. `cxx-compiler`).

## Further details

- Before the split (`fastjet-contrib` and `fastjet-contrib-split` 1.104 build 2 and earlier), each
  runtime package also held the headers and the CMake files. From build 3 on, those are only in the
  `-devel` outputs. A recipe that kept `fastjet-contrib` or `fastjet-contrib-split` in `host` now
  fails to find fjcontrib's headers: switch it to the matching `-devel` output (case A).
- FastJet itself is split the same way: `fastjet-cxx` (runtime) and `fastjet-cxx-devel`. See
  conda-forge/fastjet-cxx-feedstock#27 and its `recipe/README.md`.
- See conda-forge/fastjet-contrib-feedstock#25 for this split.
