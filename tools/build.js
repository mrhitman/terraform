const {lstatSync, readdirSync} = require("fs");
const {join, resolve, basename} = require("path");
const zipFolder = require("zip-folder");
const {build} = require("esbuild");
const glob = require("glob");

const getDirectories = (source) =>
  readdirSync(source)
    .map((name) => join(source, name))
    .filter((name) => lstatSync(name).isDirectory());

const path = resolve(__dirname, "..", "dist", "lambdas");
const entryPoints = glob.sync("./src/**/*.ts", {
  ignore: "./src/common/**/*.ts",
});

build({
  entryPoints,
  outbase: "./src",
  outdir: "./dist",
  platform: "node",
  target: "node14",
  minify: true,
  minifySyntax: true,
  sourcemap: "external",
  bundle: true,
  external: ["aws-sdk"],
  watch: false,
}).then(() => {
  const directories = getDirectories(resolve(path)).map((lambdaDistPath) => {
    return {
      source: lambdaDistPath,
      destination: resolve(
        lambdaDistPath,
        "..",
        basename(lambdaDistPath) + ".zip"
      ),
    };
  });
  for (const directory of directories) {
    zipFolder(directory.source, directory.destination, () =>
      console.log(`${directory.destination} zipped`)
    );
  }
});
