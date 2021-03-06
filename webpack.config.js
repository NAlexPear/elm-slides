const path = require('path');
const merge = require('webpack-merge');
const webpack = require('webpack');
const HTMLWebpackPlugin = require('html-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin')
const ExtractTextPlugin = require('extract-text-webpack-plugin');

const TARGET_ENV = process.env.npm_lifecycle_event === 'prod' ? 'production' : 'development';
const script = (TARGET_ENV == 'production') ? '[name]-[hash].js' : 'index.js';
const style = (TARGET_ENV == 'production') ? '[name]-[hash].css' : 'style.css';

const common = {
    entry: './index.js',
    plugins: [
        new HTMLWebpackPlugin({
            // using .ejs prevents other loaders causing errors
            template: 'index.ejs',
            // inject details of output file at end of body
            inject: 'body'
        }),
        new ExtractTextPlugin({
          filename: style,
          allChunks: true
        }),
    ],
    resolve: {
        modules: ["node_modules"],
        extensions: ['.js', '.elm', '.scss', '.css', '.png']
    },
    module: {
        rules: [
            {
                test: /\.html$/,
                exclude: /node_modules/,
                loader: 'file-loader?name=[name].[ext]'
            }, {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: ['env']
                    }
                }
            }, {
                test: /\.scss$/,
                exclude: [
                    /elm-stuff/, /node_modules/
                ],
                loaders: ["style-loader", "css-loader", "sass-loader"]
            },
            {
              test: /\.css$/,
              use: ExtractTextPlugin.extract({
                fallback: "style-loader",
                use: "css-loader"
              })
            },
             {
                test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                exclude: [
                    /elm-stuff/, /node_modules/
                ],
                loader: "url-loader",
                options: {
                    limit: 10000,
                    mimetype: "application/font-woff"
                }
            }, {
                test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                exclude: [
                    /elm-stuff/, /node_modules/
                ],
                loader: "file-loader"
            }, {
                test: /\.(jpe?g|png|gif|svg)$/i,
                loader: 'file-loader'
            }
        ]
    }
}

if (TARGET_ENV === 'development') {
    console.log('Building for dev...');
    module.exports = merge(common, {
        output: {
            path: path.join(__dirname, "dist"),
            publicPath: "/",
            filename: script
        },
        plugins: [
            new webpack.NamedModulesPlugin(),
            new webpack.NoEmitOnErrorsPlugin()
        ],
        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [
                        /elm-stuff/, /node_modules/
                    ],
                    use: [
                        {
                            loader: "elm-hot-loader"
                        },
                        {
                            loader: "elm-webpack-loader",
                            // add Elm's debug overlay to output
                            options: {
                                debug: true
                            }
                        }
                    ]
                }
            ]
        },
        devServer: {
            inline: true,
            stats: 'errors-only',
            historyApiFallback: true,
            public: '0.0.0.0:9000'
        },
        watchOptions: {
            poll: true,
        }
    });
}

if (TARGET_ENV === 'production') {
    module.exports = merge(common, {
        output: {
            path: path.join(__dirname, "dist"),
            filename: script
        },
        plugins: [
            // Delete everything from output directory and report to user
            new CleanWebpackPlugin(['dist'], {
              root:     __dirname,
              exclude:  [],
              verbose:  true,
              dry:      false
            }),
            new webpack.optimize.UglifyJsPlugin(),
        ],
        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [
                        /elm-stuff/, /node_modules/
                    ],
                    use: [
                        {
                            loader: "elm-webpack-loader"
                        }
                    ]
                }
            ]
        }
    });
}
