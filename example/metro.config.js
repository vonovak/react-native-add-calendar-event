const path = require("path");

const exclusionList = (() => {
  try {
    return require("metro-config/src/defaults/exclusionList");
  } catch (_) {
    // `blacklist` was renamed to `exclusionList` in 0.60
    return require("metro-config/src/defaults/blacklist");
  }
})();

const blockList = exclusionList([
  /node_modules\/.*\/node_modules\/react-native\/.*/,

  // This stops "react-native run-windows" from causing the metro server to
  // crash if its already running
  new RegExp(`${path.join(__dirname, "windows").replace(/[/\\]+/g, "/")}.*`),

  // Workaround for `EPERM: operation not permitted, lstat '~\midl-MIDLRT-cl.read.1.tlog'`
  /.*\.tlog/,

  // Prevent Metro from watching temporary files generated by Visual Studio
  // otherwise it may crash when they are removed when closing a project.
  /.*\/.vs\/.*/,

  // Workaround for `EBUSY: resource busy or locked, open '~\msbuild.ProjectImports.zip'`
  /.*\.ProjectImports\.zip/,
]);

const config = {
  resolver: {
    blacklistRE: blockList,
    blockList,
  },
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: false,
      },
    }),
  },
};

try {
  // Starting with react-native 0.72, we are required to provide a full config.
  const {
    getDefaultConfig,
    mergeConfig,
  } = require("@react-native/metro-config");
  module.exports = mergeConfig(getDefaultConfig(__dirname), config);
} catch (_) {
  module.exports = config;
}
