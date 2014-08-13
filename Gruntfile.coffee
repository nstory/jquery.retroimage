module.exports = (grunt) ->
  grunt.initConfig
    clean:
      build: ['build']

    coffee:
      src:
        files: [
          expand: true
          flatten: true
          ext: '.js'
          extDot: 'last'
          src: 'src/*.coffee'
          dest: 'lib/'
        ]
      specs:
        files: [
          expand: true
          ext: '.js'
          extDot: 'last'
          src: 'specs/*.coffee'
          dest: 'build/'
        ]

    jasmine:
      test:
        src: [
          'bower_components/jquery/dist/jquery.js'
          'lib/*.js'
        ]
        options:
          specs: ['build/specs/*.spec.js']

    watch:
      options:
        atBegin: true
      test:
        files: ['Gruntfile.coffee', 'src/*', 'specs/*']
        tasks: ['test']

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'build', ['clean', 'coffee:src']
  grunt.registerTask 'test', ['build', 'coffee:specs', 'jasmine']
  grunt.registerTask 'default', 'build'
