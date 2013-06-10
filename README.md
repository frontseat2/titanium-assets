# CoffeeScript and LESS compiler for Titanium projects

A system to enable compiled sources easily with your Titanium projects.

Features:

* Incremental builds. It only compiles files that are new or have changed
* Does not package CoffeeScript or LESS source files with your Titanium binary
* No extra build steps to forget

## How it works
The system treats your project's Resources directory as a build target for compiled sources such as your .coffee files. The plugin hooks into Titanium's build system to compile only newly updated files without any extra steps.

## Setup
1. Rename your `Resources` directory to `Resources-static`
2. Add your CoffeeScript and LESS files into a new directory called `Resources-compile`
3. Create a directory called `plugins` and recursively copy the `1.0` directory into it
4. To `tiapp.xml` add a plugins section if you don't already have one and register the `titanium-assets` plugin:

    &lt;plugins&gt;
    <span style='margin-left:2em'>&lt;plugin&gt;titanium-assets&lt;/plugin&gt;</span>
    &lt;/plugins&gt;

5. Recommended: Add your `Resources` directory to your .gitignore file (like you do with your build files)

The end result is a directory structure that looks roughly like:

    Project Dir
       |- Resources-static (*.js, images, etc)
       |- Resources-compile (*.coffee, *.less)
       |- plugins
          |- titanium-assets
             |- 1.0
                |- hooks

## Using it
Once you have your files in place, run a Titanium build as you normally would. Before the Titanium build takes place, the plugin will:

* Ensure you have a `Resources` directory
* Recursively copy all the files in `Resources-static` into `Resources` (maintaining directory structure)
* Recursively compile all the CoffeeScript and LESS files in `Resources-compile` into `Resources` (maintaining directory structure)

*Note: When you run a Titanium clean, the `Resources` directory will be completely removed.*

## Caveats
Things to keep in mind for this early version

* I've only tested in via command line builds
* I've only tested it on a Mac
* I've only tested it on my own projects

## License
Copyright 2013 Front Seat, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Disclaimers
This is a tool created for our own internal use. It is **not supported** by Appcelerator. If you have questions, issues, etc. then please file them in the GitHub Issues section of the repository. Even better, fork the project and make it better :)

## Sponsorship
This project brought to you by [Front Seat](http://frontseat.org)
<div style='position:relative;top:5px;left:10px'>
<img src="http://frontseat.org/images/front-seat-logo.gif">
</div>
<div>
<img src="http://frontseat.org/images/front-seat-banner.gif">
</div>
