exports.config =
  server:
    path: './server.coffee'
    port: 3333
    run: yes
    
  plugins:
    static_jade:
      extension: ".static.jade"
    jade:
      options:
        pretty: yes # Adds pretty-indentation whitespaces to output (false by default)
  files:
    javascripts:
      joinTo:
        'javascripts/remote.js': /remote/
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^(?!app)/
      order:
        before: [
          'vendor/jquery-1.9.1.js',
          'vendor/underscore-1.4.4.js',
          'vendor/auto-reload-brunch.js',
        ]
        after: [
          'vendor/bootstrap-tagsinput.js'
        ]

    stylesheets:
      joinTo: 'stylesheets/app.css'

    templates:
      joinTo: 'javascripts/app.js'