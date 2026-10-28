import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

// Runs once before the test files: the end-to-end tests execute dist/cli/main.js, and the
// shared CI workflow runs `test` before `build`.
export default function setup(): void {
  const root = fileURLToPath(new URL('../../', import.meta.url));
  const tsc = fileURLToPath(new URL('../../node_modules/typescript/bin/tsc', import.meta.url));
  execFileSync(process.execPath, [tsc, '-p', 'tsconfig.build.json'], {
    cwd: root,
    stdio: 'inherit',
  });
}
