// Karma configuration
// Generated on Fri Dec 05 2014 10:40:20 GMT+0100 (CET)

module.exports = function(config) {
	config.set({

		// base path that will be used to resolve all patterns (eg. files, exclude)
		basePath: '',


		// frameworks to use
		// available frameworks: https://npmjs.org/browse/keyword/karma-adapter
		frameworks: ['mocha', 'sinon-chai'],


		// list of files / patterns to load in the browser
		files: [
			'lib/**/*.js',
			// 'www/lib/lodash-241.underscore-152.js',
			// 'www/js/services/index.js',
			// 'www/js/services/rating-services.js',
			// 'www/js/services/social-services.js',
			// 'www/js/services/sqlite.bookmarks-service.js',
			// 'www/js/services/sqlite.notes-service.js',
			'test/js/**/*.js'
		],


		// list of files to exclude
		exclude: [
			// 'www/lib/ionic1b9/**/*.js',
			// 'test/lib/angular-scenario.js'
		],


		// preprocess matching files before serving them to the browser
		// available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
		preprocessors: {
		},


		// test results reporter to use
		// default possible values: 'dots', 'progress'
		// available reporters: https://npmjs.org/browse/keyword/karma-reporter
		reporters: ['mocha'],


		// web server port
		port: 9876,


		// enable / disable colors in the output (reporters and logs)
		colors: true,


		// level of logging
		// possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
		logLevel: config.LOG_INFO,


		// enable / disable watching file and executing tests whenever any file changes
		autoWatch: false,


		// start these browsers
		// available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
		browsers: ['Chrome'],


		// Continuous Integration mode
		// if true, Karma captures browsers, runs the tests and exits
		singleRun: false
	});
};
