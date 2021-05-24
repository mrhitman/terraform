const { resolve, join, basename } = require('path');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const { readdirSync, lstatSync, mkdirSync, existsSync } = require('fs');

const isDirectory = source => lstatSync(source).isDirectory()
const getDirectories = source =>
    readdirSync(source).map(name => join(source, name)).filter(isDirectory)

const path = resolve(__dirname, 'dist', 'lambdas');
if (!existsSync(path)) {
    mkdirSync(path, { recursive: true });
}

const directories = getDirectories(resolve(__dirname, 'src', 'lambdas'))
const config = {
    mode: 'production',
    target: 'node',
    entry: directories.reduce((acc, lambdaPath) => ({ ...acc, [basename(lambdaPath)]: lambdaPath }), {}),
    optimization: {
        minimize: true
    },
    module: {
        rules: [
            {
                test: /\.ts$/,
                loader: 'ts-loader'
            },
        ]
    },
    plugins: [
        new CleanWebpackPlugin(),
    ],
    resolve: {
        extensions: ['.ts', '.js']
    },
    output: {
        path: resolve(__dirname, 'dist'),
        libraryTarget: 'commonjs',
        filename: 'lambdas/[name]/index.js'
    }
};

module.exports = config;