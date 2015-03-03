#LiveScript gulp file
require! <[
  browserify
  envify
  gulp
  gulp-less
  gulp-util
  liveify
  uglifyify
  vinyl-source-stream
  watchify
  path
]>

is-dev = process.env.NODE_ENV isnt "production"

gulp.task 'styles' ->
  gulp.src 'assets/styles/index.less'
  .pipe gulp-less!
  .on 'error' gulp-util.log
  .pipe gulp.dest 'public/styles/'

gulp.task 'copy-scripts' ->
  gulp.src 'assets/scripts/**/*.js'
  .pipe gulp.dest 'public/scripts'

get-bundler = (instance) ->
  bundler = instance do
    cache: {}
    debug: is-dev
    full-paths: yes
    package-cache: {}
  bundler.transform liveify
  unless is-dev
    bundler.transform envify
    bundler.transform global: true, uglifyify
  bundler.add do
    path.resolve 'components/index.ls'
    entry: yes

build-config =
  debug: is-dev

update = (bundler) ->
  gulp-util.log 'Bundling'
  bundler.bundle!
  .on 'error' gulp-util.log
  .on 'end' -> gulp-util.log 'Bundle complete'
  .pipe vinyl-source-stream 'index.js'
  .pipe gulp.dest 'public/scripts/'

gulp.task 'browserify' -> browserify |> get-bundler |> update

gulp.task 'watch' ->
  gulp.watch 'assets/styles/index.less' ['styles']
  watch = browserify |> get-bundler |> watchify
  watch.on 'update' -> update watch
  update watch

gulp.task 'default' ['copy-scripts' 'styles' 'browserify']
gulp.task 'dev' ['copy-scripts' 'styles' 'watch']
