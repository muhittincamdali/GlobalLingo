// Time growth instead of wall-clock time: a crafted input 16 times larger should take about 16
// times as long on any machine, while a pattern that backtracks takes 256 times as long or more.
// The ratio stays meaningful on a slow or busy CI runner, where a fixed number of milliseconds
// does not.

export const GROWTH_FACTOR = 16;
/**
 * Linear work grows 16 times, and up to about 40 times once the collector has 2 MB strings to
 * move; quadratic work grows 256 times. The limit sits between the two with room on both sides.
 */
export const MAX_GROWTH = 100;
/**
 * The smaller input, 128 KB by default, so the larger one is 2 MB. GROWTH_BASE_KB=8 runs the same
 * cases on small inputs, to watch a slow pattern fail in seconds instead of minutes.
 */
export const BASE_SIZE = Number(process.env.GROWTH_BASE_KB ?? 128) * 1024;
/** Runs under a millisecond are timer noise; they count as one. */
const FLOOR_MS = 1;

function fastest(work: () => unknown, runs: number): number {
  let best = Number.POSITIVE_INFINITY;
  for (let run = 0; run < runs; run += 1) {
    const start = performance.now();
    try {
      work();
    } catch {
      // A reader may reject a crafted file; how long it took to say so is what counts.
    }
    best = Math.min(best, performance.now() - start);
  }
  return best;
}

/** How many times longer the work on an input of `size * 16` characters takes than on `size`. */
export function growth(make: (size: number) => () => unknown, size = BASE_SIZE): number {
  const small = make(size);
  const large = make(size * GROWTH_FACTOR);
  fastest(small, 1);
  return fastest(large, 3) / Math.max(fastest(small, 5), FLOOR_MS);
}

/** `unit` repeated to about `size` characters. */
export const fill = (unit: string, size: number) =>
  unit.repeat(Math.max(1, Math.floor(size / unit.length)));
