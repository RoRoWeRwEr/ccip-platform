import { readdir, stat } from "node:fs/promises";
import { join, relative } from "node:path";

const staticRoot = join(process.cwd(), ".next", "static");
const limits = {
  totalBytes: 1_750_000,
  javascriptBytes: 650_000,
  stylesheetBytes: 100_000,
};

async function filesUnder(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  return (
    await Promise.all(
      entries.map(async (entry) => {
        const path = join(directory, entry.name);
        return entry.isDirectory() ? filesUnder(path) : [path];
      }),
    )
  ).flat();
}

const files = await filesUnder(staticRoot);
const measured = await Promise.all(
  files.map(async (path) => ({ path, bytes: (await stat(path)).size })),
);
const totalBytes = measured.reduce((total, file) => total + file.bytes, 0);
const largestJavaScript = measured
  .filter((file) => file.path.endsWith(".js"))
  .sort((left, right) => right.bytes - left.bytes)[0];
const largestStylesheet = measured
  .filter((file) => file.path.endsWith(".css"))
  .sort((left, right) => right.bytes - left.bytes)[0];

const failures = [];
if (totalBytes > limits.totalBytes)
  failures.push(`total static bytes ${totalBytes} > ${limits.totalBytes}`);
if ((largestJavaScript?.bytes ?? 0) > limits.javascriptBytes)
  failures.push(
    `largest JavaScript ${largestJavaScript.bytes} > ${limits.javascriptBytes}`,
  );
if ((largestStylesheet?.bytes ?? 0) > limits.stylesheetBytes)
  failures.push(
    `largest stylesheet ${largestStylesheet.bytes} > ${limits.stylesheetBytes}`,
  );

console.log(
  JSON.stringify(
    {
      totalBytes,
      largestJavaScript: largestJavaScript
        ? {
            path: relative(process.cwd(), largestJavaScript.path),
            bytes: largestJavaScript.bytes,
          }
        : null,
      largestStylesheet: largestStylesheet
        ? {
            path: relative(process.cwd(), largestStylesheet.path),
            bytes: largestStylesheet.bytes,
          }
        : null,
      limits,
    },
    null,
    2,
  ),
);

if (failures.length > 0) {
  throw new Error(`Bundle budget exceeded: ${failures.join("; ")}`);
}
