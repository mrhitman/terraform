const { resolve } = require('path');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const FileManagerPlugin = require('filemanager-webpack-plugin');

const config = {
    mode: 'production',
    target: 'node',
    entry: {
        lambda1: resolve(__dirname, 'src', 'lambdas', 'lambda1'),
        lambda2: resolve(__dirname, 'src', 'lambdas', 'lambda2'),
    },
    module: {
        rules: [
            {
                test: /\.ts$/,
                loader: 'ts-loader'
            },
        ]
    },
    optimization: {
        minimize: true,
        providedExports: false,
        concatenateModules: false,
        usedExports: true
    },
    plugins: [
        new CleanWebpackPlugin(),
        new FileManagerPlugin({
            events: {
                onEnd: {
                    archive: [
                        { source: 'dist/lambdas/lambda1', destination: 'dist/lambdas/lambda1.zip' },
                        { source: 'dist/lambdas/lambda2', destination: 'dist/lambdas/lambda2.zip' },
                    ]
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