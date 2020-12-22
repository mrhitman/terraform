const { resolve, join, basename } = require('path');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const FileManagerPlugin = require('filemanager-webpack-plugin');
const { readdirSync, lstatSync } = require('fs');

const isDirectory = source => lstatSync(source).isDirectory()
const getDirectories = source =>
    readdirSync(source).map(name => join(source, name)).filter(isDirectory)

const directories = getDirectories(resolve(__dirname, 'src', 'lambdas'))
const config = {
    mode: 'production',
    target: 'node',
    entry: directories.reduce((acc, lambdaPath) => ({ ...acc, [basename(lambdaPath)]: lambdaPath }), {}),
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
        new FileManagerPlugin({
            events: {
                onEnd: {
                    archive:
                        getDirectories(
                            resolve(__dirname, 'dist', 'lambdas')).map(lambdaDistPath => ({
                                source: lambdaDistPath, destination: resolve(lambdaDistPath, '..', basename(lambdaDistPath) + '.zip')
                            }))
                }
            }
        })
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