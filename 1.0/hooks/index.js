coffeescript = require('coffee-script');
hooks = require('./hooks');

exports.cliVersion = '>=3.X';

exports.init = function (logger, config, cli, appc) {
    cli.addHook('build.pre.compile', function (build, finished) {
        hooks.build_pre_compile(logger, config, cli, build, finished);
     });

	cli.addHook('clean.post', function (build, finished) {
		hooks.clean_post(logger, config, cli, build, finished);
	});
};

