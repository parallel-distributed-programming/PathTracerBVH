# PathTracerBVH Contribution Guidelines

Team discussion draft. Use commit `88c317a` as the serial reference for correctness checks.

## Code Style

- Use C++17 and follow the existing style. Indent with two spaces. Use `PascalCase` for types and `snake_case` for functions and variables. Keep implementation files in `src/` and headers in `src/include/`.
- Keep the serial renderer runnable. `render()` returns a row-major linear RGB image, starting with the top row, and reports the total number of rays through `rays`. Update callers and documentation when changing public interfaces, command-line options, or output formats.
- In the CPU renderer, share the scene as read-only and assign each pixel to one thread. Seed from `(pixel, sample)`, preserve the sample accumulation order within each pixel, and combine thread-local ray counts after rendering.
- Keep project-wide formatting changes in a separate commit. Use `.gitignore` for build products and temporary render output.
- Place `.cu` files in `src/` and CUDA-specific `.cuh` headers in `src/include/`. Use a separate CUDA build target so the default `make` works with a C++17 compiler alone.
- Bounds-check thread indices before accessing buffers. Assign one writer per output pixel or explicitly coordinate shared writes.
- Give device buffers a clear owner and release them on both success and failure paths. Check CUDA runtime calls, check launch errors immediately after launching a kernel, and check execution errors at the synchronization point before using the results. [CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/intro-to-cuda-cpp.html)

## Git Workflow

1. **Pull before editing, every time you start or resume work.** For a new task, run `git switch main` and `git pull --ff-only`, then create your task branch. For a published task branch, switch to it and run `git pull --ff-only`. For an unpublished branch, pull `main` and rebase your local branch onto it before editing.
2. Open a GitHub issue with the goal, scope, dependencies, and acceptance criteria. Use a descriptive branch name, such as `feat/openmp-render` or `perf/bvh-layout`, and keep each pull request focused on one change.
3. Link the issue in the pull request. Summarize the change and include the commands you ran and their results.
4. Merge through a pull request once at least one teammate has approved it and the build and smoke test pass.

## Correctness Checks

From the repository root, build and run the furnace test.

```sh
make -j4
./pt -S 2 -D 3 -w 32 -h 32 -s 16 -o check-furnace.ppm
```

The test should report `max |pixel - 1| = 0.000e+00`. For changes that parallelize rendering without altering its behavior, compare the image checksum and ray count against the serial reference using the same compiler, flags, and scene settings.
