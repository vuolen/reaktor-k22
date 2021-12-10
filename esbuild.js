const path = require("path");

// Feel free to edit these options. I put in some sensible defaults for my use cases.

const common_options = {
	entryPoints: ['src/index.js'],
	bundle: true,
	outfile: 'out.js',
    external: ["url"]
}

const dev_options = {
	...common_options,
	watch: {
		onRebuild(error, result) {
			if (error) console.error('Esbuild failed:', error)
			else console.log('Esbuild succeeded:', result)
		}
	},
	sourcemap: "inline"
}

const prod_options = {
	...common_options,
	minify: true
}

require('esbuild').build(
	process.env.DEV ? dev_options : prod_options
).catch(() => process.exit(1))