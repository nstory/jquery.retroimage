module.exports = (grunt) ->
  grunt.initConfig
    clean:
      build: ['build']

    coffee:
      src:
        files: [
          expand: true
          ext: '.js'
          extDot: 'last'
          src: 'src/*.coffee'
          dest: 'build/'
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
          'specs/jquery-1.11.1.js'
          'build/src/*.js'
        ]
        options:
          specs: ['build/specs/*.spec.js']

    watch:
      options: {
        atBegin: true
      }
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
