'use strict';
var lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;
var mountFolder = function (connect, dir) {
    return connect.static(require('path').resolve(dir));
};

module.exports = function (grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  // configurable paths
  var config = {
      src: 'src',
      dist: 'dist',
      dev: '.dev'
  };

  grunt.initConfig({
    config: config,
    watch: {
      coffee: {
        files: ['<%= config.src %>/{,*/}*.coffee'],
        tasks: ['coffee:dist', 'copy']
      },
      coffeeTest: {
        files: ['test/spec/{,*/}*.coffee'],
        tasks: ['coffee:test']
      },
      compass: {
        files: ['<%= config.src %>/{,*/}*.{scss,sass}'],
        tasks: ['compass', 'copy']
      },
      statics: {
        files: ['<%= config.src %>/*.html', '{.tmp,<%= config.src %>}/{,*/}*.css', '{.tmp,<%= config.src %>}/{,*/}*.js', '{.tmp,<%= config.src %>}/vendor/{,*/}*.js'],
        tasks: ['copy']
      },
      livereload: {
        files: [
            '<%= config.src %>/*.html',
            '{.tmp,<%= config.src %>}/{,*/}*.css',
            '{.tmp,<%= config.src %>}/{,*/}*.js',
            '<%= config.src %>/images/{,*/}*.{png,jpg,jpeg,webp}'
        ],
        tasks: ['livereload']
      }
    },
    connect: {
      options: {
        port: 3000,
        // change this to '0.0.0.0' to access the server from outside
        hostname: '0.0.0.0'
      },
      livereload: {
        options: {
          middleware: function (connect) {
            return [
                lrSnippet,
                mountFolder(connect, '.tmp'),
                mountFolder(connect, 'src')
            ];
          }
        }
      },
      test: {
        options: {
          middleware: function (connect) {
            return [
                mountFolder(connect, '.tmp'),
                mountFolder(connect, 'test')
            ];
          }
        }
      },
      dist: {
        options: {
          middleware: function (connect) {
            return [
                mountFolder(connect, 'dist')
            ];
          }
        }
      }
    },
    open: {
        server: {
            path: 'http://localhost:<%= connect.options.port %>'
        }
    },
    clean: {
        dist: ['.tmp', '<%= config.dist %>/*'],
        server: '.tmp',
        dev: '.dev'
    },
    jshint: {
      options: {
          jshintrc: '.jshintrc'
      },
      all: [
          'Gruntfile.js',
          '<%= config.src %>//{,*/}*.js',
          '!vendor/*',
          'test/spec/{,*/}*.js'
      ]
    },
    mocha: {
      all: {
        options: {
            run: true,
            urls: ['http://localhost:<%= connect.options.port %>/index.html']
        }
      }
    },
    coffee: {
      dist: {
        files: [{
          // rather than compiling multiple files here you should
          // require them into your main .coffee file
          expand: true,
          cwd: '<%= config.src %>',
          src: '*.coffee',
          dest: '.tmp',
          ext: '.js'
        }]
      },
      test: {
        files: [{
          expand: true,
          cwd: '.tmp/spec',
          src: '*.coffee',
          dest: 'test/spec'
        }]
      }
    },
    compass: {
      options: {
        sassDir: '<%= config.src %>',
        cssDir: '.tmp/styles',
        imagesDir: '<%= config.src %>/images',
        javascriptsDir: '<%= config.src %>',
        fontsDir: '<%= config.src %>/styles/fonts',
        // importPath: '<%= config.src %>/components',
        relativeAssets: true
      },
      dist: {},
      server: {
        options: {
            debugInfo: true
        }
      }
    },
    uglify: {
      dist: {
        files: {
          '<%= config.dist %>/main.js': [
              '<%= config.src %>/{,*/}*.js',
              '.tmp/{,*/}*.js'
          ],
        }
      }
    },
    useminPrepare: {
      html: '<%= config.src %>/index.html',
      options: {
        dest: '<%= config.dist %>'
      }
    },
    usemin: {
      html: ['<%= config.dist %>/{,*/}*.html'],
      css: ['<%= config.dist %>/{,*/}*.css'],
      options: {
          dirs: ['<%= config.dist %>']
      }
    },
    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= config.src %>/images',
          src: '{,*/}*.{png,jpg,jpeg}',
          dest: '<%= config.dist %>/images'
        }]
      }
    },
    cssmin: {
      dist: {
        files: {
          '<%= config.dist %>/main.css': [
            // '<%= config.src %>/styles/{,*/}*.css',
            '.tmp/styles/{,*/}*.css'
          ]
        }
      }
    },
    htmlmin: {
      dist: {
        options: {
          removeCommentsFromCDATA: true,
          // https://github.com/yeoman/grunt-usemin/issues/44
          //collapseWhitespace: true,
          collapseBooleanAttributes: true,
          // removeAttributeQuotes: true,
          removeRedundantAttributes: true,
          useShortDoctype: true,
          removeEmptyAttributes: true,
          // removeOptionalTags: true
        },
        files: [{
          expand: true,
          cwd: '<%= config.src %>',
          src: '*.html',
          dest: '<%= config.dist %>'
        }]
      }
    },
    copy: {
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= config.src %>',
          dest: '<%= config.dist %>',
          src: [
            '*.{ico,txt,pdf}',
            '.htaccess'
          ]
        },
        {
          expand: true,
          dot: true,
          cwd: 'vendor',
          dest: '<%= config.dist %>/vendor',
          src: [
            '*.js'
          ]
        }]
      },
      dev: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= config.src %>',
          dest: '<%= config.dev %>',
          src: ['*.html']
        }, {
          expand: true,
          dot: true,
          cwd: 'vendor',
          dest: '<%= config.dev %>/vendor',
          src: ['*.js']
        }, {
          expand: true,
          dot: true,
          cwd: '<%= config.src %>',
          dest: '<%= config.dev %>',
          src: ['*.js']
        }, {
          expand: true,
          dot: true,
          cwd: '.tmp',
          dest: '<%= config.dev %>',
          src: ['*.js']
        }, {
          expand: true,
          dot: true,
          cwd: '.tmp',
          dest: '<%= config.dev %>',
          src: ['*.css']
        }, {
          expand: true,
          dot: true,
          cwd: '<%= config.src %>',
          dest: '<%= config.dev %>',
          src: ['*.css']
        }]
      }
    },
    rev: {
      files: {
        src: ['<%= config.dist %>/{,*/}/*.js', '<%= config.dist %>/*.css']
      }
    }
  });

  grunt.renameTask('regarde', 'watch');

  grunt.registerTask('server', function (target) {
    if (target === 'dist') {
      return grunt.task.run(['build', 'open', 'connect:dist:keepalive']);
    }

    grunt.task.run([
      'clean:server',
      'coffee:dist',
      'compass:server',
      'livereload-start',
      'connect:livereload',
      // 'open',
      'watch'
    ]);
  });

  grunt.registerTask('test', [
    'clean:server',
    'coffee',
    'compass',
    'connect:test',
    'mocha'
  ]);

  grunt.registerTask('build', [
    'clean:dist',
    'coffee',
    'compass:dist',
    'useminPrepare',
    'imagemin',
    'htmlmin',
    'cssmin',
    'uglify',
    'copy',
    'rev',
    'usemin',
  ]);

  grunt.registerTask('dev', [
    'clean:dev',
    'coffee',
    'compass:dist',
    'copy',
    // 'livereload-start',
    'watch'
  ]);

  grunt.registerTask('default', [
    // 'jshint',
    // 'test',
    'dev'
  ]);
};
