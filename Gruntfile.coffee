module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'lib/command.js': ['src/command.litcoffee']
          'lib/ssdp.js': ['src/ssdp.litcoffee']
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.registerTask 'default', ['coffee']
